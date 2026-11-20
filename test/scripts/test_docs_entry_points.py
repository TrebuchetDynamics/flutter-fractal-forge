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


def test_document_roles_contextualize_retained_payloads_and_generated_guides():
    index = text('docs/README.md')
    for owner in ('../AGENTS.md', '../pubspec.yaml', 'analysis/', 'qa/',
                  '../research/', '../opensource/', '../packages/', '../migration/'):
        assert f']({owner})' in index, owner
    assert 'not current instructions' in index
    assert 'external urls' in index.lower()
    assert 'generated directory inventories' in text('AGENTS.md').lower()
    assert 'retained snapshot' in text('CHECKLIST.md').split('## Now', 1)[0]


@pytest.mark.parametrize('path,owner', [
    ('AI_RULES.md', 'AGENTS.md'),
    ('docs/engineering/development/CLAUDE.md', '../../../AGENTS.md'),
    ('docs/engineering/development/DEPENDENCY_MODERNIZATION.md', '../../../pubspec.lock'),
    ('docs/engineering/rendering/AR_ARCHITECTURE_FULL_REPORT.md', '../../../PRD.md#active-release-contract'),
    ('docs/qa/gesture_table.md', '../../lib/features/renderer/widgets/renderer/fractal_renderer.dart'),
    ('docs/qa/gesture-navigation.md', '../../lib/features/renderer/widgets/renderer/fractal_renderer.dart'),
])
def test_stale_instruction_snapshots_start_with_current_owner(path, owner):
    preamble = text(path).split('\n## ', 1)[0]
    assert 'historical' in preamble.lower(), path
    assert f']({owner})' in preamble, path
    for link in links(preamble):
        if '://' not in link and not link.startswith('#'):
            assert ((ROOT / path).parent / link.split('#', 1)[0]).exists(), (path, link)


def test_formula_coverage_uses_capability_source_not_unsupported_parity_or_analytics():
    coverage = text('docs/engineering/rendering/formula_coverage_limitation.md')
    for source in ('cpu/formulas/cpu_formulas.dart', 'policy/precision_ladder_policy.dart'):
        assert source in coverage
    assert '100% coverage' not in coverage
    assert 'full CPU parity' not in coverage
    assert 'based on usage analytics' not in coverage
    assert 'no remote usage analytics' in coverage
    playbook = text('docs/engineering/rendering/cpu_vs_gpu_rendering.md')
    assert 'emulator status alone does not force CPU' in playbook
    assert 'or implement perturbation later' not in playbook


def test_current_navigation_separates_fibonacci_implementation_from_qualification():
    assert "id: 'fibonacci_complex_julia'" in text('lib/core/modules/builders/fibonacci_complex_module.dart')
    for path in ('PRD.md', 'docs/engineering/README.md', 'docs/engineering/spec.md',
                 'research/fibonacci-prime-degree-julia.md'):
        content = text(path)
        assert 'builders/fibonacci_complex_module.dart' in content, path
        assert 'qualification' in content.lower(), path
    assert 'not an implemented catalog addition' not in text('docs/engineering/README.md')


def test_current_readme_and_glossary_do_not_endorse_removed_or_planned_only_ux():
    readme = text('README.md')
    assert 'are planned work, not shipped controls' not in readme
    assert 'one selected parameter' in readme
    context = text('CONTEXT.md')
    assert 'Historical music terminology' in context
    assert 'Fourier Music was removed' in context
    landing = text('web/landing.html')
    assert 'downloads reported by the project owner' not in landing
    assert '#-getting-started' not in landing


def test_backend_matrix_distinguishes_dated_emulator_receipt_from_current_policy():
    matrix = text('docs/engineering/rendering/renderer_backend_matrix.md')
    policy = text('lib/features/renderer/policy/backend_policy.dart')
    current = matrix.split('## Deterministic backend policy', 1)[1].split('## Web validation', 1)[0]
    assert 'RendererBackendPolicy.explain' in current
    assert 'emulator status alone does not force CPU' in current
    assert 'Emulator targets are handled like physical devices in auto mode' in policy
    assert 'Deterministic policy routes emulator to CPU' in matrix  # preserved dated observation
