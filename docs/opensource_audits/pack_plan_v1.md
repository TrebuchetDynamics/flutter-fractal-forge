# First New Fractal Pack Plan (v1)

Date: 2026-02-18
Owner: Fractal Forge core
Scope: Implementation-ready plan for first **new** pack (5 fractals) with best ROI from `/opensource`

---

## 1) Pack choice and ROI rationale

## Selected pack: **Strange Attractors Pack 01 (2D)**

**Source basis (clean-room math):**
- `opensource/par-fractal/src/shaders/attractor_compute.wgsl`
- `opensource/par-fractal/src/shaders/fractal.wgsl`
- `opensource/par-fractal/src/fractal/types.rs`
- `opensource/par-fractal/src/fractal/mod.rs` (default view/param hints)

**Why this is best ROI for first pack**
1. **High visual differentiation** vs existing escape-time-heavy catalog.
2. **Shared implementation template** across all 5 formulas (same uniform layout, palette path, loop skeleton).
3. **Low registry risk**: all can be integrated as `EscapeTimeConfig` entries (no custom module class required).
4. **Permissive source lineage** (par-fractal is MIT; still implement clean-room).
5. **CPU fallback tractable**: each formula is a small recurrence with finite guards.

---

## 2) Pack manifest

| Fractal | moduleId | catalogId | shaderAsset | cpuFormulaId | Category |
|---|---|---|---|---|---|
| Martin Attractor | `martin` | `core.martin` | `shaders/martin_gpu.frag` | `martin` | `2D Maps / Attractors` |
| Chip Attractor | `chip` | `core.chip` | `shaders/chip_gpu.frag` | `chip` | `2D Maps / Attractors` |
| Quadruptwo Attractor | `quadruptwo` | `core.quadruptwo` | `shaders/quadruptwo_gpu.frag` | `quadruptwo` | `2D Maps / Attractors` |
| Threeply Attractor | `threeply` | `core.threeply` | `shaders/threeply_gpu.frag` | `threeply` | `2D Maps / Attractors` |
| Icon Attractor | `icon_attractor` | `core.icon_attractor` | `shaders/icon_attractor_gpu.frag` | `icon_attractor` | `2D Maps / Attractors` |

---

## 3) Per-fractal implementation specs

## 3.1 Martin Attractor

- **Source formula:** par-fractal `martin_step`
- **Recurrence:**
  - `x_{n+1} = y_n - sin(x_n)`
  - `y_{n+1} = a - x_n`

### Parameter schema

```yaml
iterations: {type: integer, min: 20, max: 500, step: 1, default: 320}
bailout:    {type: float,   min: 2.0, max: 8.0, step: 0.1, default: 8.0}
colorScheme:{type: enum64,  min: 0, max: 63, step: 1, default: 2}
a:          {type: float,   min: -10.0, max: 10.0, step: 0.01, default: 3.14159265}
```

### Default preset

```yaml
id: martin-default
moduleId: martin
view: {pan: [0.0, 0.0], zoom: 0.05}
params: {iterations: 320, bailout: 8.0, colorScheme: 2, a: 3.14159265}
```

### Shader/CPU notes
- Shader uses standard uniform slots 0..9 + extra `a` at slot 10.
- Use same palette + `linearToSRGB` pattern as existing `hopalong_gpu.frag`.
- Escape guard: use `r2 > max(64.0, bailout*bailout)` (more stable for attractors).
- CPU: add `_cpu_martin` in `cpu_formulas.dart`, with identical recurrence.

### Expected tests
- Unit: formula finite and deterministic at canonical sample points.
- Render audit: non-black ratio > 1%, structural edge/entropy pass.
- Registry/catalog presence and unique IDs.

### Integration points
- Add `EscapeTimeConfig` in `escape_time_catalog.dart` with category `2D Maps / Attractors`.
- No `module_registry.dart` code change (auto-ingested from catalog).
- Localization keys: `moduleMartin`, `paramAttractorA`.

---

## 3.2 Chip Attractor

- **Source formula:** par-fractal `chip_step`
- **Recurrence:**
  - `x_{n+1} = y_n - sign(x_n) * cos(log^2(|b*x_n - c|)) * atan(log^2(|c*x_n - b|))`
  - `y_{n+1} = a - x_n`

### Parameter schema

```yaml
iterations: {type: integer, min: 20, max: 500, step: 1, default: 420}
bailout:    {type: float,   min: 2.0, max: 8.0, step: 0.1, default: 8.0}
colorScheme:{type: enum64,  min: 0, max: 63, step: 1, default: 1}
a:          {type: float,   min: -100.0, max: 100.0, step: 0.1, default: -15.0}
b:          {type: float,   min: -100.0, max: 100.0, step: 0.1, default: -19.0}
c:          {type: float,   min: -100.0, max: 100.0, step: 0.1, default: 1.0}
```

### Default preset

```yaml
id: chip-default
moduleId: chip
view: {pan: [0.0, 0.0], zoom: 0.002}
params: {iterations: 420, bailout: 8.0, colorScheme: 1, a: -15.0, b: -19.0, c: 1.0}
```

