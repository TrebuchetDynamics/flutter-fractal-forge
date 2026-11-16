"""Hermetic checks for scripts/release-play.sh: ordering, refusals, evidence."""

import hashlib
import json
import os
from pathlib import Path
import subprocess

import pytest

ROOT = Path(__file__).resolve().parents[2]
NL = "\n"


def stub(path, body):
    path.write_text("#!/usr/bin/env bash\nset -euo pipefail\n" + body)
    path.chmod(0o755)


def make_project(tmp_path, *, build_number=121, version="1.1.121", gate_exit=0):
    """A throwaway checkout with stub lane scripts and a real git history."""
    project = tmp_path / "project"
    (project / "scripts/ci").mkdir(parents=True)
    (project / "fdroid").mkdir()
    (project / "android").mkdir()
    (project / "play-console-upload").mkdir()

    for name in ("release-play.sh",):
        (project / "scripts" / name).write_bytes((ROOT / "scripts" / name).read_bytes())
        (project / "scripts" / name).chmod(0o755)

    (project / "pubspec.yaml").write_text("name: fixture\nversion: 1.1.0+38\n")
    (project / "pubspec.lock").write_text("lock content\n")
    (project / "fdroid/version.properties").write_text(
        f"versionName={version}\nversionCode={build_number}\n")
    (project / "android/key.properties").write_text(
        "storePassword=s\nkeyPassword=k\nkeyAlias=upload\nstoreFile=upload-keystore.jks\n")
    (project / "android/upload-keystore.jks").write_text("keystore")
    (project / "play-console-upload/play-service-account.json").write_text(json.dumps(
        {"client_email": "fixture@example.invalid", "private_key": "fixture-key"}))

    calls = tmp_path / "calls.log"
    calls.write_text("")

    stub(project / "scripts/ci/offline-gate.sh",
         f'printf "%s\\n" "offline-gate $*" >> "{calls}"\nexit {gate_exit}\n')
    stub(project / "scripts/pre-release-gate.sh",
         f'printf "%s\\n" "device-gate $*" >> "{calls}"\n')
    stub(project / "scripts/ci/play-readback.sh",
         f'printf "%s\\n" "readback $*" >> "{calls}"\n'
         '''python3 - "$1" "$2" <<'PY'
import json, os, sys
print(os.environ.get("READBACK_JSON") or json.dumps({
    "found": True, "conflict": False, "versionCode": sys.argv[1],
    "aabSha256": sys.argv[2], "track": os.environ["PLAY_TRACK"],
    "status": os.environ["PLAY_RELEASE_STATUS"],
}))
PY
''')
    stub(project / "scripts/build-upload-playstore.sh", f'''
printf "%s\\n" "upload $*" >> "{calls}"
mkdir -p play-console-upload
aab="$PWD/play-console-upload/fractal-forge-v1.1.121-build121.aab"
printf 'fake aab\\n' > "$aab"
sha256sum "$aab" | awk '{{print $1"  "$2}}' > "$aab.sha256"
printf '%s\\n' "$aab" > play-console-upload/LATEST_AAB.txt
printf '{{"versionCode": "121", "publicationEditId": "edit-1", "aabSha256": "%s"}}\\n' \\
  "$(awk '{{print $1}}' "$aab.sha256")" > "$PLAY_RECEIPT_PATH"
''')

    bin_dir = tmp_path / "bin"
    bin_dir.mkdir()
    for name in ("curl", "openssl", "java"):
        stub(bin_dir / name, 'printf "%s\\n" "forbidden $0" >> "$CALLS_LOG"\nexit 97\n')
    stub(bin_dir / "flutter", 'printf "Flutter 3.47.9 • channel [user-branch]\\n"\n')

    environment = os.environ.copy()
    environment.update(PATH=str(bin_dir) + os.pathsep + environment.get("PATH", ""),
                       CALLS_LOG=str(calls), TMPDIR=str(tmp_path),
                       FLUTTER_ROOT="", PLAY_TRACK="production",
                       PLAY_RELEASE_STATUS="completed")
    environment.pop("ANDROID_DEVICE", None)
    environment.pop("ANDROID_DISPOSABLE_DEVICE", None)

    git = ["git", "-c", "user.email=fixture@example.invalid", "-c", "user.name=fixture"]
    subprocess.run(["git", "init", "-q"], cwd=project, check=True)
    subprocess.run([*git, "add", "-A"], cwd=project, check=True)
    subprocess.run([*git, "commit", "-qm", "fixture"], cwd=project, check=True)
    return project, environment, calls


def status_file(tmp_path, codes, uploaded=None):
    path = tmp_path / "play-status.json"
    path.write_text(json.dumps({
        "package": "com.trebuchetdynamics.fractal.forge",
        "track": "production",
        "releases": [{"name": "Fractal Forge", "versionCodes": [str(c) for c in codes],
                      "status": "completed"}] if codes else [],
        "trackVersionCodes": [str(code) for code in codes],
        "latestVersionCode": max(uploaded or codes or [0]),
        "uploadedVersionCodes": uploaded if uploaded is not None else codes,
    }))
    return path


