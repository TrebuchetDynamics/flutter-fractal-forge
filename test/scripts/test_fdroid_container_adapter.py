"""Exercise the real shell entrypoints; double only Podman and remote git clone."""
import json
import os
from pathlib import Path
import subprocess

import pytest

ROOT = Path(__file__).resolve().parents[2]
ADAPTER = ROOT / "scripts/ci/fdroid-container.sh"
IMAGE = ("registry.gitlab.com/fdroid/docker-executable-fdroidserver@sha256:"
         "2ad114edee50aad92fcc83fe7d801d8922780a021db070ae9f4c49f6f647c037")
APP = "com.trebuchetdynamics.fractal.forge"


def executable(path, source):
    path.write_text(source)
    path.chmod(0o755)
    return path


@pytest.fixture
def sandbox(tmp_path):
    tools = tmp_path / "bin"
    tools.mkdir()
    log = tmp_path / "podman.jsonl"
    executable(tools / "podman", '''#!/usr/bin/python3
import json, os, sys
args = sys.argv[1:]
with open(os.environ["PODMAN_LOG"], "a") as log:
    log.write(json.dumps(args) + "\\n")
assert args.pop(0) == "--remote=false", args
if args == ["info", "--format", "{{.Host.Security.Rootless}}"]:
    print(os.environ.get("FAKE_ROOTLESS", "true"))
elif args[:2] == ["image", "exists"]:
    sys.exit(int(os.environ.get("FAKE_IMAGE_STATUS", "0")))
elif args[0] == "run":
    print("399ac60")
    sys.exit(int(os.environ.get("FAKE_RUN_STATUS", "0")))
else:
    raise AssertionError(args)
''')
    workspace = tmp_path / "public metadata"
    (workspace / "metadata").mkdir(parents=True)
    env = {**os.environ, "PATH": f"{tools}:/usr/bin:/bin", "PODMAN_LOG": str(log)}
    return workspace, env, log, tools


def invoke(workspace, env, *args):
    return subprocess.run(["/bin/bash", str(ADAPTER), *args], cwd=workspace,
                          env=env, text=True, capture_output=True, timeout=10)


def calls(log):
    return [json.loads(line) for line in log.read_text().splitlines()] if log.exists() else []


def expected_run(network, *args, workspace=None, seconds=1800):
    result = ["--remote=false", "run", "--rm", "--pull=never", f"--network={network}",
              "--http-proxy=false", "--cap-drop=ALL", "--security-opt=no-new-privileges",
              "--pids-limit=512", f"--timeout={seconds}"]
    if workspace is not None:
        result += ["--volume", f"{workspace}:/repo:rw", "--workdir=/repo"]
    return result + [IMAGE, *args]


@pytest.mark.parametrize("flag", ["--version", "--help"])
def test_probe_from_project_mounts_nothing_and_disables_network(sandbox, flag):
    _, env, log, _ = sandbox
    result = invoke(ROOT, env, flag)
    assert result.returncode == 0, result.stderr
    assert result.stdout == "399ac60\n"
    assert calls(log) == [
        ["--remote=false", "info", "--format", "{{.Host.Security.Rootless}}"],
        ["--remote=false", "image", "exists", IMAGE],
        expected_run("none", flag, seconds=30),
    ]


@pytest.mark.parametrize("args,network", [
    (["lint", "--force-yamllint", APP], "none"),
    (["scanner", "--exit-code", f"{APP}:1081", f"{APP}:1082", f"{APP}:1083"], "bridge"),
])
def test_only_public_workspace_is_mounted_and_exit_status_is_preserved(sandbox, args, network):
    workspace, env, log, _ = sandbox
    env.update(FAKE_RUN_STATUS="42", AWS_SECRET_ACCESS_KEY="not-for-container",
               HTTPS_PROXY="https://user:password@private.invalid")
    result = invoke(workspace, env, *args)
    assert result.returncode == 42, result.stderr
    assert calls(log)[-1] == expected_run(network, *args, workspace=workspace)
    assert "not-for-container" not in log.read_text()
    assert "password" not in log.read_text()


@pytest.mark.parametrize("args", [[], ["build", APP], ["lint"], ["scanner", "--exit-code"],
    ["--version", "--volume", "/:/host"], ["lint", "--config", "/secret", APP],
    ["scanner", "--exit-code", f"{APP}:1081", "--delete"],
    ["scanner", "--exit-code", f"{APP}:../secret"],
])
def test_rejects_unbounded_commands_before_runtime(sandbox, args):
    workspace, env, log, _ = sandbox
    result = invoke(workspace, env, *args)
    assert result.returncode != 0
    assert "supported" in result.stderr.lower()
    assert calls(log) == []


@pytest.mark.parametrize("hazard", ["pubspec.yaml", "android/key.properties", ".env",
    "nested/.env.release", "nested/signing.jks", "release.keystore", "config.yml",
    "config.py", ".ssh/id_ed25519", ".aws/credentials", "nested/.git-credentials"])
