# Beautiful fractals worth adding — high visual impact, shader-friendly

Research pass for `flutter-fractal-forge`, 2026-10-31. Question: *which visually
striking fractals are missing from the catalog, and which of them are cheap to add
as a single fragment shader?*

## Bottom line

The catalog's **iterated-formula space is saturated**. It holds 582 `.frag` files and
1,619 registry entries, of which 376 are implemented and **1,243 are already catalogued
as `reference`-tier proposals with known formulas**. There is no unclaimed "famous
2D escape-time fractal" left to name — the obvious remaining entries are variants or
parameter presets, not new forms.

What is *not* saturated, and what this pass recommends, is three things:

1. **One genuinely new algebraic system**: the Bristorian ("imordial") algebra, whose
   `z² + c` set is a 3D Mandelbrot family that is **non-associative, non-commutative and
   non-alternative** — a different object from the quaternion/bicomplex/tricomplex
   families already implemented. Verified against a documented, MIT-licensed GLSL
   reference implementation (numeric agreement to 3.6e-15). **Recommended first.**
2. **One near-free new operator**: the inversion fold `p ← |p| / |p|² − c`. No shader in
   the repo performs this operator; the closest things are circle-inversion *group*
   limit sets (Kleinian/Schottky), which is a different construction. Cost is that of an
   ordinary 2D escape-time shader.
3. **Two "cheap beauty" fields** that are only *adjacent* to existing genres, plus a
   **volumetric rendering mode** that would raise the visual ceiling of the 90+
   existing raymarched entries without adding a single new formula.

Four candidates were prototyped offline and scored with the repo's own
`LaunchVisualMetrics` definitions; all pass the catalog's thumbnail gate. Every
prototype, metric row and command is in this directory.

## Method and limits

| Item | Value |
| --- | --- |
| Depth | `standard` (broad pass 10 query variants, gap pass 5) |
| Sources attempted | `openalex`, `crossref`, `arxiv`, `semantic-scholar` |
| Effective caps | 10 queries / 5 sources / 50 requests per batch |
| Requests used | 40/50 (broad), 20/50 (gap pass) |
| Stop reason | `completed` in both batches |
| Coverage | 378 unique records (broad), 135 (gap); `consecutive_low_yield = 0` — **not** saturated, so the runs are a bounded sweep, not exhaustive retrieval |
| Failures | 9 × `semantic-scholar` HTTP 429 rate-limit (6 broad, 3 gap). No other source failed. Recorded verbatim in `failures.jsonl` |
| Citation expansion | 1 attempt, 1 success (`10.1007/s003710050084`, 25 edges → `citation-graph.json`) |
| Full text | none fetched. No PDFs, no copyrighted full text |
| Prototypes | numpy/Pillow, 512², no GPU, no network |

Source-checking discipline: bibliographic anchors were used to identify *what a
construct is*, not to attribute claims I could not read. Several records in
`results-deduped.jsonl` carry empty abstracts (OpenAlex/Crossref metadata only); no
finding is attributed to a paper whose abstract I did not have.

Identity checking: every candidate below was grepped against `shaders/`, `lib/` and the
1,243-name reference ledger before being called new. Counts in the tables are from those
greps, not estimates.

## Where the visual gap actually is

The repo's own quality signals (`launch_visual_metrics.dart`) are *descriptive*, not
aesthetic — "pass" only means "not near-black, not washed out, not one flat colour".
Measured over the prototypes, "pass" and "beautiful" are clearly different axes:

| Candidate | center detail | edge detail | luminance sd | mean luma | verdict |
| --- | --- | --- | --- | --- | --- |
| `baseline_mandelbrot` (catalog-style control) | 0.670 | 0.252 | 32.52 | 94.34 | pass |
| `kaliset_inversion` | 0.350 | 0.358 | 22.81 | 81.07 | pass |
| `chladni_nodal_fractal` | 0.439 | 0.433 | 27.60 | 66.66 | pass |
| `domain_warp_nebula` | 0.942 | 1.000 | 70.84 | 141.58 | pass |
| `brimordial_slice_stack` | 0.892 | 0.000 | 52.82 | 26.95 | pass |

Two lessons the evidence supports:

- **Detail metrics reward texture, not form.** The ridged nebula wins on every detail
  score and is the least *mathematically* interesting of the four.
- **A centred volumetric object scores `edgeDetailScore = 0.0`.** Volumetric objects on
  black will systematically look "unframed" to the launch audit unless the object is
  scaled to fill the frame or the frame gets a glow floor. That is a framing rule for
  any future volumetric entry, not a defect in the fractal.