def release(project, environment, *arguments, status=None):
    command = ["bash", "scripts/release-play.sh", *arguments]
    if status is not None:
        command += ["--play-status-json", str(status)]
    return subprocess.run(command, cwd=project, env=environment, text=True,
                          capture_output=True, timeout=60)


def test_dry_run_prints_the_plan_and_touches_nothing(tmp_path):
    project, environment, calls = make_project(tmp_path)
    status = status_file(tmp_path, [], uploaded=[])
    result = release(project, environment, "--dry-run", "--play-status-json",
                     str(status))
    assert result.returncode == 0, result.stderr
    for step in ("3/6 shared offline gate", "5/6 build signed AAB and upload",
                 "6/6 independent Play readback"):
        assert step in result.stdout
    assert "version code 121 is free" in result.stderr
    assert calls.read_text() == ""
    assert not (project / "release-artifacts").exists()


def test_dirty_tree_is_refused_before_any_gate(tmp_path):
    project, environment, calls = make_project(tmp_path)
    status = status_file(tmp_path, [], uploaded=[])
    (project / "uncommitted.txt").write_text("dirty\n")
    result = release(project, environment, status=status)
    assert result.returncode == 2
    assert "working tree is dirty" in result.stderr
    assert calls.read_text() == ""


def test_consumed_version_code_is_refused(tmp_path):
    project, environment, calls = make_project(tmp_path, build_number=120, version="1.1.120")
    (project / "fdroid/version.properties").write_text(
        "versionName=1.1.120\nversionCode=120\n")
    status = status_file(tmp_path, [120], uploaded=[118, 119, 120])
    result = release(project, environment, status=status)
    assert result.returncode == 2
    assert "already consumed" in result.stderr
    assert calls.read_text() == ""


def test_version_must_be_newer_than_the_track(tmp_path):
    project, environment, calls = make_project(tmp_path, build_number=119, version="1.1.119")
    (project / "fdroid/version.properties").write_text(
        "versionName=1.1.119\nversionCode=119\n")
    status = status_file(tmp_path, [], uploaded=[118, 120])
    result = release(project, environment, status=status)
    assert result.returncode == 2
    assert "not newer" in result.stderr
    assert calls.read_text() == ""


def test_identity_must_match_the_prepared_version_file(tmp_path):
    project, environment, calls = make_project(tmp_path)
    (project / "fdroid/version.properties").write_text(
        "versionName=1.1.119\nversionCode=119\n")
    status = status_file(tmp_path, [], uploaded=[])
    result = release(project, environment, "--version", "1.1.121",
                     "--build-number", "121", "--allow-dirty", status=status)
    assert result.returncode == 2
    assert "does not match" in result.stderr
    assert calls.read_text() == ""


def test_a_failing_shared_gate_blocks_the_upload(tmp_path):
    project, environment, calls = make_project(tmp_path, gate_exit=1)
    status = status_file(tmp_path, [], uploaded=[])
    result = release(project, environment, status=status)
    assert result.returncode == 2
    log = calls.read_text()
    assert log.startswith("offline-gate")
    assert "upload" not in log
    assert "readback" not in log
    assert "nothing was published" in result.stderr


def test_device_gate_needs_matching_explicit_targets(tmp_path):
    project, environment, calls = make_project(tmp_path)
    status = status_file(tmp_path, [], uploaded=[])
    result = release(project, environment, "--skip-gate", status=status)
    assert result.returncode == 2
    assert "device gate needs" in result.stderr
    assert "upload" not in calls.read_text()


def test_successful_release_records_evidence_in_order(tmp_path):
    project, environment, calls = make_project(tmp_path)
    status = status_file(tmp_path, [], uploaded=[])
    result = release(project, environment, "--device", "target:5555",
                     "--disposable-device", "target:5555", status=status)
    assert result.returncode == 0, result.stderr
    log = calls.read_text().splitlines()
    stages = [line.split()[0] for line in log]
    assert stages == ["offline-gate", "device-gate", "upload", "readback"], log

    artifact_dir = project / "release-artifacts/play-1.1.121"
    evidence = json.loads((artifact_dir / "release-play-evidence.json").read_text())
    assert evidence["version"] == "1.1.121"
    assert evidence["build_number"] == "121"
    assert evidence["destination"] == {"track": "production", "release_status": "completed"}
    assert evidence["gates"] == {"shared_offline_gate": "passed", "device_gate": "passed"}
    assert evidence["play"]["publication_edit"] == "edit-1"
    assert evidence["play"]["readback"]["found"] is True
    assert len(evidence["artifact"]["sha256"]) == 64
    assert (artifact_dir / "PLAY_RECORD_STUB.md").exists()
    assert (artifact_dir / "fractal-forge-v1.1.121-build121.aab").exists()
    assert "publication confirmed on track production" in result.stderr
    assert "is live" not in result.stderr
    assert evidence["state"] == {
        "publication": "confirmed", "review": "not_observed",
        "storefront_propagation": "not_observed", "end_user_availability": "not_observed",
    }
    gate_dir = Path(evidence["gate_evidence_dir"])
    assert not gate_dir.is_relative_to(project)
    assert gate_dir.parent.stat().st_mode & 0o777 == 0o700


