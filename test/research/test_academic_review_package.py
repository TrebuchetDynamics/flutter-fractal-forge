import hashlib
import json

import pytest

from scripts.research.academic.review_package import validate_review_package, validate_review_package_files


def _package():
    return {
        "schema_version": 1,
        "pilot": {"identity_count": 1, "paper_count": 1},
        "reviewed_alias_source": {"path": "research/academic/identity-aliases.json", "reviewed_alias_count": 0},
        "family_gaps": [{"family": "Number Walls", "status": "accepted_planned_not_implemented"}],
        "decision_boundary": {
            "identity_approval": "pending for every identity; all identity_approval actors blank",
            "screening": "pending for every paper; all screening actors blank",
            "acquisition": "pending for every paper; all acquisition actors blank",
            "mathematical_claims": "unreviewed for every paper and mapping; no accepted claim",
            "full_text_acquired": False,
            "next_gate": "ACAD-03 remains human-gated; this shortlist grants no inclusion or acquisition permission",
        },
        "papers": [{
            "paper_id": "paper-a",
            "retained_pilot_record_id": "paper-a",
            "retained_record_ref": "research/academic/runs/ACAD-02-pilot-20260603/results-deduped.jsonl#1",
            "title": "Pilot source",
            "authors": ["A. Author"],
            "year": 2020,
            "doi": "10.1234/x",
            "exact_version": "published journal version",
            "source_url": "https://doi.org/10.1234/x",
            "relevance_rationale": "pilot title describes the stated method",
            "rights_evidence": "license unknown in metadata; no permission inferred",
            "metadata_observations": [{
                "url": "https://api.crossref.org/works/10.1234/x",
                "retrieved_on": "2026-10-18",
                "version_evidence": "Crossref DOI metadata",
                "facts": {
                    "title": "Pilot source",
                    "authors": ["A. Author"],
                    "year": 2020,
                    "exact_version": "published journal version",
                    "rights_evidence": "license unknown in metadata; no permission inferred",
                },
            }],
            "recommendation": "consider_for_owner_review",
            "recommendation_note": "review the proposed identity association",
            "screening_decision": "pending",
            "screening_actor": None,
            "claim_state": "unreviewed",
            "accepted_claim": False,
            "acquired": False,
            "acquisition_decision": "pending",
            "acquisition_actor": None,
            "identity_approval": "pending",
        }],
        "identity_mappings": [{
            "identity_id": "core.newton_z3",
            "original_identity_label": "newton_z3",
            "original_label": "root finding / Newton cubic basin",
            "paper_ids": ["paper-a"],
            "mapping_status": "proposed_unreviewed",
            "mapping_evidence": "pilot title and abstract",
            "ambiguity": "Exact cubic formula match not established.",
            "approval": "pending",
            "approval_actor": None,
        }],
    }


def _validate(package, *, aliases=None, record_aliases=None):
    aliases = aliases or {}
    package["reviewed_alias_source"]["reviewed_alias_count"] = len(aliases)
    return validate_review_package(
        package,
        pilot_records=[{
            "paper_id": "paper-a",
            "title": "Pilot source",
            "aliases": record_aliases or ["doi:10.1234/x"],
            "source_paths": ["research/academic/runs/ACAD-02-pilot-20260603/results-deduped.jsonl#1"],
        }],
        identity_aliases={"reviewed_aliases": aliases},
        pilot_identity_ids={"core.newton_z3"},
        pilot_identity_labels={"core.newton_z3": ("newton_z3", "root finding / Newton cubic basin")},
    )


def test_review_package_accepts_explicit_unreviewed_proposal_with_empty_aliases():
    assert _validate(_package()) == []


def test_review_package_accepts_reused_reviewed_alias_as_distinct_from_approval():
    package = _package()
    package["identity_mappings"][0].update(mapping_status="reviewed_alias", paper_ids=["paper-a"])
    assert _validate(package, aliases={"core.newton_z3": "paper-a"}) == []


def test_review_package_accepts_explicit_unresolved_identity_gap():
    package = _package()
    package["identity_mappings"][0].update(
        mapping_status="unresolved",
        paper_ids=[],
        mapping_evidence="No specific pilot record supports this identity.",
        ambiguity="Family coverage remains open.",
    )
    assert _validate(package) == []


def test_review_package_rejects_ambiguous_proposal_without_retaining_ambiguity():
    package = _package()
    package["identity_mappings"][0]["ambiguity"] = ""
    assert any("ambiguity" in error for error in _validate(package))