### Shader/CPU notes
- Extra uniforms at slots 10..12: `a,b,c`.
- Add NaN guards: `log(max(abs(v), 1e-3))`.
- Keep `sign(0)` behavior explicit in both GPU/CPU (use shared helper).
- CPU: `_cpu_chip` with same clamp policy and thresholds.

### Expected tests
- Parameter sensitivity tests (`a/b/c` perturbation changes frame hash).
- Finite-value test under extreme slider values.
- Structural render audit with tuned default view.

### Integration points
- Catalog entry + category.
- Localization: `moduleChip`, `paramAttractorA/B/C`.
- Optional alias map in catalog search: `chip`, `strange attractor`.

---

## 3.3 Quadruptwo Attractor

- **Source formula:** par-fractal `quadruptwo_step`
- **Recurrence:**
  - `x_{n+1} = y_n - sign(x_n) * sin(log(|b*x_n - c|)) * atan((|c*x_n - b|)^2)`
  - `y_{n+1} = a - x_n`

### Parameter schema

```yaml
iterations: {type: integer, min: 20, max: 500, step: 1, default: 420}
bailout:    {type: float,   min: 2.0, max: 8.0, step: 0.1, default: 8.0}
colorScheme:{type: enum64,  min: 0, max: 63, step: 1, default: 2}
a:          {type: float,   min: -100.0, max: 100.0, step: 0.1, default: 34.0}
b:          {type: float,   min: -100.0, max: 100.0, step: 0.1, default: 1.0}
c:          {type: float,   min: -100.0, max: 100.0, step: 0.1, default: 5.0}
```

### Default preset

```yaml
id: quadruptwo-default
moduleId: quadruptwo
view: {pan: [15.0, 17.0], zoom: 0.01}
params: {iterations: 420, bailout: 8.0, colorScheme: 2, a: 34.0, b: 1.0, c: 5.0}
```

### Shader/CPU notes
- Same attractor kernel skeleton as Chip (swap nonlinear term only).
- Guard logs and squared term to prevent INF growth.
- CPU: `_cpu_quadruptwo` + convergence threshold parity with shader.

### Expected tests
- Golden-ish deterministic sample for default preset (small frame hash tolerance).
- CPU formula finite + non-Mandelbrot similarity test.
- Render audit structure pass.

### Integration points
- New config entry in attractor section of catalog.
- Localization: `moduleQuadruptwo`.

---

## 3.4 Threeply Attractor

- **Source formula:** par-fractal `threeply_step`
- **Recurrence:**
  - `term = sin(x_n)*cos(b) + c - x_n*sin(a+b+c)`
  - `x_{n+1} = y_n - sign(x_n)*abs(term)`
  - `y_{n+1} = a - x_n`

### Parameter schema

```yaml
iterations: {type: integer, min: 20, max: 500, step: 1, default: 380}
bailout:    {type: float,   min: 2.0, max: 8.0, step: 0.1, default: 8.0}
colorScheme:{type: enum64,  min: 0, max: 63, step: 1, default: 0}
a:          {type: float,   min: -100.0, max: 100.0, step: 0.1, default: -55.0}
b:          {type: float,   min: -100.0, max: 100.0, step: 0.1, default: -1.0}
c:          {type: float,   min: -100.0, max: 100.0, step: 0.1, default: -42.0}
```

### Default preset

```yaml
id: threeply-default
moduleId: threeply
view: {pan: [0.0, 0.0], zoom: 1.0}
params: {iterations: 380, bailout: 8.0, colorScheme: 0, a: -55.0, b: -1.0, c: -42.0}
```

### Shader/CPU notes
- Precompute `sin(a+b+c)` in-loop constant for performance.
- Keep interior/escaped coloring consistent with other attractor shaders.
- CPU: `_cpu_threeply` mirrors GLSL exactly.

### Expected tests
- Param regression test for signed-range edges (negative defaults).
- Render audit + coverage tests.
- Optional iterator proxy test registration in `cpu_iterators.dart`.

### Integration points
- New catalog config entry + localization key `moduleThreeply`.

---

## 3.5 Icon Attractor

- **Source formula:** par-fractal `icon_step` / `icon_attractor`
- **Recurrence (v1 simplified):**
  - `p = λ + α|z|^2 + β*Re(z^n)`
  - `z_{n+1} = p*z_n + γ*z_n^(n-1)`
  - (v1 fix: `ω = 0`, `n = 5` for lower UI complexity)

### Parameter schema

```yaml
iterations: {type: integer, min: 20, max: 500, step: 1, default: 400}
bailout:    {type: float,   min: 2.0, max: 8.0, step: 0.1, default: 8.0}
colorScheme:{type: enum64,  min: 0, max: 63, step: 1, default: 3}
lambda:     {type: float,   min: -4.0, max: 4.0, step: 0.01, default: 0.4}
alpha:      {type: float,   min: -4.0, max: 4.0, step: 0.01, default: 1.0}
beta:       {type: float,   min: -4.0, max: 4.0, step: 0.01, default: 0.0}
gamma:      {type: float,   min: -4.0, max: 4.0, step: 0.01, default: 0.0}
```

