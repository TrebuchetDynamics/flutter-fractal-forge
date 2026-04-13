"""Tests for scripts.research.admit.emit_dart."""
from __future__ import annotations

from pathlib import Path

import pytest
import yaml

from scripts.research.admit.emit_dart import build_context, emit

FIXTURE_DIR = Path(__file__).parent / "fixtures" / "sample_candidates"


def _load_candidate(name: str) -> dict:
    with (FIXTURE_DIR / name).open() as f:
        return yaml.safe_load(f)


def _registry_entry_for(candidate: dict) -> dict:
    """Synthesize a minimal registry entry from the candidate for testing."""
    name = candidate["proposed_name"]
    slug = (
        name.lower()
        .replace(" ", "_")
        .replace("'", "")
        .replace("-", "_")
    )
    id_ = "f_test_" + slug
    params = candidate.get("params") or {}

    def _d(key, fallback):
        spec = params.get(key)
        if isinstance(spec, dict) and "default" in spec:
            return spec["default"]
        return fallback

    return {
        "id": id_,
        "name": name,
        "category": "Test Category",
        "family": None,
        "aliases": candidate.get("aliases") or [],
        "shader": f"shaders/{id_}_gpu.frag",
        "defaultPower": float(_d("power", 2.0)),
        "defaultBailout": float(_d("bailout", 2.0)),
        "defaultIterations": int(_d("iterations", 500)),
        "defaultSteps": int(_d("steps", 120)),
    }


_CASES = [
    ("f_sample_mandelbrot.yaml", "escape_time"),
    ("f_sample_burning_ship.yaml", "escape_time"),
    ("f_sample_mandelbulb.yaml", "raymarch_3d"),
    ("f_sample_lorenz.yaml", "strange_attractor"),
    ("f_sample_sierpinski.yaml", "ifs"),
    ("f_sample_koch.yaml", "l_system"),
]


@pytest.mark.parametrize("fixture,iter_type", _CASES)
def test_emit_produces_5_files_per_candidate(tmp_path, fixture, iter_type):
    cand = _load_candidate(fixture)
    reg = _registry_entry_for(cand)
    files = emit(cand, reg, iter_type, tmp_path)
    assert len(files) == 5
    for f in files:
        assert f.exists(), f"{f} not written"
        assert f.stat().st_size > 0, f"{f} is empty"


@pytest.mark.parametrize("fixture,iter_type", _CASES)
def test_emit_files_have_expected_names(tmp_path, fixture, iter_type):
    cand = _load_candidate(fixture)
    reg = _registry_entry_for(cand)
    id_ = reg["id"]
    files = emit(cand, reg, iter_type, tmp_path)
    names = {f.name for f in files}
    assert f"{id_}_module.dart" in names
    assert f"{id_}_presets.dart" in names
    assert f"{id_}_variants.dart" in names
    assert f"{id_}_metadata.dart" in names
    assert f"{id_}_module_test.dart" in names


def test_emit_module_dart_contains_class_name(tmp_path):
    cand = _load_candidate("f_sample_mandelbrot.yaml")
    reg = _registry_entry_for(cand)
    reg["id"] = "f001_mandelbrot"
    reg["shader"] = "shaders/f001_mandelbrot_gpu.frag"
    files = emit(cand, reg, "escape_time", tmp_path)
    module_file = next(f for f in files if f.name == "f001_mandelbrot_module.dart")
    content = module_file.read_text()
    assert "class F001Mandelbrot extends EscapeTimeModule" in content
    assert "GENERATED" in content
    assert "shaders/f001_mandelbrot_gpu.frag" in content


def test_emit_presets_dart_contains_preset_entries(tmp_path):
    cand = _load_candidate("f_sample_mandelbrot.yaml")
    reg = _registry_entry_for(cand)
    reg["id"] = "f001_mandelbrot"
    files = emit(cand, reg, "escape_time", tmp_path)
    presets_file = next(f for f in files if f.name == "f001_mandelbrot_presets.dart")
    content = presets_file.read_text()
    assert "F001MandelbrotPreset" in content
    # lowerCamelCase accessor comes from 'seahorse_valley' (Dart constant naming)
    assert "seahorseValley" in content
    assert "'seahorse_valley'" in content


def test_emit_metadata_dart_has_references_and_aliases(tmp_path):
    cand = _load_candidate("f_sample_mandelbrot.yaml")
    reg = _registry_entry_for(cand)
    reg["id"] = "f001_mandelbrot"
    files = emit(cand, reg, "escape_time", tmp_path)
    metadata_file = next(f for f in files if f.name == "f001_mandelbrot_metadata.dart")
    content = metadata_file.read_text()
    assert "F001MandelbrotMetadata" in content
    assert "Benoit Mandelbrot" in content
    assert "'M-set'" in content


def test_emit_raymarch_module_has_raymarch_base(tmp_path):
    cand = _load_candidate("f_sample_mandelbulb.yaml")
    reg = _registry_entry_for(cand)
    reg["id"] = "f003_mandelbulb"
    files = emit(cand, reg, "raymarch_3d", tmp_path)
    module_file = next(f for f in files if f.name == "f003_mandelbulb_module.dart")
    content = module_file.read_text()
    assert "extends Raymarched3DModule" in content
    assert "raymarch_3d_module_base" in content


def test_emit_unsupported_iteration_type_raises(tmp_path):
    cand = _load_candidate("f_sample_mandelbrot.yaml")
    reg = _registry_entry_for(cand)
    with pytest.raises(ValueError):
        emit(cand, reg, "reaction_diffusion", tmp_path)


def test_emit_module_hits_loc_target_range(tmp_path):
    """§14 target: 60-120 LOC per module file. Allow 20-150 per plan."""
    cand = _load_candidate("f_sample_mandelbrot.yaml")
    reg = _registry_entry_for(cand)
    reg["id"] = "f001_mandelbrot"
    files = emit(cand, reg, "escape_time", tmp_path)
    module_file = next(f for f in files if f.name.endswith("_module.dart"))
    loc = len([l for l in module_file.read_text().splitlines() if l.strip()])
    assert 20 <= loc <= 150, f"module LOC {loc} outside range"


def test_build_context_deep_zoom_flag(tmp_path):
    cand = _load_candidate("f_sample_mandelbrot.yaml")
    reg = _registry_entry_for(cand)
    ctx_escape = build_context(cand, reg, "escape_time")
    assert ctx_escape["deep_zoom_capable"] is True
    ctx_ray = build_context(cand, reg, "raymarch_3d")
    assert ctx_ray["deep_zoom_capable"] is False


def test_output_directory_layout(tmp_path):
    cand = _load_candidate("f_sample_lorenz.yaml")
    reg = _registry_entry_for(cand)
    reg["id"] = "f004_lorenz"
    reg["category"] = "Strange Attractor"
    files = emit(cand, reg, "strange_attractor", tmp_path)
    module_file = next(f for f in files if f.name == "f004_lorenz_module.dart")
    assert module_file.parts[-6:-1] == (
        "lib",
        "core",
        "modules",
        "strange_attractor",
        "f004_lorenz",
    )
    test_file = next(f for f in files if f.name.endswith("_module_test.dart"))
    assert test_file.parts[-4:] == (
        "test",
        "modules",
        "f004_lorenz",
        "f004_lorenz_module_test.dart",
    )
