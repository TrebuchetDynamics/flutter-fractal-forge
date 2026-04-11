# 10K Fractal Catalog — Phase 0: Consolidate Existing 370

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Audit, document, and thumbnail all 370 existing fractal modules. Every fractal gets: working thumbnail, EN doc, CN doc, metadata.yaml. Non-working fractals moved to reference-only.

**Architecture:** Two-tier catalog — app catalog (working shaders only) vs reference docs (all researched fractals). Declarative `EscapeTimeConfig` entries in `escape_time_catalog.dart` + custom module files. Thumbnails in `assets/catalog_thumbs/{id}.png`.

**Tech Stack:** Python (thumbnail rendering), Dart (catalog data), GLSL (shaders), Flutter asset system.

---

## Current State Assessment

| Item | Count | Notes |
|------|-------|-------|
| Escape-time configs | 350 | `escape_time_catalog.dart` |
| Custom modules | ~15 | Julia, Phoenix, Nova, Mandelbulb, etc. |
| 3D raymarched configs | ~15 | `raymarched_3d_catalog.dart` |
| **Total modules** | **~370** | |
| Existing thumbnails | 199 | `assets/catalog_thumbs/` |
| Missing thumbnails | ~171 | Need to generate |
| `_kKnownThumbnailIds` set | ~199 | Hardcoded in `fractal_catalog_screen.dart` |
| `docs/catalog/` | **0** | Must be created |

---

## Task 1: Create Directory Structure

**Files:**
- Create: `docs/catalog/`
- Create: `docs/catalog/README.md`
- Create: `docs/catalog/I_escape_time/`
- Create: `docs/catalog/II_newton/`
- Create: `docs/catalog/III_strange_attractors/`
- Create: `docs/catalog/IV_ifs_geometric/`
- Create: `docs/catalog/V_l_systems/`
- Create: `docs/catalog/VI_3d_raymarching/`
- Create: `docs/catalog/VII_cellular_stochastic/`
- Create: `docs/catalog/VIII_trigonometric/`
- Create: `docs/catalog/IX_lyapunov/`
- Create: `docs/catalog/X_tiling/`
- Create: `docs/catalog/XI_deep_chaos/`
- Create: `docs/catalog/XII_high_dim/`
- Create: `docs/catalog/XIII_other/`
- Create: `docs/catalog/XIV_physical/`
- Create: `docs/catalog/XV_reaction_diffusion/`
- Create: `docs/catalog/XVI_musical/`
- Create: `docs/catalog/XVII_architectural/`
- Create: `docs/catalog/XVIII_biological/`
- Create: `docs/catalog/XIX_number_theory/`

- [ ] **Step 1: Create all category directories**

```bash
mkdir -p docs/catalog/{I_escape_time,II_newton,III_strange_attractors,IV_ifs_geometric,V_l_systems,VI_3d_raymarching,VII_cellular_stochastic,VIII_trigonometric,IX_lyapunov,X_tiling,XI_deep_chaos,XII_high_dim,XIII_other,XIV_physical,XV_reaction_diffusion,XVI_musical,XVII_architectural,XVIII_biological,XIX_number_theory}
```

- [ ] **Step 2: Create master README**

