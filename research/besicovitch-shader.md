# Besicovitch / Perron-tree shader feasibility

## Shader feasibility

Status: Accepted

Owner decision: `/lgtm` on 2026-10-23 approved the recommended bounded shader module with geometric and luminous presets. This authorizes the local implementation, not publication, scheduling, queue migration or whole-platform qualification. The feasibility evidence below records the pre-implementation research snapshot; the current implementation is described separately below.

## Grounded construction

A planar Besicovitch/Kakeya set contains a unit line segment in every direction. Such sets can have zero area. Requiring a needle to rotate continuously inside the set is stronger: continuous-motion needle sets can have arbitrarily small positive area, not zero area [1]. Terminology varies, so name the property explicitly rather than relying on Kakeya alone.

Use a finite Perron tree: split a unit-height triangular fan into narrow triangles, translate pairs and then groups to overlap them, and retain the original triangle shapes/directions [2,3]. A classical equilateral fan covers a 60-degree interval of unoriented directions; three suitably rotated copies cover all directions modulo 180 degrees. Validate this using the original direction intervals and unit-length witnesses, not just a pretty screenshot or a finite angular sample. Finite unions of these positive-area triangles are approximations, not the zero-area limiting set. Three rotated copies alone do not provide continuous needle movement between pieces; that requires the additional joins described in the mathematical construction.

For the heart/arms construction in the cited notes, a conservative normalized area bound is alpha^(2n) + 2(1-alpha)/(1+alpha). The bound's fixed-alpha tail is nonzero: depth alone does not establish zero area from this bound. Arbitrarily small-area constructions choose overlap parameters together with depth; the measure-zero result also needs a limiting/compactness argument [2,3,4]. Rendered pixel coverage, antialiasing and glow are not this mathematical area.

## Smallest useful shader design — recommendation, not a benchmark

One geometric module, not a Mandelbrot escape-time variant. Working display name: **Besicovitch — Perron Tree**. One faithful preset and a luminous artistic preset can share the same identity.

- Derive and verify leaf translations from the published construction in a small CPU geometry model when controls change. Upload horizontal offsets, not a large array of all triangle vertices. The rest of each leaf is determined by its original slope interval, height and translation.
- At a fragment position, rotate coordinates for each of the three fan copies, test triangle half-planes, combine their coverage, then apply color and optional edge glow. This is a 2D coverage calculation, not a 3D signed-distance field or proof of the limiting set.
- Initial proposed cap: depth 5, at most 32 leaves per fan and 96 triangle tests per pixel, with 32 translation floats shared by the rotated copies. This avoids per-pixel geometry regeneration and a large uniform array of vertices. Actual uniform reflection, Flutter backend compatibility and timing still require compile/draw tests; no fps claim is established.
- Use screen-space antialiasing derived from resolution/zoom or a backend-supported derivative path, finite arithmetic, explicit depth caps and cancellation for geometry rebuilds. Do not silently lower depth. At higher requested budgets, show the supported limit rather than pretending to draw infinite detail.
- Controls: depth, construction/merge parameter, palette, rotation and luminous-edge amount. Do not expose unrelated power or escape bailout controls. Existing 2D pan/zoom/export state can be reused, but no Flutter module has yet been implemented or tested for this design.

Expected art direction, not an observed render: branching fans, overlapping crystalline wedges, layered needle-like filaments and fine geometric gaps. Color can encode direction or overlap count; a monochrome coverage mode should expose the actual model. No generic particle field or unrelated fractal hidden behind the name.

## Honest styling and animation

Glow/thickness belongs to presentation and increases visible covered pixels. Keep it separate from geometric coverage and any area readout. Curving the lines, adding nonlinear warps or arbitrary recursive decorative branches produces an **inspired** variant and may destroy the straight-unit-segment property. Rigid rotation preserves it; translating entire intact leaves preserves each leaf's directions, although an animation of their assembly is not a continuously turning needle trajectory. A direction-sampling needle may jump between translated leaves; label that rather than showing false continuous motion. Provide a static/reduced-motion mode and freeze actual state for exports if animation is added later.

