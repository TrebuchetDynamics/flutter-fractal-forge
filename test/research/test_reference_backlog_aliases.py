from pathlib import Path

import pytest
from ruamel.yaml import YAML

from scripts.research.canonicalize.dedup import dedup
from scripts.research.lib.registry import Registry
from scripts.research.migrate.seed_aliases import build_alias_table


_REPO_ROOT = Path(__file__).resolve().parents[2]
_REGISTRY_PATH = _REPO_ROOT / "docs" / "catalog" / "fractal_registry.yaml"
_SEED_PATH = _REPO_ROOT / "research" / "seeds" / "canonical_aliases.seed.yaml"


@pytest.fixture(scope="module")
def registry():
    return Registry.load(_REGISTRY_PATH)


@pytest.fixture(scope="module")
def alias_table(registry):
    yaml = YAML()
    with _SEED_PATH.open() as f:
        seed = yaml.load(f) or {}
    return build_alias_table(registry.entries, seed=seed)


@pytest.mark.parametrize(
    ("canonical_id", "reference_alias"),
    [
        ("halley", "Halley's Method"),
        ("schroeder", "Schröder's Method"),
        ("chebyshev", "Chebyshev's Method"),
        ("householder", "Householder's Method (3rd Order)"),
        ("newton_z3", "Newton z^3 - 1"),
        ("newton_z4", "Newton z^4 - 1"),
        ("newton_z5", "Newton z^5 - 1"),
        ("newton_z6", "Newton z^6 - 1"),
        ("newton_z7", "Newton z^7 - 1"),
        ("newton_z8", "Newton z^8 - 1"),
        ("moore_curve", "f0230_moore_curve"),
        ("levy_c_curve", "f0232_l_vy_c_curve"),
        ("mcworter_pentigree", "f0233_mcworter_pentigree"),
        ("cesaro_fractal", "f0237_ces_ro_fractal"),
        ("ammann_beenker", "f0686_ammann_beenker_tiling"),
        ("pinwheel_tiling", "f0691_pinwheel_tiling"),
        ("chair_tiling", "f0696_chair_tiling"),
        ("sphinx_tiling", "f0698_sphinx_tiling"),
        ("collatz", "f0768_collatz_fractal"),
        ("gauss_map", "Gauss Map Fractal"),
        ("fibonacci_word", "f0777_fibonacci_word_fractal"),
        ("bicomplex", "f0551_bicomplex_mandelbrot"),
    ],
)
def test_reference_backlog_aliases_point_to_implemented_entries(
    registry,
    alias_table,
    canonical_id,
    reference_alias,
):
    entry = registry.by_id(canonical_id)
    assert entry is not None
    assert entry["tier"] == "implemented"
    assert reference_alias in alias_table[canonical_id]["aliases"]


@pytest.mark.parametrize(
    ("proposed_name", "expected_id"),
    [
        ("Halley's Method", "halley"),
        ("Schröder's Method", "schroeder"),
        ("Newton z^3 - 1", "newton_z3"),
        ("Newton z^8 - 1", "newton_z8"),
        ("Gauss Map Fractal", "gauss_map"),
        ("f0551_bicomplex_mandelbrot", "bicomplex"),
    ],
)
def test_reference_backlog_names_trigger_dedup_review(
    registry,
    alias_table,
    proposed_name,
    expected_id,
):
    candidate = {
        "proposed_name": proposed_name,
        "formula_ast": {
            "iteration_type": "other",
            "variables": ["z", "c"],
            "update": f"z = z**2 + c + {abs(hash(proposed_name)) % 997}",
        },
    }

    result = dedup(candidate, existing=registry.entries, aliases=alias_table)

    assert result.action == "review_fuzzy"
    assert result.suggested_id == expected_id
