"""Current navigation must resolve without turning historical records into queues."""
from pathlib import Path
import re

import pytest

ROOT = Path(__file__).resolve().parents[2]
ISSUES = "https://github.com/TrebuchetDynamics/flutter-fractal-forge/issues"


def text(path):
    return (ROOT / path).read_text()


def links(content):
    return re.findall(r"\[[^\]]+\]\(([^)]+)\)", content)


@pytest.mark.parametrize("path,content", [
    ("docs/README.md", text("docs/README.md")),
    ("README.md", text("README.md").split("## Project references", 1)[1]),
    ("AGENTS.md", text("AGENTS.md").split("## Subdirectories", 1)[0]),
    ("docs/planning/PRD.md", text("docs/planning/PRD.md").split("### 1.1", 1)[0]),
    ("docs/planning/PIPELINE_STATE.md", text("docs/planning/PIPELINE_STATE.md").split("## 1.", 1)[0]),
    ("todo.archive.md", text("todo.archive.md").split("## Repository interview", 1)[0]),
    ("research/fibonacci-prime-degree-julia.md", text("research/fibonacci-prime-degree-julia.md").splitlines()[2]),
], ids=lambda value: value.splitlines()[0] if "\n" in value else value)
def test_entry_point_relative_links_exist(path, content):
    for link in links(content):
        if "://" in link or link.startswith("#"):
            continue
        target = (ROOT / path).parent / link.split("#", 1)[0]
        assert target.exists(), f"{path}: missing target {link}; use current queue/history navigation"
        assert target.resolve().is_relative_to(ROOT), f"{path}: outside checkout: {link}"


def test_index_starts_at_current_product_and_release_owners():
    index = text("docs/README.md")
    assert "[current product contract](../PRD.md)" in index
    assert "(engineering/release/)" in index
    assert "`release/`" not in index
    assert "Start with [`planning/PRD.md`]" not in index


def test_queue_owners_are_distinct_and_reachable():
    index = text("docs/README.md").split("## Queues and history", 1)[1]
    assert f"({ISSUES})" in index and "Orbi" in index
    assert "Autowork" in index and "(../tasks/items/)" in index and "(../tasks/goals/)" in index
    assert "(../todo.archive.md)" in index and "not an execution queue" in index
    assert "not one shared queue" in index
    for path in ("README.md", "AGENTS.md", "PRD.md"):
        assert "(docs/README.md#queues-and-history)" in text(path), path


def test_historical_snapshots_link_onward_without_replacing_inventory():
    readiness = text("docs/planning/PRD.md")
    pipeline = text("docs/planning/PIPELINE_STATE.md")
    assert "Historical readiness snapshot" in readiness
    assert "(../../PRD.md#active-release-contract)" in readiness
    assert "(../README.md#queues-and-history)" in readiness
    assert "Historical snapshot" in pipeline and "2026-04-12" in pipeline
    assert "(../../PRD.md)" in pipeline and "(../README.md#queues-and-history)" in pipeline
    assert "**357 are fully renderable" in pipeline
    assert "| `implemented` | 357 |" in pipeline


def test_archived_task_navigation_uses_case_sensitive_relative_path():
    stubs = [path for path in (ROOT / "tasks/items").glob("*.md") if "- Archived:" in path.read_text()]
    assert stubs, "No archive navigation found"
    for path in stubs:
        content = path.read_text()
        assert "- Archived: [todo.archive.md](../../todo.archive.md)" in content, path
        assert "TODO.archive.md" not in content, path
        assert (path.parent / "../../todo.archive.md").is_file(), path


def test_retired_queue_files_are_not_recreated_or_linked():
    assert not (ROOT / "TODO.md").exists()
    assert not (ROOT / "TODO.archive.md").exists()
    for path in ("README.md", "AGENTS.md", "PRD.md", "docs/README.md", "docs/planning/PRD.md",
                 "research/fibonacci-prime-degree-julia.md", "docs/engineering/README.md",
                 "docs/engineering/test-plan.md", "docs/planning/visual-fidelity-audit-next.md",
                 "docs/qa/PLAYTESTING_QA_GUIDE.md"):
        assert not any(re.search(r"(?:^|/)(?:TODO\.md|goals\.json)(?:#|$)", link)
                       for link in links(text(path))), path
    preamble = text("todo.archive.md").split("## Repository interview", 1)[0]
    assert "historical" in preamble.lower() and "(docs/README.md#queues-and-history)" in preamble
    assert "not actionable current navigation" in preamble