def test_rejects_secret_or_project_workspace_without_starting_runtime(sandbox, hazard):
    workspace, env, log, _ = sandbox
    path = workspace / hazard
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("secret")
    result = invoke(workspace, env, "lint", "--force-yamllint", APP)
    assert result.returncode != 0
    assert "workspace" in result.stderr.lower()
    assert calls(log) == []


@pytest.mark.parametrize("fault", ["missing_metadata", "symlink_metadata", "symlink_secret", "home", "project"])
def test_rejects_non_dedicated_directories(sandbox, fault):
    workspace, env, log, _ = sandbox
    if fault == "missing_metadata":
        (workspace / "metadata").rmdir()
    elif fault == "symlink_metadata":
        (workspace / "metadata").rmdir()
        (workspace / "metadata").symlink_to(ROOT / "fdroid", target_is_directory=True)
    elif fault == "symlink_secret":
        (workspace / "leak").symlink_to(ROOT / ".env")
    elif fault == "home":
        env["HOME"] = str(workspace)
    elif fault == "project":
        workspace = ROOT
    result = invoke(workspace, env, "lint", "--force-yamllint", APP)
    assert result.returncode != 0
    assert "workspace" in result.stderr.lower()
    assert calls(log) == []


@pytest.mark.parametrize("fault", ["rootful", "missing_image", "missing_runtime"])
def test_fails_closed_when_local_rootless_runtime_or_cached_image_is_missing(sandbox, fault):
    workspace, env, log, tools = sandbox
    if fault == "rootful":
        env["FAKE_ROOTLESS"] = "false"
    elif fault == "missing_image":
        env["FAKE_IMAGE_STATUS"] = "1"
    else:
        (tools / "podman").unlink()
        # Only expose bash's external dependencies, not the installed host Podman.
        for name in ("dirname", "realpath"):
            (tools / name).symlink_to(Path("/usr/bin") / name)
        env["PATH"] = str(tools)
    result = invoke(workspace, env, "--version")
    assert result.returncode != 0
    assert not any("run" in call for call in calls(log))
    assert "podman" in result.stderr.lower() or "image" in result.stderr.lower()


@pytest.mark.parametrize("mismatch", [False, True])
@pytest.mark.parametrize("relative_tmpdir", [False, True])
def test_scanner_uses_explicit_fdroid_binary_and_real_source_identity(sandbox, mismatch, relative_tmpdir):
    workspace, env, log, tools = sandbox
    artifact = workspace.parent / "artifacts" / "fdroid" / "fdroiddata" / "metadata"
    artifact.mkdir(parents=True)
    (artifact / f"{APP}.yml").write_text("RepoType: git\n")
    clone_log = workspace.parent / "clones.jsonl"
    executable(tools / "git", '''#!/usr/bin/python3
import json, os, pathlib, sys
if sys.argv[1:2] == ["clone"]:
    assert sys.argv[1:4] == ["clone", "--depth=1", "https://gitlab.com/fdroid/fdroiddata.git"]
    target = pathlib.Path(sys.argv[4])
    (target / "metadata").mkdir()
    (target / "config.yml").write_text("must be removed before container mount")
    with open(os.environ["CLONE_LOG"], "a") as log:
        log.write(json.dumps(str(target.resolve())) + "\\n")
else:
    os.execv("/usr/bin/git", ["/usr/bin/git", *sys.argv[1:]])
''')
    # Spaces prove FDROID_BIN is invoked as one executable, never eval'd/split.
    fdroid = executable(tools / "explicit fdroid", f'#!/bin/bash\nexec "{ADAPTER}" "$@"\n')
    commit = subprocess.check_output(["/usr/bin/git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip()
    env.update(FDROID_BIN=str(fdroid), RELEASE_LOCAL_STAGE="1", RELEASE_COMMIT="0" * 40 if mismatch else commit,
               RELEASE_VERSION="1.1.108", RELEASE_BUILD_NUMBER="108", CLONE_LOG=str(clone_log),
               RELEASE_ARTIFACT_DIR=str(artifact.parents[2]),
               TMPDIR=os.path.relpath(workspace.parent, ROOT) if relative_tmpdir else str(workspace.parent))
    result = subprocess.run(["/bin/bash", str(ROOT / "scripts/ci/fdroid-scan.sh")],
                            cwd=ROOT, env=env, text=True, capture_output=True, timeout=15)
    if mismatch:
        assert result.returncode != 0
        assert "identity mismatch" in result.stderr
        assert not clone_log.exists()
        assert calls(log) == []
    else:
        assert result.returncode == 0, result.stdout + result.stderr
        scan_root = Path(json.loads(clone_log.read_text()))
        runs = [call for call in calls(log) if "run" in call]
        assert runs == [
            expected_run("none", "lint", "--force-yamllint", APP, workspace=scan_root),
            expected_run("bridge", "scanner", "--exit-code", f"{APP}:1081", f"{APP}:1082",
                         f"{APP}:1083", workspace=scan_root),
        ]
        assert not scan_root.exists(), "scanner must clean its temporary mount workspace"