So the ranking below is *not* by these metrics. It is by **visual ceiling × novelty per
GPU cycle**, with the metrics used only as a rejection gate.

## Recommended additions (ranked)

### 1. Imordial / Bristorian `z² + c` — `brimordial_brot` (new algebra, 3D + 4D sections)

**Status: absent from the catalog and from the reference ledger** (`grep -ri bristor`,
`imordial`, `bristor_product` → 0 hits in `shaders/`, `lib/`, registry).

The algebra (published rule, verified):

```
e_a · e_a = −1
e_a · e_b = sgn(b − a) · e_b      (a ≠ b)       ⇒  e1·e2 = +e2,  e2·e1 = −e1
```

There is no `ij = k`. That single change makes the algebra non-commutative,
**non-associative** and non-alternative, so a cubic map depends on bracketing
(`(zz)z ≠ z(zz)`) and the plane of a 4D orbit produces structure the quaternion and
tricomplex entries cannot produce. Closed form used in the prototype (matches the
published GLSL `bp_square` to `3.6e-15` over 2,000 random samples):

```glsl
vec4 bp_square(vec4 z) {   // z = (real, e1, e2, e3)
  return vec4(z.x*z.x - z.y*z.y - z.z*z.z - z.w*z.w,
              z.y*(2.0*z.x - z.z - z.w),
              z.z*(2.0*z.x + z.y - z.w),
              z.w*(2.0*z.x + z.y + z.z));
}
```

Cost: 1 square = ~14 mul + 9 add, i.e. about a quaternion square. With the published
Jacobian (`J(z)v = z·v + v·z`, bilinear — no associativity needed) the existing
raymarch DE loop drops in unchanged. Use the cheap `vec3` B2 form (two imaginary units)
for most presets and `vec4` B3 for the 4D slices.

Why it looks good: the escape set is a rounded, cusped solid with faceted lobes and thin
filament "fins" between sections; a translucent slice stack (prototype) reads as a
glowing glass body. Prototype: `prototypes/brimordial_slice_stack.png`
(center 0.892, sd 52.82). 4D beta/axis sections give real parameter variety rather than
the current hypercomplex entries' power-sweep variety.

Integration: one `Raymarched3DConfig` in
`lib/core/modules/builders/raymarched_3d/catalog_impl.dart`, one `.frag` in
`shaders/3d_and_hypercomplex/raymarched_volumes/`, `pubspec.yaml` shader entry, registry
entry + formula hash. Reference GLSL (MIT, attribution requested) is portable as-is:
`core/bristor_product/v1.glsl` and `core/brot_de_march/v1.glsl` from
`github.com/dougbristor/bristorbrot` — the latter already implements the section roll,
leash-capped directional DE, adaptive safety and hit epsilon the repo's other
raymarchers use.

Follow-on that costs almost nothing once the algebra exists: **two cubic entries**
(`(zz)z + c` and `z(zz) + c`), which are genuinely different fractals from the same
formula — a visual demonstration of non-associativity, and a natural "compare both
brackets" preset pair.

### 2. Inversion-fold lattice — `inversion_fold_kali` (new operator, near-zero cost)

**Status: absent.** `grep -rl "/ *dot("` finds only line-segment projections and two
circle-inversion group sets; no shader performs `|p| / |p|²`.

```glsl
vec2 p    = uv / zoom + center;
vec2 c    = julia ? uJuliaC : p;          // Julia or Mandelbrot analogue
float trap = 1e9, acc = 0.0;
for (int i = 0; i < 24; i++) {
  float d = max(dot(p, p), 1e-6);
  p = abs(p) / d - c;
  p = mat2(0.9987, -0.05, 0.05, 0.9987) * p;   // tiny per-step rotation
  trap = min(trap, abs(p.x) + abs(p.y));
  acc += exp(-5.0 * trap);
}
```

This is the "Kali" family formula, which is practitioner/community-sourced (no academic
primary source, and no verifiable canonical parameter set — see *Limits*). Present it as
"inversion-fold kaleidoscopic set", not as an attribution.

Cost: 24 iterations × ~8 flops, branch-free — cheaper than the existing 2D entries that
run 500-iteration loops. Prototype: `prototypes/kaliset_inversion.png` (center 0.350,
sd 22.81) shows the characteristic dense filigree with orbital "eyes". It is the best
beauty-per-cycle item in this report, and it fills a real hole: the catalog is full of
polynomial and transcendental escape-time maps but has no *inversion* escape-time map.

Integration: declarative `EscapeTimeConfig` part file + one `.frag`; no new Dart class.

### 3. Volumetric slice-stack render mode (technique, applies to 90+ existing entries)

