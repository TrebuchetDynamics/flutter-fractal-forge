"""Exercise readback state classification with no network or credentials."""

import base64
import json
import os
from pathlib import Path
import subprocess

import pytest


ROOT = Path(__file__).resolve().parents[2]
SHA = "a" * 64


@pytest.fixture
def readback(tmp_path):
    script = tmp_path / "play-readback.sh"
    script.write_bytes((ROOT / "scripts/ci/play-readback.sh").read_bytes())
    (tmp_path / "play-api.sh").write_text('''
play_access_token() { echo test-token; }
play_open_edit() { echo test-edit; }
play_get() {
  case "$3" in
    /tracks/*) printf '%s' "$TRACK_RESPONSE" ;;
    /bundles) printf '%s' "$BUNDLES_RESPONSE" ;;
    *) return 97 ;;
  esac
}
play_discard_edit() { printf '%s\\n' "$2" >> "$CLEANUP_LOG"; }
''')

    def run(track, bundles):
        env = os.environ.copy()
        env.update(PLAY_TRACK="production", PLAY_RELEASE_STATUS="completed",
                   TRACK_RESPONSE=json.dumps(track), BUNDLES_RESPONSE=json.dumps(bundles),
                   CLEANUP_LOG=str(tmp_path / "cleanup.log"))
        result = subprocess.run(["bash", str(script), "124", SHA], env=env,
                                text=True, capture_output=True, timeout=10)
        assert "test-edit" in (tmp_path / "cleanup.log").read_text()
        return result

    return run


def track_resource(**overrides):
    return {"track": "production", "releases": [
        {"versionCodes": ["124"], "status": "completed"}
    ], **overrides}


def bundle_resource(sha=SHA):
    return {"bundles": [{"versionCode": "124", "sha256": sha}]}


@pytest.mark.parametrize("sha", [SHA, base64.b64encode(bytes.fromhex(SHA)).decode()])
def test_exact_match_confirms_publication(readback, sha):
    result = readback(track_resource(), bundle_resource(sha))
    assert result.returncode == 0, result.stderr
    assert json.loads(result.stdout)["found"] is True


def test_valid_empty_resources_establish_absence(readback):
    result = readback({"track": "production"}, {})
    assert result.returncode == 0, result.stderr
    assert json.loads(result.stdout)["found"] is False
    assert json.loads(result.stdout)["conflict"] is False


def test_consumed_code_with_wrong_hash_is_conflict(readback):
    result = readback(track_resource(), bundle_resource("b" * 64))
    assert result.returncode == 0, result.stderr
    assert json.loads(result.stdout)["found"] is False
    assert json.loads(result.stdout)["conflict"] is True


@pytest.mark.parametrize("track,bundles", [
    (track_resource(track="internal"), bundle_resource()),
    ({}, {}),
    ([], {}),
    (track_resource(releases=None), {}),
    (track_resource(releases=[None]), {}),
    (track_resource(releases=[{"status": "completed", "versionCodes": "124"}]), {}),
    (track_resource(), []),
    (track_resource(), {"bundles": None}),
    (track_resource(), {"bundles": [None]}),
    (track_resource(), {"bundles": [{"versionCode": "124"}]}),
])
def test_unknown_resources_cannot_confirm_or_authorize_retry(readback, track, bundles):
    result = readback(track, bundles)
    assert result.returncode != 0
    assert result.stdout == ""
    assert "Play readback returned" in result.stderr
