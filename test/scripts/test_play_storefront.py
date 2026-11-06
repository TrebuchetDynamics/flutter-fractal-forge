"""Storefront observation parser: fixture-based, no network."""

import importlib.util
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location(
    "play_storefront", ROOT / "scripts" / "ci" / "play_storefront.py"
)
assert SPEC and SPEC.loader
storefront = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(storefront)

AVAILABLE = """
<html><head><title>Fractal Forge</title></head><body>
<div class="TKjAsc"><div><div class="lXlx5">Updated on</div>
<div class="xg1aie">Nov 6, 2026</div></div></div>
<script>AF_initDataCallback({key: 'ds:5', data:
{"141":[[["1.1.121"]],[[[36]],[[[24,"7.0"]]]]],"146":[["Nov 6, 2026",[1793945756,389000000]]]}});</script>
</body></html>
"""

NOT_FOUND = """
<!DOCTYPE html><html><head><title>Not Found</title></head><body>missing</body></html>
"""


def test_available_parses_updated_date_and_version():
    parsed = storefront.parse_storefront(AVAILABLE, 200)
    assert parsed["available"] is True
    assert parsed["updated"] == "Nov 6, 2026"
    assert parsed["version"] == "1.1.121"
    assert parsed["reason"] is None


def test_not_found_page_is_unavailable():
    parsed = storefront.parse_storefront(NOT_FOUND, 404)
    assert parsed["available"] is False
    assert "not-found" in parsed["reason"]


def test_unexpected_status_is_unknown_not_unavailable():
    parsed = storefront.parse_storefront("", 500)
    assert parsed["available"] is None
    assert "500" in parsed["reason"]


def test_page_without_version_still_reports_availability():
    body = AVAILABLE.replace('"141":[[["1.1.121"]],', "")
    parsed = storefront.parse_storefront(body, 200)
    assert parsed["available"] is True
    assert parsed["version"] is None
    assert parsed["updated"] == "Nov 6, 2026"


def test_summarize_splits_states_and_matches_expectations():
    rows = [
        {"country": "US", "available": True, "updated": "Nov 6, 2026", "version": "1.1.121"},
        {"country": "GB", "available": True, "updated": "Nov 5, 2026", "version": "1.1.120"},
        {"country": "ES", "available": False, "updated": None, "version": None},
        {"country": "JP", "available": None, "updated": None, "version": None},
    ]
    summary = storefront.summarize(rows, "1.1.121", "Nov 6, 2026")
    assert summary["propagated"] == ["US"]
    assert [item["country"] for item in summary["pending"]] == ["GB"]
    assert summary["unavailable"] == ["ES"]
    assert summary["errors"] == ["JP"]
    assert summary["probed"] == 4
    assert summary["available"] == 2


def test_summarize_without_expectations_only_reports_availability():
    rows = [
        {"country": "US", "available": True, "updated": "Nov 6, 2026", "version": "1.1.121"},
        {"country": "GB", "available": True, "updated": "Nov 5, 2026", "version": "1.1.120"},
    ]
    summary = storefront.summarize(rows, None, None)
    assert summary["propagated"] == ["US", "GB"]
    assert summary["pending"] == []
    assert summary["available"] == 2


def test_infer_review_reports_published_when_every_probe_matches():
    document = {
        "summary": {"propagated": ["US", "GB"], "pending": [], "errors": [], "probed": 2}
    }
    inferred = storefront.infer_review(document, "1.1.121", "Nov 6, 2026")
    assert inferred["state"] == "published-to-probed-storefronts"
    assert inferred["basis"]["propagated"] == 2
    assert "not the Play Console review state" in inferred["caveats"][2]


def test_infer_review_reports_partial_and_not_visible():
    partial = {
        "summary": {"propagated": ["US"], "pending": [{"country": "GB"}], "errors": [], "probed": 2}
    }
    assert storefront.infer_review(partial, "1.1.121", None)["state"] == "partially-propagated"
    none = {"summary": {"propagated": [], "pending": [], "errors": [], "probed": 2}}
    assert storefront.infer_review(none, "1.1.121", None)["state"] == "not-yet-visible"


def test_infer_review_without_expectations_is_unknown():
    inferred = storefront.infer_review({"summary": {"probed": 0}}, None, None)
    assert inferred["state"] == "unknown"
