#!/usr/bin/env python3
"""
Generate fractal_registry.yaml from Dart catalog files.

This script extracts fractal metadata and produces a YAML file suitable for
documentation or external tools.

Usage:
    python scripts/generate_fractal_registry.py
"""

import re
import sys
from pathlib import Path
from typing import Dict, List, Any, Optional
import yaml

REPO_ROOT = Path(__file__).parent.parent
ESCAPE_TIME_CATALOG = REPO_ROOT / "lib/core/modules/builders/escape_time_catalog.dart"
RAYMARCHED_3D_CATALOG = (
    REPO_ROOT / "lib/core/modules/builders/raymarched_3d_catalog.dart"
)
OUTPUT_YAML = REPO_ROOT / "docs/catalog/fractal_registry.yaml"
THUMBS_DIR = REPO_ROOT / "assets/catalog_thumbs"


def parse_dart_file(content: str) -> List[Dict[str, Any]]:
    configs = []
    pattern = r"EscapeTimeConfig\s*\("

    for match in re.finditer(pattern, content):
        start = match.start()
        depth = 0
        i = start
        while i < len(content):
            if content[i] == "(":
                depth += 1
            elif content[i] == ")":
                depth -= 1
                if depth == 0:
                    break
            i += 1

        block = content[start : i + 1]
        config = _parse_config(block)
        if config:
            configs.append(config)

    return configs


def _parse_config(block: str) -> Optional[Dict[str, Any]]:
    cfg = {
        "id": None,
        "name": None,
        "shaderAsset": None,
        "category": "Escape-Time",
        "defaultZoom": 1.0,
        "defaultCenterX": 0.0,
        "defaultCenterY": 0.0,
        "defaultIterations": 120,
        "defaultBailout": 4.0,
        "defaultColorScheme": 0,
        "extraPresets": [],
        "dimension": "2D",
    }

    id_match = re.search(r"id:\s*'([^']+)'", block)
    if id_match:
        cfg["id"] = id_match.group(1)

    name_match = re.search(r"name:\s*'([^']+)'", block)
    if name_match:
        cfg["name"] = name_match.group(1)

    shader_match = re.search(r"shaderAsset:\s*'([^']+)'", block)
    if shader_match:
        cfg["shaderAsset"] = shader_match.group(1)

    cat_match = re.search(r"category:\s*'([^']+)'", block)
    if cat_match:
        cfg["category"] = cat_match.group(1)

    zoom_match = re.search(r"defaultZoom:\s*([0-9.]+)", block)
    if zoom_match:
        cfg["defaultZoom"] = float(zoom_match.group(1))

    cx_match = re.search(r"defaultCenterX:\s*(-?[0-9.]+)", block)
    if cx_match:
        cfg["defaultCenterX"] = float(cx_match.group(1))

    cy_match = re.search(r"defaultCenterY:\s*(-?[0-9.]+)", block)
    if cy_match:
        cfg["defaultCenterY"] = float(cy_match.group(1))

    iter_match = re.search(r"defaultIterations:\s*([0-9]+)", block)
    if iter_match:
        cfg["defaultIterations"] = int(iter_match.group(1))

    bailout_match = re.search(r"defaultBailout:\s*([0-9.]+)", block)
    if bailout_match:
        cfg["defaultBailout"] = float(bailout_match.group(1))

    cs_match = re.search(r"defaultColorScheme:\s*([0-9]+)", block)
    if cs_match:
        cfg["defaultColorScheme"] = int(cs_match.group(1))

    cfg["extraPresets"] = _extract_presets(block)

    if not cfg["id"]:
        return None

    return cfg


def _extract_presets(block: str) -> List[Dict[str, Any]]:
    presets = []
    preset_pattern = r"FractalPreset\s*\("

    for preset_match in re.finditer(preset_pattern, block):
        start = preset_match.start()
        depth = 0
        i = start
        while i < len(block):
            if block[i] == "(":
                depth += 1
            elif block[i] == ")":
                depth -= 1
                if depth == 0:
                    break
            i += 1

        preset_block = block[start : i + 1]
        preset_id_match = re.search(r"id:\s*'([^']+)'", preset_block)
        if preset_id_match:
            presets.append({"id": preset_id_match.group(1)})

    return presets


def parse_3d_file(content: str) -> List[Dict[str, Any]]:
    configs = []
    pattern = r"Raymarched3DConfig\s*\("

    for match in re.finditer(pattern, content):
        start = match.start()
        depth = 0
        i = start
        while i < len(content):
            if content[i] == "(":
                depth += 1
            elif content[i] == ")":
                depth -= 1
                if depth == 0:
                    break
            i += 1

        block = content[start : i + 1]
        config = _parse_3d_config(block)
        if config:
            configs.append(config)

    return configs


