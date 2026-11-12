"""Keep the coloring guide aligned with bounded source cases and live bindings."""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[2]
GUIDE = ROOT / "docs/engineering/performance/SHADER_OPTIMIZATIONS.md"
COVERAGE = ROOT / "test/shaders/smooth_coloring_family_coverage_test.dart"
CATALOG = ROOT / "lib/core/modules/builders/escape_time_catalog"
CATALOG_SOURCES = (
    "families/core_escape_time_family.dart",
    "families/cellular_stochastic.dart",
    "research_batches/batch_14_extensions.dart",
    "research_batches/mandlebrot_sfml_batch_1.dart",
)


def check_paths(guide):
    paths = re.findall(r"`((?:shaders/|lib/|test/)[^`]+|pubspec\.yaml)`", guide)
    paths += re.findall(r"^flutter test (\S+)$", guide, re.M)
    assert paths, "missing repository references"
    for path in paths:
        assert (ROOT / path).is_file(), f"missing repository path: {path}"
    for link in re.findall(r"\[[^\]]+\]\(([^)]+)\)", guide):
        assert (GUIDE.parent / link.split("#", 1)[0]).is_file(), link


def check_bindings(guide):
    documented = {
        module: (asset, float(power))
        for module, asset, power in re.findall(
            r"^\| `(multibrot\d+|buffalo_cubic)` \| `([^`]+)` \| (\d+) \|$",
            guide, re.M,
        )
    }
    modules = {f"multibrot{degree}" for degree in range(3, 13)} | {"buffalo_cubic"}
    expected = {}
    # Bounded EscapeTimeConfig syntax, not a general Dart parser.
    for owner in CATALOG_SOURCES:
        for config in (CATALOG / owner).read_text().split("EscapeTimeConfig(")[1:]:
            module = re.search(r"\bid:\s*'([^']+)'", config)
            if module and module[1] in modules:
                asset = re.search(r"shaderAsset:\s*'([^']+)'", config)
                power = re.search(r"id:\s*'power'[\s\S]*?defaultValue:\s*([\d.]+)", config)
                assert asset and power, module[1]
                expected[module[1]] = (asset[1], float(power[1]))
    assert expected.keys() == modules, "incomplete bounded catalog inventory"
    assert documented == expected, "stale live module-to-shader association or default power"


def test_current_paths_links_and_command_targets_resolve():
    check_paths(GUIDE.read_text())


def test_live_bindings_and_default_powers_match_catalog():
    check_bindings(GUIDE.read_text())


def test_source_inventory_and_numeric_only_limits():
    coloring = GUIDE.read_text().split("## Coloring coverage\n", 1)[1].split("\n## ", 1)[0]
    coverage = COVERAGE.read_text()
    cases = coverage.split("    ];", 1)[0]
    source_cases = re.findall(r"family:\s*'([^']+)',\s*path:\s*'([^']+)'", cases)
    assert source_cases, "missing source cases"
    documented = set()
    table = coloring.split("| Module |", 1)[0]
    for family, cell in re.findall(r"^\| ([^|]+) \| ([^|]+) \|", table, re.M):
        documented.update((family.lower(), path) for path in re.findall(r"`(shaders/[^`]+)`", cell))
    assert documented == {(family.lower(), path) for family, path in source_cases}
    assert not re.search(r"\b\d+ (?:shaders|families|source cases)\b", coloring)

    numeric = coverage.split("test('higher-degree Multibrot", 1)[1]
    assert "File(" not in numeric and "[5, 6, 7, 8, 9, 10, 11, 12]" in numeric
    limitation = next(p for p in coloring.split("\n\n") if "numeric-only" in p)
    assert "degrees 5–12" in limitation
    assert re.search(r"not .*shader-source assertions", limitation)
    assert re.search(r"not .*rendered proof", limitation)
    assert "P1-3 is still open" in coloring
    assert "not visual or hardware-GPU qualification" in coloring
