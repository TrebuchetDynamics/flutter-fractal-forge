from scripts.research.admit.promote_candidate import _build_registry_entry
from scripts.research.canonicalize.taxonomy_classifier import classify


def test_new_reference_admission_does_not_copy_unverified_confidence_or_compile_status():
    candidate = {
        "proposed_name": "Unverified example",
        "formula_ast": {"iteration_type": "escape_time", "update": "z=z**2+c"},
        "quality": {
            "confidence": 1.0,
            "shader_compile": {"glsl": "ok", "sksl": "ok"},
        },
        "references": [{"url": "https://example.org/source"}],
    }

    entry = _build_registry_entry(candidate, "f0001_unverified", classify(candidate["formula_ast"]))

    assert entry["tier"] == "reference"
    assert entry["implemented"] is False
    assert "confidence" not in entry["quality"]
    assert entry["quality"]["citation_health"]["status"] == "unchecked"
    assert entry["quality"]["shader_compile"]["glsl"] == "n/a"
    assert entry["references"] == candidate["references"]