def _parse_3d_config(block: str) -> Optional[Dict[str, Any]]:
    cfg = {
        "id": None,
        "name": None,
        "shaderAsset": None,
        "category": "3D Fractals",
        "defaultPower": 2.0,
        "defaultIterations": 50,
        "defaultSteps": 120,
        "defaultBailout": 4.0,
        "defaultColorScheme": 0,
        "extraPresets": [],
        "dimension": "3D",
    }

    id_match = re.search(r"id:\s*'([^']+)'", block)
    if id_match:
        cfg["id"] = id_match.group(1)

    name_match = re.search(r"name:\s*'([^']+)'", block)
    if name_match:
        cfg["name"] = name_match.group(1)

    shader_match = re.search(r"shaderAsset:\s*'([^']+)'", block)
    if shader_match:
        cfg["shaderAsset"] = shader_match.group(1)

    cat_match = re.search(r"category:\s*'([^']+)'", block)
    if cat_match:
        cfg["category"] = cat_match.group(1)

    power_match = re.search(r"defaultPower:\s*([0-9.]+)", block)
    if power_match:
        cfg["defaultPower"] = float(power_match.group(1))

    iter_match = re.search(r"defaultIterations:\s*([0-9.]+)", block)
    if iter_match:
        cfg["defaultIterations"] = float(iter_match.group(1))

    steps_match = re.search(r"defaultSteps:\s*([0-9.]+)", block)
    if steps_match:
        cfg["defaultSteps"] = float(steps_match.group(1))

    bailout_match = re.search(r"defaultBailout:\s*([0-9.]+)", block)
    if bailout_match:
        cfg["defaultBailout"] = float(bailout_match.group(1))

    cs_match = re.search(r"defaultColorScheme:\s*([0-9]+)", block)
    if cs_match:
        cfg["defaultColorScheme"] = int(cs_match.group(1))

    cfg["extraPresets"] = _extract_presets(block)

    if not cfg["id"]:
        return None

    return cfg


def get_thumbnails() -> set:
    if not THUMBS_DIR.exists():
        return set()
    return {f.stem for f in THUMBS_DIR.glob("*.png")}


def generate_registry():
    OUTPUT_YAML.parent.mkdir(parents=True, exist_ok=True)

    escape_content = ESCAPE_TIME_CATALOG.read_text()
    raymarched_content = RAYMARCHED_3D_CATALOG.read_text()

    escape_configs = parse_dart_file(escape_content)
    raymarched_configs = parse_3d_file(raymarched_content)

    thumbnails = get_thumbnails()

    all_fractals = []

    for cfg in escape_configs:
        fid = cfg["id"]
        fractal = {
            "id": fid,
            "name": cfg["name"],
            "shader": cfg["shaderAsset"],
            "category": cfg["category"],
            "dimension": cfg["dimension"],
            "defaultZoom": cfg["defaultZoom"],
            "defaultCenterX": cfg["defaultCenterX"],
            "defaultCenterY": cfg["defaultCenterY"],
            "defaultIterations": float(cfg["defaultIterations"]),
            "defaultBailout": cfg["defaultBailout"],
            "defaultColorScheme": cfg["defaultColorScheme"],
            "hasThumbnail": fid in thumbnails,
            "implemented": True,
            "presets": [p["id"] for p in cfg["extraPresets"]],
            "variants": [],
            "references": [],
        }
        all_fractals.append(fractal)

    for cfg in raymarched_configs:
        fid = cfg["id"]
        fractal = {
            "id": fid,
            "name": cfg["name"],
            "shader": cfg["shaderAsset"],
            "category": cfg["category"],
            "dimension": cfg["dimension"],
            "defaultPower": cfg["defaultPower"],
            "defaultIterations": cfg["defaultIterations"],
            "defaultSteps": cfg["defaultSteps"],
            "defaultBailout": cfg["defaultBailout"],
            "defaultColorScheme": cfg["defaultColorScheme"],
            "hasThumbnail": fid in thumbnails,
            "implemented": True,
            "presets": [p["id"] for p in cfg["extraPresets"]],
            "variants": [],
            "references": [],
        }
        all_fractals.append(fractal)

    all_fractals.sort(key=lambda f: (f["category"], f["name"]))

    registry = {"fractals": all_fractals}

    with open(OUTPUT_YAML, "w") as f:
        yaml.dump(
            registry, f, default_flow_style=False, sort_keys=False, allow_unicode=True
        )

    print(f"Generated {OUTPUT_YAML}")
    print(f"  Total fractals: {len(all_fractals)}")
    print(f"  - Escape-time: {len(escape_configs)}")
    print(f"  - 3D: {len(raymarched_configs)}")
    print(f"  - With thumbnails: {sum(1 for f in all_fractals if f['hasThumbnail'])}")


if __name__ == "__main__":
    generate_registry()
    sys.exit(0)
