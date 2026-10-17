"""Offline import and validation for the shared academic evidence index."""
from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path
from typing import Any

CLAIM_STATES = {"unreviewed", "source_checked", "implementation_compared", "numerically_checked", "contradicted"}
CONTENT_STATES = {"metadata_only", "access_pending", "full_text_available", "unavailable"}
SHA256_RE = re.compile(r"^sha256:[0-9a-f]{64}$")


def _canonical(value: Any) -> str:
    return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":"))


def _doi(value: str) -> str:
    value = value.strip().lower()
    value = re.sub(r"^https?://(dx\.)?doi\.org/", "", value)
    return value.removeprefix("doi:").strip()


def _arxiv(value: str) -> str:
    value = value.strip().lower()
    value = re.sub(r"^(https?://)?(www\.)?arxiv\.org/(abs|pdf)/", "", value)
    value = re.sub(r"\.pdf$", "", value)
    return re.sub(r"v\d+$", "", value)


def _normalized_record(record: dict[str, Any]) -> dict[str, Any]:
    identifiers = record.get("Identifiers", {}) if isinstance(record.get("Identifiers"), dict) else {}
    urls = record.get("URLs", [])
    if isinstance(urls, str):
        urls = [urls]
    return {
        **record,
        "title": record.get("title") or record.get("Title"),
        "doi": record.get("doi") or identifiers.get("DOI"),
        "arxiv_id": record.get("arxiv_id") or record.get("arxiv") or identifiers.get("ArXivID"),
        "authors": record.get("authors") or record.get("Authors", []),
        "year": record.get("year") or record.get("Year"),
        "url": record.get("url") or (urls[0] if urls else None),
    }


def _aliases(record: dict[str, Any]) -> list[str]:
    record = _normalized_record(record)
    aliases = []
    doi = record.get("doi")
    arxiv = record.get("arxiv_id") or record.get("arxiv")
    if isinstance(doi, str) and doi.strip():
        aliases.append("doi:" + _doi(doi))
    if isinstance(arxiv, str) and arxiv.strip():
        aliases.append("arxiv:" + _arxiv(arxiv))
    return sorted(set(aliases))


def _paper(record: dict[str, Any], source_path: str) -> dict[str, Any]:
    record = _normalized_record(record)
    aliases = _aliases(record)
    title = str(record.get("title") or "").strip()
    if not title:
        raise ValueError(f"missing title in {source_path}")
    # Without a stable identifier, preserve each occurrence for explicit duplicate review.
    identity_material = next((alias for alias in aliases if alias.startswith("doi:")), None) or next(
        (alias for alias in aliases if alias.startswith("arxiv:")), source_path
    )
    paper_id = "paper-" + hashlib.sha256(identity_material.encode()).hexdigest()[:20]
    authors = record.get("authors", record.get("author", []))
    if isinstance(authors, str):
        authors = [authors]
    kind_hint = str(record.get("source_kind") or record.get("kind") or record.get("type") or "paper").lower()
    source_kind = "video" if "video" in kind_hint or "youtube" in kind_hint else "code" if any(term in kind_hint for term in ("software", "code", "github")) else "book" if "book" in kind_hint else "paper"
    return {
        "paper_id": paper_id,
        "title": title,
        "authors": sorted(set(str(author).strip() for author in authors if str(author).strip())),
        "year": record.get("year"),
        "source_kind": source_kind,
        "aliases": aliases,
        "source_urls": sorted(set(filter(None, [record.get("url"), record.get("doi_url")]))),
        "source_paths": [source_path],
        "content_state": "metadata_only",
        "claim_state": "unreviewed",
        "rights": {"status": "unknown", "declared_license": record.get("License") or record.get("license")},
        "record_hash": "sha256:" + hashlib.sha256(_canonical(record).encode()).hexdigest(),
        "source_hash": None,
    }


