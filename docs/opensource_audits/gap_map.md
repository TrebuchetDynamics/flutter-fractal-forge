# Fractal Gap Map (opensource vs current modules)

Date: 2026-02-18

## Scope

Compared current app fractal coverage from:
- `lib/core/modules/module_registry.dart`
- `lib/core/modules/builders/escape_time_catalog.dart`

Against opensource references under:
- `opensource/CATALOG.md`
- `opensource/par-fractal`
- `opensource/repos/formula-catalogs/glChAoS.P`
- `opensource/repos/formula-catalogs/mandelbulber2`
- `opensource/repos/renderers/GAPFixFractal`
- spot checks in `opensource/repos/renderers/FractaVista` and `opensource/repos/renderers/FractalExplorer`

## Baseline coverage (current app)

- Escape-time catalog configs: **332 unique IDs**
- + custom modules in registry (`julia`, `julia_dual`, `phoenix`, `nova`, `mandelbulb`, `mandelbox`)
- Estimated total non-debug core modules: **338**

Interpretation: 2D escape-time coverage is already broad. Main opportunity gaps are **true 3D attractors/volumetrics**, **polyhedral/Kleinian 3D IFS**, and a few **formula families from GPL projects** (clean-room only).

## Quick gap snapshot (normalized-ID comparison)

> Normalization used: lowercase + strip non-alphanumeric, then compare against app module IDs.

| Reference source | Formula/type names scanned | Not matched to current app IDs | Notes |
|---|---:|---:|---|
| `opensource/par-fractal/src/fractal/types.rs` | 35 | 21 | Includes true 3D attractors and polyhedral IFS that are currently absent |
| `opensource/repos/formula-catalogs/glChAoS.P` (`*.sca` `"Name"` fields) | 97 | 71 | Many volumetric/3D attractor names and family variants not present |
| `opensource/repos/formula-catalogs/mandelbulber2/mandelbulber2/formula/ui/*.ui` | 467 | 461 | Very large 3D DE formula library; only tiny overlap with current app IDs |
| `opensource/repos/renderers/GAPFixFractal/src/include/formulas.h` | 16 | 12 | Multiple custom escape-time variants absent (e.g., `sqtwice_a`, `tails`) |

---

## Exact grep/find commands used

```bash
cd flutter-fractal-forge
find lib -maxdepth 4 -type f | grep -E '(registry|catalog|module|fractal)' | head -n 200

grep -Rho "id: '[^']*'" lib/core/modules/builders/escape_time_catalog.dart | sed "s/id: '//;s/'//" | sort -u > /tmp/app_escape_ids.txt

cd flutter-fractal-forge/opensource
grep -n "Fractal Types\|Fractal types\|built-in formulas\|formulas\|Variations\|variation" CATALOG.md | head -n 200

cd flutter-fractal-forge/opensource/repos/renderers/FractaVista
grep -RIn "Mandelbrot\|Julia\|Tricorn\|BurningShip\|Newton\|Cubic\|Feather\|FractalType\|enum" src assets/shaders README.md | head -n 200

cd flutter-fractal-forge/opensource/repos/renderers/FractalExplorer
find . -maxdepth 4 -type f | head -n 80

cd flutter-fractal-forge/opensource/repos/formula-catalogs/mandelbulber2/mandelbulber2
find formula -maxdepth 2 -type f | head -n 120

cd flutter-fractal-forge/opensource/repos/formula-catalogs/glChAoS.P
grep -RIn --exclude-dir=.git -E "enum|Attractor|Aizawa|Lorenz|Rossler|Thomas|Rucklidge|Chua|Coullet|Sprott|Halvorsen|Rabinovich|Dequan|TSUCS|Globo|Rikitake" . | head -n 260

cd flutter-fractal-forge/opensource/repos/renderers/GAPFixFractal
find . -maxdepth 4 -type f | head -n 120
```

---

## Prioritized shortlist (25 candidate fractals to add)

Legend:
- GPU feasibility: High / Medium / Low-Med (with current Flutter fragment pipeline)
- CPU fallback complexity: Low / Medium / High / Very High
- Licensing notes are about **reuse safety** (math is safe, code reuse may not be)

