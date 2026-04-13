"""Interactive (and --auto-approve-new) review of a candidate batch.

Reads candidates from research/candidates/{batch_id}/, runs dedup against the
registry, prompts reviewer, writes research/decisions/{batch_id}.yaml.
"""
from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

from ruamel.yaml import YAML

from scripts.research.canonicalize.dedup import dedup, DedupResult
from scripts.research.lib.registry import Registry


def _yaml() -> YAML:
    y = YAML()
    y.preserve_quotes = True
    y.indent(mapping=2, sequence=4, offset=2)
    return y


@dataclass
class ReviewResult:
    batch_id: str
    decisions: dict[str, dict] = field(default_factory=dict)


def _load_aliases(path: Path) -> dict:
    if not path.exists():
        return {}
    with path.open() as f:
        return _yaml().load(f) or {}


def _load_candidate(path: Path) -> dict:
    with path.open() as f:
        return _yaml().load(f)


def review_batch(
    batch_path: Path,
    registry: Registry,
    aliases: dict,
    auto_approve_new: bool = False,
    interactive_input=None,
) -> ReviewResult:
    """Process a batch. Returns ReviewResult with per-candidate decisions.

    interactive_input: callable taking a prompt and returning a string response.
    If None and not auto_approve_new, raises RuntimeError.
    """
    result = ReviewResult(batch_id=batch_path.name)

    candidate_files = sorted(batch_path.glob("ct_*.yaml"))
    for cf in candidate_files:
        candidate = _load_candidate(cf)
        if candidate is None:
            continue
        cid = candidate.get("candidate_id", cf.stem)
        verdict = dedup(candidate, registry.entries, aliases)

        if verdict.action == "new":
            result.decisions[cid] = {"action": "approve_new", "reason": verdict.reason}
        elif verdict.action == "auto_merge":
            result.decisions[cid] = {
                "action": "approve_merge",
                "merge_into": verdict.merge_into,
                "reason": verdict.reason,
            }
        else:
            # review_fuzzy or review_family
            if auto_approve_new:
                result.decisions[cid] = {
                    "action": "approve_new",
                    "reason": f"auto-approved despite {verdict.action}: {verdict.reason}",
                    "suggested_merge": verdict.suggested_id,
                }
            else:
                if interactive_input is None:
                    raise RuntimeError(f"interactive review required for {cid}, no input handler")
                answer = interactive_input(
                    f"{cid} ({candidate.get('proposed_name')}): {verdict.action} against {verdict.suggested_id}. [a]pprove new / [m]erge / [r]eject: "
                )
                if answer.lower().startswith("m"):
                    result.decisions[cid] = {"action": "approve_merge", "merge_into": verdict.suggested_id}
                elif answer.lower().startswith("r"):
                    result.decisions[cid] = {"action": "reject", "reason": verdict.reason}
                else:
                    result.decisions[cid] = {"action": "approve_new", "reason": verdict.reason}

    return result


def write_decisions(result: ReviewResult, decisions_dir: Path) -> Path:
    decisions_dir.mkdir(parents=True, exist_ok=True)
    path = decisions_dir / f"{result.batch_id}.yaml"
    with path.open("w") as f:
        _yaml().dump({"batch_id": result.batch_id, "decisions": result.decisions}, f)
    return path


def run_review(
    repo_root: Path,
    batch_id: str,
    auto_approve_new: bool = False,
) -> int:
    batch_path = repo_root / "research" / "candidates" / batch_id
    if not batch_path.exists():
        print(f"review: batch {batch_id} not found at {batch_path}")
        return 1

    registry = Registry.load(repo_root / "docs" / "catalog" / "fractal_registry.yaml")
    aliases = _load_aliases(repo_root / "research" / "canonical" / "canonical_aliases.yaml")

    result = review_batch(batch_path, registry, aliases, auto_approve_new=auto_approve_new,
                          interactive_input=input if not auto_approve_new else None)
    path = write_decisions(result, repo_root / "research" / "decisions")
    print(f"review: OK - {len(result.decisions)} decisions written to {path}")
    return 0