**Status: absent as a mode.** The raymarchers do surface shading with alpha, and
`luminous_fold_lattice` accumulates emission along the ray, but nothing renders an
escape-time set as an ordered stack of translucent boundary slices.

Prototype (`prototypes/brimordial_slice_stack.png`) is exactly this: for 56 offsets
through a perpendicular coordinate, take the boundary of the bounded region, tint by
offset, accumulate with a soft bloom. The result reads as a glass object and — critically
— makes the *4D-ness* legible, which surface shading cannot do.

Cost: N_slices × (iteration + 2 morphology passes) on the CPU prototype; in GLSL it is
one extra loop dimension, so the natural form is `uSlices` (4–64) with early exit on
saturated alpha. Cheap enough for a preset, expensive enough to be opt-in.

Value: it is a *multiplier* on content already shipped — Mandelbulb, Mandelbox, quaternion
Julia, Menger, the recursive crystals, all imordial slices.

### 4. Nodal-line ("cymatic") field — `chladni_nodal_field` (cheap beauty, lower novelty)

**Status: absent** (`grep -ri chladni` → 0), but **genuinely adjacent** to four existing
wave/Fourier entries: `quasicrystal_interference`, `talbot_fractal_carpet`,
`substitution_diffraction_field`, `bessel_zero_field`. Treat it as a fifth member of an
existing genre, not a new family.

```glsl
float w = 0.0;
for (int k = 0; k < modes; k++) {
  float n = float(k) + 1.0, m = float(3*k + 5);
  w += (cos(n*PI*x)*cos(m*PI*y) - cos(m*PI*x)*cos(n*PI*y)) / pow(float(k)+1.0, 0.85);
}
float node = exp(-abs(w) * 30.0);       // thin nodal lines
float band = exp(-abs(w) * 2.6) - node; // soft antinode glow
```

The recursion that makes it fractal rather than ornamental: displace the fine modes by
`tanh` of a coarse 5-mode field, which nests plate figures inside plate figures.
Prototype: `prototypes/chladni_nodal_fractal.png` (center 0.439 / edge 0.433 — the most
*balanced* detail profile of the four, and the most convincing single image).

Anchor: Chladni plate figures are documented experimentally and numerically (e.g.
"Numerical Chladni figures", *Eur. J. Phys.* 34 (2013), doi:10.1088/0143-0807/34/4/1067).
Cost: ~13 modes × 6 trig calls. Cheap.

### 5. Recursive domain-warped ridged fBm — `warped_ridged_nebula` (cheap beauty, lowest novelty)

**Status: absent as a named entry**; adjacent to `multifractal_plasma`,
`fractal_terrain_noise`, `fractal_interpolation_relief`, `voronoi_fractal_crackle`.
Disclose that. Its justification is not novelty but **thumbnail performance**: it scored
highest on every detail metric (0.942 / 1.000 / sd 70.84) at 5 octaves and two warp
stages — i.e. it is cheap *and* it reliably produces a busy, colourful first impression.

Prototype: `prototypes/domain_warp_nebula.png`. Note it also scored the brightest
(mean luma 141.6), which is an aesthetic choice on a dark UI, not a metric failure.

## Beautiful, already queued, still unimplemented

These are **not** new research: they already exist as `reference`-tier registry entries
with formulas and sources, and are the highest visual payoff per unit of work left in
the ledger. Priorities if the goal is "more beauty on screen fast":

| Ledger id | Construct | Why high impact | Estimated cost |
| --- | --- | --- | --- |
| `coxeter_honeycomb_435_slice` | `{4,3,5}` hyperbolic honeycomb slice | Order-5 cubic honeycomb in H³ renders as luminous cubic chambers receding in every direction — the strongest "impossible architecture" image available | medium: reflection folds in a hyperbolic metric, ~80 iterations, DE needs care |
| `hyperbolic_honeycomb_534_slice` | `{5,3,4}` slice | Dodecahedral cells; complements `{4,3,5}` with a rounder, jewel-like read | medium |
| `dodecahedral_fold_fractal` | dodecahedral KIFS | Existing `carpathian_recursive_objects` proves the recursive-object skeleton works; this is the one high-symmetry fold family not yet in it | low once the shared shader has a fold variant |
| `4d_polychoron_fold_slice` | 4D polychoron projection | Gives the hypercomplex group a true 4D visual (current entries are 3D slices of 4D algebras) | medium |
| `octonion_mandelbrot`, `tricomplex_mandelbrot`, `coquaternion_mandelbrot` | remaining Cayley–Dickson / hypercomplex families | Completes a family the app already markets; each is a slice renderer | low–medium, mechanical |

