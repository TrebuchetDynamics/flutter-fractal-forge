# Flutter Fractal Forge — 10K Fractal Catalog Design Spec

**Date:** 2026-04-11  
**Owner:** Sidon  
**Status:** Approved

---

## 1. Vision

Build **the world's largest fractal catalog** — 10,000+ fractal types — as a unified EN+中文 reference encyclopedia and fully-implemented GPU-accelerated app catalog.

- **Research** in English and Chinese (bilingual sources)
- **Documentation** in English (primary) + Chinese translation
- **App catalog** contains only fully-implemented fractals (working shader + thumbnail)
- **Reference docs** contain formula + description for all researched fractals

---

## 2. Scope

### What's In Scope

- Hierarchical taxonomy of 19 mathematical categories
- Full GPU shader implementation for each app-catalog fractal
- Regenerated thumbnails with optimal initial params (zoom, bailout, iterations, palette)
- EN + 中文 bilingual reference documentation per fractal
- Phased roadmap: consolidate 370 → 1,000 → 3,000 → 10,000+

### What's Out of Scope

- Placeholder/stub shaders for unimplemented fractals (not in app)
- Chinese display in app UI (docs only)
- Video recording
- User-defined formulas
- Runtime shader compilation

---

## 3. Taxonomy (19 Categories)

```
Fractals (10,000+)
├── I.   Escape-Time (Complex Plane)           ~2,000
├── II.  Newton / Root-Finding               ~500
├── III. Strange Attractors                  ~1,000
├── IV.  IFS & Geometric Construction         ~1,500
├── V.   L-Systems & Space-Filling           ~500
├── VI.  3D Raymarching & Hypercomplex       ~1,000
├── VII. Cellular & Stochastic               ~1,500
├── VIII.Trigonometric & Transcendental       ~500
├── IX.  Lyapunov & Stability                ~500
├── X.   Tiling & Aperiodic                 ~500
├── XI.  Deep Chaos & Flows                  ~500
├── XII. High-Dimensional Algebra             ~300
├── XIII. Other / Uncategorized              ~700
├── XIV.  Physical & Constructed Fractals     ~400
│   ├── Origami / Paper-Folding            ~80
│   ├── Geometric Ruler-Compass             ~80
│   ├── Physical Arrangement (sticks/tiles)  ~80
│   ├── Natural Structures (crystals, plants) ~80
│   └── Tactile / 3D-Printed Models        ~80
├── XV.  Reaction-Diffusion & Chemical       ~300
│   ├── Turing Patterns                     ~100
│   ├── Electrolysis / Electrodeposition    ~80
│   ├── Belousov-Zhabotinsky (BZ reaction) ~60
│   └── Other Chemical                     ~60
├── XVI. Musical & Rhythmic Patterns         ~200
│   ├── Self-Similar Rhythms               ~80
│   ├── Fractal Scales & Compositions      ~60
│   └── Auditory Fractals                  ~60
├── XVII. Architectural & Structural        ~300
│   ├── Gothic / Sacred Geometry           ~80
│   ├── Fractal Architecture               ~80
│   ├── Islamic Geometric Patterns          ~80
│   └── Structural Load-Bearing Fractals   ~60
├── XVIII. Biological & Organic            ~400
│   ├── Plant Morphology (ferns, trees)   ~100
│   ├── Vascular & Branching Systems        ~80
│   ├── Animal Patterns (spots, stripes)    ~80
│   ├── Fractals in DNA/Proteins          ~80
│   └── Neuroscience (neuronal branching)  ~60
└── XIX. Number-Theory Fractals           ~300
    ├── Continued Fraction Fractals          ~80
    ├── Eisenstein Series                  ~60
    ├── Farey Sequence Fractals            ~60
    └── Other Number-Theory               ~100
```

---

## 4. Two-Tier Catalog System

| Tier | Contents | In App? | In Docs? |
|------|----------|---------|----------|
| **Implemented** | Working shader + thumbnail + metadata + EN+CN docs | ✅ Yes | ✅ Yes |
| **Reference** | Formula + description + EN+CN docs, no shader | ❌ No | ✅ Yes |

**Rule:** If it doesn't work in the app, it doesn't get an app catalog entry. Reference docs only.

---

## 5. Documentation Structure

### Directory Layout

