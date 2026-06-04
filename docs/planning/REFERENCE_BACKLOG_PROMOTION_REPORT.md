# Reference Backlog Promotion Report

**Date:** 2026-06-03  
**Status:** Planning artifact  
**Scope:** Concrete next candidates for turning reference-tier registry entries into app-visible implemented fractals.

## Evidence Snapshot

| Evidence | Result |
|---|---|
| Registry entries | 1588 total |
| Implemented tier | 357 entries |
| Reference tier | 1231 entries |
| Reference entries with existing shader path | 0 / 1231 |
| Strict app-catalog doctor | `forge doctor: OK (1588 entries, 0 error(s), 0 warning(s))` |

All reference-tier entries currently point at generated `shaders/fNNNN_*_gpu.frag` paths that do **not** exist. Promotion is therefore not a pure metadata flip. Each promotion must either:

1. intentionally map a reference entry to an existing generic/family shader; or
2. add a new real shader and thumbnail; or
3. merge/deduplicate the reference entry into an already implemented canonical entry.

## Main Finding

The safest first backlog work is **not** adding new shaders. It is reconciling duplicate and taxonomy-drift entries.

Many reference-tier entries correspond to concepts already implemented under legacy ids or legacy categories. Promoting these blindly would duplicate the app catalog. The first pass should decide whether each reference entry becomes:

- an alias of an implemented entry;
- a variant/preset of an implemented entry;
- a renamed canonical replacement; or
- a truly new implemented fractal.

## Category Counts in Reference Tier

| Category | Reference entries | Promotion difficulty |
|---|---:|---|
| Strange Attractors | 289 | Medium; many can share attractor shader templates, but need formulas/params |
| Cellular & Stochastic | 187 | Medium/high; some static CA are easy, stochastic accumulation is harder |
| Escape-Time (Complex Plane) | 330 | Low/medium; many can use existing escape-time builder patterns |
| L-Systems & Space-Filling | 89 | Medium; many are deterministic distance/procedural shaders |
| IFS & Geometric Construction | 75 | Medium; variants can reuse IFS templates |
| 3D Raymarching & Hypercomplex | 65 | High; strong visuals but frame-time risk |
| Newton / Root-Finding | 48 | Low/medium; best first true-promotion family |
| Tiling & Aperiodic | 41 | Medium; many already have legacy equivalents |
| Number-Theory Fractals | 40 | Medium; strong differentiation, often shader-friendly |
| Lyapunov & Stability | 34 | Medium; reusable logistic-map patterns |
| Reaction-Diffusion & Chemical | 33 | High for live simulation; medium for static/procedural approximations |

## Phase 1: Reconcile Already-Implemented Concepts

These entries have high name similarity to implemented entries. Treat them as **dedup/taxonomy work**, not new fractal implementation.

| Reference entry | Existing implemented match | Recommended action |
|---|---|---|
| `f0006_halley_s_method` — Halley's Method | `halley` — Halley | Merge as alias or canonicalize naming |
| `f0007_schr_der_s_method` — Schröder's Method | `schroeder` — Schröder | Merge as alias; fix ASCII/diacritic naming drift |
| `f0008_chebyshev_s_method` — Chebyshev's Method | `chebyshev` — Chebyshev Fractal | Merge or mark as method variant |
| `f0009_householder_s_method_3rd_order` — Householder H3 | `householder` — Householder Fractal | Merge or split only if order-specific shader differs |
| `f0012_nova_fractal` — Nova Fractal | `nova_degree4`, `nova_cubic`, `nova_julia` | Convert to family umbrella or alias, not a separate app card |
| `f1184_newton_z_3_1` — Newton z^3 - 1 | `newton_z3` | Merge as alias |
| `f1185_newton_z_4_1` — Newton z^4 - 1 | `newton_z4`, `newton_general` | Merge/choose canonical |
| `f1186_newton_z_5_1` — Newton z^5 - 1 | `newton_z5` | Merge as alias |
| `f1187_newton_z_6_1` — Newton z^6 - 1 | `newton_z6` | Merge as alias |
| `f1188_newton_z_7_1` — Newton z^7 - 1 | `newton_z7` | Merge as alias |
| `f1189_newton_z_8_1` — Newton z^8 - 1 | `newton_z8` | Merge as alias |
| `f0230_moore_curve` — Moore Curve | `moore_curve` | Merge as alias |
| `f0232_l_vy_c_curve` — Lévy C Curve | `levy_c_curve` | Merge; normalize Unicode id/name |
| `f0233_mcworter_pentigree` — McWorter Pentigree | `mcworter_pentigree` | Merge as alias |
| `f0237_ces_ro_fractal` — Cesàro Fractal | `cesaro_fractal` | Merge; normalize Unicode id/name |
| `f0686_ammann_beenker_tiling` | `ammann_beenker` | Merge as alias |
| `f0691_pinwheel_tiling` | `pinwheel_tiling` | Merge as alias |
| `f0696_chair_tiling` | `chair_tiling` | Merge as alias |
| `f0698_sphinx_tiling` | `sphinx_tiling` | Merge as alias |
| `f0759_ford_circles_apollonian` | `ford_circles` | Variant/preset under Ford Circles if Apollonian-specific rendering is absent |
| `f0768_collatz_fractal` | `collatz` | Merge as alias |
| `f0771_gauss_map_fractal` | `gauss_map` | Merge as alias |
| `f0777_fibonacci_word_fractal` | `fibonacci_word` | Merge as alias |
| `f0551_bicomplex_mandelbrot` | `bicomplex` | Merge as alias |

### Phase 1 deliverable

Create a registry/dedup patch that records these as aliases/variants or removes duplicate reference pressure without changing app-visible behavior.

Suggested validation:

```bash
PYTHONDONTWRITEBYTECODE=1 python3 scripts/research/forge.py doctor --strict-app-catalog
PYTHONDONTWRITEBYTECODE=1 pytest tests/research/test_dedup.py tests/research/test_doctor.py -q
```

## Phase 2: First True New Promotions

After dedup reconciliation, use Newton/root-finding as the first actual implementation family. It has the best ratio of visual variety to shader complexity.

| Rank | Candidate | Why |
|---:|---|---|
| 1 | `f1190_newton_z_11_1` — Newton z^11 - 1 | Extends already implemented z^3–z^8 pattern; should be family-template friendly |
| 2 | `f1191_newton_z_12_1` — Newton z^12 - 1 | Same template as above; good paired validation with z^11 |
| 3 | `f1192_newton_z_3_z` — Newton z^3 - z | New root layout but still simple polynomial derivative |
| 4 | `f1193_newton_z_4_z` — Newton z^4 - z | Same family as z^3 - z; paired shader/template test |
| 5 | `f1194_newton_z_5_z` — Newton z^5 - z | Same family; adds visual diversity |
| 6 | `f0010_secant_method` — Secant Method | Distinct numerical method; likely reusable root-basin coloring |
| 7 | `f0011_m_ller_s_method` — Müller's Method | Strong method diversity; needs careful formula validation |
| 8 | `f0013_polynomiography_basic_family_iteration` | Product differentiator; should be implemented only with clear formula/test values |
| 9 | `f0001_mitchell_adjusted_newton` | Cited Bridges Math Art entry; good showcase after template is stable |
| 10 | `f0002_mitchell_rotating_c_newton` | More visually distinctive Mitchell variant; likely needs custom params |

### Phase 2 implementation shape

Prefer one generic root-finding shader/module family over one-off shader sprawl:

- parameterized polynomial family where possible;
- root color palette shared across Newton variants;
- module metadata records polynomial, derivative, method, and exactness limits;
- widget tests verify catalog card and shader path;
- pixel smoke test verifies non-black and root-region color diversity.

## Phase 3: High-Value Variant Promotions

These are attractive after Newton promotion proves the flow, because they can often reuse or adapt existing family shaders.

| Candidate | Existing family leverage | Caution |
|---|---|---|
| `f0263_barnsley_fern_variant_thistle` | `barnsley_fern` shader/IFS params | Need true thistle transform params, not just renamed fern |
| `f0264_barnsley_mutant_fern` | `barnsley_fern` shader/IFS params | Good preset/variant candidate |
| `f0266_sierpinski_pentagon_ifs` | `sierpinski_pentagon` | Likely dedup unless IFS construction differs |
| `f0267_sierpinski_hexagon_ifs` | Sierpinski polygon template | Add only if n-gon template is real |
| `f0268_sierpinski_heptagon_ifs` | Sierpinski polygon template | Same as above |
| `f0269_sierpinski_octagon_ifs` | Sierpinski polygon template | Same as above |
| `f0273_koch_snowflake_ifs` | `koch_snowflake` | Likely dedup unless IFS-specific variant differs |
| `f0274_3d_cantor_dust` | `cantor_dust`, 3D projection conventions | Clarify 2D vs 3D render path |
| `f0276_menger_sponge_3d` | existing Menger/KIFS shaders | Performance budget required |
| `f0281_dragon_ifs` | `dragon_curve` | Likely variant/preset candidate |

## Phase 4: Distinctive But Riskier Families

### Reaction-diffusion

Do not start with live Gray-Scott simulation unless the render pipeline supports stateful/multi-pass updates. Safer first options:

- static procedural Turing pattern approximation;
- CPU-generated thumbnail/reference implementation;
- explicit “not live simulation” metadata.

Best candidates after a state strategy exists:

- `f0724_gray_scott_spots`;
- `f0726_gray_scott_mazes`;
- `f0730_gray_scott_stripes`;
- `f0739_turing_spots_isotropic`;
- `f0741_turing_labyrinth`.

### Number theory

Good product differentiation, but some entries are curves/functions rather than area fractals. First candidates should be shader-friendly 2D visual fields:

- `f0759_ford_circles_apollonian` if it is made distinct from existing `ford_circles`;
- `f0770_continued_fraction_fractal`;
- `f0772_thue_morse_sequence`;
- `f0773_thue_morse_2d_heatmap`;
- `f0785_eisenstein_integer_lattice_fractal`;
- `f0786_gaussian_integer_lattice_fractal`.

### 3D/hypercomplex

High screenshot value, but should be gated by frame-time and shader compile checks. Start with variants that reuse existing raymarchers:

- quaternion Julia parameter variants as presets, not separate cards, unless they have distinct formulas;
- Mandelbulb power variants as presets/parameters, not separate one-off shaders;
- KIFS variants only if each has distinctive folding rules.

## Promotion Checklist

For every promoted entry:

- resolve duplicate/alias status first;
- ensure shader path exists and is declared in `pubspec.yaml`;
- generate a real thumbnail, not a placeholder;
- update app registry/module wiring;
- run strict app-catalog doctor;
- run focused Dart analyzer/tests for touched module/catalog code;
- add or update pixel smoke coverage for non-black output and frame progression;
- document exactness/deep-zoom capability if it is an escape-time/root-finding family.

## Recommended Next Implementation Slice

**Do Phase 1 dedup/taxonomy reconciliation before adding a shader.**

Reason: it reduces catalog ambiguity, prevents duplicate app entries, and makes later promotion metrics honest.

If implementation is preferred immediately, choose **one** Newton true-promotion slice:

> Implement `f1190_newton_z_11_1` using the existing Newton root-of-unity family pattern, then validate with strict app-catalog doctor and a non-black pixel smoke.
