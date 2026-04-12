#!/usr/bin/env python3
"""
Audit script for Flutter Fractal Forge fractal catalog.

Parses escape_time_catalog.dart and raymarched_3d_catalog.dart to extract all
fractal entries, cross-references with thumbnail PNGs, and produces a YAML registry.

Usage:
    python scripts/audit_fractals.py
"""

import re
import os
import sys
from pathlib import Path
from typing import Dict, List, Optional, Tuple, Any
import yaml

# Paths relative to repository root
REPO_ROOT = Path(__file__).parent.parent
ESCAPE_TIME_CATALOG = REPO_ROOT / "lib/core/modules/builders/escape_time_catalog.dart"
RAYMARCHED_3D_CATALOG = (
    REPO_ROOT / "lib/core/modules/builders/raymarched_3d_catalog.dart"
)
THUMBS_DIR = REPO_ROOT / "assets/catalog_thumbs"
OUTPUT_YAML = REPO_ROOT / "docs/catalog/fractal_registry.yaml"


def parse_escape_time_configs(content: str) -> List[Dict[str, Any]]:
    """Parse all EscapeTimeConfig entries from Dart file content."""
    configs = []

    # Match EscapeTimeConfig blocks - capture from 'EscapeTimeConfig(' to matching ')'
    # We need to properly handle nested parentheses in FractalPreset blocks
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
        config = _parse_escape_time_block(block)
        if config:
            configs.append(config)

    return configs


