<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# fractals-library

## Purpose
Reference library of 200 fractal definitions organized by mathematical category. Each fractal is defined in a standalone Dart file with mathematical description, parameter specifications, rendering notes, and category metadata. Used as a reference for implementing GPU shaders and fractal modules.

## Key Files

| File | Description |
|------|-------------|
| `fractal_manifest.json` | Master manifest listing all 200 fractals with IDs, names, and categories |
| `fractal-library.md` | English documentation overview |
| `fractali-library.md` | Alternate language documentation |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `categories/` | 12 subdirectories organized by mathematical category (see below) |
| `scripts/` | Validation scripts for manifest integrity |

### Category Subdirectories
| Category | Fractals | Description |
|----------|----------|-------------|
| `the_escape_time_family/` | f001-f025 | Mandelbrot, Julia, Burning Ship, Celtic, etc. |
| `convergent_and_root_finding/` | f026-f034 | Newton, Halley, Secant, Nova, Magnet |
| `strange_attractors/` | f036-f055 | Lorenz, Rossler, Henon, Ikeda, Clifford |
| `ifs_and_geometric_construction/` | f056-f080 | Sierpinski, Koch, Dragon, Barnsley Fern |
| `l_systems_and_space_filling_curves/` | f082-f089 | Hilbert, Peano, Gosper, Moore |
| `3d_raymarching_and_hypercomplex/` | f091-f100 | Mandelbulb, Mandelbox, Quaternion |
| `trigonometric_and_transcendental/` | f101-f115 | Sine Julia, Exponential, Zeta |
| `advanced_rational_and_polynomial/` | f116-f130 | Chebyshev, Legendre, Taylor |
| `the_lyapunov_and_stability/` | f131-f140 | Lyapunov, Standard Map, Arnold Cat |
| `deep_chaos_and_flows/` | f141-f155 | Chua, Sprott, Thomas, Four-Wing |
| `high_dimensional_algebra/` | f156-f170 | Octonion, Sedenion, Pseudo-Kleinian |
| `tiling_and_graph_fractals/` | f171-f184 | Hat Monotile, Penrose, Rauzy |
| `cellular_and_stochastic/` | f185-f200 | Buddhabrot, DLA, Langton, Sandpile |

## For AI Agents

### Working In This Directory
- Each `fXXX_*.dart` file is a standalone fractal definition (NOT imported by the app)
- These serve as reference material for shader implementation
- The manifest JSON is the source of truth for fractal IDs and names
- Use `scripts/validate_manifest.py` to verify manifest integrity

### Common Patterns
- Fractal IDs are `f001` through `f200`
- Each file contains: mathematical description, parameter list, rendering approach, category tags
- Category directories group fractals by mathematical family

## Dependencies

### Internal
- Referenced by `lib/core/modules/` when implementing new fractal modules

<!-- MANUAL: -->