```bash
cat > docs/catalog/README.md << 'EOF'
# Flutter Fractal Forge — Fractal Catalog

Bilingual EN+CN reference encyclopedia. Each fractal has:

- `{id}.md` — English reference doc
- `{id}.zh.md` — Chinese translation
- `{id}.glsl` — Working shader (implemented only)
- `metadata.yaml` — Parameters, presets, taxonomy

## Categories

| # | Category | Count |
|---|----------|-------|
| I | Escape-Time (Complex Plane) | ~350 |
| II | Newton / Root-Finding | ~15 |
| III | Strange Attractors | ~30 |
| IV | IFS & Geometric Construction | ~25 |
| V | L-Systems & Space-Filling | ~10 |
| VI | 3D Raymarching & Hypercomplex | ~15 |
| VII | Cellular & Stochastic | ~20 |
| VIII | Trigonometric & Transcendental | ~15 |
| IX | Lyapunov & Stability | ~10 |
| X | Tiling & Aperiodic | ~10 |
| XI | Deep Chaos & Flows | ~15 |
| XII | High-Dimensional Algebra | ~10 |
| XIII | Other / Uncategorized | — |
| XIV | Physical & Constructed | — |
| XV | Reaction-Diffusion & Chemical | — |
| XVI | Musical & Rhythmic | — |
| XVII | Architectural & Structural | — |
| XVIII | Biological & Organic | — |
| XIX | Number-Theory | — |

Auto-generated index: see `scripts/generate_catalog_readme.py`
EOF
```

- [ ] **Step 3: Create category README templates (one per category)**

For each of the 19 category directories, create a `README.md` and `.zh.md` with:
- Category description
- Mathematical family
- Known fractals in this category
- Current implementation status

Example for `docs/catalog/I_escape_time/README.md`:
```markdown
# I. Escape-Time (Complex Plane)

The escape-time family of fractals is defined by iterating a complex function $f_c(z)$ and testing whether the orbit escapes to infinity.

## Definition

$$z_{n+1} = f_c(z_n)$$

Points that do not escape belong to the fractal set.

## Subcategories

- Mandelbrot Family (z² + c)
- Julia Variants
- Burning Ship Variants
- Multibrot (z^d)
- Phoenix
- Nova
- ...

## Implementation Status

See `escape_time_catalog.dart` for all declarative configs.
```

---

## Task 2: Audit Existing Fractals

**Files:**
- Modify: `lib/features/catalog/fractal_catalog_screen.dart` (add `_kKnownThumbnailIds` entries)
- Create: `scripts/audit_fractals.py`

- [ ] **Step 1: Run audit script to compare modules vs thumbnails**

Create `scripts/audit_fractals.py`:

```python
#!/usr/bin/env python3
"""Audit fractal catalog: find missing thumbnails, broken shaders, undocumented entries."""

import os
import re
import yaml

# Paths
CATALOG_DART = "lib/core/modules/builders/escape_time_catalog.dart"
RAYMARCH_DART = "lib/core/modules/builders/raymarched_3d_catalog.dart"
THUMB_DIR = "assets/catalog_thumbs"
KNOWN_IDS_SET = "lib/features/catalog/fractal_catalog_screen.dart"
EXISTING_THUMBS = set(f.replace('.png', '') for f in os.listdir(THUMB_DIR) if f.endswith('.png'))

# Parse EscapeTimeConfig entries from catalog dart file
with open(CATALOG_DART) as f:
    content = f.read()

configs = re.findall(r"EscapeTimeConfig\(\s*id:\s*'([^']+)'", content)
print(f"Escape-time configs found: {len(configs)}")
print(f"Existing thumbnails: {len(EXISTING_THUMBS)}")

# Find missing
missing = [c for c in configs if c not in EXISTING_THUMBS]
print(f"\nMissing thumbnails ({len(missing)}):")
for m in missing[:20]:
    print(f"  - {m}")
if len(missing) > 20:
    print(f"  ... and {len(missing)-20} more")

# Find extra thumbs (thumbs without matching module)
all_ids = set(configs)  # add custom modules etc.
extra = EXISTING_THUMBS - all_ids
print(f"\nExtra thumbnails (no matching module): {len(extra)}")
for e in sorted(extra)[:10]:
    print(f"  - {e}")
```

Run: `python scripts/audit_fractals.py`

- [ ] **Step 2: Create full fractal registry YAML**

Create `scripts/generate_fractal_registry.py`:

```python
#!/usr/bin/env python3
"""Generate fractal_registry.yaml from escape_time_catalog.dart + custom modules."""

import re
import yaml

CATALOG_DART = "lib/core/modules/builders/escape_time_catalog.dart"
OUTPUT = "docs/catalog/fractal_registry.yaml"

with open(CATALOG_DART) as f:
    content = f.read()

# Parse all EscapeTimeConfig entries
# Pattern: id, name, shaderAsset, category, defaultZoom, defaultIterations, etc.
entries = re.findall(
    r"EscapeTimeConfig\(\s*"
    r"id:\s*'([^']+)'\s*,\s*"
    r"name:\s*'([^']+)'\s*,\s*"
    r"(?:displayName:.*?,\s*)?"
    r"shaderAsset:\s*'([^']+)'\s*,\s*"
    r"(?:.*?category:\s*'([^']+)'\s*,\s*)?"
    r".*?defaultZoom:\s*([^,]+)\s*,\s*"
    r".*?defaultCenterX:\s*([^,]+)\s*,\s*"
    r".*?defaultCenterY:\s*([^,]+)\s*,"
    r".*?defaultIterations:\s*([^,]+)\s*,"
    r".*?defaultBailout:\s*([^,)]+)\s*,"
    r".*?defaultColorScheme:\s*(\d+)\s*,"
    r".*?\)",
    content,
    re.DOTALL
)

registry = []
for entry in entries:
    (id, name, shader, category, zoom, cx, cy, iterations, bailout, color) = entry
    registry.append({
        'id': id,
        'name': name,
        'shader': shader,
        'category': category or 'Escape-Time',
        'defaultZoom': float(zoom),
        'defaultCenterX': float(cx),
        'defaultCenterY': float(cy),
        'defaultIterations': float(iterations),
        'defaultBailout': float(bailout),
        'defaultColorScheme': int(color),
        'hasThumbnail': True,  # will be updated by audit
        'implemented': True,
    })

with open(OUTPUT, 'w') as f:
    yaml.dump({'fractals': registry}, f, default_flow_style=False, allow_unicode=True)

print(f"Generated {OUTPUT} with {len(registry)} entries")
```

Run: `python scripts/generate_fractal_registry.py`

- [ ] **Step 3: Cross-reference with thumbnail audit**

Update the registry YAML to mark which fractals have thumbnails:

```python
import yaml
import os

THUMB_DIR = "assets/catalog_thumbs"
existing = set(f.replace('.png', '') for f in os.listdir(THUMB_DIR) if f.endswith('.png'))

with open('docs/catalog/fractal_registry.yaml') as f:
    data = yaml.safe_load(f)

for fractal in data['fractals']:
    fractal['hasThumbnail'] = fractal['id'] in existing
    fractal['implemented'] = fractal['hasThumbnail']  # only implemented if thumbnail exists

with open('docs/catalog/fractal_registry.yaml', 'w') as f:
    yaml.dump(data, f, default_flow_style=False, allow_unicode=True)

implemented = sum(1 for f in data['fractals'] if f['implemented'])
print(f"Implemented with thumbnails: {implemented}/{len(data['fractals'])}")
```

Run: `python scripts/audit_fractals.py` (revised to read registry)

---

## Task 3: Build Thumbnail Generation Script

**Files:**
- Create: `scripts/render_thumbnails.py`

- [ ] **Step 1: Create thumbnail renderer script**

This script uses the Flutter app's screenshot capability. Since Flutter doesn't have a headless mode, the approach is:

1. For each fractal ID missing a thumbnail, add it to a temporary "thumbnail batch" list
2. Use the app's existing screenshot infrastructure to render at 512×512
3. Save to `assets/catalog_thumbs/`

Alternative (simpler): Write a Python script using `fractal-renderer` CLI if one exists, or use a pure Python Mandelbrot renderer for quick thumbnail generation.