def _parse_escape_time_block(block: str) -> Optional[Dict[str, Any]]:
    """Parse a single EscapeTimeConfig block."""
    config = {
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

    # Extract id
    id_match = re.search(r"id:\s*'([^']+)'", block)
    if id_match:
        config["id"] = id_match.group(1)

    # Extract name
    name_match = re.search(r"name:\s*'([^']+)'", block)
    if name_match:
        config["name"] = name_match.group(1)

    # Extract shaderAsset
    shader_match = re.search(r"shaderAsset:\s*'([^']+)'", block)
    if shader_match:
        config["shaderAsset"] = shader_match.group(1)

    # Extract category (if explicitly set)
    cat_match = re.search(r"category:\s*'([^']+)'", block)
    if cat_match:
        config["category"] = cat_match.group(1)

    # Extract defaultZoom
    zoom_match = re.search(r"defaultZoom:\s*([0-9.]+)", block)
    if zoom_match:
        config["defaultZoom"] = float(zoom_match.group(1))

    # Extract defaultCenterX
    cx_match = re.search(r"defaultCenterX:\s*(-?[0-9.]+)", block)
    if cx_match:
        config["defaultCenterX"] = float(cx_match.group(1))

    # Extract defaultCenterY
    cy_match = re.search(r"defaultCenterY:\s*(-?[0-9.]+)", block)
    if cy_match:
        config["defaultCenterY"] = float(cy_match.group(1))

    # Extract defaultIterations
    iter_match = re.search(r"defaultIterations:\s*([0-9]+)", block)
    if iter_match:
        config["defaultIterations"] = int(iter_match.group(1))

    # Extract defaultBailout
    bailout_match = re.search(r"defaultBailout:\s*([0-9.]+)", block)
    if bailout_match:
        config["defaultBailout"] = float(bailout_match.group(1))

    # Extract defaultColorScheme
    cs_match = re.search(r"defaultColorScheme:\s*([0-9]+)", block)
    if cs_match:
        config["defaultColorScheme"] = int(cs_match.group(1))

    # Extract presets
    presets = _parse_presets(block)
    config["extraPresets"] = presets

    if not config["id"]:
        return None

    return config


def _parse_presets(block: str) -> List[Dict[str, Any]]:
    """Parse FractalPreset blocks within a config."""
    presets = []

    # Find all FractalPreset blocks
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
        preset = _parse_preset_block(preset_block)
        if preset:
            presets.append(preset)

    return presets


def _parse_preset_block(block: str) -> Optional[Dict[str, Any]]:
    """Parse a single FractalPreset block."""
    preset = {
        "id": None,
        "moduleId": None,
        "name": None,
        "params": {},
        "view": None,
    }

    # Extract id
    id_match = re.search(r"id:\s*'([^']+)'", block)
    if id_match:
        preset["id"] = id_match.group(1)

    # Extract moduleId
    mid_match = re.search(r"moduleId:\s*'([^']+)'", block)
    if mid_match:
        preset["moduleId"] = mid_match.group(1)

    # Extract name
    name_match = re.search(r"name:\s*'([^']+)'", block)
    if name_match:
        preset["name"] = name_match.group(1)

    # Extract params dict
    params_match = re.search(r"params:\s*\{([^}]*)\}", block)
    if params_match:
        preset["params"] = _parse_params_dict(params_match.group(1))

    # Extract view (FractalViewState)
    view_match = re.search(
        r"FractalViewState\s*\(\s*pan:\s*Vector2\(([^,]+),\s*([^)]+)\)[^)]*zoom:\s*([0-9.]+)",
        block,
    )
    if view_match:
        preset["view"] = {
            "panX": float(view_match.group(1)),
            "panY": float(view_match.group(2)),
            "zoom": float(view_match.group(3)),
        }

    if not preset["id"]:
        return None

    return preset


def _parse_params_dict(params_str: str) -> Dict[str, Any]:
    """Parse a params dict like {'iterations': 350, 'bailout': 4.0}."""
    params = {}

    # Match key: value pairs
    # Values can be numbers (int or float) or quoted strings
    pattern = r"'([^']+)':\s*([0-9.]+|[0-9]+)"
    for match in re.finditer(pattern, params_str):
        key = match.group(1)
        value_str = match.group(2)
        if "." in value_str:
            params[key] = float(value_str)
        else:
            params[key] = int(value_str)

    return params


def parse_raymarched_3d_configs(content: str) -> List[Dict[str, Any]]:
    """Parse all Raymarched3DConfig entries from Dart file content."""
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
        config = _parse_raymarched_3d_block(block)
        if config:
            configs.append(config)

    return configs


def _parse_raymarched_3d_block(block: str) -> Optional[Dict[str, Any]]:
    """Parse a single Raymarched3DConfig block."""
    config = {
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

    # Extract id
    id_match = re.search(r"id:\s*'([^']+)'", block)
    if id_match:
        config["id"] = id_match.group(1)

    # Extract name
    name_match = re.search(r"name:\s*'([^']+)'", block)
    if name_match:
        config["name"] = name_match.group(1)

    # Extract shaderAsset
    shader_match = re.search(r"shaderAsset:\s*'([^']+)'", block)
    if shader_match:
        config["shaderAsset"] = shader_match.group(1)

    # Extract category
    cat_match = re.search(r"category:\s*'([^']+)'", block)
    if cat_match:
        config["category"] = cat_match.group(1)

    # Extract defaultPower
    power_match = re.search(r"defaultPower:\s*([0-9.]+)", block)
    if power_match:
        config["defaultPower"] = float(power_match.group(1))

    # Extract defaultIterations
    iter_match = re.search(r"defaultIterations:\s*([0-9.]+)", block)
    if iter_match:
        config["defaultIterations"] = float(iter_match.group(1))

    # Extract defaultSteps
    steps_match = re.search(r"defaultSteps:\s*([0-9.]+)", block)
    if steps_match:
        config["defaultSteps"] = float(steps_match.group(1))

    # Extract defaultBailout
    bailout_match = re.search(r"defaultBailout:\s*([0-9.]+)", block)
    if bailout_match:
        config["defaultBailout"] = float(bailout_match.group(1))

    # Extract defaultColorScheme
    cs_match = re.search(r"defaultColorScheme:\s*([0-9]+)", block)
    if cs_match:
        config["defaultColorScheme"] = int(cs_match.group(1))

    # Extract presets
    presets = _parse_presets(block)
    config["extraPresets"] = presets

    if not config["id"]:
        return None

    return config


def get_existing_thumbnails(thumbs_dir: Path) -> set:
    """Get set of thumbnail IDs (filenames without .png)."""
    if not thumbs_dir.exists():
        return set()

    thumbnails = set()
    for f in thumbs_dir.glob("*.png"):
        # Remove .png extension to get ID
        thumbnails.add(f.stem)

    return thumbnails


def audit_fractals():
    """Main audit function."""
    print("=" * 70)
    print("FLUTTER FRACTAL FORGE - CATALOG AUDIT")
    print("=" * 70)
    print()

    # Ensure output directory exists
    OUTPUT_YAML.parent.mkdir(parents=True, exist_ok=True)

    # Read catalog files
    print(f"Reading escape-time catalog: {ESCAPE_TIME_CATALOG}")
    escape_time_content = ESCAPE_TIME_CATALOG.read_text()

    print(f"Reading 3D catalog: {RAYMARCHED_3D_CATALOG}")
    raymarched_3d_content = RAYMARCHED_3D_CATALOG.read_text()

    # Parse configs
    print("Parsing fractal configurations...")
    escape_configs = parse_escape_time_configs(escape_time_content)
    raymarched_configs = parse_raymarched_3d_configs(raymarched_3d_content)

    print(f"  Found {len(escape_configs)} escape-time fractals")
    print(f"  Found {len(raymarched_configs)} 3D ray-marched fractals")
    print()

    # Get thumbnails
    thumbnails = get_existing_thumbnails(THUMBS_DIR)
    print(f"Found {len(thumbnails)} thumbnail PNGs in {THUMBS_DIR}")
    print()

    # Build registry
    all_fractals = []
    fractal_ids = set()

    # Process escape-time fractals
    for cfg in escape_configs:
        fid = cfg["id"]
        if fid in fractal_ids:
            print(f"  WARNING: Duplicate fractal ID: {fid}")
            continue
        fractal_ids.add(fid)

        has_thumb = fid in thumbnails
        fractal = {
            "id": fid,
            "name": cfg["name"],
            "shader": cfg["shaderAsset"],
            "category": cfg["category"],
            "dimension": cfg["dimension"],
            "defaultZoom": cfg["defaultZoom"],
            "defaultCenterX": cfg["defaultCenterX"],
            "defaultCenterY": cfg["defaultCenterY"],
            "defaultIterations": cfg["defaultIterations"],
            "defaultBailout": cfg["defaultBailout"],
            "defaultColorScheme": cfg["defaultColorScheme"],
            "hasThumbnail": has_thumb,
            "implemented": True,
            "presets": [p["id"] for p in cfg["extraPresets"]],
            "variants": [],
            "references": [],
        }
        all_fractals.append(fractal)

    # Process 3D fractals
    for cfg in raymarched_configs:
        fid = cfg["id"]
        if fid in fractal_ids:
            print(f"  WARNING: Duplicate fractal ID: {fid}")
            continue
        fractal_ids.add(fid)

        has_thumb = fid in thumbnails
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
            "hasThumbnail": has_thumb,
            "implemented": True,
            "presets": [p["id"] for p in cfg["extraPresets"]],
            "variants": [],
            "references": [],
        }
        all_fractals.append(fractal)

    # Sort by category then name (handle None names)
    all_fractals.sort(key=lambda f: (f["category"] or "", f["name"] or ""))

    # Write YAML
    registry = {"fractals": all_fractals}
    with open(OUTPUT_YAML, "w") as f:
        yaml.dump(
            registry, f, default_flow_style=False, sort_keys=False, allow_unicode=True
        )
    print(f"Wrote registry to {OUTPUT_YAML}")
    print()

    # Statistics
    total_fractals = len(all_fractals)
    with_thumbs = sum(1 for f in all_fractals if f["hasThumbnail"])
    missing_thumbs = total_fractals - with_thumbs

    print("-" * 70)
    print("SUMMARY")
    print("-" * 70)
    print(f"Total fractals found:      {total_fractals}")
    print(f"  - Escape-time (2D):      {len(escape_configs)}")
    print(f"  - Ray-marched (3D):      {len(raymarched_configs)}")
    print()
    print(f"Total with thumbnails:     {with_thumbs}")
    print(f"Total missing thumbnails:   {missing_thumbs}")

    # Check for extra thumbnails (PNG exists but no matching fractal)
    extra_thumbs = thumbnails - fractal_ids
    if extra_thumbs:
        print(f"Extra thumbnails (no module): {len(extra_thumbs)}")
        for t in sorted(extra_thumbs)[:10]:
            print(f"    - {t}.png")
        if len(extra_thumbs) > 10:
            print(f"    ... and {len(extra_thumbs) - 10} more")

    # List missing thumbnails (first 30)
    missing = [f for f in all_fractals if not f["hasThumbnail"]]
    if missing:
        print()
        print(f"Missing thumbnails (first 30 of {len(missing)}):")
        for f in sorted(missing, key=lambda x: x["name"])[:30]:
            print(f"    - {f['id']} ({f['name']})")
        if len(missing) > 30:
            print(f"    ... and {len(missing) - 30} more")

    print()
    print("=" * 70)

    return {
        "total": total_fractals,
        "escape_time": len(escape_configs),
        "raymarched_3d": len(raymarched_configs),
        "with_thumbnails": with_thumbs,
        "missing_thumbnails": missing_thumbs,
        "extra_thumbnails": len(extra_thumbs),
    }


if __name__ == "__main__":
    stats = audit_fractals()
    sys.exit(0)
