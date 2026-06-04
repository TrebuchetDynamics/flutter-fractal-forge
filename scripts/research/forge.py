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


SUBCOMMANDS: dict[str, tuple[str, Callable[[argparse.Namespace], int]]] = {
    "doctor": ("Verify registry invariants", _cmd_doctor),
    "retrofit": ("Migrate registry to pipeline schema (adds formula_hash, quality, tier)", _cmd_retrofit),
    "seed-aliases": ("Generate canonical_aliases.yaml from registry + seed", _cmd_seed_aliases),
    "batch": ("Build a candidates batch from extracted/", _cmd_batch),
    "review": ("Review a candidates batch", _cmd_review),
    "admit": ("Promote approved candidates to registry + emit Dart", _cmd_admit),
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