```python
#!/usr/bin/env python3
"""
Render fractal thumbnails using pure Python.
For 2D escape-time fractals only.
3D fractals need GPU rendering — handle separately.
"""
import os
import sys
import yaml

THUMB_DIR = "assets/catalog_thumbs"
os.makedirs(THUMB_DIR, exist_ok=True)

def render_mandelbrot(cx, cy, zoom, iters, size=512, bailout=4.0):
    """Render Mandelbrot region to RGBA numpy array."""
    import numpy as np
    escape = bailout * bailout
    xmin = cx - 2.0 / zoom
    xmax = cx + 2.0 / zoom
    ymin = cy - 2.0 / zoom
    ymax = cy + 2.0 / zoom
    
    x = np.linspace(xmin, xmax, size)
    y = np.linspace(ymin, ymax, size)
    X, Y = np.meshgrid(x, y)
    C = X + 1j * Y
    Z = np.zeros_like(C)
    
    M = np.zeros(C.shape, dtype=np.uint8)
    for i in range(iters):
        Z = Z * Z + C
        escaped = np.abs(Z) > bailout
        M[escaped & (M == 0)] = int(255 * i / iters)
        Z[escaped] = 0
    return M

def save_png(arr, path):
    from PIL import Image
    img = Image.fromarray(arr, mode='L')
    img = img.convert('RGB')
    img.save(path)

# Load registry
with open('docs/catalog/fractal_registry.yaml') as f:
    data = yaml.safe_load(f)

missing = [f for f in data['fractals'] if not f['hasThumbnail'] and f['implemented']]
print(f"Need to generate {len(missing)} thumbnails")

for fractal in missing:
    fid = fractal['id']
    # Simple 2D fractals can use generic renderer
    # Complex ones (Nova, Phoenix) need custom rendering
    try:
        thumb = render_mandelbrot(
            cx=fractal['defaultCenterX'],
            cy=fractal['defaultCenterY'],
            zoom=fractal['defaultZoom'],
            iters=int(fractal['defaultIterations']),
            bailout=fractal['defaultBailout'],
        )
        save_png(thumb, f"{THUMB_DIR}/{fid}.png")
        print(f"  ✓ {fid}")
    except Exception as e:
        print(f"  ✗ {fid}: {e}")
```

Note: This is a starting point. Refine per-fractal rendering based on shader type.

- [ ] **Step 2: Run thumbnail generation for all missing 2D fractals**

Run: `python scripts/render_thumbnails.py`

Expected: ~171 missing thumbnails generated.

- [ ] **Step 3: Manually verify a sample of generated thumbnails**

```bash
ls -la assets/catalog_thumbs/ | head -20
# Check file sizes — should be 5-50KB each
# Any 0-byte files = failed renders
```

- [ ] **Step 4: Add generated thumbnails to git**

```bash
git add assets/catalog_thumbs/*.png
git status  # verify only new thumbnails staged
```

---

## Task 4: Generate metadata.yaml Per Fractal

**Files:**
- Create: `scripts/generate_metadata.py`
- Create: `docs/catalog/I_escape_time/mandelbrot/metadata.yaml` (example)

- [ ] **Step 1: Create metadata generator script**

