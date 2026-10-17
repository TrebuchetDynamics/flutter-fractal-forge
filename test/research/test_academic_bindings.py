import json
import shutil

from scripts.research.academic.library import validate_catalog_bindings
from scripts.research.doctor.check_registry import check_registry
from scripts.research.lib.registry import Registry
from scripts.research.migrate.retrofit_registry import retrofit_entries


def _binding(source_hash="sha256:" + "a" * 64, formula_hash="sha256:" + "b" * 64):
    return {
        "schema_version": 1,
        "papers": [{
            "paper_id": "paper-00000000000000000001",
            "title": "Reviewed source",
            "content_state": "full_text_available",
            "claim_state": "source_checked",
            "source_hash": source_hash,
            "source_urls": ["https://example.org/paper"],
        }],
        "mappings": [{
            "identity": "f0001_demo",
            "source_ids": ["paper-00000000000000000001"],
            "claim_state": "numerically_checked",
            "claim_spans": [{"source_id": "paper-00000000000000000001", "locator": "p. 4, equation 2"}],
            "source_checked": True,
            "source_hashes": {"paper-00000000000000000001": source_hash},
            "formula_hash": formula_hash,
            "numerical_check": True,
        }],
    }


def _registry(formula_hash="sha256:" + "b" * 64):
    return [{"id": "f0001_demo", "formula_hash": formula_hash, "references": [{"url": "https://example.org/paper"}]}]


def test_reviewed_catalog_binding_requires_current_source_formula_and_span():
    assert validate_catalog_bindings(_binding(), _registry()) == []


def test_mathematically_verified_claim_rejects_missing_source_and_span():
    library = _binding()
    library["mappings"][0]["source_ids"] = []
    library["mappings"][0]["claim_spans"] = []

    errors = validate_catalog_bindings(library, _registry())

    assert any("missing source" in error for error in errors)
    assert any("claim span" in error for error in errors)


def test_mathematically_verified_claim_rejects_unreviewed_source():
    library = _binding()
    library["papers"][0]["claim_state"] = "unreviewed"

    errors = validate_catalog_bindings(library, _registry())

    assert any("unreviewed source" in error for error in errors)


def test_mathematically_verified_claim_rejects_source_missing_from_catalog_references():
    registry = _registry()
    registry[0]["references"] = []

    errors = validate_catalog_bindings(_binding(), registry)

    assert any("source missing from catalog references" in error for error in errors)


def test_mathematically_verified_claim_rejects_wrong_formula():
    library = _binding(formula_hash="sha256:" + "c" * 64)

    errors = validate_catalog_bindings(library, _registry())

    assert any("formula binding mismatch" in error for error in errors)


def test_mathematically_verified_claim_rejects_stale_source_hash():
    library = _binding()
    library["mappings"][0]["source_hashes"]["paper-00000000000000000001"] = "sha256:" + "d" * 64

    errors = validate_catalog_bindings(library, _registry())

    assert any("stale source binding" in error for error in errors)


def test_doctor_rejects_a_stale_reviewed_catalog_binding(tmp_path, tmp_registry):
    root = tmp_path / "repo"
    catalog_dir = root / "docs" / "catalog"
    catalog_dir.mkdir(parents=True)
    registry_path = catalog_dir / "fractal_registry.yaml"
    shutil.copy(tmp_registry, registry_path)
    registry = Registry.load(registry_path)
    retrofit_entries(registry.entries)
    registry.save()
    entry = registry.entries[0]
    academic_dir = root / "research" / "academic"
    academic_dir.mkdir(parents=True)
    (academic_dir / "papers.jsonl").write_text(json.dumps({
        "paper_id": "paper-00000000000000000001",
        "title": "Reviewed source",
        "content_state": "full_text_available",
        "claim_state": "source_checked",
        "source_hash": "sha256:" + "a" * 64,
    }) + "\n")
    (academic_dir / "mappings.json").write_text(json.dumps({
        "schema_version": 1,
        "mappings": [{
            "identity": entry["id"],
            "source_ids": ["paper-00000000000000000001"],
            "claim_state": "numerically_checked",
            "claim_spans": [{"source_id": "paper-00000000000000000001", "locator": "p. 4, equation 2"}],
            "source_checked": True,
            "source_hashes": {"paper-00000000000000000001": "sha256:" + "d" * 64},
            "formula_hash": entry["formula_hash"],
            "numerical_check": True,
        }],
    }))

    result = check_registry(registry_path)

    assert not result.ok
    assert any("stale source binding" in error for error in result.errors)


def test_draft_claims_do_not_advertise_as_reviewed():
    library = _binding()
    library["mappings"][0]["claim_state"] = "unreviewed"
    library["mappings"][0].pop("formula_hash")
    library["mappings"][0].pop("source_hashes")
    library["mappings"][0]["claim_spans"] = []
    library["mappings"][0]["source_checked"] = False

    assert validate_catalog_bindings(library, _registry()) == []
