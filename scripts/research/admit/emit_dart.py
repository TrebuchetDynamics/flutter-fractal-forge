"""Emit rich Dart code per §14 from a candidate + registry entry.

Renders 5 files per admitted fractal:
  - lib/core/modules/<category_slug>/<id>/<id>_module.dart
  - lib/core/modules/<category_slug>/<id>/<id>_presets.dart
  - lib/core/modules/<category_slug>/<id>/<id>_variants.dart
  - lib/core/modules/<category_slug>/<id>/<id>_metadata.dart
  - test/modules/<id>/<id>_module_test.dart

Dispatch to a per-iteration_type module template; presets/variants/metadata/test
templates are shared.
"""
from __future__ import annotations

import re
from pathlib import Path
from typing import Any

from jinja2 import Environment, FileSystemLoader, select_autoescape

TEMPLATE_DIR = Path(__file__).parent / "templates" / "dart"

_ITERATION_TYPE_TO_MODULE_TEMPLATE: dict[str, str] = {
    "escape_time": "escape_time_module.j2",
    "raymarch_3d": "raymarch_3d_module.j2",
    "strange_attractor": "attractor_module.j2",
    "ifs": "ifs_module.j2",
    "l_system": "l_system_module.j2",
    "cellular": "cellular_module.j2",
    # Newton fractals are escape-time at the rendering level (iterate a complex
    # function until convergence-to-root or max iterations). Reuse the
    # escape_time Dart template + base class.
    "newton": "escape_time_module.j2",
    # Lyapunov fractals are rendered as 2D colour maps over (r_a, r_b) space;
    # use the escape_time template with custom preset-baked parameters.
    "lyapunov": "escape_time_module.j2",
    # Tilings use IFS-like recursive placement.
    "tiling": "ifs_module.j2",
}

_ITERATION_TYPE_TO_BASE_CLASS_FILE: dict[str, str] = {
    "escape_time": "escape_time_module_base",
    "raymarch_3d": "raymarch_3d_module_base",
    "strange_attractor": "attractor_module_base",
    "ifs": "ifs_module_base",
    "l_system": "l_system_module_base",
    "cellular": "cellular_module_base",
    "newton": "escape_time_module_base",
    "lyapunov": "escape_time_module_base",
    "tiling": "ifs_module_base",
}


def _camel(s: str) -> str:
    """Convert snake_case / kebab-case / arbitrary id to PascalCase."""
    tokens = re.split(r"[^0-9a-zA-Z]+", str(s))
    return "".join(t[:1].upper() + t[1:] for t in tokens if t)


_DART_RESERVED = {
    "abstract", "as", "assert", "async", "await", "break", "case", "catch",
    "class", "const", "continue", "covariant", "default", "deferred", "do",
    "dynamic", "else", "enum", "export", "extends", "extension", "external",
    "factory", "false", "final", "finally", "for", "Function", "get", "hide",
    "if", "implements", "import", "in", "interface", "is", "late", "library",
    "mixin", "new", "null", "on", "operator", "part", "required", "rethrow",
    "return", "set", "show", "static", "super", "switch", "sync", "this",
    "throw", "true", "try", "typedef", "var", "void", "while", "with", "yield",
}


def _lower_camel(s: str) -> str:
    """Convert to lowerCamelCase for Dart identifiers. Reserved words are suffixed."""
    pascal = _camel(s)
    ident = pascal[:1].lower() + pascal[1:] if pascal else pascal
    if ident in _DART_RESERVED:
        ident = f"{ident}_"
    return ident


def _slugify(cat: str) -> str:
    return re.sub(r"[^a-z0-9]+", "_", cat.lower()).strip("_") or "unknown"


def _class_name(id_: str) -> str:
    return _camel(id_)


def _env() -> Environment:
    env = Environment(
        loader=FileSystemLoader(str(TEMPLATE_DIR)),
        autoescape=select_autoescape(disabled_extensions=("j2",)),
        trim_blocks=True,
        lstrip_blocks=True,
        keep_trailing_newline=True,
    )
    env.filters["camel"] = _camel
    env.filters["lower_camel"] = _lower_camel
    env.filters["dart_str"] = _dart_str
    return env


def _dart_str(s: object) -> str:
    """Escape a value for use inside a single-quoted Dart string literal.

    Escapes backslashes, single quotes, $-interpolation markers, and newlines.
    Any non-string input is coerced via str().
    """
    text = "" if s is None else str(s)
    return (
        text.replace("\\", "\\\\")
        .replace("'", "\\'")
        .replace("$", "\\$")
        .replace("\n", "\\n")
        .replace("\r", "\\r")
    )


