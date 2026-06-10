# Animated Fractal Catalog Expansion Backlog

**Date:** 2026-06-06
**Status:** Research backlog / planning artifact
**Goal:** Add animated fractal families to Flutter Fractal Forge without weakening catalog honesty. Animated app entries need deterministic frame behavior, motion controls, and measurable frame validation.

## Current app evidence

| Signal | Evidence |
|---|---:|
| Shader inventory | 469 `.frag` files under `shaders/` |
| Animated shader audit | `docs/planning/ANIMATED_SHADER_AUDIT_2026_06_06.csv` |
| Declarative app configs audited | 462 rows |
| Configs with code references to `uTime` | 442 rows |
| Top time-aware shader directories | `strange_attractors` 69, `ifs_and_geometric` 52, `root_finding` 34, `cellular_and_stochastic` 15, raymarched 3D 7 |
| Audit animation-class guesses | color 347, growth 36, sampling 30, camera/raymarch 29, static/unused 20 |
| Renderer timing | `FractalRenderer` owns a long-running `AnimationController` and passes time into module uniform setters |
| Test safety | Renderer disables always-running ticker in automated tests via runtime mode checks |
| Existing motion feature | `AutoExploreService` supports continuous cinematic zoom loops |
| Existing animation-like params | `colorCycleSpeed`, kaleidoscope rotation, auto-explore speed, shader `uTime` uniforms |

The app already has the basic infrastructure for **time-parametric shader animation**. It does not yet have a proven general multipass/ping-pong texture pipeline for stateful simulations.

## Animation classes

Use these classes in registry metadata and implementation planning so “animated” does not mean one vague thing.

| Class | Description | Current feasibility | Examples |
|---|---|---|---|
| `time_parametric` | Single-pass shader changes with `uTime`; no persistent state | Ready now | color cycling, pulsing orbit traps, kaleidoscope rotation, Lichtenberg growth radius |
| `parameter_morph` | App/controller animates one or more uniforms along a loop | Ready with small UI/planner work | Julia seed loops, Mandelbulb power sweep, Newton damping sweep |
| `camera_path` | View/rotation/zoom changes over time, formula stays fixed | Already partially supported by auto-explore | deep-zoom flights, 3D orbiting, pan/zoom tours |
| `progressive_accumulation` | Frame improves over time by accumulating samples/histograms | Needs prototype | Buddhabrot full, Nebulabrot, fractal flames, orbit-density attractors |
| `stateful_grid` | Next frame depends on previous texture/grid state | Needs multipass/ping-pong or CPU state | Gray-Scott, Lenia, Physarum, cellular automata evolution |
| `growth_process` | Apparent growth front over time; can be stateless approximation or stateful simulation | Approximation ready; true simulation later | DLA, Lichtenberg, corrosion, cracks, crystals, plants |
| `audio_reactive` | Parameters driven by audio/rhythm; visual fractal remains deterministic per input frame | Future feature | fractal oscilloscope, rhythmic L-systems, Fourier/fractal harmonics |
| `interactive_dynamical` | User input changes attractor/formula live while preserving stable render | Future polish | magnetic pendulum basins, double pendulum phase maps, coupled maps |

## Highest-value animated frontiers

| Priority | Animated frontier | Why it is cool | First practical path |
|---:|---|---|---|
| 1 | **Lichtenberg / lightning growth** | Instantly legible, dramatic, store-screenshot friendly | Existing `lichtenberg_growth` shader; validate `uTime` frame progression |
| 2 | **Reaction-diffusion morphogenesis** | Organic spots/stripes/coral; true animation differentiator | Start with `gray_scott_rd` approximation; prototype true ping-pong later |
| 3 | **Fractal flames / orbit-density art** | Classic animated generative art; huge parameter space | Time-parametric preview now; progressive accumulator later |
| 4 | **3D raymarched flythroughs** | High wow factor, works with existing 3D shaders | Camera/rotation path + power/material morphs |
| 5 | **Julia/parameter morph loops** | Smooth looping Mandelbrot/Julia transformations | Uniform path presets; deterministic loop duration |
| 6 | **Buddhabrot/Nebulabrot progressive reveal** | Looks like a nebula forming over time | Validate existing approximation; future histogram accumulation |
| 7 | **Strange-attractor orbit evolution** | Trails, ribbons, flow fields; great motion aesthetics | Time-sliced orbit-density shaders; later accumulation trails |
| 8 | **Kaleidoscope and symmetry animation** | Low-cost, colorful, shareable short loops | Existing kaleidoscope shader pack; decide catalog vs effect category |
| 9 | **Natural growth systems** | Plants, cracks, rivers, slime, crystals; accessible to users | Stateless growth approximations first |
| 10 | **Musical/rhythmic fractals** | Unique catalog category beyond visual-only apps | Reference-tier research first; app feature later |