```python
#!/usr/bin/env python3
"""Generate metadata.yaml for each fractal from fractal_registry.yaml."""

import os
import yaml

REGISTRY = "docs/catalog/fractal_registry.yaml"
OUTPUT_BASE = "docs/catalog"

with open(REGISTRY) as f:
    data = yaml.safe_load(f)

for fractal in data['fractals']:
    fid = fractal['id']
    cat_slug = fractal['category'].lower().replace(' ', '_').replace('/', '_')
    
    # Map to canonical category directory
    cat_dir = _canonical_category(fractal['category'])
    fractal_dir = f"{OUTPUT_BASE}/{cat_dir}/{fid}"
    os.makedirs(fractal_dir, exist_ok=True)
    
    meta = {
        'id': fid,
        'name': fractal['name'],
        'category': fractal['category'],
        'shader': fractal['shader'],
        'hasThumbnail': fractal['hasThumbnail'],
        'implemented': fractal['implemented'],
        'params': {
            'initialZoom': fractal['defaultZoom'],
            'centerX': fractal['defaultCenterX'],
            'centerY': fractal['defaultCenterY'],
            'iterations': fractal['defaultIterations'],
            'bailout': fractal['defaultBailout'],
            'colorScheme': fractal['defaultColorScheme'],
        },
        'presets': [],  # filled from escape_time_catalog.dart presets
        'references': [],
    }
    
    with open(f"{fractal_dir}/metadata.yaml", 'w') as f:
        yaml.dump(meta, f, default_flow_style=False, allow_unicode=True)

def _canonical_category(cat):
    mapping = {
        'Escape-Time': 'I_escape_time',
        'Newton': 'II_newton',
        'Attractor': 'III_strange_attractors',
        'IFS': 'IV_ifs_geometric',
        'L-Systems': 'V_l_systems',
        '3D': 'VI_3d_raymarching',
        'Cellular': 'VII_cellular_stochastic',
        'Trigonometric': 'VIII_trigonometric',
        'Lyapunov': 'IX_lyapunov',
        'Tiling': 'X_tiling',
        'Chaos': 'XI_deep_chaos',
        'High-Dim': 'XII_high_dim',
    }
    for key, val in mapping.items():
        if key.lower() in cat.lower():
            return val
    return 'XIII_other'
```

- [ ] **Step 2: Extract presets from escape_time_catalog.dart**

Extend the registry generator to also extract preset data:

```python
# In generate_fractal_registry.py, add preset extraction:
preset_blocks = re.findall(
    r"FractalPreset\(\s*"
    r"id:\s*'([^']+)'\s*,\s*"
    r"moduleId:\s*'([^']+)'\s*,\s*"
    r"name:\s*'([^']+)'\s*,"
    r".*?params:\s*\{([^}]+)\}\s*,"
    r".*?view:\s*FractalViewState\("
    r".*?pan:\s*Vector2\(([^,]+),\s*([^)]+)\)\s*,"
    r".*?zoom:\s*([^,]+)\s*,"
    r".*?\)",
    content,
    re.DOTALL
)
```

Map presets back to fractal IDs and include in metadata.yaml.

- [ ] **Step 3: Run metadata generation**

Run: `python scripts/generate_metadata.py`

- [ ] **Step 4: Verify output structure**

```bash
ls docs/catalog/I_escape_time/mandelbrot/
# Expected: metadata.yaml, mandelbrot.md, mandelbrot.zh.md, thumbnails/
```

---

## Task 5: Write EN Reference Docs

**Files:**
- Create: `docs/catalog/{category}/{id}/{id}.md` (per fractal)
- Create: `scripts/generate_en_docs.py`

- [ ] **Step 1: Create EN doc generator**

```python
#!/usr/bin/env python3
"""Generate EN reference docs for all implemented fractals."""

import os
import yaml

REGISTRY = "docs/catalog/fractal_registry.yaml"
OUTPUT_BASE = "docs/catalog"

with open(REGISTRY) as f:
    data = yaml.safe_load(f)

for fractal in data['fractals']:
    if not fractal['implemented']:
        continue
    
    fid = fractal['id']
    cat_dir = _canonical_category(fractal['category'])
    fractal_dir = f"{OUTPUT_BASE}/{cat_dir}/{fid}"
    os.makedirs(fractal_dir, exist_ok=True)
    
    with open(f"{fractal_dir}/{fid}.md", 'w') as f:
        f.write(_render_en_doc(fractal))

def _render_en_doc(f):
    params = f['params']
    return f"""# {f['name']}

## Overview

**Category:** {f['category']}  
**ID:** {f['id']}  
**Shader:** `{f['shader']}`  
**Has Thumbnail:** {'✅' if f['hasThumbnail'] else '❌'}

## Parameters

| Parameter | Default | Description |
|----------|---------|-------------|
| Zoom | {params['initialZoom']} | Initial zoom level |
| Center X | {params['centerX']} | Initial center X |
| Center Y | {params['centerY']} | Initial center Y |
| Iterations | {params['iterations']} | Max iterations |
| Bailout | {params['bailout']} | Escape radius |
| Color Scheme | {params['colorScheme']} | Palette index |

## Presets

See `metadata.yaml` for full preset list.

## References

- [Fractal Wiki](https://fractal.fandom.com/wiki/{f['name']})
- [Wikipedia](https://en.wikipedia.org/wiki/{f['name'].replace(' ', '_')})
"""
```

