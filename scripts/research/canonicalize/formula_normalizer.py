"""Canonicalize formula_ast dicts into a deterministic string, then hash.

Strategy:
 1. Parse the `update` and `init` expressions with sympy.
 2. Alpha-rename free symbols to v0, v1, v2, ... in order of first occurrence.
 3. Canonicalize via sympy.srepr (sorts commutative args, strips whitespace).
 4. Emit a tuple (iteration_type, canonical_init, canonical_update), JSON-dump, SHA-256.
"""
from __future__ import annotations

import hashlib
import json
from typing import Any

import sympy as sp


def _parse(expr: str):
    """Parse a math expression like 'z = z**2 + c' into a sympy Expr.
    If it contains '=', take the RHS. Return None on empty, raise on unparseable."""
    if not expr or not expr.strip():
        return None
    if "=" in expr:
        _, expr = expr.split("=", 1)
    expr = expr.strip()
    if not expr:
        return None
    try:
        return sp.sympify(expr, evaluate=True)
    except (sp.SympifyError, SyntaxError, TypeError):
        return None


def _alpha_rename(expr, mapping: dict[str, sp.Symbol]):
    if expr is None or not hasattr(expr, "free_symbols"):
        return expr
    symbols = sorted(expr.free_symbols, key=lambda s: s.name)
    for s in symbols:
        if s.name not in mapping:
            mapping[s.name] = sp.Symbol(f"v{len(mapping)}")
    return expr.xreplace({s: mapping[s.name] for s in symbols})


def normalize(ast: dict[str, Any]) -> str:
    """Return a deterministic canonical string for this formula_ast."""
    update_raw = ast.get("update", "") or ""
    init_raw = ast.get("init", "") or ""
    iteration_type = ast.get("iteration_type", "other")

    mapping: dict[str, sp.Symbol] = {}
    try:
        update = _alpha_rename(_parse(update_raw), mapping)
    except Exception:
        update = None
    try:
        init = _alpha_rename(_parse(init_raw), mapping)
    except Exception:
        init = None

    update_repr = sp.srepr(update) if update is not None else f"raw:{update_raw}"
    init_repr = sp.srepr(init) if init is not None else f"raw:{init_raw}"

    tup = (iteration_type, init_repr, update_repr)
    return json.dumps(tup, sort_keys=True, separators=(",", ":"))


def hash_ast(ast: dict[str, Any]) -> str:
    """Return 'sha256:<hex>' for this formula_ast. Stable across equivalent formulas."""
    normal = normalize(ast).encode("utf-8")
    return "sha256:" + hashlib.sha256(normal).hexdigest()
