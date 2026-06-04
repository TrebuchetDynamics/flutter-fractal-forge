from pathlib import Path

from ruamel.yaml import YAML

from scripts.research.doctor.app_catalog_audit import audit_app_catalog


def _write_project(root: Path, *, missing: bool = False) -> None:
    (root / "docs" / "catalog").mkdir(parents=True)
    (root / "lib" / "core" / "modules" / "builders").mkdir(parents=True)
    (root / "shaders").mkdir()

    present_shader = "shaders/present.frag"
    missing_shader = "shaders/missing.frag"
    if not missing:
        (root / present_shader).write_text("void main() {}\n")
    else:
        (root / present_shader).write_text("void main() {}\n")

    shader_for_checks = missing_shader if missing else present_shader

    yaml = YAML()
    with (root / "pubspec.yaml").open("w") as f:
        yaml.dump({"flutter": {"shaders": [shader_for_checks]}}, f)

    (root / "lib" / "core" / "modules" / "builders" / "escape_time_catalog.dart").write_text(
        f"""
final catalog = [
  EscapeTimeConfig(
    id: 'example',
    name: 'Example',
    shaderAsset: '{shader_for_checks}',
  ),
];
"""
    )

    with (root / "docs" / "catalog" / "fractal_registry.yaml").open("w") as f:
        yaml.dump(
            {
                "fractals": [
                    {
                        "id": "example",
                        "name": "Example",
                        "shader": shader_for_checks,
                        "implemented": True,
                    }
                ]
            },
            f,
        )


def test_app_catalog_audit_passes_when_app_paths_exist(tmp_path):
    _write_project(tmp_path)

    result = audit_app_catalog(tmp_path, strict=True)

    assert result.ok
    assert result.issues == []
    assert result.stats["pubspec_shaders"] == 1
    assert result.stats["escape_time_shader_assets"] == 1
    assert result.stats["implemented_registry_shader_paths"] == 1


def test_app_catalog_audit_reports_each_app_path_source(tmp_path):
    _write_project(tmp_path, missing=True)

    result = audit_app_catalog(tmp_path)

    assert result.ok, "non-strict audit should preserve current doctor compatibility"
    warnings = "\n".join(result.warnings)
    assert "pubspec shader declarations missing files" in warnings
    assert "escape-time catalog shaderAsset values missing files" in warnings
    assert "implemented registry shader paths missing files" in warnings
    assert "shaders/missing.frag" in warnings


def test_app_catalog_audit_can_fail_strictly(tmp_path):
    _write_project(tmp_path, missing=True)

    result = audit_app_catalog(tmp_path, strict=True)

    assert not result.ok
    assert len(result.issues) == 3
