# Number Walls presentation and PNG export

The [accepted design](../../../docs/engineering/spec.md#number-walls-and-modular-windows)
owns product scope. This component displays an already completed exact integer
field; it does not calculate determinants or certify primes.

## Data and styling

- `NumberWallStyle` snapshots the selected `PaletteService` palette into 256
  opaque colours. Residue bins use BigInt scaling in Dart. Zero residues use
  separate zero ink; a nonzero palette colour that equals that ink is inverted
  to preserve the visible divisibility distinction.
- Binary mode uses the nonzero RGB colour. Both modes use the chosen zero RGB
  colour. Background RGB fills the margins and optional one-pixel grid lines.
  Transparent export clears margins only; cells and grid lines remain opaque.
- `NumberWallPainter` is shared by the exact Canvas viewer, sampler viewer and
  offscreen export. Pan/zoom define a normalized field rectangle. Other output
  dimensions rasterize those same cells into that same normalized viewport,
  without changing source, modulus, origin, row count or column count.
- Presentation-only controller edits retain the identical immutable grid and do
  not restart determinant generation or prime certification. A locally retained
  canonical prime can reuse its controller-owned certification, including a
  completed Continue check; serialized verification flags remain untrusted.

## Manual randomization

`FractalController.randomizeNumberWall` stores a materialized seed, source,
palette and RGB colours. It preserves the current grid budget/origin and prime.
Only an explicit `randomizeModulus` opt-in permits a prime from 2/3/5/7/11/13.
Undo restores the prior committed settings and exact grid; Replay seed repeats
that seed within the current budget and modulus policy. Presets/history retain
the materialized parameters, not an instruction to rerun randomness. There is no
autoplay. Number Walls hides unsupported auxiliary tools and discloses the static
boundary in both control surfaces; other modules retain their tool controls.

## Export ownership

[`NumberWallExportCapture`](../viewer/export/number_wall_export.dart) freezes the
completed grid, materialized style, settings and copied viewport when the image
export sheet or quick-share flow opens. It invalidates an unfinished wall request.
The existing export session owns the modal flow and cancellation coordinator.

`ExportService.withRasterizer` asks this capture for the final target dimensions
before the ordinary encoding, metadata and save/share pipeline. It does not resize
a mutable screenshot or fall back to another renderer when wall export fails.
Cancellation is checked before rendering and after image readback/encoding; owned
images and pictures are disposed. Navigation or later edits cannot replace the
capture's grid/style. Platform save behavior remains in the existing export service.

## Focused verification

```sh
flutter test test/number_walls/number_wall_style_export_test.dart test/number_walls/number_wall_randomizer_test.dart test/export/viewer_export_session_test.dart --reporter expanded
flutter test test/number_walls/number_wall_viewer_test.dart --reporter expanded
```

The style/export test decodes actual encoded PNG bytes from the rasterizer/export
processing path, samples cell centres and the zero mask, and checks background
alpha, nonzero pan and changed aspect ratios. Viewer tests compare Canvas/sampler
pixels, including styled grid lines, and exercise EN/ES colour editing. Randomizer
tests cover seed replay, undo, opt-in primes and a custom prime certified above
the default validation budget. These offline fixtures do not qualify installed
Android, Linux or browser journeys. Browser-harness execution and physical/device
save/share checks remain separate qualification evidence.
