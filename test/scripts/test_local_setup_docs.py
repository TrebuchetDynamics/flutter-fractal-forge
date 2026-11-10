"""Keep current setup/queue entry points aligned without banning historical evidence."""
from pathlib import Path
import re

import pytest

ROOT = Path(__file__).resolve().parents[2]
PIN = (ROOT / "fdroid/flutter.version").read_text().strip()
SETUP = (ROOT / "AGENTS.md").read_text()
RUNBOOK = "docs/engineering/runbook.md"


def section(path, title):
    text = (ROOT / path).read_text()
    heading = re.search(rf"^(#+) {re.escape(title)}$", text, re.M)
    assert heading, f"{path}: missing {title}"
    rest = text[heading.end():]
    end = re.search(rf"^#{{1,{len(heading[1])}}} ", rest, re.M)
    return rest[:end.start()] if end else rest


@pytest.mark.parametrize("path", ["README.md", "CONTRIBUTING.md"])
def test_current_prerequisites_follow_repository_toolchain(path):
    current = section(path, "Prerequisites").split("```", 1)[0]
    assert "fdroid/flutter.version" in current
    assert "AGENTS.md#common-offline-integration-gate" in current
    assert all(v == PIN for v in re.findall(r"Flutter(?: SDK)? (\d+\.\d+\.\d+)", current))
    dart = re.search(r"Dart (\d+\.\d+\.\d+)", SETUP)[1]
    assert all(v == dart for v in re.findall(r"Dart (\d+\.\d+\.\d+)", current))
    assert "bundled" in current.lower() or "included with Flutter" in current


def test_active_sdk_examples_use_existing_process_local_cache():
    for title in ("Official Dart Flutter MCP workflow", "Owned Linux runtime with reserved ports"):
        current = section(RUNBOOK, title)
        assert "AGENTS.md#common-offline-integration-gate" in current
        blocks = re.findall(r"```sh\n(.*?)```", current, re.S)
        recipes = [block for block in blocks if "FLUTTER_ROOT=" in block]
        assert recipes, f"{title}: missing process-local SDK selection"
        for recipe in recipes:
            assert re.findall(r'FLUTTER_ROOT="\$AUTOWORK_CACHE/flutter-([^"\n]+)"', recipe) == [PIN]
            assert 'AUTOWORK_CACHE="${AUTOWORK_CACHE:-$(git rev-parse --path-format=absolute --git-common-dir)/autowork-execution/cache}"' in recipe
            assert 'export PUB_CACHE="$AUTOWORK_CACHE/pub-cache"' in recipe
            assert recipe.index("export FLUTTER_ROOT=") < recipe.index("export PATH=")
            assert 'export PATH="$FLUTTER_ROOT/bin:/usr/bin:$PATH"' in recipe
            assert 'test -x "$FLUTTER_ROOT/bin/flutter"' in recipe
            assert 'test -d "$PUB_CACHE"' in recipe
            assert recipe.lstrip().startswith("(") and recipe.rstrip().endswith(")")


def test_current_mcp_guidance_does_not_mutate_a_shared_sdk():
    current = section(RUNBOOK, "Official Dart Flutter MCP workflow")
    assert not re.search(r"git[^\n`]*(?:checkout|switch|reset|pull)\b", current)
    assert not re.search(r"/home/[^\s`]+/flutter\b", current)
    assert not re.search(r"Do not provision a private SDK", current, re.I)


def test_current_queue_links_resolve_to_task_store():
    for path, title in (
        ("README.md", "Current development priority"),
        ("README.md", "Project references"),
        (RUNBOOK, "Queue and retained-check handoff"),
    ):
        current = section(path, title)
        links = re.findall(r"\[[^\]]+\]\(([^)]+)\)", current)
        queue_links = [link for link in links if re.search(r"(?:tasks/|TODO\.md|goals\.json)", link)]
        assert queue_links, f"{path}: {title} lacks a current queue link"
        for link in queue_links:
            target = ((ROOT / path).parent / link.split("#", 1)[0]).resolve()
            assert target.exists(), f"{path}: broken queue link {link}"
            assert target.is_relative_to(ROOT / "tasks"), link
    handoff = section(RUNBOOK, "Queue and retained-check handoff")
    assert "tasks/items/" in handoff and "tasks/goals/" in handoff
    assert "authoritative" in handoff.lower()