No extension to complex or four-dimensional state is required: complex notation z=x+iy would merely encode this same real plane. A 3D artistic extrusion should not be described as a proof about a limiting higher-dimensional Kakeya set.

## Source/reference inspection and limits

[1] Indiana University Mathematics, Ciprian Demeter, *Perron Trees and Kakeya Needle Sets*: https://math.indiana.edu/research/gallery/perron-trees-and-kakeya-needle-sets.html . Academic exposition distinguishes direction coverage from continuous motion.

[2] Jonathan Hickman, *The Kakeya Conjecture: where does it come from and why is it important?*, arXiv:2512.09842v1, section 1.2: https://arxiv.org/html/2512.09842v1 . Author exposition of the finite cut/shift construction and additional limiting argument. No claim about recent higher-dimensional results is needed for this design.

[3] Yuval Wigderson, *The Kakeya Conjecture*, Mathcamp 2017: https://ywigderson.math.ethz.ch/math/static/KakeyaNotes.pdf . Public search-extracted notes provide the heart/arms area bound and translation/needle-join explanation. No PDF was acquired in this run. MathWorld corroborates the finite construction and rotation distinction: https://mathworld.wolfram.com/PerronTree.html . Original Perron reference: https://doi.org/10.1007/BF01181172 .

[4] The limiting construction needs care: https://mathoverflow.net/questions/352427/explicit-construction-of-kakeya-sets-using-perron-tree . This secondary discussion is a warning not to equate a finite collection or an arbitrary intersection with a proved measure-zero set; it is not the implementation's only mathematical reference.

A small browser reference exists at https://teorth.github.io/tao-web/apps/besicovitch-sets.html . Its source was inspected at commit `3905d9f89bbdab4573130c355c16ede86202d760`, path `static/apps/besicovitch-sets.html`, content SHA-256 `0fa4a4cac312f14b153cbf13cea23f1fb32205d679310c4bd0f44099ebbb07fc`. The repository's current LICENSE grants MIT terms for applet source, not its diagram data or other website content; it explicitly says the applets are AI-generated and not reviewed line by line. The inspected app draws a single fan, not a demonstrated all-direction multi-copy set. Its captions/area display must not be treated as a verified theorem or copied into our mathematical claims. No reference code, figures or applet was incorporated into the application. Pin/license record and retrieved reference source remain private research artifacts.

A bounded source-name search found no Besicovitch/Kakeya/Perron entry under current lib/ or shaders/. This is not an exhaustive mathematical duplicate audit of differently named modules.

## Evidence and future checks

Research completed at Standard depth: five query variants, OpenAlex and Crossref; caps 10 variants, 5 providers, 50 requests, limit 5 per query/provider. Actual: 10 requests, 50 records, 49 deduplicated, 46 unique DOIs, no failed/pending pairs, stop reason completed. Marginal yield did not saturate; this is a completed selected sweep, not exhaustive literature coverage. Broad-query results included unrelated/unreviewed material and were not all read. Three Crossref reference expansions were attempted separately; their actual results/errors are retained with provenance. No PDF acquisition or human inclusion/privacy/claim approval occurred.

Validated arithmetic: the proposed depth-5 cap gives 32 shared offsets and 96 triangle tests per pixel. At alpha=0.8,n=5, the cited conservative finite normalized bound evaluates to about 0.3295964, with fixed-alpha tail about 0.2222222; neither is a measured render area. No shader compilation, rendered preview, CPU/GPU parity, export or performance test ran.

Before adding the module: independently check the translation schedule, original leaf orientation/unit lengths, continuous angular coverage by the three rotated fans, geometric union area against valid bounds, and depth/parameter limits. Then exercise a real Flutter shader draw/PNG readback, finite antialiasing at supported cameras, same-state export, palette/coverage separation and named-backend timing at increasing depths. Do not label a Canvas geometry fallback as CPU Precision unless it is actually integrated/qualified as such. This feasibility note and proposed task are not implementation evidence.

## Finite implementation

