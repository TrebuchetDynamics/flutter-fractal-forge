"""Read-only Play status: hermetic API doubles, no network and no publication."""

import json
import os
from pathlib import Path
import subprocess
import textwrap

ROOT = Path(__file__).resolve().parents[2]
NL = "\n"


def fake_api(temp):
    """Fake curl/openssl pair that records every request method and URL."""
    bin_dir = temp / "bin"
    bin_dir.mkdir()
    calls = temp / "curl.calls"
    curl = bin_dir / "curl"
    curl.write_text(NL.join([
        "#!/usr/bin/env python3",
        "import json, os, sys",
        "args = sys.argv[1:]",
        "url = next(arg for arg in reversed(args) if arg.startswith('https://'))",
        "method = args[args.index('-X') + 1] if '-X' in args else 'GET'",
        "open(os.environ['FAKE_CURL_CALLS'], 'a').write(method + ' ' + url + '\\n')",
        "if 'oauth2.googleapis.com/token' in url:",
        "    print(json.dumps({'access_token': 'test-token'}))",
        "elif url.endswith('/edits') and method == 'POST':",
        "    print(json.dumps({'id': 'draft-edit'}))",
        "elif '/tracks/production' in url:",
        "    print(json.dumps({'track': 'production', 'releases': [",
        "        {'name': 'Fractal Forge 1.1.119 (119)', 'versionCodes': ['119'], 'status': 'completed'}]}))",
        "elif url.endswith('/bundles'):",
        "    print(json.dumps({'bundles': [",
        "        {'versionCode': 118, 'sha256': 'aa'}, {'versionCode': 119, 'sha256': 'bb'}]}))",
        "else:",
        "    print('{}')",
        "",
    ]))
    curl.chmod(0o755)
    openssl = bin_dir / "openssl"
    openssl.write_text(NL.join([
        "#!/bin/sh",
        "if [ \"$1\" = dgst ]; then cat >/dev/null; printf signature; else exec /usr/bin/openssl \"$@\"; fi",
        "",
    ]))
    openssl.chmod(0o755)
    credentials = temp / "service-account.json"
    credentials.write_text(json.dumps({"client_email": "release@example.invalid",
                                       "private_key": "test-key"}))
    environment = os.environ.copy()
    environment.update(PATH=str(bin_dir) + os.pathsep + environment.get("PATH", ""),
                       TMPDIR=str(temp), PLAY_SERVICE_ACCOUNT_JSON=str(credentials),
                       FAKE_CURL_CALLS=str(calls), PLAY_TRACK="production")
    return environment, calls


def run_status(temp, *arguments, environment=None):
    environment = environment or fake_api(temp)[0]
    return subprocess.run(["bash", str(ROOT / "scripts/ci/play-status.sh"), *arguments],
                          cwd=ROOT, env=environment, text=True, capture_output=True, timeout=30)


def test_status_reports_the_live_track_without_publishing(tmp_path):
    environment, calls = fake_api(tmp_path)
    result = run_status(tmp_path, environment=environment)
    assert result.returncode == 0, result.stderr
    status = json.loads(result.stdout)
    assert status["track"] == "production"
    assert status["trackVersionCodes"] == ["119"]
    assert status["latestVersionCode"] == 119
    assert status["uploadedVersionCodes"] == [118, 119]
    assert status["bundleSha256"]["119"] == "bb"
    assert status["releases"][0]["status"] == "completed"

    requests = calls.read_text().splitlines()
    edit_posts = [line for line in requests if line.startswith("POST ") and line.endswith("/edits")]
    deletes = [line for line in requests if line.startswith("DELETE ")]
    assert len(edit_posts) == 1, requests
    assert len(deletes) == 1, requests
    forbidden = [line for line in requests if "upload" in line or ":commit" in line]
    assert forbidden == []


def test_pretty_output_is_human_readable(tmp_path):
    result = run_status(tmp_path, "--pretty")
    assert result.returncode == 0, result.stderr
    assert "latest consumed version code: 119" in result.stdout
    assert "completed" in result.stdout


def test_missing_credentials_are_a_setup_refusal(tmp_path):
    environment, _ = fake_api(tmp_path)
    environment["PLAY_SERVICE_ACCOUNT_JSON"] = str(tmp_path / "absent.json")
    result = run_status(tmp_path, environment=environment)
    assert result.returncode == 2
    assert "unavailable" in result.stderr.lower()


def test_readback_keeps_its_read_only_contract_after_the_helper_refactor():
    source = (ROOT / "scripts/ci/play-readback.sh").read_text(encoding="utf-8")
    assert '. "$SCRIPT_DIR/play-api.sh"' in source
    assert "play_discard_edit" in source
    assert "upload" not in source
    assert ":commit" not in source


def test_the_shared_helper_never_publishes():
    source = (ROOT / "scripts/ci/play-api.sh").read_text(encoding="utf-8")
    assert "uploadType" not in source
    assert ":commit" not in source
    assert "-X DELETE" in source
