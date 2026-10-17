"""Generated namespace-aware identity coverage; names never imply identity."""
from __future__ import annotations

from typing import Any, Iterable


def build_coverage(
    namespaces: dict[str, Iterable[dict[str, Any]]],
    *,
    reviewed_aliases: dict[str, str] | None = None,
    papers: list[dict[str, Any]] | None = None,
) -> dict[str, Any]:
    reviewed_aliases = reviewed_aliases or {}
    papers_by_id = {paper["paper_id"]: paper for paper in (papers or []) if paper.get("paper_id")}
    rows = []
    for namespace, identities in namespaces.items():
        for item in identities:
            identity = item["id"]
            paper_id = reviewed_aliases.get(identity)
            paper = papers_by_id.get(paper_id)
            content_state = paper.get("content_state", "metadata_only") if paper else None
            rows.append({
                "namespace": namespace,
                "identity": identity,
                "name": item.get("name", ""),
                "paper_ids": [paper_id] if paper else [],
                "status": content_state or "gap",
                "alias_review": "reviewed" if paper else "unresolved",
            })
    rows.sort(key=lambda row: (row["namespace"], row["identity"]))
    keys = [(row["namespace"], row["identity"]) for row in rows]
    if len(keys) != len(set(keys)):
        raise ValueError("duplicate identity within namespace")
    return {
        "schema_version": 1,
        "namespaces": sorted(namespaces),
        "counts": {namespace: sum(row["namespace"] == namespace for row in rows) for namespace in sorted(namespaces)},
        "rows": rows,
    }


def validate_coverage(coverage: dict[str, Any]) -> list[str]:
    errors = []
    if coverage.get("schema_version") != 1:
        errors.append("unsupported coverage schema_version")
    rows = coverage.get("rows", [])
    keys = [(row.get("namespace"), row.get("identity")) for row in rows]
    if len(keys) != len(set(keys)):
        errors.append("duplicate coverage identity")
    for row in rows:
        if not row.get("namespace") or not row.get("identity"):
            errors.append("malformed coverage row")
        if row.get("status") not in {"gap", "metadata_only", "access_pending", "full_text_available", "unavailable"}:
            errors.append(f"unsupported coverage status: {row.get('identity')}")
        if row.get("status") == "gap" and row.get("paper_ids"):
            errors.append(f"gap row unexpectedly has papers: {row.get('identity')}")
        if row.get("alias_review") != "reviewed" and row.get("paper_ids"):
            errors.append(f"unreviewed alias resolved: {row.get('identity')}")
    return errors