def import_run(
    run_path: Path | str,
    index_path: Path | str,
    source_base: Path | str | None = None,
) -> int:
    """Merge a frozen ResearchForge-style run into a canonical, stable JSONL index."""
    run_path, index_path = Path(run_path), Path(index_path)
    source_base = Path(source_base).resolve() if source_base is not None else None
    inputs = [run_path] if run_path.is_file() else sorted(run_path.rglob("results*.jsonl"))
    papers: dict[str, dict[str, Any]] = {}
    if index_path.exists():
        for line_number, line in enumerate(index_path.read_text(encoding="utf-8").splitlines(), 1):
            if not line.strip():
                continue
            item = json.loads(line)
            papers[item["paper_id"]] = item
    imported = 0
    for input_path in inputs:
        for line_number, line in enumerate(input_path.read_text(encoding="utf-8").splitlines(), 1):
            if not line.strip():
                continue
            display_path = input_path.resolve().relative_to(source_base).as_posix() if source_base else input_path.as_posix()
            source_path = display_path + f"#{line_number}"
            item = _paper(json.loads(line), source_path)
            incoming_dois = {alias for alias in item["aliases"] if alias.startswith("doi:")}
            incoming_arxiv = {alias for alias in item["aliases"] if alias.startswith("arxiv:")}
            matches = []
            for existing_id, existing in papers.items():
                existing_aliases = set(existing.get("aliases", []))
                existing_dois = {alias for alias in existing_aliases if alias.startswith("doi:")}
                existing_arxiv = {alias for alias in existing_aliases if alias.startswith("arxiv:")}
                # Cross-linking a preprint and published DOI is not evidence that their
                # versions have identical equations; only same-kind identifiers merge.
                if incoming_dois and existing_dois and incoming_dois & existing_dois:
                    matches.append(existing_id)
                elif not incoming_dois and not existing_dois and incoming_arxiv & existing_arxiv:
                    matches.append(existing_id)
            matches.sort()
            paper_id = matches[0] if matches else item["paper_id"]
            if paper_id in papers:
                current = papers[paper_id]
                current["aliases"] = sorted(set(current.get("aliases", [])) | set(item["aliases"]))
                current["source_paths"] = sorted(set(current.get("source_paths", [])) | {source_path})
                current["source_urls"] = sorted(set(current.get("source_urls", [])) | set(item["source_urls"]))
            else:
                item["paper_id"] = paper_id
                papers[paper_id] = item
            imported += 1
    index_path.parent.mkdir(parents=True, exist_ok=True)
    data = "".join(_canonical(papers[paper_id]) + "\n" for paper_id in sorted(papers))
    index_path.write_text(data, encoding="utf-8")
    return imported


def validate_catalog_bindings(
    library: dict[str, Any],
    registry_entries: list[dict[str, Any]],
) -> list[str]:
    """Validate reviewed academic claims against current source and catalog metadata.

    Draft and unreviewed mappings remain ingestible, but only source-checked claims
    with exact source spans, a reviewed full-text source hash, and a matching
    catalog formula may carry a reviewed qualification.
    """
    errors: list[str] = []
    papers = {
        paper.get("paper_id"): paper
        for paper in library.get("papers", [])
        if isinstance(paper, dict) and paper.get("paper_id")
    }
    entries = {entry.get("id"): entry for entry in registry_entries if entry.get("id")}
    verified_states = {"source_checked", "implementation_compared", "numerically_checked"}
    for mapping in library.get("mappings", []):
        identity = mapping.get("identity", "<unknown>")
        state = mapping.get("claim_state", "unreviewed")
        if state not in verified_states:
            continue
        entry = entries.get(identity)
        if entry is None:
            errors.append(f"{identity}: reviewed claim has no catalog identity")
            continue
        source_ids = mapping.get("source_ids", [])
        spans = mapping.get("claim_spans", [])
        if not source_ids:
            errors.append(f"{identity}: missing source for reviewed claim")
        if not spans or any(not span.get("source_id") or not span.get("locator") for span in spans):
            errors.append(f"{identity}: claim span missing or malformed")
        elif any(span.get("source_id") not in source_ids for span in spans):
            errors.append(f"{identity}: claim span references unbound source")
        catalog_references = entry.get("references", [])
        reference_values = {
            str(value).strip().lower()
            for reference in catalog_references
            if isinstance(reference, dict)
            for value in (reference.get("url"), reference.get("doi"))
            if value
        }
        for source_id in source_ids:
            paper = papers.get(source_id)
            if paper is None:
                errors.append(f"{identity}: missing source: {source_id}")
                continue
            paper_values = {
                str(value).strip().lower()
                for value in [*paper.get("source_urls", []), *paper.get("aliases", [])]
                if value
            }
            if not paper_values.intersection(reference_values):
                errors.append(f"{identity}: source missing from catalog references: {source_id}")
            if paper.get("claim_state", "unreviewed") not in verified_states:
                errors.append(f"{identity}: unreviewed source: {source_id}")
            if paper.get("content_state", "metadata_only") != "full_text_available":
                errors.append(f"{identity}: source text unavailable: {source_id}")
            source_hash = paper.get("source_hash")
            bound_hash = (mapping.get("source_hashes") or {}).get(source_id)
            if not isinstance(source_hash, str) or not SHA256_RE.fullmatch(source_hash) or bound_hash != source_hash:
                errors.append(f"{identity}: stale source binding: {source_id}")
        if not mapping.get("source_checked"):
            errors.append(f"{identity}: reviewed claim missing source check")
        if mapping.get("formula_hash") != entry.get("formula_hash"):
            errors.append(f"{identity}: formula binding mismatch")
        if state == "numerically_checked" and not mapping.get("numerical_check"):
            errors.append(f"{identity}: numerical claim missing numerical check")
    return errors