| # | Candidate fractal | Formula family | GPU feasibility | CPU fallback complexity | Expected visual uniqueness | Licensing safety notes |
|---|---|---|---|---|---|---|
| 1 | **Octahedral IFS 3D** | Polyhedral IFS / DE raymarch | Medium | High | Very high | Source: par-fractal (MIT) → safe clean port with attribution |
| 2 | **Icosahedral IFS 3D** | Polyhedral IFS / DE raymarch | Medium | High | Very high | Source: par-fractal (MIT) → safe clean port |
| 3 | **Quaternion Cubic 3D** | Hypercomplex polynomial (3D slice/DE) | Low-Med | Very High | Very high | Source: par-fractal (MIT), math-level reuse safe |
| 4 | **Hybrid Mandelbulb-Julia 3D** | Hybrid DE (bulb + Julia coupling) | Medium | Very High | Very high | Source: par-fractal (MIT) |
| 5 | **Julia Set 3D** | Quaternion/3D Julia DE | Medium | Very High | Very high | Source: par-fractal (MIT) |
| 6 | **Pickover Attractor 3D** | Chaotic attractor (ODE) | Medium | High | Very high | Source: par-fractal (MIT), glChAoS.P (BSD-2) |
| 7 | **Lorenz Attractor 3D** | Chaotic attractor (ODE) | Medium | Medium | High | Source: par-fractal (MIT) |
| 8 | **Rossler Attractor 3D** | Chaotic attractor (ODE) | Medium | Medium | High | Source: par-fractal (MIT) |
| 9 | **Martin Attractor 2D** | Strange attractor map | High | Medium | High | Source: par-fractal (MIT) |
| 10 | **Chip Attractor 2D** | Strange attractor map | High | Medium | High | Source: par-fractal (MIT) |
| 11 | **Quadruptwo Attractor 2D** | Strange attractor map | High | Medium | High | Source: par-fractal (MIT) |
| 12 | **Threeply Attractor 2D** | Strange attractor map | High | Medium | High | Source: par-fractal (MIT) |
| 13 | **MultiChuaII (3D)** | Chua-family chaotic system | Medium | High | Very high | Source: glChAoS.P (BSD-2) → permissive |
| 14 | **Sprott-Linz (3D)** | Polynomial chaotic flow | Medium | High | High | Source: glChAoS.P (BSD-2) |
| 15 | **Henon3D** | Discrete 3D map | Medium | High | High | Source: glChAoS.P (BSD-2) |
| 16 | **Mira3D** | Discrete 3D map | Medium | High | High | Source: glChAoS.P (BSD-2) |
| 17 | **Kaneko3D** | Coupled chaotic map | Medium | High | Very high | Source: glChAoS.P (BSD-2) |
| 18 | **Hopalong3D** | Hopalong map extension to 3D | Medium | High | High | Source: glChAoS.P (BSD-2) |
| 19 | **Volumetric Quaternion Julia** | Volume fractal / ray-march density | Low-Med | Very High | Very high | Source: glChAoS.P (BSD-2) |
| 20 | **Volumetric Real Mandelbrot** | 3D volumetric Mandelbrot field | Low-Med | Very High | Very high | Source: glChAoS.P (BSD-2) |
| 21 | **Mandelbox Smooth** | DE Mandelbox variant (smooth folds) | Medium | High | High | Source: mandelbulber2 (GPL-3) → clean-room only |
| 22 | **Kaleidoscopic IFS** | KIFS fold/symmetry DE family | Medium | High | Very high | Source: mandelbulber2 (GPL-3) → no code copy |
| 23 | **Jos Kleinian** | Kleinian group / inversion fractal | Medium | High | Very high | Source: mandelbulber2 (GPL-3) → math-only reuse |
| 24 | **Amazing Surf** | Mandelbox-derived fold hybrid | Medium | High | Very high | Source: mandelbulber2 (GPL-3) |
| 25 | **SqTwice-A** | 2D escape-time polynomial variant | High | Low | Medium-High | Source: GAPFixFractal (GPL-3) → clean-room only |

---

## Gap summary by family

1. **3D attractors are underrepresented** in current app (many 2D attractors exist, but not true 3D ODE/map renderers).
2. **Polyhedral/Kleinian IFS 3D** is the strongest visual gap versus par-fractal + mandelbulber2.
3. **Volumetric hypercomplex fractals** (e.g., volumetric quaternion Julia) are absent and highly differentiating.
4. **Formula variants from GAPFix/mandelbulber2** are rich but GPL-heavy; treat as math references and implement independently.

## Practical implementation order (recommended)

- **Wave A (safe + high impact):** #1, #2, #6, #7, #8, #9-#12
- **Wave B (unique 3D expansion):** #3, #4, #5, #13-#20
- **Wave C (GPL-inspired clean-room):** #21-#25

This gives early wins with permissive-license references first, then progressively higher-complexity additions.