## Near-term app-visible candidates from existing shaders

These are already close because shader files exist and are declared. They still need frame validation before claiming animation quality.

| Candidate | Existing shader | Animation class | Validation needed |
|---|---|---|---|
| `lichtenberg_growth` | `shaders/cellular_and_stochastic/lichtenberg_growth_gpu.frag` | `growth_process`, `time_parametric` | ✅ Validated at t=0/0.5/1.0; measurable growth-front progression |
| `gray_scott_rd` | `shaders/cellular_and_stochastic/gray_scott_rd_gpu.frag` | `time_parametric` now, `stateful_grid` later | ✅ Procedural approximation validated at t=0/10/50; not a true stateful simulation yet |
| `fractal_flame` | `shaders/escape_time_family/geometry_and_ifs/fractal_flame_gpu.frag` | `time_parametric` now, `progressive_accumulation` later | ✅ Single-pass preview validated at t=0/1/10; progressive histogram accumulation not claimed |
| `buddhabrot_full` | `shaders/escape_time_family/families/buddhabrot/buddhabrot_full_gpu.frag` | `time_parametric` now, `progressive_accumulation` later | Confirm whether `uTime` changes sample seed or just colors |
| `magnetic_pendulum` | `shaders/escape_time_family/experimental_named/physical_simulation/magnetic_pendulum_gpu.frag` | `parameter_morph`, `interactive_dynamical` | Animate magnet strength/damping; verify basins stay readable |
| `mandelbulb_time_modulated` | `shaders/3d_and_hypercomplex/raymarched_volumes/mandelbulb_time_modulated_gpu.frag` | `time_parametric`, `camera_path` | Frame-budget proof and 3D screenshot/pixel sanity |
| `domain_coloring` | `shaders/escape_time_family/orbit_and_domain/domain_coloring_gpu.frag` | `parameter_morph` | Animate function selector/phase offset; ensure accessibility description |
| `phase_portrait` | `shaders/escape_time_family/orbit_and_domain/phase_portrait_gpu.frag` | `parameter_morph` | Loop phase offset; assert color-wheel continuity |
| Kaleidoscope pack | `shaders/kaleidoscopes/**` | `time_parametric`, `parameter_morph` | Owner decision: catalog entries vs effect layer |
| Strange-attractor pack | `shaders/strange_attractors/**` | `time_parametric`, future `progressive_accumulation` | Distinguish static phase portrait from animated trail/density renderer |

## Animated families to research next

### A. Time-parametric escape-time and root-finding

These are single-pass and easiest to app-admit:

- Julia seed loops: circle, epicycle, Lissajous, cardioid-boundary paths
- Mandelbrot parameter-plane orbit tours
- Multibrot power sweep loops
- Burning Ship / Tricorn / Celtic morph loops
- Phoenix memory-term animation
- Nova relaxation animation
- Newton damping animation
- Chebyshev-Halley family parameter sweep
- Durand-Kerner root tracking animation
- Root constellation morphs: roots rotate, split, merge, or orbit
- Orbit-trap animation: moving point, circle, line, rose, star traps
- Domain-coloring phase rotation and contour pulse
- Rational map pole/zero morph loops

### B. 3D raymarched animation