The `{4,3,5}`/`{5,3,4}` pair is the single biggest missing *image*. Hyperbolic 3-space
honeycombs are documented (horosphere packings of `(3,3,6)`, doi:10.3840/08003913;
Coxeter's hyperbolic groups), so the references are already adequate.

## Considered and deferred

| Candidate | Why deferred |
| --- | --- |
| Hopf fibration (nested linked tori) | Visually iconic and cheap in principle, but my stereographic-fibre prototype produced a pole-dominated blob (`darkPixelRatio` 0.77, no readable rings). Needs a proper 3D camera + depth-sorted torus rendering, which is a small project, not a shader one-liner. Worth doing later; not validated here. The failed prototype is kept at `prototypes/hopf_fibration.png`. |
| Gielis superformula / supershapes | Beautiful and well-anchored (3D graphic-arts superformula, doi:10.1145/1186415.1186420; superformula and regular polygons, doi:10.1007/s00022-015-0269-z) but **not self-similar** — it is ornament, and the catalog's own framing is fractal. Rejected on genre, not on feasibility. |
| Physarum / slime-mould transport networks | Needs agent state in ping-pong textures; the repo has that machinery (Gray-Scott) but the per-frame cost is a different class. Not a single-fragment shader. |
| 3D reaction–diffusion, Cahn–Hilliard | Same multi-pass cost issue; already deferred by the tenth wave. |
| Schramm–Loewner traces, double-pendulum FTLE | Bench-gated in the tenth wave; no new evidence here to unblock them. |
| Droste / recursive-feedback zoom | Requires framebuffer feedback; a rendering feature, not a fractal. |
| Gyroid lattice | Already shipped (`gyroid_echo_reliquary`; gyroid field inside `carpathian_recursive_objects`). No action. |

## Recommended order

1. **Imordial `z² + c`** (B2 `vec3` first, one preset pair Mandelbrot/Julia, one slice
   preset). Highest novelty, smallest ambiguity, MIT reference code, verified arithmetic.
2. **Inversion-fold lattice.** Highest beauty per cycle; one declarative config.
3. **Volumetric slice-stack mode.** Multiplies 90+ existing entries; ship behind a
   preset flag so the default surface render is untouched.
4. **`{4,3,5}` hyperbolic honeycomb** from the existing ledger entry — the biggest
   *single* missing image, but the most expensive item on this list.
5. Chladni, then the warped nebula, if catalogue breadth matters more than novelty.

Do **not** add more power-sweep variants (`Mandelbulb n=…`, `Mandelbox s=…`, `Burning Ship
d=…`). The ledger contains hundreds; they inflate counts without changing what a user
sees.

## Acceptance protocol (reuse what exists)

No new harness is needed. For each candidate:

1. Shader compiles: the existing shader-compile test pattern that fills
   `FractalRegistry.quality.shader_compile`.
2. Registry identity: `formula_hash` (SHA-256 of the distance/iteration source) plus the
   production-count assertion that already guards the catalog.
3. Render gate: generate the catalogue thumbnail and run `LaunchVisualMetrics`. Reject
   on `near-black`, `needs-palette`, `needs-framing`. **Accept nothing on verdict alone**
   — for the volumetric mode add the fill-frame rule (object bbox ≥ 60% of the short
   edge) so `edgeDetailScore` is meaningful.
4. Visual regression: one 384 px reference image per candidate, exported to the ignored
   `test/results/` path, exactly as `docs/catalog/recursive-crystals.md` does.
5. Control responsiveness: assert each exposed parameter changes the image by more than
   a pixel-noise floor (existing pattern for active-control tests).

Numerical check worth keeping for the algebra entry: assert the GLSL `bp_square` against
the reference vector set (`core/bristor_product/vectors.json` in the upstream repo) or
against a Dart-side closed form. The prototype here already reproduces the published
terms to `3.6e-15`, so a port regression would be a code bug, not a formula ambiguity.

## Limits

- **Not exhaustively retrieved.** `standard` depth, `stop_reason: completed`, low-yield
  count 0 — the sweep was bounded, not saturated. Semantic Scholar was entirely
  rate-limited (9 × 429), so its coverage contribution is zero.
- **Community formulas have no primary source.** The inversion-fold ("Kali") family is
  documented only in practitioner venues; no canonical parameter set or authorship claim
  is made here.
- **Aesthetic claims are not measured.** The metrics are falsification gates. The
  judgement "this will look striking in the gallery" rests on the prototypes plus the
  regularities in the fractal-aesthetics literature (preference varies with physical
  complexity rather than monotone detail: doi:10.3389/fnhum.2016.00210,
  doi:10.3389/fnhum.2016.00213), not on a user study.
- **No GPU timings.** All cost statements are operation counts at shader level. Real
  frame times on the target Linux/Waydroid hardware were not measured; the 3D entry
  should be profiled against `mandelbox_3d` before shipping a default preset.
- **The prototypes are not the shaders.** They validate the mathematics and the visual
  ceiling of the *formula*, not the Flutter/SkSL port. In particular the slice-stack
  prototype uses CPU morphology that a GLSL version would implement differently.

## Evidence index

| Path | Contents |
| --- | --- |
| `prototypes/render_prototypes.py` | Deterministic numpy renderer + metric replication |
| `prototypes/metrics.json` | Metric rows above |
| `prototypes/*.png` | Five 512² prototypes (4 candidates + 1 catalog-style control) |
| `prototypes/contact_sheet.png` | 2×2 overview |
| `results-deduped.jsonl`, `gap-pass/results-deduped.jsonl` | 378 + 135 deduplicated records |
| `failures.jsonl`, `gap-pass/failures.jsonl` | The 9 rate-limit failures verbatim |
| `manifest.json`, `gap-pass/manifest.json` | Caps, requests used, stop reason, coverage |
| `citation-graph.json` | 25-edge reference expansion of Hart 1996 (sphere tracing) |
| `provenance.json` | Schema-v2 index; validated by `rforge provenance validate` |

Anchors actually used: sphere tracing for implicit surfaces
(doi:10.1007/s003710050084), gyroid minimal surface computation
(doi:10.1016/s0009-2614(00)00373-0), hyperbolic Coxeter honeycomb horosphere packings
(doi:10.3840/08003913), numerical Chladni figures (doi:10.1088/0143-0807/34/4/1067),
Gielis superformula in 3D graphics (doi:10.1145/1186415.1186420), fractal aesthetics vs
physical complexity (doi:10.3389/fnhum.2016.00210, doi:10.3389/fnhum.2016.00213), and the
Bristorbrot algebra + MIT reference implementation
(`github.com/dougbristor/bristorbrot`, `LICENSE` = MIT, 2026).

---

## Implementation status (added 2026-10-31)

All four recommended entries are now implemented, registered, tested and
documented. Details and limits: `docs/catalog/high-impact-visuals.md`.

| # | Entry | Outcome | Deviation from this report |
| --- | --- | --- | --- |
| 1 | `imordial_brot` (3D) | shipped, 4 variants + 5 presets | none on the algebra; the distance estimate is heuristic, so fin edges alias and thin structure speckles in a still frame |
| 2 | `inversion_fold_lattice` (2D) | shipped, 5 presets | the entry ships the Julia side only (`c` exposed as two controls). The Mandelbrot analogue is still the same map at `c = pixel`, but it was not exposed as a mode. Four presets had to move to the structured band of the parameter plane (`c ≈ (1.0, 0.12)`, `(0.25, 0.12)`, `(0.38, 0.25)`, `(0.25, 0.38)`); the prototype's `(0.62, 0.38)` renders as a sparkle field rather than a lattice |
| 3 | volumetric slice-stack mode | **not shipped** | implemented and measured only as the offline prototype. Shipping it needs an opt-in path through the shared 3D renderer plus a frame-fill rule for the launch audit; that is a renderer change, not a fractal addition |
| 4 | `chladni_nodal_field` (2D) | shipped, 4 presets | moved to `shaders/number_theory/` because the trig directory enforces a subfolder-only, fixed-count layout |
| 5 | `domain_warp_nebula` (2D) | shipped, 4 presets | `uIterations` is a detail budget (`iterations / 6` octaves) because the shared escape-time ABI floors the slider at 20 |

Prototype numbers in this report remain the pre-implementation evidence. The
shipped shaders differ in two ways the prototypes did not model: the
inversion-fold colouring uses a fixed log divisor instead of a per-image
normalisation, and the imordial shading colours from surface normal and world
position rather than the orbit radius (an orbit-based palette wobbled with the
hit point and read as noise).

Verification actually run for the implementation: `flutter analyze --no-pub`
(clean), `flutter test --no-pub` (3385 passed, 9 skipped), `pytest test/research
test/scripts` (454 passed, 1 skipped), `bats test/scripts/*.bats` (25 ok), and
`forge doctor` on the registry (1623 entries, 0 errors, 0 warnings). Ambient
toolchain was Flutter 3.44.2 / Dart 3.12.2, not the pinned 3.44.6, because
`AUTOWORK_CACHE` was unset on this host; that version mismatch is unqualified.
