<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# fractals-library

## Purpose
Reference library of 200 fractal definitions organized by mathematical category. Each fractal is defined in a standalone Dart file with mathematical description, parameter specifications, rendering notes, and category metadata. Used as a reference for implementing GPU shaders and fractal modules.

## Key Files

| File | Description |
|------|-------------|
| `data/fractal_manifest.json` | Master manifest listing all 200 fractals with IDs, names, and categories |
| `docs/fractal-library.md` | English documentation overview |
| `docs/fractali-library.md` | Alternate language documentation |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `categories/` | 12 subdirectories organized by mathematical category (see below) |
| `data/` | Manifest and structured reference-library data |
| `docs/` | Human-readable reference-library overviews |
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
- Manifest data lives in `data/fractal_manifest.json`; overview docs live in `docs/`

### Common Patterns
- Fractal IDs are `f001` through `f200`
- Each file contains: mathematical description, parameter list, rendering approach, category tags
- Category directories group fractals by mathematical family

## Dependencies

### Internal
- Referenced by `lib/core/modules/` when implementing new fractal modules

<!-- MANUAL: -->

<!-- karpathy-guidelines:start -->
## Karpathy-Inspired Agent Guardrails

Source: https://github.com/forrestchang/andrej-karpathy-skills at commit `2c60614`.

These guardrails supplement the local instructions above. Local project, safety, and user-specific rules win on conflict.

Tradeoff: they bias toward caution over speed for non-trivial work; use judgment for obvious one-line fixes.

### Think Before Coding

- State assumptions and choose the simplest reversible solution supported by repository evidence. Ask only when a missing decision prevents safe, authorized work; continue independent work meanwhile.
- Briefly record material tradeoffs and select a reasonable default for routine local work.
- Push back when a simpler approach meets the goal.

### Simplicity First

- Build the minimum code that solves the requested problem.
- Avoid speculative features, single-use abstractions, and unnecessary configurability.
- If the solution is growing large, stop and simplify before continuing.

### Surgical Changes

- Touch only files and lines required by the request.
- Preserve existing style, comments, and nearby code unless the task requires changing them.
- Clean up only dead code introduced by your own change; mention unrelated dead code instead of deleting it.

### Goal-Driven Execution

- Convert the request into verifiable success criteria before editing.
- For multi-step work, state a short plan with a verification check for each step.
- Loop until the relevant tests, builds, or manual checks prove the goal is met.
<!-- karpathy-guidelines:end -->

<!-- karpathy-project-adjustment:start -->
## Project-Specific Karpathy Adjustment

This section localizes the Karpathy guardrails for `workspace-sidon/trebuchet-dynamics/flutter-fractal-forge/fractals-library`. Source inspiration: https://github.com/forrestchang/andrej-karpathy-skills at commit `2c60614`.

- Project family: Sidon fractal/rendering and visual-app workspace.
- Local focus: GPU/fractal rendering, Flutter/Electron apps, shaders, accessibility, and measurable visual behavior.
- Stack cues: Flutter/Dart.
- Evidence to prefer: test output, analyzer/linter output, screenshot/pixel checks when relevant, shader compile logs, frame/performance metrics, and exact UI state text.
- Surgical boundary: do not rely on visual vibes; validate rendering numerically and describe results in screen-reader-friendly text.
- For underspecified visual work, derive measurable acceptance criteria from existing patterns and accessibility requirements, implement a reversible improvement, and validate it. Escalate only a material unresolved product decision; continue other work.
<!-- karpathy-project-adjustment:end -->

## Autowork local execution

Follow the repository-root Autowork policy for autonomous local planning,
implementation, verification and scoped commits. Keep this directory’s technical
contracts and live-operation limits; ordinary local work needs no owner reply.
