"""Keep the linked guide's current SDK examples aligned with the repository pin."""
import re

import pytest

from test_local_setup_docs import PIN, ROOT, SETUP, section

GUIDE = "docs/engineering/development/DEVELOPMENT.md"
SDK = "Flutter SDK Installation"


@pytest.mark.parametrize("title,pattern", [
    (SDK, r"Flutter(?: SDK)? (\d+\.\d+\.\d+)"),
    (SDK, r"git clone --branch (\S+)"),
    ("CI Example (GitHub Actions)", r'''flutter-version:\s*["']?([^\s"']+)'''),
], ids=["prerequisite", "clone", "ci"])
def test_current_flutter_selectors_follow_repository_pin(title, pattern):
    versions = re.findall(pattern, section(GUIDE, title))
    assert versions, f"{title}: missing current Flutter selector"
    assert all(version == PIN for version in versions), versions


def test_current_dart_matches_root_setup_or_uses_bundled_toolchain():
    current = section(GUIDE, SDK)
    dart = re.search(r"Dart (\d+\.\d+\.\d+)", SETUP)[1]
    assert all(version == dart for version in re.findall(r"Dart (\d+\.\d+\.\d+)", current))
    assert "bundled" in current.lower()


def test_provisioned_offline_setup_link_resolves():
    current = section(GUIDE, SDK)
    links = re.findall(r"\[[^\]]+\]\(([^)]+)\)", current)
    setup_links = [link for link in links if link.endswith("AGENTS.md#common-offline-integration-gate")]
    assert setup_links, "missing authoritative provisioned offline setup link"
    for link in setup_links:
        path, anchor = link.split("#", 1)
        assert not path.startswith("/"), "setup link must be relative"
        target = ((ROOT / GUIDE).parent / path).resolve()
        assert target == ROOT / "AGENTS.md" and target.is_file()
        headings = re.findall(r"^#+ (.+)$", target.read_text(), re.M)
        assert anchor in [heading.lower().replace(" ", "-") for heading in headings]
