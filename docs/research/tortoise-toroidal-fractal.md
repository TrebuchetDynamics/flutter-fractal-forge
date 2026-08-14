# TORTOISE Toroidal Fractal — Source Study

## Source

- Reddit post: https://www.reddit.com/r/SacredGeometry/s/3ozHT7x05t
- Resolved post: `r/SacredGeometry/comments/1vn31rt/the_mother_of_all_symbols/`
- Post title: **The Mother of all Symbols...**
- Media: 50.99-second Reddit-hosted video (`v.redd.it/pq4kjp3t83jh1`), 1920×1080 source.
- Interface shown in the recording: **TORTOISE — Symbol Composer**.

This module is an original procedural implementation based on visual study of the linked recording. It does not copy source code or bundle media from the post.

## Observed construction

Representative frames at 0, 6, 12, 30, 40, and 45 seconds show:

- a hollow carrier torus as the dominant primitive;
- sixfold radial placement of smaller toroidal forms;
- nested ring/rosette hierarchy at multiple scales;
- paired positive- and negative-chirality fibers winding in opposite directions;
- warm burgundy carrier surfaces with orange/gold fibers;
- depth-darkened rear geometry and sparse warm particles on black;
- continuous, slow camera/object rotation;
- alternate presets in the source composer, including BLACK HOLE, WORMHOLE, COSMIC EGG, FLOWER OF LIFE, YIN YANG, TORUS KNOT, and TOROIDAL POLYHEDRA.

The app module models the shared TORTOISE construction rather than attempting to reproduce every source-composer preset.

## Fractal Forge mapping

| Observed feature | Implementation |
|---|---|
| Hollow carrier | Signed-distance torus |
| Sixfold organization | Six fixed radial sectors per generation |
| Nested forms | Up to three scaled toroidal generations |
| Opposite chirality | `winding*theta ± 11*phi` fiber fields |
| Warm fiber material | Burgundy carrier plus two gold fiber palettes |
| Rear attenuation | Exponential travel-depth fade |
| Motion | Slow time-driven yaw with gentle pitch drift |
| User controls | Fiber winding, recursion, ray steps, bailout, palette, rotation, zoom |

## Device verification

The first on-device render ran on a Samsung SM-S928B at 1080×2340. It visibly produced one dominant open torus, six inner toroidal forms, outer recursive loops, counter-winding gold detail, and a black particle field. Measured over the renderer area:

- luminance mean: `14.032`
- luminance standard deviation: `27.459`
- non-black pixel ratio: `0.4194`
- warm-material pixel ratio: `0.3104`
- screenshot SHA-256: `b2ec2874d7de77c5be5180aca7a6c7b45e1445b23e4547086dd661611f780591`
- sustained FPS: `60.1`
- mean build / raster / total: `3.23 ms` / `4.97 ms` / `10.12 ms`
- p95 frame time: `11.92 ms`
- long frames: `0 / 300`

The first device view was too tightly framed. Independent review then found
that its child generations were concentric rather than recursively nested and
that the original time scaling was effectively static. The final implementation
uses six explicit parent tori plus local sixfold space folding for 36/216
descendants, a visible approximately 30-second orbit, and premultiplied-safe
transparent misses.

A final post-review 512×512 `FragmentProgram` capture verified one complete
carrier, six distinct first-level child apertures, six visible descendants,
clear sixfold rosette symmetry, and no clipping:

- final default zoom: `0.95`
- final capture SHA-256: `a8a4f2b1c0b339a652246e836ca551e1d910cd938af353c2784913190cb281fd`
- final visual gate: **SHIP**

A behavior test additionally verifies that more than 200 pixels change over one
runtime second and that every zero-alpha pixel has zero RGB.
