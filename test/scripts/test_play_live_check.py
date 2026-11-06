"""Reusable live check: policy evaluation against observation fixtures."""

import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "scripts" / "ci" / "play-live-check.sh"


def observation():
    return {
        "package": "com.example.app",
        "expected_version": "1.1.121",
        "expected_updated": "Nov 6, 2026",
        "observed_at_utc": "2026-11-06T00:00:00+00:00",
        "official": {
            "track": {"releases": [{"status": "completed", "versionCodes": ["121"]}]}
        },
        "storefront": {
            "summary": {
                "probed": 2,
                "available": 2,
                "unavailable": [],
                "errors": [],
                "pending": [],
                "propagated": ["US", "GB"],
            }
        },
        "review": {
            "console": None,
            "inferred_from_storefront": {"state": "published-to-probed-storefronts"},
        },
    }


def run(tmp_path, document, *args):
    path = tmp_path / "observed.json"
    path.write_text(json.dumps(document), encoding="utf-8")
    completed = subprocess.run(
        ["bash", str(SCRIPT), "--input", str(path), *args],
        capture_output=True,
        text=True,
    )
    return completed.returncode, json.loads(completed.stdout), completed.stderr


def test_passes_when_track_propagation_and_version_match(tmp_path):
    code, result, err = run(tmp_path, observation())
    assert code == 0, err
    assert result["status"] == "pass"
    assert result["checks"]["version_code"]["observed"] == ["121"]
    assert result["checks"]["version_code"]["expected_code"] == "121"


def test_fails_when_track_is_not_completed(tmp_path):
    doc = observation()
    doc["official"]["track"]["releases"][0]["status"] = "inProgress"
    code, result, _ = run(tmp_path, doc)
    assert code == 1
    assert result["checks"]["track_completed"]["passed"] is False


def test_fails_when_version_code_is_missing(tmp_path):
    doc = observation()
    doc["official"]["track"]["releases"][0]["versionCodes"] = ["120"]
    code, result, _ = run(tmp_path, doc)
    assert code == 1
    assert any("not on the track" in reason for reason in result["reasons"])


def test_pending_storefronts_fail_unless_allowed(tmp_path):
    doc = observation()
    doc["storefront"]["summary"]["pending"] = [{"country": "GB", "version": "1.1.120"}]
    code, result, _ = run(tmp_path, doc)
    assert code == 1
    assert result["checks"]["propagation"]["passed"] is False
    code, result, _ = run(tmp_path, doc, "--allow-pending")
    assert code == 0, result


def test_probe_errors_always_fail(tmp_path):
    doc = observation()
    doc["storefront"]["summary"]["errors"] = ["JP"]
    doc["storefront"]["summary"]["available"] = 2
    code, result, _ = run(tmp_path, doc)
    assert code == 1
    assert result["checks"]["storefront_available"]["passed"] is False


def test_min_available_relaxes_unavailable_countries(tmp_path):
    doc = observation()
    doc["storefront"]["summary"].update(
        {"probed": 2, "available": 1, "unavailable": ["ES"], "propagated": ["US"]}
    )
    code, _, _ = run(tmp_path, doc)
    assert code == 1
    code, result, _ = run(tmp_path, doc, "--min-available", "1")
    assert code == 0, result


def test_no_probes_fails(tmp_path):
    doc = observation()
    doc["storefront"]["summary"] = {
        "probed": 0,
        "available": 0,
        "unavailable": [],
        "errors": [],
        "pending": [],
        "propagated": [],
    }
    code, result, _ = run(tmp_path, doc)
    assert code == 1
    assert any("no storefront was probed" in reason for reason in result["reasons"])


def test_required_review_needs_console_state(tmp_path):
    code, result, _ = run(tmp_path, observation(), "--require-review", "approved")
    assert code == 1
    assert result["checks"]["review"]["observed"] == "missing"


def test_required_review_passes_on_approved_or_published(tmp_path):
    doc = observation()
    doc["review"]["console"] = {"state": "approved"}
    code, result, _ = run(tmp_path, doc, "--require-review", "approved")
    assert code == 0, result
    doc["review"]["console"] = {"state": "published"}
    code, result, _ = run(tmp_path, doc, "--require-review", "approved")
    assert code == 0, result


def test_required_review_fails_in_review_and_rejected(tmp_path):
    for state in ("changes_in_review", "in_review", "rejected"):
        doc = observation()
        doc["review"]["console"] = {"state": state}
        code, result, _ = run(tmp_path, doc, "--require-review", "approved")
        assert code == 1, state
        assert result["checks"]["review"]["passed"] is False
