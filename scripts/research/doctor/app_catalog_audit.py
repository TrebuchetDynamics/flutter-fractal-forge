"""App-facing catalog admission checks.

The registry doctor validates registry invariants. This module validates the
next seam: whether catalog entries that claim app implementation line up with
app-facing shader declarations and Dart catalog references.

The real repository currently has legacy drift, so callers can run this as a
warning-producing audit first and opt into strict failures once cleanup is done.
"""
from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
import re
from typing import Any

from ruamel.yaml import YAML

from scripts.research.lib.registry import Registry


@dataclass(frozen=True)
class AppCatalogAuditIssue:
    kind: str
    count: int
    examples: tuple[str, ...] = ()

    def format(self) -> str:
        sample = ""
        if self.examples:
            sample = ": " + ", ".join(self.examples)
        return f"{self.kind}: {self.count}{sample}"


@dataclass
class AppCatalogAuditResult:
    ok: bool
    issues: list[AppCatalogAuditIssue] = field(default_factory=list)
    stats: dict[str, int] = field(default_factory=dict)

    @property
    def warnings(self) -> list[str]:
        return [issue.format() for issue in self.issues]

    def format_summary(self) -> str:
        status = "OK" if self.ok else "FAIL"
        warning_count = sum(issue.count for issue in self.issues)
        return f"app catalog audit: {status} ({warning_count} warning item(s))"


def audit_app_catalog(repo_root: Path, *, strict: bool = False) -> AppCatalogAuditResult:
    """Audit app-facing catalog assets and declarations.

    Checks are intentionally mechanical and file-based:
    - `pubspec.yaml` shader declarations point at files that exist.
    - `EscapeTimeConfig.shaderAsset` paths point at files that exist.
    - `implemented: true` registry entries with `shader` paths point at files
      that exist.

    `strict=False` keeps the result OK while surfacing issues as warnings.
    `strict=True` turns any issue into a failing result for future CI gates.
    """
    repo_root = Path(repo_root)
    issues: list[AppCatalogAuditIssue] = []
    stats: dict[str, int] = {}

    pubspec_shaders = _load_pubspec_shaders(repo_root / "pubspec.yaml")
    stats["pubspec_shaders"] = len(pubspec_shaders)
    _append_missing_issue(
        issues,
        kind="pubspec shader declarations missing files",
        repo_root=repo_root,
        paths=pubspec_shaders,
    )

    escape_catalog_shaders = _extract_escape_time_shader_assets(
        repo_root / "lib" / "core" / "modules" / "builders" / "escape_time_catalog.dart"
    )
    stats["escape_time_shader_assets"] = len(escape_catalog_shaders)
    _append_missing_issue(
        issues,
        kind="escape-time catalog shaderAsset values missing files",
        repo_root=repo_root,
        paths=escape_catalog_shaders,
    )

    registry_shader_paths = _load_implemented_registry_shader_paths(
        repo_root / "docs" / "catalog" / "fractal_registry.yaml"
    )
    stats["implemented_registry_shader_paths"] = len(registry_shader_paths)
    _append_missing_issue(
        issues,
        kind="implemented registry shader paths missing files",
        repo_root=repo_root,
        paths=registry_shader_paths,
    )

    return AppCatalogAuditResult(
        ok=not strict or not issues,
        issues=issues,
        stats=stats,
    )


def _append_missing_issue(
    issues: list[AppCatalogAuditIssue],
    *,
    kind: str,
    repo_root: Path,
    paths: list[str],
) -> None:
    missing = [path for path in paths if not (repo_root / path).exists()]
    if not missing:
        return
    issues.append(
        AppCatalogAuditIssue(
            kind=kind,
            count=len(missing),
            examples=tuple(missing[:5]),
        )
    )


def _load_pubspec_shaders(path: Path) -> list[str]:
    if not path.exists():
        return []
    yaml = YAML(typ="safe")
    with path.open("r") as f:
        doc: Any = yaml.load(f) or {}
    flutter = doc.get("flutter") if isinstance(doc, dict) else None
    shaders = flutter.get("shaders") if isinstance(flutter, dict) else None
    if not isinstance(shaders, list):
        return []
    return [str(shader) for shader in shaders]


def _extract_escape_time_shader_assets(path: Path) -> list[str]:
    if not path.exists():
        return []
    text = path.read_text()
    return re.findall(r"shaderAsset:\s*'([^']+)'", text)


def _load_implemented_registry_shader_paths(path: Path) -> list[str]:
    if not path.exists():
        return []
    registry = Registry.load(path)
    return [
        str(entry["shader"])
        for entry in registry.entries
        if entry.get("implemented") and entry.get("shader")
    ]
