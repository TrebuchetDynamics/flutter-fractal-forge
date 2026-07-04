# Flutter Fractal Forge Context

Flutter Fractal Forge is a fractal exploration app centered on GPU-first rendering with honest fallback paths when deep zoom exceeds the current preview path.

## Language

**Browser Web Preview**:
The public browser entrypoint for discovery and tester feedback. It proves the JavaScript web target can boot, browse the catalog, and open a renderer, but it is not a promise of full app parity.
_Avoid_: Full web app, production web parity, Wasm app

**Featured Launch Set**:
The small, curated set of fractals used for first-time screenshots, GIFs, website copy, and soft-launch guidance. It is the entry path into the broader catalog, not a replacement for it.
_Avoid_: Random catalog sample, all fractals, top count

**Trust-Breaking First-Impression Defect**:
A defect that prevents a new visitor from trusting the Browser Web Preview during the landing, app boot, catalog, or Featured Launch Set path. It blocks bigger launch; ordinary limitations outside that path can be documented instead.
_Avoid_: Any bug, known limitation, edge-case bug

**Precision Ladder**:
The ordered set of render paths used as zoom depth increases: realtime GPU, extended GPU preview, then CPU precision. It is the source of truth for deep-zoom render-path copy and routing.
_Avoid_: Scattered thresholds, backend toggle

**Visual Fidelity Audit**:
A scoped, evidence-backed review of launch-critical shaders, presets, thumbnails, and screenshots before visual polish changes are made. It is not a blanket shader rewrite; it identifies measurable first-impression fixes for the Featured Launch Set.
_Avoid_: Visual vibes, global shader pass, polish sweep

**Seeded Thumbnail Palette**:
A deterministic color variation chosen from a thumbnail generation seed and a stable fractal/module ID. It should feel visually varied while keeping regenerated catalog thumbnails reviewable and reproducible.
_Avoid_: True random thumbnail colors, one-off palette shuffle, unreviewable visual diff

**Fractal Music**:
A viewer audio mode that turns the current fractal state into explainable sonification, starting with constrained polar/spiral-scan motifs. It is not a generic background soundtrack, AI song generator, or MIDI export promise.
_Avoid_: AI song, opaque music generator, soundtrack mode

**Radial Scan Sonification**:
The first Fractal Music scan mode: a visible rotating center-out radar beam samples the current fractal view and maps those samples to bounded musical pitch, loudness, rhythm, or pan. It is the canonical launch path for Fractal Music, not a promise that every shader exposes exact internal iteration data.
_Avoid_: Pixel-to-song, hidden soundtrack, exact shader readback

**Performance Fractals**:
A separate catalog family for reactive, instrument-like fractal visuals whose parameters may be driven by time, gestures, or modulation. They do not change the behavior, controls, presets, or render contracts of existing mathematical fractal modules.
_Avoid_: Global perform mode, retrofitted modulator, all-fractal audio mode

**Launch Thumbnail Standard**:
The thumbnail contract for bundled catalog assets used in launch-critical browsing and screenshots: 320×320 PNGs. Smaller staged smoke outputs are allowed only as generation-test artifacts, not as bundled catalog assets.
_Avoid_: Smoke thumbnail size, arbitrary thumbnail size, per-run asset size

**Launch Visual Metrics**:
The objective thumbnail measurements used during a Visual Fidelity Audit for the Featured Launch Set. They describe first-impression image health without making long-tail catalog visuals fail by default.
_Avoid_: Visual vibes, subjective polish score, catalog-wide failure rule

**Counted Catalog Identity**:
A stable renderable formula, rule, grammar, transform system, map, or distance estimator counted toward the world-largest catalog goal. Presets, palettes, camera views, thumbnails, and renderer implementation details do not create Counted Catalog Identities.
_Avoid_: Preset count, thumbnail count, random variant, renderer count

**Extended GPU Preview**:
A GPU render path that extends useful deep zoom beyond ordinary float32, currently through double-float Mandelbrot or perturbation shaders. It is preview-grade unless a later refine path proves exactness.
_Avoid_: Exact GPU, CPU fallback

**CPU Precision**:
The stable renderer path used when the precision ladder decides the GPU preview paths are insufficient or unavailable and a native CPU formula exists for that module. It is slower, but it is the current exact-intended deep-zoom path. Deterministic synthetic CPU previews are not CPU Precision.
_Avoid_: Slow mode, fallback-only mode, synthetic CPU preview

**Reference Corpus**:
The local collection of upstream fractal projects used as research input for algorithms, patterns, parameter ranges, and validation ideas. It is not app source; production changes should come from tracked distillation with provenance and license review.
_Avoid_: Vendored source, copy-paste library, third-party app code

**Provenance Record**:
A tracked note that connects a Reference Corpus idea to its upstream source, license context, intended app target, and validation signal before it influences production code.
_Avoid_: Scratch note, clone path, license guess

**Reference Orbit Fixture**:
A tested, replayable reference-orbit data shape used to validate perturbation/refine bookkeeping before it becomes a precision renderer. It is not CPU Precision until its orbit generation uses the exact-intended deep-zoom path.
_Avoid_: CPU Precision, exact reference, production perturbation renderer

## Example Dialogue

Developer: “Can we say the web app is launched?”
Domain expert: “Say Browser Web Preview until export/share, deep zoom, CPU precision fallback, and hardware GPU behaviour are validated.”

Developer: “Should the launch lead with hundreds of fractals?”
Domain expert: “Lead with the Featured Launch Set, then mention the broader catalog as depth.”

Developer: “A non-featured fractal has a visual glitch. Does Reddit wait?”
Domain expert: “Not unless it is a Trust-Breaking First-Impression Defect on the landing, boot, catalog, or Featured Launch Set path.”

Developer: “Should we add sRGB to every shader because an upstream note recommends it?”
Domain expert: “No. Run a Visual Fidelity Audit first; many launch shaders already encode sRGB, and a global pass could double-encode colors.”

Developer: “At 1e10 zoom, should Julia jump to CPU?”
Domain expert: “No. Julia has Extended GPU Preview, so the Precision Ladder should keep interaction on GPU and describe it as Deep GPU.”

Developer: “When an unknown 2D module crosses its threshold?”
Domain expert: “Do not call the synthetic CPU fallback CPU Precision. Keep it on GPU/preview unless a native CPU formula exists, then move to CPU Precision after hysteresis.”

Developer: “Can I paste this upstream GLSL function from the Reference Corpus into our shader?”
Domain expert: “No. First create a Provenance Record with source, license context, target, and validation signal, then implement our own version or explicitly record why direct reuse is license-compatible.”

Developer: “Can Fractal Music just play a nice backing track?”
Domain expert: “No. Fractal Music should stay tied to the current fractal state through explainable sonification; a generic soundtrack is a different feature.”

Developer: “Should the music button draw a line from the center like a radar scan?”
Domain expert: “Yes. That is Radial Scan Sonification: the visible beam is the listening path, and the sound should explain what that beam is sampling.”

Developer: “Can we add LFO/audio-reactive controls to every current fractal?”
Domain expert: “No. Put reactive instrument visuals in Performance Fractals so the existing catalog keeps its current module contracts.”

Developer: “Does the new Mandelbrot reference orbit mean CPU Precision is implemented?”
Domain expert: “No. It is a Reference Orbit Fixture until orbit generation uses the exact-intended deep-zoom path.”