Good for premium screenshots and video export:

- Mandelbulb power breathing
- Mandelbox fold-scale sweep
- KIFS fold-angle morphs
- Quaternion Julia constant path loops
- Kleinian / Schottky parameter morphs
- Apollonian sphere packing inversion radius loops
- Coxeter kaleidoscope mirror-angle loops
- Hyperbolic honeycomb flythroughs
- Camera orbit presets with depth-of-field and palette cycling
- Material/light animation: sun rotation, ambient-occlusion pulse, fog sweep

### C. Progressive orbit-density renderers

High visual payoff; needs accumulation architecture:

- Buddhabrot progressive reveal
- Nebulabrot RGB channel accumulation
- Anti-Buddhabrot reveal
- Fractal flame density accumulation
- Strange-attractor trail accumulation
- Clifford / de Jong animated density fields
- Hopalong / Gumowski-Mira orbit painting
- Chaotic map particle swarms
- Brownian tree / DLA progressive growth
- Electric Sheep-style flame mutation loops

### D. Stateful simulations and morphogenesis

These need a true state path or honest approximation label:

- Gray-Scott parameter atlas animation
- Brusselator waves
- Oregonator / Belousov-Zhabotinsky spirals
- FitzHugh-Nagumo excitable media
- Gierer-Meinhardt activator-inhibitor spots
- Cahn-Hilliard phase separation
- Swift-Hohenberg stripe formation
- Complex Ginzburg-Landau turbulence
- Lenia / Orbium families
- Physarum slime mold transport networks
- Cyclic cellular automata waves
- Wireworld, Brian's Brain, HighLife, Day & Night evolution
- Abelian sandpile avalanches
- Forest-fire spread and regrowth
- Percolation front growth

### E. Natural growth and physical process fractals

Great for approachable catalog entries:

- Lichtenberg figure branching
- Dielectric breakdown model growth
- DLA crystal growth
- Snowflake growth fronts
- Coral accretion
- Crack propagation
- River network erosion
- Vascular tree pulse/growth
- Leaf venation growth
- Phyllotaxis bloom animation
- Root/mycelium network growth
- Lightning strike and afterglow loops
- Mountain/cloud turbulence morphs

### F. L-systems, tilings, and constructed animation

Good for teaching and accessibility because the construction sequence is explainable:

- L-system rewrite generation reveal
- Hilbert/Peano/Moore curve drawing animation
- Dragon curve fold animation
- Koch snowflake construction stages
- Sierpinski subdivision reveal
- Penrose deflation/inflation morph
- Hat/spectre monotile patch growth
- Hyperbolic tiling expansion
- Origami/paper-folding fractals
- Architectural fractal growth: Gothic tracery, Islamic pattern expansion

### G. Musical and rhythmic fractals

Reference-tier first; app requires audio/rhythm feature design:

- Self-similar rhythm visualizers
- Euclidean rhythm tilings
- Fractal metronome trees
- L-system melody curves
- Fourier-domain fractal harmonics
- Chladni/fractal resonance approximations
- Audio-reactive Julia/domain-coloring phase
- MIDI-driven parameter morphs

## Registry metadata recommendation

Add these fields when the registry schema evolves for animation:

```yaml
animation:
  class: time_parametric | parameter_morph | camera_path | progressive_accumulation | stateful_grid | growth_process | audio_reactive | interactive_dynamical
  defaultEnabled: false
  loopSeconds: 8.0
  deterministic: true
  reducedMotionFallback: static_t0 | static_best_frame | disabled
  frameValidation:
    sampleTimes: [0.0, 0.5, 1.0]
    requireNonIdenticalFrames: true
    minNonBlackRatio: 0.02
    maxFrameDelta: null
```

Until the schema exists, track this in planning docs and candidate metadata notes rather than overloading `category` or `tier`.

## Candidate animation wording pending schema

These notes are screenshot-friendly and screen-reader-friendly wording for app copy, export metadata, and future registry fields. They intentionally separate visual behavior from implementation claims.

### `lichtenberg_growth`

