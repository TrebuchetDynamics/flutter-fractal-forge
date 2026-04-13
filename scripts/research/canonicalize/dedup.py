"""Three-stage dedup pipeline: formula hash → name fuzzy → family classifier.

Given a candidate and the existing registry + alias table, decides whether to
admit as new, auto-merge (formula hash match), or flag for human review (fuzzy
name match or family match).
"""
from __future__ import annotations

from dataclasses import dataclass
from typing import Any

from rapidfuzz import fuzz, process

from scripts.research.canonicalize.formula_normalizer import hash_ast
from scripts.research.canonicalize.taxonomy_classifier import classify


@dataclass
class DedupResult:
    action: str  # one of: new, auto_merge, review_fuzzy, review_family
    merge_into: str | None = None      # registry id to merge into (auto_merge only)
    suggested_id: str | None = None     # registry id suggested for review (review_*)
    reason: str = ""


def dedup(
    candidate: dict[str, Any],
    existing: list[dict[str, Any]],
    aliases: dict[str, dict[str, Any]],
) -> DedupResult:
    """Classify a candidate against existing registry + alias table.

    Args:
        candidate: Extracted candidate dict (must have formula_ast, proposed_name)
        existing: List of registry entry dicts (must have id, formula_hash; name/family optional)
        aliases: canonical_aliases.yaml structure — {id: {canonical_name, aliases, family}}

    Returns: DedupResult with action and details.
    """
    # Stage 1: formula hash exact match
    c_hash = hash_ast(candidate["formula_ast"])
    for e in existing:
        if e.get("formula_hash") == c_hash:
            return DedupResult(
                action="auto_merge",
                merge_into=e["id"],
                reason=f"formula_hash match: {c_hash[:16]}...",
            )

    # Stage 2: name/alias fuzzy match
    if aliases:
        all_aliases: list[tuple[str, str]] = []  # (alias_string, registry_id)
        for eid, info in aliases.items():
            for a in info.get("aliases", []):
                all_aliases.append((a, eid))

        if all_aliases:
            choices = [a[0] for a in all_aliases]
            best = process.extractOne(
                candidate["proposed_name"],
                choices,
                scorer=fuzz.token_set_ratio,
            )
            if best and best[1] >= 85:
                eid = all_aliases[best[2]][1]
                return DedupResult(
                    action="review_fuzzy",
                    suggested_id=eid,
                    reason=f"fuzzy name match {best[1]}% against '{best[0]}'",
                )

    # Stage 3: family classifier
    family = classify(candidate["formula_ast"]).get("family")
    if family:
        same_family = [e for e in existing if e.get("family") == family]
        if same_family:
            return DedupResult(
                action="review_family",
                suggested_id=same_family[0]["id"],
                reason=f"same family '{family}' as {same_family[0]['id']}",
            )

    # Default: new
    return DedupResult(action="new", reason="no match across 3 stages")
