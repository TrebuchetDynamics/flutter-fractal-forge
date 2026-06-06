# Visual Fidelity Reference Corpus Extraction

Status: second Reference Corpus mining lane. This note distills low-risk visual polish patterns that can improve Flutter Fractal Forge screenshots, catalog thumbnails, and the Browser Web Preview without treating upstream code as app source.

## Current app fit

Visual polish should be mined under the Reference Corpus rules:

- Prefer adapted implementations in our own shader/app style.
- Keep source URL, path, commit, license, and validation signal attached to each idea.
- Do not copy shader code from GPL/unknown-license projects into app shaders without explicit license review.
- Validate visual changes with analyzer/shader compile plus screenshot, pixel, or golden-like checks where practical.

## Ranked implementation candidates

### 1. Color-management/sRGB output audit

Most fractal shaders produce math-linear color and hand it directly to the framebuffer. Psychtoolbox and glChAoS.P both reinforce that display output needs an explicit color-space/gamma decision. The safest first improvement is not to edit every shader immediately, but to audit our active shaders and pick one canonical output policy.

Recommended first slice:

- Create a small tracked shader-output audit for the Featured Launch Set and core Mandelbrot/Julia shaders.
- Decide whether Flutter's current backend path expects shader output in linear or display/sRGB space.
- If applying correction, start with one shader and a measurable before/after screenshot/pixel check.

### 2. Smooth iteration coloring as default escape-time polish

Fractals-Explorer and MV2 both use continuous/smooth coloring variants to reduce banding. Our codebase already has many escape-time shaders, so this is likely a high-impact launch-polish lane if applied carefully to a few flagship modules first.

Recommended slice:

- Target one visible escape-time shader first, not every shader.
- Compare banding numerically by sampling neighboring pixels or via screenshot diff.
- Keep existing palette/iteration parameters stable unless the test proves a better default.

### 3. Cosine/procedural palettes with curated launch presets

Fractals-Explorer, giulia, and par-fractal all point to compact procedural palettes and phase-shifted cosine gradients. Because `giulia` and `Fractals-Explorer` lack local license files, use them only as concept references unless license context is resolved. par-fractal's MIT docs/source can anchor the provenance for cosine palette UX/palette breadth.

Recommended slice:

- Add or curate palette presets in app services/modules rather than copying upstream palette tables.
- Prioritize accessibility: avoid all-neon palettes as defaults; keep contrast readable in thumbnails.
- Validate with catalog thumbnail screenshots and screen-reader-friendly palette names.

### 4. Cardioid / period-2 bulb early-out for Mandelbrot

MV2 uses a user-toggleable cardioid/bulb skip for Mandelbrot. This is a visual-performance improvement rather than a visual-style change: it can reduce wasted iterations in known-inside regions without changing the expected image.

Recommended slice:

- Add an adapted early-out to a Mandelbrot shader only after confirming the shader's coordinate convention.
- Validate with pixel equivalence for interior/exterior sample points and shader compile logs.
- Treat MV2 as GPL provenance: adapted math only, no direct shader copying.

### 5. Post-processing as optional polish: FXAA/glow/bloom

glChAoS.P and par-fractal both show the value of separable/post-process pipelines: FXAA, glow, bloom, exposure/contrast, and palette controls. This has higher app-architecture cost than shader-local fixes, so it should follow color/smooth/palette work.

Recommended slice:

- Start with one optional post-process toggle, not a full visual-effects stack.
- Prefer FXAA or mild glow for launch thumbnails; avoid changing precision/status semantics.
- Validate frame cost and screenshot deltas.

## Provenance records

### Psychtoolbox-3 — sRGB/color-management policy

- Source repo: https://github.com/Psychtoolbox-3/Psychtoolbox-3
- Source path: `Psychtoolbox/PsychGLImageProcessing/kPsychEnableSRGBRendering.m`; `Psychtoolbox/License.txt`
- Source commit: `0749271298e9896756e97e06b3ac9049d814c343`
- License: mixed distribution; license file says unlisted material outside `PsychContributed` can generally be assumed MIT, but component-specific license review is required.
- Idea summary: Treat sRGB/display output as an explicit rendering policy, not an accidental shader detail.
- Reuse mode: adapted idea only
- Target app area: `shaders/` output policy, launch screenshot validation, future shader audit.
- Validation signal: shader compile plus screenshot/pixel comparison for one launch shader before broad rollout.

### glChAoS.P — gamma/tuning, FXAA, glow, bilateral smoothing