- **Description:** Branching electric filaments grow outward from the center like a Lichtenberg lightning figure, with a bright moving growth front and fading branch glow.
- **Animation class:** `growth_process`, `time_parametric`.
- **Honesty note:** Stateless shader approximation of outward dielectric-breakdown-style growth; not a stored simulation history.
- **Reduced-motion fallback:** use `static_best_frame` at `t=1.0` because `t=0.0` is the black seed/pre-growth frame.
- **Loopability:** not claimed; current proof is frame progression, not a seamless loop.
- **Validation sample times:** `[0.0, 0.5, 1.0]`.

### `gray_scott_rd`

- **Description:** Organic reaction-diffusion spots, stripes, and maze-like bands slowly drift and warp, suggesting chemicals spreading and competing across a surface.
- **Animation class:** `time_parametric` now; future target `stateful_grid` only after ping-pong or CPU-state simulation exists.
- **Honesty note:** Single-pass procedural Gray-Scott-like approximation controlled by feed/kill/scale; not a true iterative reaction-diffusion grid yet.
- **Reduced-motion fallback:** use `static_t0` or a user-selected still frame.
- **Loopability:** not claimed; current proof is slow measurable drift, not a seamless loop.
- **Validation sample times:** `[0.0, 10.0, 50.0]` because the shader intentionally evaluates `uTime * 0.01`.

### `fractal_flame`

- **Description:** A symmetric nonlinear IFS flame preview twists and recolors as its affine transforms move, producing bright swirling density patterns.
- **Animation class:** `time_parametric` now; future target `progressive_accumulation` only after a histogram/accumulator renderer exists.
- **Honesty note:** Single-pass per-pixel IFS density preview with variation and symmetry uniforms; not an Apophysis/Electric-Sheep-style progressive flame renderer yet.
- **Reduced-motion fallback:** use `static_t0` or a curated still frame with the same variation/symmetry settings.
- **Loopability:** not claimed; current proof is frame progression, not a seamless loop.
- **Validation sample times:** `[0.0, 1.0, 10.0]`.

## Animated app admission gates

An animated fractal should be app-visible only when these checks pass:

1. **Static render proof:** t=0 frame is non-black and not a placeholder.
2. **Frame progression proof:** t=0 and t=Δ differ by a measurable pixel hash or nonzero frame-delta ratio.
3. **Loop proof where claimed:** t=0 and t=loopSeconds match within tolerance, or the entry is explicitly non-looping.
4. **Motion accessibility:** honors `disableAnimations`; has a static fallback frame.
5. **Performance budget:** target device frame time measured for at least one representative resolution.
6. **Determinism:** pseudo-random shaders seed from stable uniforms, not nondeterministic runtime state.
7. **Export honesty:** exported stills/video identify the same params and time/frame range.
8. **Screen-reader description:** state what changes over time, e.g. “branching lightning grows outward,” not just “animated fractal.”

## Practical rollout slices

### Slice A — Animated metadata audit ✅ completed 2026-06-06

Produced `docs/planning/ANIMATED_SHADER_AUDIT_2026_06_06.csv`, classifying declarative app modules by guessed animation class and registry status. The audit found 442 time-referenced shader configs out of 462 declarative configs.

Future refinement should manually review the heuristic class guesses, especially color-only vs geometry-changing `uTime` uses.

Original target:

- time-aware shader path;
- app module ID;
- category;
- whether `uTime` affects geometry, color only, or sampling;
- whether reduced-motion fallback is obvious.

### Slice B — Validate one existing animated shader ✅ completed 2026-06-06

Validated target: `lichtenberg_growth`.

Implemented `test/animated_lichtenberg_frame_delta_test.dart`, which renders the actual fragment shader offscreen at `t=0.0`, `t=0.5`, and `t=1.0`, then checks existing `RenderValidation` frame and pair metrics.

Validation receipt:

```text
/home/xel/flutter/bin/flutter test test/animated_lichtenberg_frame_delta_test.dart
[animated-lichtenberg] nonBlack=t0:0.0000 t05:0.5720 t1:1.0000 delta0_05:0.5735 delta05_1:1.0000
All tests passed
```

