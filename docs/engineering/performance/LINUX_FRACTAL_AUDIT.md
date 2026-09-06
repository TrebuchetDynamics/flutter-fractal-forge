# Linux catalog quality audit

Run from the repository root:

```bash
python3 scripts/audit-linux-fractals.py
```

The command builds a **profile-mode Linux app**, using the production
`FractalRenderer`, controller, palettes, shader loading, and module presets.
It enumerates **every production fractal in ModuleRegistry**, excluding diagnostic
shaders and the Hydrogen scientific visualization. There is no hardcoded 544-item
escape-time subset. Preferences use an empty in-memory store, so saved user
palettes/settings are isolated. The manifest and report preserve the exact denominator.

Requirements: the project's Flutter SDK and Linux build dependencies; a running
X11 display, or `xvfb` and `xauth`. Install `mesa-utils` to record GL driver/vendor
information. A headless Mesa software run checks rendering correctness but is
not a hardware GPU performance benchmark. Keep local linker tools outside Git.

```bash
# Small smoke run before a full sweep:
python3 scripts/audit-linux-fractals.py --only mandelbrot,octahedral_crystal_bloom
# Reuse the audit binary from an unchanged checkout; larger performance sample:
python3 scripts/audit-linux-fractals.py --skip-build --frames 120 --size 640
# Isolate an entry needing repair:
python3 scripts/audit-linux-fractals.py --skip-build --only cantor_cross_crystal
```

Every run writes a fresh directory under `build/fractal-audit/`. Open its
`index.html` locally: filter by name and action, compare default/alternate PNGs,
and expand the numeric evidence. `report.json` is machine-readable; `junit.xml` exposes each fractal in GitLab
Tests with objective failures and review hints;
`results.jsonl`, `timings.jsonl`, `manifest.json`, `run.json`, `build.log`, and `run.log` retain
raw evidence. `--output` selects an empty directory. `--only` and `--limit` are
explicit partial runs, labeled as such in metadata. Never compare partial counts
to the full-catalog denominator.

## What is measured

- A real renderer snapshot must appear within 30 seconds. A loader, widget-test
  placeholder, error panel, missing result, wrong capture dimensions, or fewer
  than two captures cannot count as a successful fractal.
- Two views: the default preset and the first built-in preset with different parameters/camera settings (renamed
  aliases do not count), or a
  0.75x zoom of the default if no alternate is available. Animation is frozen for
  repeatable still inspection. This is not exhaustive parameter or motion testing.
- After load and warm-up, small alternating zoom changes force real frames.
  Engine build/raster timings are associated with that module's monotonic-time
  measurement interval. Raster p50/p95, build p95, and the proportion exceeding
  the configurable `--budget-ms` (default 16.667) are reported. Capture/readback
  time is excluded. Per-entry device pixel ratio distinguishes screen raster
  resolution from the 1x PNG capture resolution. Missing samples are **unmeasured**, never fabricated 60 FPS.
- Twenty frames are a screening sample, not a statistically strong benchmark.
  Rerun suspects with `--frames 120` on the same GPU, resolution, and build before
  tuning. Hardware, compositor, thermal load, shader caching, and software Mesa
  affect results. `loadMs` includes renderer readiness and may benefit from cache.
- Image health uses existing `RenderAuditMetrics`: blank/transparent output,
  contrast, occupancy, and color variation. Additional 64px luminance measurements
  flag dense edges and almost detail-free gradients. A coarse 16x16 fingerprint
  finds identical default compositions for manual comparison.

## Fix or retire workflow

**Fix:** a renderer error, missing coverage, or blank view. Inspect both images,
reproduce with `--only`, check default camera/uniforms/palette, and compare against
a mathematical reference. Fix the source and rerun the same settings. A blank
zoom/preset alone does not prove the formula is broken.

**Review:** low contrast, a nearly uniform composition, dense edges, matching
fingerprints, slow frames, or insufficient performance evidence. Each suggestion
includes its observed condition. Sparse black-and-white geometry and deliberate
noise can be valid art; these heuristics are not beauty scores.

**Keep:** no measured issue in the two sampled views. This is not a mathematical
correctness certificate or proof of all presets working.

Consider removal only when a reproducible broken entry cannot be repaired, or
formula/preset review confirms a redundant entry. Check saved presets and links
before retiring IDs. The audit never deletes modules automatically. It exits 1
for objective failures/missing coverage, 0 for completed runs without objective
failures (review hints can remain), and 2 for setup/configuration failures.

A process watchdog restarts remaining IDs after a crash or stall. Completed rows
are retained; the current entry is marked for isolated reproduction. A failure
before any entry becomes active is infrastructure failure, leaving remaining
entries explicitly missing rather than falsely blaming their formulas.

## GitLab

`linux-fractal-audit` is a GitLab-only manual job, also runnable automatically from
a scheduled/web pipeline with `FRACTAL_AUDIT=1`. It retains the HTML, JSON, PNGs,
and logs even on failure. The hosted runner uses Mesa software rendering, so its
performance findings are screening hints. Use a stable GPU-equipped Linux machine
for performance acceptance. No GitHub Actions job is added.

## Initial execution and repairs

The original catalog had 1,018 production fractals. The first full Linux run
(`build/fractal-audit/full-v1`) recorded all 1,018 with 20,360 engine samples.
Its alternate selection exposed a test-harness defect: differently named
Default/Classic aliases often had identical settings. Those images must not be
counted as independent view coverage. The selector now compares actual preset
parameters and camera coordinates, with a regression test for this case.

The corrected full sweep (`build/fractal-audit/full-final`) covered all 1,018
entries with **2,036 captures**, distinct default/alternate input settings for
every entry, and **10,180 engine samples**. It found six blank alternate presets, Shape Modulus Julia's
missing shader inputs, and the incorrectly bound standalone Mandelbrot DF2 entry.
The earlier Baker, Tricorn, Multibrot and Multijulia default repairs passed this
second sweep. These reports are historical evidence and preserve their failures.

Repairs retain the fractal/preset identities while correcting camera framing,
recursion depth, lighting direction, missing shape/seed inputs, complex-tangent
overflow, and the undefined power-at-zero case. The standalone `mandelbrot_df2`
catalog entry was retired because the generic escape-time uniform layout does
not match that precision shader. The normal Mandelbrot deep-zoom path retains
its dedicated `buildMandelbrotDf2Module` adapter. The current catalog has **1,017**
production fractals.

The final targeted Linux run (`build/fractal-audit/verified-repairs`) rechecked
**all 21 affected entries**, with **42 captures and 2,520 engine samples** at
120 frames per entry. All objective image-health checks passed. Its JSON/HTML
includes the exact effective camera/parameters, and its JUnit has zero failures.
Mandelbox Cathedral was subsequently pulled back further and checked again
with 120 samples in `build/fractal-audit/mandelbox-framing` (zero objective
failures). Unchanged entries retain the corrected full-sweep evidence; this is selective
post-fix verification, not a third complete sweep.

All runs used 320px captures on Mesa llvmpipe (software rendering). Some local
validation ran during portions of the sweeps. Treat timings as screening evidence;
rerun performance candidates in isolation on the intended GPU. The remaining
review hints are not automatic retirement recommendations. Generated reports and
PNGs stay under ignored `build/`, outside source control.
