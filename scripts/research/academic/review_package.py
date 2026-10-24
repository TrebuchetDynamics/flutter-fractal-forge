"""Validation for the bounded, metadata-only academic owner review package."""
from __future__ import annotations

import hashlib
import json
from pathlib import Path
from typing import Any
from urllib.parse import urlparse

RUN_PREFIX = "research/academic/runs/ACAD-02-pilot-20260603/"
INPUT_PATHS = (
    "research/academic/runs/ACAD-02-pilot-20260603/results.jsonl",
    "research/academic/runs/ACAD-02-pilot-20260603/results-deduped.jsonl",
    "research/academic/runs/ACAD-02-pilot-20260603/review-queue.csv",
    "research/academic/runs/ACAD-02-pilot-20260603/owner-review.csv",
    "research/academic/identity-aliases.json",
)
PILOT_INPUT_KEY = "docs/planning/visual-audit-inventory.json#academic-pilot"


def _sha256(path: Path) -> str:
    return "sha256:" + hashlib.sha256(path.read_bytes()).hexdigest()


def validate_review_package(
    package: dict[str, Any],
    *,
    pilot_records: list[dict[str, Any]],
    identity_aliases: dict[str, Any],
    pilot_identity_ids: set[str],
    pilot_identity_labels: dict[str, tuple[str, str]] | None = None,
    expected_input_hashes: dict[str, str] | None = None,
) -> list[str]:
    errors: list[str] = []
    if package.get("schema_version") != 1:
        errors.append("unsupported schema_version")
    papers = package.get("papers", [])
    mappings = package.get("identity_mappings", [])
    if not isinstance(papers, list) or not isinstance(mappings, list):
        return ["papers and identity_mappings must be lists"]
    if len(papers) > 12 or len(mappings) > 12:
        errors.append("review package exceeds 12-paper or 12-identity cap")
    paper_ids = [p.get("paper_id") for p in papers if isinstance(p, dict)]
    if len(paper_ids) != len(set(paper_ids)):
        errors.append("duplicate paper_id")
    identity_ids = [m.get("identity_id") for m in mappings if isinstance(m, dict)]
    if len(identity_ids) != len(set(identity_ids)):
        errors.append("duplicate identity_id")
    if set(identity_ids) != pilot_identity_ids:
        errors.append("identity mapping set does not exactly match the selected actual pilot")
    if package.get("pilot", {}).get("identity_count") != len(identity_ids):
        errors.append("declared pilot identity_count does not match mapping set")
    if package.get("pilot", {}).get("paper_count") != len(papers):
        errors.append("declared pilot paper_count does not match paper set")

    pilot_by_id = {
        record.get("paper_id"): record
        for record in pilot_records
        if isinstance(record, dict) and record.get("paper_id")
    }
    paper_id_set = set(paper_ids)
    for paper in papers:
        if not isinstance(paper, dict):
            errors.append("malformed paper row")
            continue
        pid = paper.get("paper_id")
        retained_id = paper.get("retained_pilot_record_id")
        record = pilot_by_id.get(retained_id)
        if not record or pid != retained_id:
            errors.append(f"{pid}: not bound to a retained pilot record")
        elif not any(path.startswith(RUN_PREFIX) for path in record.get("source_paths", [])):
            errors.append(f"{pid}: retained record has no ACAD-02 pilot source path")
        if record and paper.get("retained_record_ref") not in record.get("source_paths", []):
            errors.append(f"{pid}: retained_record_ref is not an exact source path")
        if record and paper.get("title") != record.get("title"):
            errors.append(f"{pid}: title differs from retained pilot record")
        for field in ("title", "authors", "year", "exact_version", "relevance_rationale", "rights_evidence"):
            if not paper.get(field):
                errors.append(f"{pid}: missing {field}")
        doi, arxiv = paper.get("doi"), paper.get("arxiv_id")
        if not doi and not arxiv:
            errors.append(f"{pid}: missing stable identifier")
        elif record and doi and "doi:" + doi.lower() not in record.get("aliases", []):
            errors.append(f"{pid}: DOI does not match retained record")
        if record and arxiv:
            arxiv_aliases = {"arxiv:" + arxiv.lower(), "doi:10.48550/arxiv." + arxiv.lower()}
            if not arxiv_aliases.intersection(record.get("aliases", [])):
                errors.append(f"{pid}: arXiv ID does not match retained record")
        source_url = urlparse(str(paper.get("source_url", "")))
        if source_url.scheme != "https" or not source_url.netloc:
            errors.append(f"{pid}: missing stable HTTPS source_url")
        observations = paper.get("metadata_observations", [])
        if not observations:
            errors.append(f"{pid}: missing metadata observations")
        expected_facts = {key: paper.get(key) for key in ("title", "authors", "year", "exact_version", "rights_evidence")}
        has_verified_facts = False
        for obs in observations:
            parsed = urlparse(str(obs.get("url", "")))
            if parsed.scheme != "https" or not parsed.netloc or not obs.get("retrieved_on") or not obs.get("version_evidence"):
                errors.append(f"{pid}: metadata observation missing HTTPS URL/retrieval/version evidence")
            if obs.get("facts") == expected_facts:
                has_verified_facts = True
        if not has_verified_facts:
            errors.append(f"{pid}: no source observation substantiates title/authors/year/version/rights facts")
        if paper.get("recommendation") not in {"consider_for_owner_review", "hold_for_owner_review", "consider_supplementary_context_only"}:
            errors.append(f"{pid}: unsupported recommendation value")
        if paper.get("screening_decision") != "pending" or paper.get("screening_actor") is not None:
            errors.append(f"{pid}: screening_decision/actor must remain pending/blank")
        if paper.get("identity_approval") != "pending":
            errors.append(f"{pid}: identity_approval must remain pending")
        if paper.get("acquisition_decision") != "pending" or paper.get("acquisition_actor") is not None:
            errors.append(f"{pid}: acquisition_decision/actor must remain pending/blank")
        if paper.get("claim_state") != "unreviewed" or paper.get("accepted_claim") is not False:
            errors.append(f"{pid}: claim must remain unreviewed and unaccepted")
        if paper.get("acquired") is not False:
            errors.append(f"{pid}: metadata-only package cannot mark content acquired")

    aliases = identity_aliases.get("reviewed_aliases", {})
    alias_source = package.get("reviewed_alias_source", {})
    if alias_source.get("path") != "research/academic/identity-aliases.json":
        errors.append("reviewed alias source path is not canonical")
    if alias_source.get("reviewed_alias_count") != len(aliases):
        errors.append("reviewed alias count does not match unchanged source")
    for mapping in mappings:
        if not isinstance(mapping, dict):
            errors.append("malformed identity mapping")
            continue
        identity = mapping.get("identity_id")
        status = mapping.get("mapping_status")
        ids = mapping.get("paper_ids", [])
        if identity not in pilot_identity_ids:
            errors.append(f"{identity}: identity is not in the selected actual pilot")
        if not mapping.get("original_label") or not mapping.get("original_identity_label"):
            errors.append(f"{identity}: missing original identity/family label")
        if pilot_identity_labels is not None and identity in pilot_identity_labels:
            original_identity, original_label = pilot_identity_labels[identity]
            if (mapping.get("original_identity_label"), mapping.get("original_label")) != (original_identity, original_label):
                errors.append(f"{identity}: original label differs from selected pilot")
        if mapping.get("approval") != "pending" or mapping.get("approval_actor") is not None:
            errors.append(f"{identity}: identity approval/actor must remain pending/blank")
        if mapping.get("claim_state", "unreviewed") != "unreviewed" or mapping.get("accepted_claim", False) is not False:
            errors.append(f"{identity}: mapping claim must remain unreviewed and unaccepted")
        if any(pid not in paper_id_set for pid in ids):
            errors.append(f"{identity}: mapping references a paper outside the shortlist")
        if not set(ids).issubset(paper_id_set):
            errors.append(f"{identity}: mapping references unknown paper IDs")
        if status == "reviewed_alias":
            if len(ids) != 1 or aliases.get(identity) != ids[0]:
                errors.append(f"{identity}: reviewed mapping does not match current reviewed aliases")
        elif status == "proposed_unreviewed":
            if identity in aliases:
                errors.append(f"{identity}: reviewed alias must be represented as reviewed_alias")
            if not ids or not mapping.get("mapping_evidence"):
                errors.append(f"{identity}: proposed mapping missing paper/evidence")
            if not mapping.get("ambiguity"):
                errors.append(f"{identity}: proposed mapping must retain ambiguity/limits")
        elif status == "unresolved":
            if ids:
                errors.append(f"{identity}: unresolved mapping cannot bind papers")
            if not mapping.get("ambiguity"):
                errors.append(f"{identity}: unresolved mapping must state the gap")
        else:
            errors.append(f"{identity}: unsupported mapping_status")

    boundaries = package.get("decision_boundary", {})
    required_boundary = {
        "identity_approval": "pending for every identity; all identity_approval actors blank",
        "screening": "pending for every paper; all screening actors blank",
        "acquisition": "pending for every paper; all acquisition actors blank",
        "mathematical_claims": "unreviewed for every paper and mapping; no accepted claim",
        "full_text_acquired": False,
        "next_gate": "ACAD-03 remains human-gated; this shortlist grants no inclusion or acquisition permission",
    }
    if boundaries != required_boundary:
        errors.append("decision_boundary must preserve all pending human gates")
    gaps = package.get("family_gaps", [])
    if not any(gap.get("family") == "Number Walls" and gap.get("status") == "accepted_planned_not_implemented" for gap in gaps):
        errors.append("Number Walls must remain planned, not implemented")
    if expected_input_hashes is not None:
        recorded = package.get("input_hashes", {})
        for path, digest in expected_input_hashes.items():
            if recorded.get(path) != digest:
                errors.append(f"input hash mismatch: {path}")
        if set(recorded) != set(expected_input_hashes):
            errors.append("input hash path set does not match required originals")
    return errors