```
docs/catalog/
├── README.md                          ← Auto-generated master index
│
├── I_escape_time/
│   ├── I_escape_time.md              ← Category overview (EN)
│   ├── I_escape_time.zh.md           ← Category overview (中文)
│   ├── mandelbrot/
│   │   ├── mandelbrot.md            ← EN reference doc
│   │   ├── mandelbrot.zh.md         ← 中文版
│   │   ├── mandelbrot.glsl          ← Working shader source
│   │   ├── mandelbrot.yaml          ← Metadata (params, presets)
│   │   └── thumbnails/
│   │       └── default.png          ← Regenerated thumbnail
│   └── ...
│
├── XIV_physical/
│   ├── XIV_physical.md
│   ├── XIV_physical.zh.md
│   ├── origami/
│   │   └── lucky_star/
│   │       ├── lucky_star.md
│   │       ├── lucky_star.zh.md
│   │       ├── lucky_star.glsl
│   │       ├── lucky_star.yaml
│   │       └── thumbnails/default.png
│   └── ...
│
└── XIX_number_theory/
    └── ...
```

### Fractal Entry Files

#### `metadata.yaml`
```yaml
id: f001_mandelbrot_set
name: Mandelbrot Set
category: I. Escape-Time (Complex Plane)
subcategory: Mandelbrot Family
shader: mandelbrot.glsl
thumbnail: thumbnails/default.png

# Initial render params for thumbnail + default viewer state
params:
  initialZoom: 1.5
  centerX: -0.5
  centerY: 0.0
  iterations: 500
  bailout: 2.0
  power: 2.0
  palette: "default"
  coloring: "smooth"

presets:
  - id: seahorse_valley
    name: Seahorse Valley
    params:
      centerX: -0.747
      centerY: 0.1
      zoom: 2.5
  - id: elephant_valley
    name: Elephant Valley
    params:
      centerX: -1.75
      centerY: 0.0
      zoom: 0.1

variants:
  - id: multibrot
    name: Multibrot
    params:
      power: 3.0
  - id: burning_ship
    name: Burning Ship

references:
  - author: Benoît Mandelbrot
    title: "Les objets fractals"
    year: 1975
  - url: https://en.wikipedia.org/wiki/Mandelbrot_set
```

#### `fractal_name.md` (EN)
```markdown
# Mandelbrot Set

## Overview
The Mandelbrot set is the set of complex numbers $c$ for which the 
iterated function $f_c(z) = z^2 + c$ does not diverge when starting 
from $z_0 = 0$.

**Category:** I. Escape-Time (Complex Plane)  
**Subcategory:** Mandelbrot Family  
**ID:** f001_mandelbrot_set  
**Deep Zoom:** Perturbation theory supported  

## Mathematical Definition
$$z_{n+1} = z_n^2 + c, \quad z_0 = 0$$

## Parameters
| Parameter | Type | Default | Range | Description |
|-----------|------|---------|-------|-------------|
| `iterations` | Int | 500 | 1–10000 | Max iterations |
| `bailout` | Float | 2.0 | 1.0–10.0 | Escape radius |
| `power` | Float | 2.0 | 1.0–12.0 | Exponent |

## Known Presets
| Name | Parameters | Description |
|------|------------|-------------|
| Seahorse Valley | center=(-0.747, 0.1) | Classic region |
| Elephant Valley | center=(-1.75, 0.0) | Another famous region |

## Variants
- Multibrot (z^d): see `multibrot.md`
- Burning Ship: see `burning_ship.md`

## References
- [Mandelbrot (1975)](https://...)
- [Wikipedia](https://en.wikipedia.org/wiki/Mandelbrot_set)
- [Mu-Ency](https://www.mrob.com/pub/muency.html)
```

#### `fractal_name.zh.md` (中文)
```markdown
# 曼德勃罗集合

## 概述
曼德勃罗集合是复数 $c$ 的集合，对于该集合中的每个数 $c$，
迭代函数 $f_c(z) = z^2 + c$ 从 $z_0 = 0$ 开始迭代时不会发散。

**类别：** I. 逃逸时间（复平面）  
**子类别：** 曼德勃罗家族  
**ID：** f001_mandelbrot_set  
**深度缩放：** 支持微扰理论  

## 数学定义
$$z_{n+1} = z_n^2 + c, \quad z_0 = 0$$

## 参数
| 参数 | 类型 | 默认值 | 范围 | 描述 |
|------|------|---------|-------|-------------|
| `iterations` | 整数 | 500 | 1–10000 | 最大迭代次数 |
| `bailout` | 浮点数 | 2.0 | 1.0–10.0 | 逃逸半径 |
| `power` | 浮点数 | 2.0 | 1.0–12.0 | 指数 |

## 已知预设
| 名称 | 参数 | 描述 |
|------|------|-------------|
| 海马谷 | center=(-0.747, 0.1) | 经典区域 |
| 大象谷 | center=(-1.75, 0.0) | 另一个著名区域 |
```

