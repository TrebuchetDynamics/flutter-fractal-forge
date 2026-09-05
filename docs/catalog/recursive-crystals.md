# Recursive crystals

Three finite-depth artistic IFS constructions join the 3D catalog. These are
named visual variants, not claims of newly discovered mathematical families.
They use the existing recursive-object shader and require no image assets.

| Catalog entry | Construction | Default / allowed depth |
| --- | --- | --- |
| Octahedral Crystal Bloom | Absolute-value and dominant-axis folds select six axial branches; an octahedral seed gives faceted crystal clusters. | 4 / 2–6 |
| Tetrahedral Orbit Lantern | Three tetrahedral plane folds repeat a six-edge capsule frame, leaving nested triangular chambers. | 4 / 2–6 |
| Cantor Cross Crystal | Corner folds repeat three perpendicular capsule-like ribs; a union retains the large cross while adding smaller branches. | 4 / 2–6 |

Each entry exposes branch scale, recursion depth, ray-march steps, reach, palette,
and camera controls, with its construction identity fixed. Default views include
an oblique camera angle and time-driven rotation. Catalog thumbnails are rendered
on demand by the existing thumbnail system; no pre-rendered thumbnail is claimed.

Distance estimates are scaled back to world coordinates after each affine fold.
The shared renderer supplies conservative marching, finite normal fallback,
bounding-sphere rejection, lighting, and premultiplied transparent backgrounds.
Material color depends on orbit and position rather than the number of solver
steps. Increasing a converged ray's step budget therefore preserves its color.

Validation lives in `test/modules/carpathian_recursive_objects_test.dart`: shader
compilation and pixel checks cover all eight objects sharing this shader, including
visible structure, distinct common-view silhouettes, active controls, motion,
maximum zoom, and alpha correctness. Registry identity tests lock the production
count at 1,018 fractals (plus one scientific visualization and seven diagnostics).
The new entries' formula hashes are SHA-256 of their distance-function source.

To export 384 px review images without adding generated files to Git:

```bash
flutter test --dart-define=EXPORT_CRYSTAL_REVIEW=true \
  test/modules/carpathian_recursive_objects_test.dart \
  --plain-name 'export recursive crystal review images'
```

Images are written to ignored `test/results/recursive-crystals/`.