def validate_review_package_files(repo_root: Path | str) -> list[str]:
    root = Path(repo_root)
    package_path = root / "research/academic/reviews/ACAD-02-pilot-approval.json"
    package = json.loads(package_path.read_text(encoding="utf-8"))
    aliases = json.loads((root / "research/academic/identity-aliases.json").read_text(encoding="utf-8"))
    inventory = json.loads((root / "docs/planning/visual-audit-inventory.json").read_text(encoding="utf-8"))
    papers_path = root / "research/academic/papers.jsonl"
    records = [json.loads(line) for line in papers_path.read_text(encoding="utf-8").splitlines() if line.strip()]
    pilot_records = [
        record for record in records
        if any(path.startswith(RUN_PREFIX) for path in record.get("source_paths", []))
    ]
    pilot_entries = inventory["quality_pilot"]["entries"]
    identity_ids = {entry["id"] for entry in pilot_entries}
    inventory_rows = {row["id"]: row for row in inventory["rows"]}
    identity_labels = {
        entry["id"]: (inventory_rows.get(entry["id"], {}).get("source_id", ""), entry.get("family_group", ""))
        for entry in pilot_entries
    }
    hashes = {path: _sha256(root / path) for path in INPUT_PATHS}
    # The live catalog grows independently. Bind the complete pilot and its
    # selected rows, not unrelated catalog identities/counts or JSON formatting.
    pilot_input = {
        "quality_pilot": inventory["quality_pilot"],
        "rows": sorted(
            (row for row in inventory["rows"] if row["id"] in identity_ids),
            key=lambda row: row["id"],
        ),
    }
    pilot_bytes = json.dumps(pilot_input, ensure_ascii=False, sort_keys=True, separators=(",", ":")).encode("utf-8")
    hashes[PILOT_INPUT_KEY] = "sha256:" + hashlib.sha256(pilot_bytes).hexdigest()
    return validate_review_package(
        package,
        pilot_records=pilot_records,
        identity_aliases=aliases,
        pilot_identity_ids=identity_ids,
        pilot_identity_labels=identity_labels,
        expected_input_hashes=hashes,
    )


def main() -> int:
    import argparse

    parser = argparse.ArgumentParser(description="Validate the metadata-only academic pilot review package")
    parser.add_argument("--repo-root", type=Path, default=Path.cwd())
    args = parser.parse_args()
    errors = validate_review_package_files(args.repo_root)
    if errors:
        print("\n".join(errors))
        return 1
    print("academic review package: valid")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
