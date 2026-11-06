"""Play Console review-state parser: fixture-based, no network or session."""

import importlib.util
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location(
    "play_console_review", ROOT / "scripts" / "ci" / "play_console_review.py"
)
assert SPEC and SPEC.loader
console = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(console)


def test_detects_changes_in_review_before_generic_in_review():
    result = console.classify("<main><h2>Changes in review</h2></main>")
    assert result["state"] == "changes_in_review"
    assert result["matched"].lower() == "changes in review"


def test_detects_in_review():
    assert console.classify("<p>This release is in review.</p>")["state"] == "in_review"


def test_detects_ready_to_publish_and_rejection():
    assert console.classify("Ready to publish")["state"] == "ready_to_publish"
    assert console.classify("Removed for policy violation")["state"] == "rejected"


def test_detects_approval_and_publication():
    assert console.classify("Review completed")["state"] == "approved"
    assert console.classify("Published on Nov 6")["state"] == "published"


def test_unknown_page_stays_unknown():
    result = console.classify("<html><body>Developer dashboard</body></html>")
    assert result["state"] == "unknown"
    assert result["matched"] is None


def test_netscape_cookie_file_builds_header(tmp_path):
    cookies = tmp_path / "cookies.txt"
    cookies.write_text(
        "# Netscape HTTP Cookie File\n"
        ".play.google.com\tTRUE\t/\tTRUE\t0\tSID\ttest-value\n",
        encoding="utf-8",
    )
    assert console.netscape_cookies(str(cookies)) == "SID=test-value"
