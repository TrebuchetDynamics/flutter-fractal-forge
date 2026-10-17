#!/usr/bin/env python3
"""Fractal research pipeline CLI.

Subcommands are registered in SUBCOMMANDS. Each dispatches to a function
taking argparse.Namespace and returning an int exit code.
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path
from typing import Callable

REPO_ROOT = Path(__file__).resolve().parents[2]


def _cmd_doctor(args: argparse.Namespace) -> int:
    from scripts.research.doctor.check_registry import run_doctor
    return run_doctor(
        REPO_ROOT,
        verbose=args.verbose,
        include_app_catalog=args.app_catalog,
        strict_app_catalog=args.strict_app_catalog,
    )


def _cmd_retrofit(args: argparse.Namespace) -> int:
    from scripts.research.migrate.retrofit_registry import run_retrofit
    return run_retrofit(REPO_ROOT, dry_run=args.dry_run)


def _cmd_seed_aliases(args: argparse.Namespace) -> int:
    from scripts.research.migrate.seed_aliases import run_seed_aliases
    registry_path = REPO_ROOT / "docs" / "catalog" / "fractal_registry.yaml"
    seed_path = REPO_ROOT / "research" / "seeds" / "canonical_aliases.seed.yaml"
    output_path = REPO_ROOT / "research" / "canonical" / "canonical_aliases.yaml"
    return run_seed_aliases(registry_path, seed_path if seed_path.exists() else None, output_path)


def _cmd_batch(args: argparse.Namespace) -> int:
    from scripts.research.review.build_batch import run_build_batch
    return run_build_batch(REPO_ROOT, batch_id=args.batch_id, limit=args.limit)


def _cmd_review(args: argparse.Namespace) -> int:
    from scripts.research.review.review_batch import run_review
    return run_review(REPO_ROOT, batch_id=args.batch_id, auto_approve_new=args.auto_approve_new)


def _cmd_admit(args: argparse.Namespace) -> int:
    from scripts.research.admit.promote_candidate import run_admit
    return run_admit(REPO_ROOT, batch_id=args.batch_id)


def _cmd_academic_check(_args: argparse.Namespace) -> int:
    import json
    from jsonschema import Draft202012Validator
    from scripts.research.academic.coverage import build_coverage, validate_coverage
    from scripts.research.academic.library import find_title_collisions, import_run, validate_library
    from ruamel.yaml import YAML

    academic_dir = REPO_ROOT / "research" / "academic"
    papers_path = academic_dir / "papers.jsonl"
    import_run(REPO_ROOT / "research", papers_path, source_base=REPO_ROOT)
    papers = [json.loads(line) for line in papers_path.read_text(encoding="utf-8").splitlines() if line.strip()]
    mappings_path = academic_dir / "mappings.json"
    mappings = json.loads(mappings_path.read_text(encoding="utf-8")) if mappings_path.exists() else {"schema_version": 1, "mappings": []}
    library = {"schema_version": 1, "papers": papers, "mappings": mappings.get("mappings", [])}

    yaml = YAML(typ="safe")
    registry = yaml.load((REPO_ROOT / "docs/catalog/fractal_registry.yaml").read_text(encoding="utf-8"))["fractals"]
    inventory = json.loads((REPO_ROOT / "docs/planning/visual-audit-inventory.json").read_text(encoding="utf-8"))
    manifest = json.loads((REPO_ROOT / "research/fractals-library/data/fractal_manifest.json").read_text(encoding="utf-8"))
    app_names = {row["id"]: row.get("name", "") for row in inventory.get("rows", [])}
    namespaces = {
        "app": [{"id": identity, "name": app_names.get(identity, "")} for group in inventory["explore_ids_by_group"].values() for identity in group],
        "registry": [{"id": row["id"], "name": row.get("name", "")} for row in registry],
        "reference": [{"id": row["id"], "name": row.get("name", "")} for row in manifest],
        "planned": [{"id": "core.number_wall", "name": "Number Walls"}],
    }
    aliases_path = academic_dir / "identity-aliases.json"
    aliases_data = json.loads(aliases_path.read_text(encoding="utf-8"))
    reviewed_aliases = aliases_data.get("reviewed_aliases", {})
    coverage = build_coverage(namespaces, reviewed_aliases=reviewed_aliases, papers=papers)
    (academic_dir / "coverage.json").write_text(json.dumps(coverage, ensure_ascii=False, sort_keys=True, indent=2) + "\n", encoding="utf-8")
    (academic_dir / "identity-review.json").write_text(json.dumps({"schema_version": 1, "title_collisions": find_title_collisions(papers)}, ensure_ascii=False, sort_keys=True, indent=2) + "\n", encoding="utf-8")
    errors = validate_library(library, repo_root=REPO_ROOT) + validate_coverage(coverage)
    if mappings.get("schema_version") != 1 or not isinstance(mappings.get("mappings"), list):
        errors.append("malformed mapping index schema")
    schema_paths = {
        "paper": academic_dir / "papers.schema.json",
        "mapping": academic_dir / "mapping.schema.json",
        "coverage": academic_dir / "coverage.schema.json",
        "identity aliases": academic_dir / "identity-aliases.schema.json",
    }
    schema_documents = {name: json.loads(path.read_text(encoding="utf-8")) for name, path in schema_paths.items()}
    for index, paper in enumerate(papers):
        errors.extend(f"paper {index}: {error.message}" for error in Draft202012Validator(schema_documents["paper"]).iter_errors(paper))
    for index, mapping in enumerate(mappings.get("mappings", [])):
        errors.extend(f"mapping {index}: {error.message}" for error in Draft202012Validator(schema_documents["mapping"]).iter_errors(mapping))
    errors.extend(f"coverage: {error.message}" for error in Draft202012Validator(schema_documents["coverage"]).iter_errors(coverage))
    errors.extend(f"identity aliases: {error.message}" for error in Draft202012Validator(schema_documents["identity aliases"]).iter_errors(aliases_data))
    if aliases_data.get("schema_version") != 1:
        errors.append("unsupported identity alias schema_version")
    paper_ids = {paper["paper_id"] for paper in papers}
    if any(paper_id not in paper_ids for paper_id in reviewed_aliases.values()):
        errors.append("identity alias references missing paper")
    if errors:
        print("academic-check: FAIL")
        for error in errors:
            print(f"  - {error}")
        return 1
    print(f"academic-check: OK — {len(papers)} sources; {len(coverage['rows'])} identity rows across {len(namespaces)} namespaces")
    return 0


SUBCOMMANDS: dict[str, tuple[str, Callable[[argparse.Namespace], int]]] = {
    "doctor": ("Verify registry invariants", _cmd_doctor),
    "retrofit": ("Migrate registry to pipeline schema (adds formula_hash, quality, tier)", _cmd_retrofit),
    "seed-aliases": ("Generate canonical_aliases.yaml from registry + seed", _cmd_seed_aliases),
    "batch": ("Build a candidates batch from extracted/", _cmd_batch),
    "review": ("Review a candidates batch", _cmd_review),
    "admit": ("Promote approved candidates to registry + emit Dart", _cmd_admit),
    "academic-check": ("Import historical metadata and validate academic coverage", _cmd_academic_check),
}


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="forge",
        description="Fractal research pipeline CLI.",
    )
    sub = parser.add_subparsers(dest="command", required=True)

    for name, (help_text, _) in SUBCOMMANDS.items():
        sp = sub.add_parser(name, help=help_text)
        if name == "doctor":
            sp.add_argument("-v", "--verbose", action="store_true")
            sp.add_argument(
                "--app-catalog",
                action="store_true",
                help="also audit app-facing shader paths and declarations as warnings",
            )
            sp.add_argument(
                "--strict-app-catalog",
                action="store_true",
                help="fail when app-facing shader path/declaration drift is found",
            )
        if name == "retrofit":
            sp.add_argument("--dry-run", action="store_true",
                            help="Show what would change without writing")
        if name == "batch":
            sp.add_argument("--batch-id", default=None, dest="batch_id")
            sp.add_argument("--limit", type=int, default=500)
        if name == "review":
            sp.add_argument("batch_id")
            sp.add_argument("--auto-approve-new", action="store_true", dest="auto_approve_new")
        if name == "admit":
            sp.add_argument("batch_id")
    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    _help, handler = SUBCOMMANDS[args.command]
    return handler(args)


if __name__ == "__main__":
    sys.path.insert(0, str(REPO_ROOT))
    sys.exit(main())