def find_title_collisions(papers: list[dict[str, Any]]) -> list[dict[str, Any]]:
    """Return review suggestions only; matching titles never merge records."""
    by_title: dict[str, list[dict[str, Any]]] = {}
    for paper in papers:
        title_key = " ".join(str(paper.get("title", "")).casefold().split())
        if title_key:
            by_title.setdefault(title_key, []).append(paper)
    collisions = []
    for title_key, candidates in sorted(by_title.items()):
        if len(candidates) > 1:
            collisions.append({
                "normalized_title": title_key,
                "paper_ids": sorted(paper["paper_id"] for paper in candidates),
                "status": "review_pending",
            })
    return collisions


def validate_library(
    library: dict[str, Any],
    repo_root: Path | None = None,
) -> list[str]:
    errors: list[str] = []
    if library.get("schema_version") != 1:
        errors.append("unsupported library schema_version")
    papers = library.get("papers", [])
    paper_ids = {paper.get("paper_id") for paper in papers if isinstance(paper, dict)}
    for paper in papers:
        if not isinstance(paper, dict) or not paper.get("paper_id") or not paper.get("title"):
            errors.append("malformed paper record")
            continue
        if paper.get("content_state", "metadata_only") not in CONTENT_STATES:
            errors.append(f"unsupported content state: {paper.get('paper_id')}")
        if paper.get("source_kind", "paper") not in {"paper", "book", "code", "video"}:
            errors.append(f"unsupported source kind: {paper['paper_id']}")
        if paper.get("claim_state", "unreviewed") not in CLAIM_STATES:
            errors.append(f"unsupported paper claim state: {paper['paper_id']}")
        rights = paper.get("rights", {})
        if rights.get("status") not in {"unknown", "metadata_only", "open_access", "permission_granted", "restricted"}:
            errors.append(f"unsupported rights status: {paper['paper_id']}")
        if rights.get("status") in {"open_access", "permission_granted"} and not rights.get("basis"):
            errors.append(f"rights basis missing: {paper['paper_id']}")
        for hash_name in ("source_hash", "record_hash"):
            digest = paper.get(hash_name)
            if digest and (not isinstance(digest, str) or not SHA256_RE.fullmatch(digest)):
                errors.append(f"malformed {hash_name}: {paper['paper_id']}")
    for mapping in library.get("mappings", []):
        identity = mapping.get("identity", "<unknown>")
        state = mapping.get("claim_state", "unreviewed")
        if state not in CLAIM_STATES:
            errors.append(f"unsupported claim state: {identity}")
        for source_id in mapping.get("source_ids", []):
            if source_id not in paper_ids:
                errors.append(f"missing source: {identity}: {source_id}")
        if state in {"source_checked", "implementation_compared", "numerically_checked", "contradicted"}:
            spans = mapping.get("claim_spans", [])
            if not spans or any(not span.get("source_id") or not span.get("locator") for span in spans):
                errors.append(f"claim span missing or malformed: {identity}")
            elif any(span["source_id"] not in mapping.get("source_ids", []) or span["source_id"] not in paper_ids for span in spans):
                errors.append(f"claim span references missing source: {identity}")
            if not mapping.get("source_checked"):
                errors.append(f"unsupported claim upgrade without source check: {identity}")
        if state in {"implementation_compared", "numerically_checked"}:
            binding = mapping.get("implementation", {})
            digest = binding.get("sha256")
            observed = mapping.get("observed_sha256")
            if not binding.get("path") or not isinstance(digest, str) or not SHA256_RE.fullmatch(digest):
                errors.append(f"malformed implementation binding: {identity}")
            elif digest != observed:
                errors.append(f"stale implementation binding: {identity}")
            elif repo_root is not None:
                bound_path = (repo_root / binding["path"]).resolve()
                if not bound_path.is_relative_to(repo_root.resolve()) or not bound_path.is_file():
                    errors.append(f"stale implementation binding: {identity}")
                elif "sha256:" + hashlib.sha256(bound_path.read_bytes()).hexdigest() != digest:
                    errors.append(f"stale implementation binding: {identity}")
        if state == "numerically_checked" and not mapping.get("numerical_check"):
            errors.append(f"unsupported claim upgrade without numerical check: {identity}")
        for file_name in mapping.get("public_files", []):
            suffix = Path(file_name).suffix.lower()
            if suffix in {".pdf", ".txt", ".html"}:
                errors.append(f"illegal public file: {identity}: {file_name}")
    return errors