Interpretation:

- `t=0.0` is the seed/pre-growth state and is expected to be black.
- `t=0.5` and `t=1.0` are visibly non-black.
- Both requested frame intervals have large measurable deltas, proving real time-parametric growth.
- Classification: `growth_process/time_parametric`.

Follow-up deliverables:

- ✅ screenshot-friendly accessibility description added in “Candidate animation wording pending schema”;
- decide where animation metadata should live once the registry schema grows.

### Slice B.1 — Validate Gray-Scott procedural animation ✅ completed 2026-06-06

Validated target: `gray_scott_rd`.

Implemented `test/animated_gray_scott_frame_delta_test.dart`, which renders the actual fragment shader offscreen at `t=0.0`, `t=10.0`, and `t=50.0`, then checks existing `RenderValidation` frame and pair metrics.

Validation receipt:

```text
/home/xel/flutter/bin/flutter test test/animated_gray_scott_frame_delta_test.dart
[animated-gray-scott] nonBlack=t0:1.0000 t10:1.0000 t50:1.0000 delta0_10:0.2428 delta10_50:0.4458
All tests passed
```

Interpretation:

- All sampled frames have sane non-black histograms.
- `t=0.0 → t=10.0` and `t=10.0 → t=50.0` exceed frame-progression thresholds.
- The shader deliberately uses `uTime * 0.01`, so subsecond `t=0.0/0.5/1.0` samples were below visible-delta thresholds in probing.
- Classification: procedural `time_parametric` approximation now; do not claim true `stateful_grid` Gray-Scott simulation until a stateful renderer exists.

### Slice B.2 — Validate fractal flame preview animation ✅ completed 2026-06-06

Validated target: `fractal_flame`.

Implemented `test/animated_fractal_flame_frame_delta_test.dart`, which renders the actual single-pass fragment shader offscreen at `t=0.0`, `t=1.0`, and `t=10.0`, then checks existing `RenderValidation` frame and pair metrics.

Validation receipt:

```text
/home/xel/flutter/bin/flutter test test/animated_fractal_flame_frame_delta_test.dart
[animated-fractal-flame] nonBlack=t0:1.0000 t1:1.0000 t10:1.0000 delta0_1:0.9498 delta1_10:0.9498
All tests passed
```

Interpretation:

- All sampled frames have sane non-black histograms.
- `t=0.0 → t=1.0` and `t=1.0 → t=10.0` exceed frame-progression thresholds.
- This proves the current single-pass preview is animated through time-parametric affine/color behavior.
- Classification: `time_parametric` preview now; do not claim true `progressive_accumulation` flame rendering until a histogram accumulator exists.

### Slice C — Add animation controls surface

Minimum product controls:

- play/pause animation;
- speed;
- loop length;
- reset to static frame;
- respect system reduced-motion.

### Slice D — Prototype stateful rendering

Prototype only; do not commit to app visibility until evidence exists.

Questions:

- Can Flutter’s current renderer support ping-pong textures cleanly?
- Is CPU/offscreen accumulation acceptable for thumbnails or exports?
- Which family gets first true state path: Gray-Scott, Lenia, Buddhabrot, or flame?

### Slice E — Animated catalog pack

After Slice B/C, admit a small pack:

1. `lichtenberg_growth`
2. `gray_scott_rd` as procedural approximation or true sim if proven
3. `fractal_flame` preview
4. `mandelbulb_time_modulated`
5. one Julia seed loop
6. one root-finding damping loop
7. one kaleidoscope loop if owner approves kaleidoscopes as catalog entries

## Red lines

- Do not mark stateful simulations as true simulations if they are stateless approximations.
- Do not count every time value or parameter preset as a new fractal type.
- Do not add autoplaying motion without a reduced-motion fallback.
- Do not claim loopability without measuring t=0 vs t=loop.
- Do not add progressive accumulation to implemented tier until memory/performance behavior is measured.