- Source repo: https://github.com/BrutPitt/glChAoS.P
- Source path: `readme.md`; `Shaders/colorSpaces.glsl`; `Shaders/filtersFrag.glsl`; `Shaders/bilateralVersions.glsl`; `src/src/ShadersClasses.cpp`
- Source commit: `f3b604a6885f7e80567c2bffe91f7dd2ef2be4b7`
- License: BSD-2-Clause via `license.txt`
- Idea summary: Post-render stack with gamma/exposure/brightness/contrast, FXAA, multi-pass glow, and threshold/bilateral smoothing; useful as architecture inspiration for optional launch polish.
- Reuse mode: adapted idea only
- Target app area: optional post-process shader/service roadmap; thumbnail polish validation.
- Validation signal: frame-time measurement plus before/after screenshot diffs for one effect.

### par-fractal — palette breadth and post-process feature matrix

- Source repo: https://github.com/paulrobello/par-fractal
- Source path: `docs/README.md`; `docs/FEATURES.md`; `docs/ARCHITECTURE.md`; `src/fractal/palettes.rs`; `LICENSE`
- Source commit: `dd7318132b24ff0a0f5255e7a25c833eedbb536b`
- License: MIT via `LICENSE`
- Idea summary: Large static/procedural palette system, cosine palette parameters, palette cycling UX, and explicit render pass ordering with bloom/FXAA options.
- Reuse mode: adapted idea only
- Target app area: `palette_service.dart`, catalog thumbnail presets, optional post-processing roadmap.
- Validation signal: palette unit tests plus thumbnail screenshot checks for the Featured Launch Set.

### Mandelbrot Voyage 2 — smooth coloring, cardioid/bulb skip, palette buffer model

- Source repo: https://github.com/Yilmaz4/MV2
- Source path: `README.md`; `shaders/render.glsl`; `src/main.cpp`; `LICENSE.txt`
- Source commit: `d13ac77b6b8cfd440957698c4b736beb9965b052`
- License: GPL-3.0 via `LICENSE.txt`
- Idea summary: Smooth coloring, cardioid/period-2 bulb skipping, normal-map lighting, and palette buffer workflow for high-quality Mandelbrot visuals.
- Reuse mode: adapted idea only
- Target app area: Mandelbrot shader polish, palette architecture research, performance tests.
- Validation signal: shader compile and pixel equivalence for cardioid/bulb early-out; screenshot diff for smooth coloring.

### giulia — compact HSV/preset UX concept

- Source repo: https://github.com/bernardocrodrigues/giulia
- Source path: `README.md`; `src/gl/shaders/single_precision.shader`; `src/gl/shaders/double_precision.shader`
- Source commit: `9b4a073a6383b21b2e655b391c01e84a0b9fb744`
- License: unknown; no local license file found.
- Idea summary: Compact color preset controls and simple HSV-based fractal coloring UX.
- Reuse mode: concept only until license is resolved
- Target app area: palette preset naming/UX, not shader code reuse.
- Validation signal: palette UX copy review and thumbnail contrast checks.

### Fractals-Explorer — smooth coloring and cosine palette concept

- Source repo: https://github.com/Greece4ever/Fractals-Explorer
- Source path: `README.md`; `web/shaders/mandel.glsl`; `docs/shaders/mandel.glsl`
- Source commit: `07f33315064ef60cdc97e356a6dba251e598d7e6`
- License: unknown; no local license file found.
- Idea summary: Browser/WebGL escape-time viewer using multiple coloring modes, smooth iteration values, and cosine palette styling.
- Reuse mode: concept only until license is resolved
- Target app area: smooth-coloring/palette design notes, not direct shader reuse.
- Validation signal: one adapted shader style test plus screenshot/pixel comparison.

## Recommended next implementation slice

Before editing shaders broadly, add a **visual-fidelity audit note/test target** for one flagship shader:

1. Pick one launch-critical shader (`Mandelbrot`, `Julia`, or current Featured Launch Set candidate).
2. Record current screenshot/pixel behavior.
3. Apply one adapted improvement only: smooth coloring or sRGB policy, not both.
4. Validate with shader compile, analyzer/tests, and a measurable screenshot/pixel delta.

## Not selected yet

- Copying GLSL snippets from GPL or unknown-license projects.
- Global color-management policy without a one-shader proof.
- Full post-processing stack before single-shader polish is measurable.
- Broad palette table imports; prefer curated app-native presets.
