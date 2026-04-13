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
    return run_doctor(REPO_ROOT, verbose=args.verbose)


def _cmd_retrofit(args: argparse.Namespace) -> int:
    from scripts.research.migrate.retrofit_registry import run_retrofit
    return run_retrofit(REPO_ROOT, dry_run=args.dry_run)


SUBCOMMANDS: dict[str, tuple[str, Callable[[argparse.Namespace], int]]] = {
    "doctor": ("Verify registry invariants", _cmd_doctor),
    "retrofit": ("Migrate registry to pipeline schema (adds formula_hash, quality, tier)", _cmd_retrofit),
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
        if name == "retrofit":
            sp.add_argument("--dry-run", action="store_true",
                            help="Show what would change without writing")
    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    _help, handler = SUBCOMMANDS[args.command]
    return handler(args)


if __name__ == "__main__":
    sys.path.insert(0, str(REPO_ROOT))
    sys.exit(main())