def _default_int(src: dict, key: str, fallback: int) -> int:
    val = src.get(key)
    if val is None:
        return fallback
    try:
        return int(val)
    except (TypeError, ValueError):
        return fallback


def _default_float(src: dict, key: str, fallback: float) -> float:
    val = src.get(key)
    if val is None:
        return fallback
    try:
        return float(val)
    except (TypeError, ValueError):
        return fallback


def build_context(
    candidate: dict[str, Any],
    registry_entry: dict[str, Any],
    iteration_type: str,
) -> dict[str, Any]:
    """Assemble render context merging candidate + registry fields."""
    id_ = registry_entry["id"]
    params = candidate.get("params", {}) or {}

    def _param_default(name: str, fallback: float | int) -> float | int:
        spec = params.get(name)
        if isinstance(spec, dict) and "default" in spec:
            return spec["default"]
        return fallback

    defaults = {
        "power": _default_float(
            registry_entry, "defaultPower", float(_param_default("power", 2.0))
        ),
        "bailout": _default_float(
            registry_entry, "defaultBailout", float(_param_default("bailout", 2.0))
        ),
        "iterations": _default_int(
            registry_entry,
            "defaultIterations",
            int(_param_default("iterations", 500)),
        ),
        "steps": _default_int(
            registry_entry, "defaultSteps", int(_param_default("steps", 120))
        ),
        "step_size": float(_param_default("step_size", 0.01)),
        "depth": int(_param_default("depth", 5)),
        "generations": int(_param_default("generations", 100)),
    }

    category = registry_entry.get("category") or "Unknown"
    return {
        "id": id_,
        "class_name": _class_name(id_),
        "name": registry_entry.get("name") or candidate.get("proposed_name") or id_,
        "category": category,
        "category_slug": _slugify(category),
        "family": registry_entry.get("family")
        or (candidate.get("formula_ast") or {}).get("family"),
        "aliases": registry_entry.get("aliases") or candidate.get("aliases") or [],
        "shader": registry_entry.get("shader") or f"shaders/{id_}_gpu.frag",
        "base_class_file": _ITERATION_TYPE_TO_BASE_CLASS_FILE.get(
            iteration_type, "module_base"
        ),
        "defaults": defaults,
        "presets": candidate.get("presets") or [],
        "variants": candidate.get("variants") or [],
        "references": candidate.get("references") or [],
        "deep_zoom_capable": iteration_type == "escape_time",
        "iteration_type": iteration_type,
    }


def emit(
    candidate: dict[str, Any],
    registry_entry: dict[str, Any],
    iteration_type: str,
    output_root: Path,
) -> list[Path]:
    """Render all Dart files for one admitted fractal.

    Returns the list of file paths written: 4 lib files + 1 test file.
    """
    if iteration_type not in _ITERATION_TYPE_TO_MODULE_TEMPLATE:
        raise ValueError(
            f"unsupported iteration_type for Dart emission: {iteration_type!r}"
        )

    env = _env()
    ctx = build_context(candidate, registry_entry, iteration_type)
    id_ = ctx["id"]
    category_slug = ctx["category_slug"]

    module_dir = (
        Path(output_root) / "lib" / "core" / "modules" / category_slug / id_
    )
    module_dir.mkdir(parents=True, exist_ok=True)

    module_template = _ITERATION_TYPE_TO_MODULE_TEMPLATE[iteration_type]

    lib_files: list[tuple[Path, str]] = [
        (module_dir / f"{id_}_module.dart", module_template),
        (module_dir / f"{id_}_presets.dart", "presets.j2"),
        (module_dir / f"{id_}_variants.dart", "variants.j2"),
        (module_dir / f"{id_}_metadata.dart", "metadata.j2"),
    ]

    written: list[Path] = []
    for path, template in lib_files:
        content = env.get_template(template).render(**ctx)
        path.write_text(content)
        written.append(path)

    test_dir = Path(output_root) / "test" / "modules" / id_
    test_dir.mkdir(parents=True, exist_ok=True)
    test_path = test_dir / f"{id_}_module_test.dart"
    test_path.write_text(env.get_template("module_test.j2").render(**ctx))
    written.append(test_path)

    return written