---

## 6. Thumbnail Regeneration Spec

Each thumbnail must be regenerated with correct initial params.

### Thumbnail Requirements

| Property | Value |
|----------|-------|
| Resolution | 512×512 px |
| Format | PNG |
| Background | Dark theme background |
| Quality | Production-ready, no artifacts |
| Params | Must match `metadata.yaml` |

### Per-Category Thumbnail Strategy

| Category Type | Strategy |
|--------------|----------|
| Escape-Time 2D | Zoom to visually distinctive region |
| 3D Raymarching | Best camera angle for shape |
| Attractors | Phase portrait or orbit view |
| IFS/L-Systems | Full fractal visible |
| Tiling | Centered, full repeat visible |
| Physical | Photo or rendered model |
| Musical | Waveform or score view |

---

## 7. Phased Roadmap

### Phase 0: Consolidate Existing 370
**Goal:** Perfect the current catalog

1. Audit all 370 modules → working vs. broken shaders
2. For working fractals:
   - Regenerate thumbnail with optimal params
   - Write EN doc
   - Write CN doc
   - Populate `metadata.yaml`
   - Apply canonical taxonomy
3. Remove non-working from app catalog → reference docs only
4. **Deliverable:** 370-entry app catalog, all with thumbnails + EN+CN docs

### Phase 1: 1,000 Total
**Goal:** 630 new implemented fractals

1. Research: EN+CN web (Ultra Fractal DB, arXiv, Fractal Forums, Mu-Ency)
2. For each new fractal:
   - Write shader
   - Test until working
   - Regenerate thumbnail
   - Write EN+CN docs
   - Populate metadata
3. **Deliverable:** 1,000-entry app catalog

### Phase 2: 3,000 Total
**Goal:** 2,000 more implemented fractals

- Batch research from all sources
- Prioritize visually interesting + implementable first
- Community contribution workflow established
- **Deliverable:** 3,000-entry app catalog

### Phase 3+: 10,000+ Total
**Goal:** Ongoing expansion

- Automated formula discovery from academic papers
- Formula variation generator (Julia c-values, etc.)
- Community contributions via PR workflow
- **Deliverable:** 10,000+ reference entries, N implemented

---

## 8. Key Sources

| Source | Type | Count | Use |
|--------|------|-------|-----|
| Ultra Fractal Formula DB | EN | 5,000+ | Primary formula source |
| Fractal Forums Gallery | EN | 18,000+ | Parameters in posts |
| Mu-Ency (mrob.com) | EN | 1,000+ | Best Mandelbrot taxonomy |
| arXiv | EN | 1,000+ | Novel/academic fractals |
| MathWorld | EN | 150+ | Mathematical definitions |
| Wikipedia EN | EN | 200+ | Categorization |
| Wikipedia CN | 中文 | ~20 major | CN translation reference |
| CNKI | 中文 | 1,000+ papers | CN fractal theory |

**Note:** No comprehensive CN fractal database exists. CN sources provide theory + translation reference; EN sources provide the bulk of formulas.

---

## 9. Implementation Checklist Per Fractal

For each fractal to be added to the app catalog:

- [ ] Write GPU shader (GLSL fragment shader)
- [ ] Verify shader compiles on SkSL + GLSL
- [ ] Determine optimal initial params (zoom, center, iterations, bailout, palette)
- [ ] Render thumbnail at 512×512
- [ ] Write `metadata.yaml` with all params and presets
- [ ] Write EN reference doc (`{id}.md`)
- [ ] Write CN translation (`{id}.zh.md`)
- [ ] Add shader to `pubspec.yaml` under `flutter.shaders`
- [ ] Register module in `ModuleRegistry`
- [ ] Add to canonical taxonomy category
- [ ] Run `flutter analyze` — zero errors
- [ ] Visual verification in app

---

## 10. Out of Scope (Hard Limits)

- ❌ Stub/placeholder shaders in app catalog
- ❌ Unimplemented fractals in app catalog
- ❌ Chinese UI in app (docs only)
- ❌ Video recording
- ❌ User-defined formulas
- ❌ Runtime shader compilation
- ❌ Community marketplace

---

## 11. Success Criteria

| Milestone | Criteria |
|-----------|----------|
| Phase 0 | All 370 working fractals have: thumbnail + EN doc + CN doc + metadata.yaml |
| Phase 1 | 1,000 app-catalog entries, all with working shaders |
| Phase 2 | 3,000 app-catalog entries |
| Phase 3+ | 10,000+ reference entries |
| All phases | All implemented fractals: `flutter analyze` zero errors |