def test_skipped_gates_are_recorded_as_skipped(tmp_path):
    project, environment, calls = make_project(tmp_path)
    status = status_file(tmp_path, [], uploaded=[])
    result = release(project, environment, "--skip-gate", "--skip-device-gate",
                     status=status)
    assert result.returncode == 0, result.stderr
    evidence = json.loads(
        (project / "release-artifacts/play-1.1.121/release-play-evidence.json").read_text())
    assert evidence["gates"] == {"shared_offline_gate": "skipped",
                                 "device_gate": "skipped"}


@pytest.mark.parametrize("relative_scratch", [False, True])
def test_gate_scratch_is_private_and_outside_checkout_by_default(tmp_path, relative_scratch):
    project, environment, calls = make_project(tmp_path)
    if relative_scratch:
        environment["TMPDIR"] = ".."
    stub(project / "scripts/ci/offline-gate.sh", '''
python3 - "$PWD" "$TMPDIR" "$3" <<'PY'
from pathlib import Path
import sys
root, scratch, logs = map(Path, sys.argv[1:])
assert scratch.is_absolute() and logs.is_absolute()
assert not logs.resolve().is_relative_to(root.resolve())
assert scratch.stat().st_mode & 0o777 == 0o700
PY
''')
    result = release(project, environment, "--allow-dirty", "--device", "target:5555",
                     "--disposable-device", "target:5555",
                     status=status_file(tmp_path, [], uploaded=[]))
    assert result.returncode == 0, result.stderr
    assert "upload" in calls.read_text()


def test_scratch_creation_failure_is_a_prepublication_refusal(tmp_path):
    project, environment, calls = make_project(tmp_path)
    stub(tmp_path / "bin/mktemp", 'echo "scratch unavailable" >&2\nexit 1\n')
    result = release(project, environment, status=status_file(tmp_path, [], uploaded=[]))
    assert result.returncode == 2
    assert "could not create private gate scratch" in result.stderr
    assert calls.read_text() == ""


def test_checkout_local_scratch_is_refused_before_any_gate(tmp_path):
    project, environment, calls = make_project(tmp_path)
    environment["TMPDIR"] = str(project)
    result = release(project, environment, status=status_file(tmp_path, [], uploaded=[]))
    assert result.returncode == 2
    assert "outside the checkout" in result.stderr
    assert calls.read_text() == ""


@pytest.mark.parametrize("readback", [
    {"versionCode": "120"},
    {"track": "internal"},
    {"track": None},
    {"status": "draft"},
    {"aabSha256": "b" * 64},
    {"conflict": True},
    {"conflict": "false"},
    {"found": "true"},
    [],
])
def test_unconfirmed_readback_never_reuploads_or_claims_success(tmp_path, readback):
    project, environment, calls = make_project(tmp_path)
    if isinstance(readback, dict):
        readback = {
            "found": True, "conflict": False, "versionCode": "121",
            "track": "production", "status": "completed",
            "aabSha256": hashlib.sha256(b"fake aab\n").hexdigest(),
            **readback,
        }
    environment["READBACK_JSON"] = json.dumps(readback)
    result = release(project, environment, "--skip-gate", "--skip-device-gate",
                     status=status_file(tmp_path, [], uploaded=[]))
    assert result.returncode == 1
    assert "DO NOT upload again" in result.stderr
    assert calls.read_text().count("upload ") == 1
    assert calls.read_text().count("readback ") == 1
    assert not (project / "release-artifacts/play-1.1.121/release-play-evidence.json").exists()


def test_readback_receives_requested_track_and_status(tmp_path):
    project, environment, calls = make_project(tmp_path)
    result = release(project, environment, "--skip-gate", "--skip-device-gate",
                     "--track", "internal", "--release-status", "draft",
                     status=status_file(tmp_path, [], uploaded=[]))
    assert result.returncode == 0, result.stderr
    evidence = json.loads(
        (project / "release-artifacts/play-1.1.121/release-play-evidence.json").read_text())
    assert evidence["play"]["readback"]["track"] == "internal"
    assert evidence["play"]["readback"]["status"] == "draft"


def test_ambiguous_upload_is_unknown_not_a_prepublication_refusal(tmp_path):
    project, environment, calls = make_project(tmp_path)
    stub(project / "scripts/build-upload-playstore.sh",
         f'echo "upload commit-response-lost" >> "{calls}"\nexit 17\n')
    result = release(project, environment, "--allow-dirty", "--skip-gate", "--skip-device-gate",
                     status=status_file(tmp_path, [], uploaded=[]))
    assert result.returncode == 1
    assert "publication state is unknown" in result.stderr
    assert "DO NOT upload again" in result.stderr
    assert calls.read_text().splitlines() == ["upload commit-response-lost"]
    assert "publication confirmed" not in result.stderr