def test_review_package_rejects_false_approval_flags():
    package = _package()
    paper = package["papers"][0]
    paper["screening_decision"] = "included"
    paper["identity_approval"] = "approved"
    paper["acquisition_decision"] = "approved"
    paper["acquired"] = True
    paper["accepted_claim"] = True
    paper["recommendation"] = "approved; acquire now"
    errors = _validate(package)
    assert any("screening_decision" in error for error in errors)
    assert any("identity_approval" in error for error in errors)
    assert any("acquisition_decision" in error for error in errors)
    assert any("acquired" in error for error in errors)
    assert any("claim" in error for error in errors)
    assert any("recommendation" in error for error in errors)


@pytest.mark.parametrize("arxiv_id", ["2109.03765", "9999.99999"])
def test_review_package_checks_arxiv_id_even_with_a_retained_doi(arxiv_id):
    package = _package()
    package["papers"][0].update(doi="10.48550/arxiv.2109.03765", arxiv_id=arxiv_id)
    errors = _validate(package, record_aliases=["doi:10.48550/arxiv.2109.03765"])
    if arxiv_id == "2109.03765":
        assert errors == []
    else:
        assert any("arXiv ID" in error for error in errors)


@pytest.mark.parametrize("claim_field,value", [("claim_state", "source_checked"), ("accepted_claim", True)])
def test_review_package_rejects_mapping_claim_promotion(claim_field, value):
    package = _package()
    package["identity_mappings"][0][claim_field] = value
    assert any("mapping claim" in error for error in _validate(package))


@pytest.mark.parametrize("change", ["unrelated_identity", "selected_shader", "raw_input"])
def test_file_validation_hashes_only_selected_inventory_without_weakening_originals(tmp_path, change):
    run = "research/academic/runs/ACAD-02-pilot-20260603/"
    paths = [run + name for name in ("results.jsonl", "results-deduped.jsonl", "review-queue.csv", "owner-review.csv")]
    paths.append("research/academic/identity-aliases.json")
    package = _package()
    package["input_hashes"] = {}
    for path in paths:
        target = tmp_path / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text('{"reviewed_aliases": {}}' if path.endswith("identity-aliases.json") else "original input\n")
        package["input_hashes"][path] = "sha256:" + hashlib.sha256(target.read_bytes()).hexdigest()
    inventory = {
        "quality_pilot": {"entries": [{"id": "core.newton_z3", "family_group": "root finding / Newton cubic basin"}]},
        "rows": [{"id": "core.newton_z3", "source_id": "newton_z3", "shader": "newton.frag"}],
    }
    snapshot = json.dumps(inventory, ensure_ascii=False, sort_keys=True, separators=(",", ":")).encode()
    package["input_hashes"]["docs/planning/visual-audit-inventory.json#academic-pilot"] = "sha256:" + hashlib.sha256(snapshot).hexdigest()
    inventory_path = tmp_path / "docs/planning/visual-audit-inventory.json"
    inventory_path.parent.mkdir(parents=True)
    inventory_path.write_text(json.dumps(inventory))
    package_path = tmp_path / "research/academic/reviews/ACAD-02-pilot-approval.json"
    package_path.parent.mkdir(parents=True)
    package_path.write_text(json.dumps(package))
    (tmp_path / "research/academic/papers.jsonl").write_text(json.dumps({
        "paper_id": "paper-a", "title": "Pilot source", "aliases": ["doi:10.1234/x"],
        "source_paths": [run + "results-deduped.jsonl#1"],
    }) + "\n")
    assert validate_review_package_files(tmp_path) == []

    if change == "unrelated_identity":
        inventory["rows"].append({"id": "core.unrelated", "source_id": "unrelated"})
        inventory["counts"] = {"explore_core": 2}
    elif change == "selected_shader":
        inventory["rows"][0]["shader"] = "changed.frag"
    else:
        (tmp_path / paths[0]).write_text("changed input\n")
    inventory_path.write_text(json.dumps(inventory))
    errors = validate_review_package_files(tmp_path)
    if change == "unrelated_identity":
        assert errors == []
    else:
        assert any("input hash mismatch" in error for error in errors)


def test_review_package_rejects_paper_outside_retained_pilot():
    package = _package()
    package["papers"][0]["retained_pilot_record_id"] = "paper-not-in-pilot"
    assert any("pilot" in error for error in _validate(package))