Implemented identity: `perron_tree`, via `lib/core/models/perron_tree_model.dart`, `lib/core/modules/fractals/perron_tree_module.dart` and `shaders/ifs_and_geometric/perron_tree_gpu.frag`. The depth cap is 5 (32 offsets shared by three fans); depth, heart scale, rotation, hue, geometric/luminous style and glow are captured in ordinary module parameters. Geometry is cached by depth/scale, not regenerated per pixel. No extra dependencies or nonlinear warps were added.

For half-base H=1/sqrt(3), N=2^d and leaf width delta=2H/N, stage k pairs groups of 2^k leaves. The existing hearts have height h=a^k. Aligning their apexes translates the right group by -2^k delta(1-h); merging aligned hearts adds -2(2^k delta h)(1-a). Thus the right-group translation is -2^k delta[1+a^k(1-2a)], added to leaves whose index has bit k set. Original triangle slopes and unit height remain unchanged. The final heart has height a^d; rigid recentering preserves the geometry.

Continuous direction coverage is not inferred from the finite-angle test: original slopes [-1/sqrt(3),1/sqrt(3)] give the closed angle interval [pi/3,2pi/3]. Rotations 0, 2pi/3 and 4pi/3 cover [0,pi] modulo pi, including interval boundaries. Every slope belongs to one retained leaf; a unit vector along that slope has vertical projection at most 1, so its segment from the translated apex remains in that unit-height leaf. The tests sample this analytic construction as regression checks, not as a proof of the limiting Besicovitch theorem.

The default is a static luminous three-fan figure; the geometric preset exposes coverage without glow. Antialiasing is a bounded approximation, not an area estimator. The image and its glow have positive area. Nonfinite control inputs fall back to legal defaults; legal extreme zooms must not fill the background. This module is shader-only: CPU-only viewing displays a localized unsupported notice, and low-level CPU dispatch refuses an unrelated synthetic substitute. It is not advertised as CPU Precision or a qualified Android-emulator path.

Existing focused coverage: independent affine-interval union integration through depth 5 at several scales; two-stage translation fixtures; sampled unit-segment witnesses; real Flutter shader/PNG readback against a barycentric coverage oracle; style/time/transparency/camera limits; EN/ES CPU-only notice and refusal; registry/animation/public-count integrity. Artifact generation can be enabled with `PERRON_PREVIEW_DIR`; its host draw/readback timing is not device FPS.

Remaining qualification: actual browse/customize/understand/export journeys, exported-file integrity, browser/device measurements and physical hardware GPU behavior remain independent. The pre-existing task-store conversion is still blocked; this pass does not edit or close TODO/goals records, waive checks, resume the runner or grant migration consent. Reconcile the existing BESICOVITCH-01 record through the supported store after that boundary is resolved; do not schedule duplicate implementation.

## Readability improvement

The original luminous blend took component-wise color maxima and added glow for every overlapping leaf, clipping the center and concealing the construction. The improved shader averages the covered direction colors, uses a bounded maximum edge halo, and composites that halo only through uncovered opacity. Geometric coverage, triangle translations, directions, depth limits, uniforms, IDs and saved parameters are unchanged; no decorative branches or new catalog identity were added.

For coverage C, halo opacity L and premultiplied halo color G, output opacity is C+(1-C)L and output color is C times the weighted direction color plus (1-C)G. Since each component of G is at most L, premultiplied color stays bounded by opacity. This follows Flutter's [normalized premultiplied shader-output contract](https://docs.flutter.dev/ui/design/graphics/fragment-shaders); the documentation is a protocol reference, while execution uses pinned Flutter 3.44.6. The [published Perron-tree construction](https://math.indiana.edu/research/gallery/perron-trees-and-kakeya-needle-sets.html) remains the mathematical basis, not the luminous effect.

Matched 960×720 host shader PNGs contained 4,935 versus zero near-white pixels (all RGB channels at least 250). This measures clipping, not set area. The default geometric 240×200 RGBA images were pixel-identical. New regressions cover center clipping through several depths/glow strengths and premultiplied transparent-to-opaque compositing within two byte levels; native and Chrome geometry/shader checks pass. Physical GPU performance, full platform journeys and publication remain unqualified; previous full-suite results are historical, not a fresh full-suite run for this styling patch.
