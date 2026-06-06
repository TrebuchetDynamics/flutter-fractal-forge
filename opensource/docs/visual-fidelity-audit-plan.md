# Visual Fidelity Audit and Fix Plan

Status: implementation planning note for the approved next slice. The owner accepted a Featured Launch Set–scoped Visual Fidelity Audit before broad shader rewrites or new visual features.

## Decision

Run a scoped Visual Fidelity Audit first. Do not globally apply Reference Corpus snippets or blanket shader changes.

Why:

- The launch goal is first impression: screenshots, thumbnails, Browser Web Preview reliability, and a small Featured Launch Set.
- The obvious upstream patterns are already present in many current shaders:
  - 469 registered `.frag` shader files in `shaders/`.
  - 442 include a `linearToSRGB` output helper.
  - 283 include smooth-coloring markers such as `smoothVal`, `smoothIter`, or log-log escape coloring.
  - Core Mandelbrot/Julia targets already include sRGB, smooth iteration, cosine palettes, and related polish.
- A global sRGB or palette pass risks double-encoding colors and changing hundreds of screenshots without a validation target.

## Source material

Use the existing provenance records rather than ignored clone paths alone:

- `opensource/docs/visual-fidelity-extraction.md`
- `opensource/docs/reference-corpus-workflow.md`
- `opensource/docs/CATALOG.md`
- `docs/planning/LAUNCH_LADDER.md`

Reference Corpus ideas are research inputs only. Production fixes must be adapted in our style and backed by a provenance record plus validation signal.

## Audit target

Start with a Featured Launch Set candidate pool, selected for browser reliability, exact-thumbnail availability, and category variety.

### Primary candidate pool with exact thumbnail assets

These IDs currently have module references and exact thumbnail assets:

| Module ID | Launch role | First audit focus |
|---|---|---|
| `mandelbrot` | classic Mandelbrot anchor | Verify current shader/preset; avoid double sRGB changes. |
| `julia` | Julia anchor | Verify preset diversity and thumbnail strength. |
| `burning_ship` | Mandelbrot-family variety | Check smooth-coloring/sRGB consistency against flagship output. |
| `phoenix` | escape-time variation | Verify exact thumbnail and preset quality. |
| `nova` | Newton/escape hybrid | Verify exact thumbnail and color readability. |
| `magnet_newton` | root-finding/Newton visual | Check thumbnail contrast and web reliability. |
| `halley` | root-finding method | Check thumbnail contrast and label clarity. |
| `ducky` | unusual escape-time shape | Check if visual strength justifies launch inclusion. |
| `barnsley_fern` | IFS/geometric | Check thumbnail framing. |
| `koch_snowflake` | geometric/classic | Check visual variety, not necessarily wow factor. |
| `clifford` | strange attractor | Check exact thumbnail and web render stability. |
| `henon` | strange attractor | Check exact thumbnail and palette readability. |
| `lorenz_2d` | strange attractor | Check exact thumbnail and line density. |
| `menger_3d_slice` | 3D-ish/geometric slice | Check if it can represent 3D before hardware smoke. |

### Candidate pool requiring extra work

| Module ID | Why not primary yet | Needed fix |
|---|---|---|
| `julia_dual` | Strong concept but no exact thumbnail asset found. | Generate thumbnail and verify split-panel readability. |
| `mandelbulb` | True 3D flagship candidate but no exact thumbnail asset found. | Generate thumbnail and run hardware browser smoke before launch inclusion. |
| `kifs_sierpinski_tetra` | 3D/geometric candidate but no exact thumbnail asset found. | Generate thumbnail and verify raymarch cost. |

## Implementation slices

### Slice 1 — Test-only audit harness

Goal: make launch visual quality review replayable before changing shader code.

Proposed files:

- `test/features/catalog/featured_launch_set_visual_audit_test.dart`
- optional helper in `test/helpers/` only if duplication appears

Test assertions:

1. Every primary Featured Launch Set candidate resolves to a registered `FractalModule`.
2. Every primary candidate's `shaderAsset` is registered in `pubspec.yaml` under `flutter.shaders`.
3. Every primary candidate has an exact thumbnail under `assets/catalog_thumbs/<moduleId>.png`.
4. For primary escape-time shader assets, classify whether they contain:
   - `linearToSRGB`
   - smooth-coloring marker (`smoothVal`, `smoothIter`, `log2(log2`, or `log(log`)
   - palette function marker (`palette(`, `getPaletteColor`, or equivalent)
5. The audit output names gaps rather than silently passing vague visual quality.

Validation:

```bash
/home/xel/flutter/bin/flutter test test/features/catalog/featured_launch_set_visual_audit_test.dart
/home/xel/flutter/bin/flutter analyze test/features/catalog/featured_launch_set_visual_audit_test.dart
```

Expected result: no production behavior change. If the test fails, the failure becomes the first concrete fix list.

### Slice 2 — Generate/curate missing launch thumbnails

Goal: move high-value candidates (`julia_dual`, `mandelbulb`, maybe `kifs_sierpinski_tetra`) from candidate pool to primary pool.

Work:

1. Generate exact thumbnails for selected candidates.
2. Confirm asset paths are bundled and do not trigger Browser Web Preview 404s.
3. Update the primary candidate list only after the thumbnails exist.

Validation:

```bash
/home/xel/flutter/bin/flutter test test/features/catalog/catalog_thumbnail_plan_test.dart
/home/xel/flutter/bin/flutter test test/features/catalog/featured_launch_set_visual_audit_test.dart
```

Manual/browser validation:

- Browser Web Preview catalog loads with no above-the-fold thumbnail 404s.
- New exact thumbnails are not labelled approximate.

### Slice 3 — Shader consistency fixes only where audit finds gaps

Goal: adapt Reference Corpus visual ideas only where the selected launch shader lacks them.

Allowed fixes:

- Add sRGB only to a selected shader that lacks display encoding and is not already encoded elsewhere.
- Add smooth iteration only to selected escape-time shaders that visibly band and lack smooth-coloring markers.
- Adjust one palette/preset only when screenshot/pixel comparison shows better first-impression readability.

Do not:

- Apply `linearToSRGB` to all shaders.
- Copy GLSL from GPL or unknown-license sources.
- Change hundreds of thumbnails/presets in one pass.
- Add FXAA/glow/bloom before single-shader and thumbnail fixes are measured.

Validation per shader:

```bash
/home/xel/flutter/bin/flutter test <targeted module/catalog tests>
/home/xel/flutter/bin/flutter analyze <changed Dart test/module files>
/home/xel/flutter/bin/flutter build web --release
```

Plus one measurable visual signal:

- screenshot diff,
- thumbnail pixel comparison,
- or documented before/after capture with exact module/preset/viewport.

### Slice 4 — Featured Launch Set documentation/update

Goal: make launch assets and docs describe the same set.

Work:

- Record the final 10–20 Featured Launch Set IDs in launch planning docs.
- Update README/landing screenshots only after the audit-selected set has exact thumbnails and Browser Web Preview smoke evidence.
- Keep the set marketing/docs/media scoped; do not add an in-app Featured tab unless later feedback asks for it.

Validation:

- README/landing images match selected IDs.
- Browser Web Preview caveat remains visible.
- Known limitations are explicit for deep zoom/export/share behavior.

## Ranked first fixes after the audit

1. **Audit harness** — highest leverage, no production risk.
2. **Missing exact thumbnails for `julia_dual` / `mandelbulb`** — likely launch-impactful if render smoke passes.
3. **Preset framing fixes** for candidates whose exact thumbnails exist but look weak.
4. **One selected shader polish fix** only if the audit proves a gap.
5. **Post-processing experiments** only after launch set screenshots are stable.

## Open questions for the next grill branch

1. Should `mandelbulb` be promoted as the one 3D flagship despite missing exact thumbnail and pending hardware browser smoke?
2. Should the audit harness live as a permanent test or a temporary launch-only test?
3. Should the primary Featured Launch Set target 10, 12, or 20 items for the first Browser Web Preview push?