- [ ] **Step 2: Run EN doc generation**

Run: `python scripts/generate_en_docs.py`

- [ ] **Step 3: Manually review a sample of generated docs**

```bash
head -30 docs/catalog/I_escape_time/mandelbrot/mandelbrot.md
```

---

## Task 6: Write CN Translation Docs

**Files:**
- Create: `docs/catalog/{category}/{id}/{id}.zh.md` (per fractal)
- Create: `scripts/generate_cn_docs.py`

- [ ] **Step 1: Create CN doc generator**

```python
#!/usr/bin/env python3
"""Generate CN translation docs for all fractals."""

import os
import yaml

REGISTRY = "docs/catalog/fractal_registry.yaml"
OUTPUT_BASE = "docs/catalog"

# Chinese translations for common terms
TRANSLATIONS = {
    'Mandelbrot': '曼德勃罗集合',
    'Julia': '朱莉娅集合',
    'Burning Ship': '燃烧之船',
    'Escape-Time': '逃逸时间',
    'Newton': '牛顿',
    'Parameters': '参数',
    'Presets': '预设',
    'References': '参考文献',
    'Zoom': '缩放',
    'Iterations': '迭代次数',
    'Bailout': '逃逸半径',
    'Color Scheme': '配色方案',
    'Category': '类别',
    'Has Thumbnail': '缩略图',
    'Shader': '着色器',
}

def translate(text):
    for en, cn in TRANSLATIONS.items():
        text = text.replace(en, cn)
    return text

with open(REGISTRY) as f:
    data = yaml.safe_load(f)

for fractal in data['fractals']:
    fid = fractal['id']
    cat_dir = _canonical_category(fractal['category'])
    fractal_dir = f"{OUTPUT_BASE}/{cat_dir}/{fid}"
    os.makedirs(fractal_dir, exist_ok=True)
    
    # Load EN doc
    en_path = f"{fractal_dir}/{fid}.md"
    if not os.path.exists(en_path):
        continue
    
    with open(en_path) as f:
        en_content = f.read()
    
    # Translate
    cn_content = translate(en_content)
    
    with open(f"{fractal_dir}/{fid}.zh.md", 'w') as f:
        f.write(cn_content)
```

- [ ] **Step 2: Run CN doc generation**

Run: `python scripts/generate_cn_docs.py`

- [ ] **Step 3: Verify Chinese content**

```bash
head -20 docs/catalog/I_escape_time/mandelbrot/mandelbrot.zh.md
# Should contain: 曼德勃罗集合, 缩放, 迭代次数, etc.
```

---

## Task 7: Update `_kKnownThumbnailIds` in App Code

**Files:**
- Modify: `lib/features/catalog/fractal_catalog_screen.dart`

- [ ] **Step 1: Extract all fractal IDs with thumbnails**

```bash
ls assets/catalog_thumbs/ | sed "s/.png$//" | sort > /tmp/thumb_ids.txt
```

- [ ] **Step 2: Update `_kKnownThumbnailIds` set**

The set in `fractal_catalog_screen.dart` must contain every fractal ID that has a thumbnail PNG. Generate the new set content:

```python
import os
thumb_ids = sorted(os.listdir('assets/catalog_thumbs'))
print(',\n  '.join(f"'{t.replace('.png', '')}'" for t in thumb_ids))
```

- [ ] **Step 3: Replace the hardcoded set**