### Default preset

```yaml
id: icon-attractor-default
moduleId: icon_attractor
view: {pan: [0.0, 0.0], zoom: 1.0}
params: {iterations: 400, bailout: 8.0, colorScheme: 3, lambda: 0.4, alpha: 1.0, beta: 0.0, gamma: 0.0}
```

### Shader/CPU notes
- Implement `z^(n-1)` via fixed small loop (`n=5`) for deterministic mobile cost.
- Use finite clamps around `|z|` growth to avoid NaNs.
- CPU: `_cpu_iconAttractor` should match fixed-degree shader path.

### Expected tests
- Determinism test for fixed-degree icon orbit.
- Finite output under extreme parameter ranges.
- Render audit structure pass with fallback alternate view if default is sparse.

### Integration points
- New config entry in attractor category.
- Localization key `moduleIconAttractor` (+ optional param labels `paramLambda/Alpha/Beta/Gamma`).

---

## 4) Shared code-change checklist (implementation sequence)

1. **Add shaders**
   - `shaders/martin_gpu.frag`
   - `shaders/chip_gpu.frag`
   - `shaders/quadruptwo_gpu.frag`
   - `shaders/threeply_gpu.frag`
   - `shaders/icon_attractor_gpu.frag`

2. **Register shader assets**
   - `pubspec.yaml` (`flutter.shaders` list)

3. **Add catalog module configs**
   - `lib/core/modules/builders/escape_time_catalog.dart`
   - Set `displayName`, `category`, defaults, and `extraParams`

4. **CPU fallback formulas**
   - `lib/features/renderer/cpu_formulas.dart`
   - Add map entries + `_cpu_*` implementations

5. **CPU iterator coverage (optional but recommended)**
   - `lib/features/renderer/cpu_iterators.dart`
   - Add true iterators or explicit proxy registration for new IDs

6. **Localization**
   - `lib/l10n/app_en.arb`
   - `lib/l10n/app_es.arb`
   - run l10n generation

7. **Tests**
   - update existing + add dedicated pack tests (see section 5)

---

## 5) Test additions expected

## Must-update existing tests
- `test/module_registry_widget_test.dart`
  - assert 5 new module names resolve and render.
- `test/cpu_formula_coverage_test.dart`
  - ensure new IDs produce finite output and differ from Mandelbrot baseline.
- `test/fractal_render_audit_test.dart`
  - verify structural pass for all 5 defaults (add per-id tuned-view fallback if needed).
- `test/catalog_repository_test.dart`
  - sanity check lookups for `core.martin`, `core.chip`, etc.

## New tests to add
- `test/attractor_pack_v1_cpu_formulas_test.dart`
  - recurrence-level finite + deterministic checks at canonical parameter sets.
- `test/attractor_pack_v1_params_test.dart`
  - slider bounds and default value clamp checks for `a/b/c` and icon params.
- `test/attractor_pack_v1_localization_test.dart`
  - English/Spanish module labels present.

---

## 6) Module registry / catalog / localization integration map

## Module Registry
- **No direct file edit required** in `module_registry.dart`.
- New entries are auto-built via `buildEscapeTimeCatalogModules()`.

## Catalog
- `CatalogRepository.fromRegistry()` will auto-generate:
  - `core.martin`, `core.chip`, `core.quadruptwo`, `core.threeply`, `core.icon_attractor`
- Set `category` directly in each `EscapeTimeConfig` to keep pack grouped.

## Localization
Add keys:
- Modules:
  - `moduleMartin`
  - `moduleChip`
  - `moduleQuadruptwo`
  - `moduleThreeply`
  - `moduleIconAttractor`
- Params (recommended):
  - `paramAttractorA`, `paramAttractorB`, `paramAttractorC`
  - `paramLambda`, `paramAlpha`, `paramBeta`, `paramGamma`

Files:
- `lib/l10n/app_en.arb`
- `lib/l10n/app_es.arb`

---

## 7) Risk notes

1. **Attractor defaults can appear sparse/flat** at some views.
   - Mitigation: keep source-inspired default pans/zooms and add one tuned built-in preset per fractal.
2. **Bailout slider range (2..8) is narrow** for attractor families.
   - Mitigation: in shader, use internal floor threshold (`max(64, bailout²)`), preserving UI compatibility.
3. **CPU/GPU parity drift** from transcendental/log handling.
   - Mitigation: shared epsilon constants and explicit clamp policy in both shader and CPU.

---

## 8) Suggested rollout slice

- **PR 1:** Martin + Chip (lowest risk pair, validate pipeline)
- **PR 2:** Quadruptwo + Threeply
- **PR 3:** Icon Attractor (slightly higher risk), finalize localization + tests

This keeps regressions contained while still shipping a coherent first pack.