Find the `_kKnownThumbnailIds` definition in `fractal_catalog_screen.dart` and replace with the complete set from the filesystem.

```dart
const _kKnownThumbnailIds = <String>{
  // Auto-generated from assets/catalog_thumbs/
  'aizawa',
  'ammann_beenker',
  // ... all 370 IDs
};
```

- [ ] **Step 4: Verify the update compiles**

```bash
/home/xel/flutter/bin/flutter analyze lib/features/catalog/fractal_catalog_screen.dart
```

Expected: 0 errors.

---

## Task 8: Verify Full Catalog Integrity

**Files:**
- Modify: `lib/core/modules/module_registry.dart` (if taxonomy changes affect registry)
- Modify: `pubspec.yaml` (if new shader assets added)

- [ ] **Step 1: Run full Flutter analyze**

```bash
/home/xel/flutter/bin/flutter analyze
```

Expected: 0 errors, 0 warnings (or only pre-existing warnings).

- [ ] **Step 2: Run catalog thumbnail audit test**

```bash
/home/xel/flutter/bin/flutter test test/catalog_thumbnail_audit_test.dart
```

Expected: PASS — all thumbnails exist for IDs in catalog.

- [ ] **Step 3: Run module registry test**

```bash
/home/xel/flutter/bin/flutter test test/module_registry_widget_test.dart
```

Expected: PASS — all modules registered.

- [ ] **Step 4: Visual spot-check (manual)**

```bash
/home/xel/flutter/bin/flutter run -d linux --no-sound-null-safety
```

Navigate to catalog, scroll through, verify thumbnails load without shimmer errors.

---

## Task 9: Commit Phase 0 Work

- [ ] **Step 1: Stage all changes**

```bash
git add assets/catalog_thumbs/*.png
git add docs/catalog/
git add lib/features/catalog/fractal_catalog_screen.dart
git add scripts/
git status
```

- [ ] **Step 2: Commit**

```bash
git commit -m "feat(catalog): Phase 0 — consolidate 370 fractals

- Create docs/catalog/ with 19-category taxonomy
- Audit: 199 existing + ~171 newly generated thumbnails
- Generate metadata.yaml for all 370 fractals
- Generate EN reference docs for all implemented fractals
- Generate CN translations for all fractals
- Update _kKnownThumbnailIds with all 370 fractal IDs
- Regenerate fractal_registry.yaml from escape_time_catalog.dart
- All 370 fractals: thumbnail + EN doc + CN doc + metadata.yaml
- flutter analyze: 0 errors
- All catalog tests pass"
```

---

## Phase 0 Exit Criteria

| Criterion | How to Verify |
|-----------|--------------|
| All 370 modules have thumbnail PNG | `ls assets/catalog_thumbs/*.png \| wc -l` ≥ 370 |
| All 370 modules have metadata.yaml | `find docs/catalog -name metadata.yaml \| wc -l` ≥ 370 |
| All implemented fractals have EN doc | `find docs/catalog -name '*.md' \| grep -v '.zh.' \| wc -l` ≥ 370 |
| All fractals have CN doc | `find docs/catalog -name '*.zh.md' \| wc -l` ≥ 370 |
| `_kKnownThumbnailIds` has all IDs | `flutter analyze` clean |
| `flutter test` passes | All tests pass |
| `flutter analyze` clean | 0 errors |

---

## Notes for Agentic Workers

- **Thumbnail generation** is the hardest part — the Python renderer above is a starting point. For complex fractals (Nova, Phoenix, 3D), you may need to use the actual Flutter app's screenshot functionality or write fractal-specific rendering code.
- **Batch processing**: Run thumbnail generation overnight — 170+ renders at 512×512 takes hours in Python.
- **CN translations**: Machine translation is acceptable for Phase 0; human review can come later.
- **Taxonomy mapping**: The `_canonical_category()` function in metadata.py may need refinement as you discover edge cases in how `escape_time_catalog.dart` categorizes fractals.
