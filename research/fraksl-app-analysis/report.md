# Fraksl app research: lessons for Fractal Forge

## Method and limits

Sources retrieved:

- Google Play listing for Fraksl (`com.workSPACE.Fraksl`), reviewed on 2026-06-27 (saved copies removed before publication).
- Google Play listing for Fractal Forge (`com.trebuchetdynamics.fractal.forge`), reviewed for comparison (saved copy removed before publication).
- Public Fraksl Play screenshots, first 8 reviewed (saved copies removed before publication; third-party copyright).
- rforge search sweep across OpenAlex, Crossref, Semantic Scholar, and arXiv for 8 queries around Fraksl, fractal apps, fractal aesthetics, mobile touch visualization, and generative art.
- Citation expansion for four background papers.

Limits:

- No app binary was decompiled, no copyrighted full text was downloaded, and no private analytics were used.
- Google Play HTML is dynamic; numbers can differ by device/form factor and change over time.
- Fraksl's marketing claims were treated as claims, not verified behavior.

## Bottom line

Fraksl wins by being a **visual instrument**, not a math catalog: live feedback, layers, modulators, sequences, performance capture, and full-screen kaleidoscopic output. Fractal Forge already has the stronger catalog/deep-zoom/privacy story; the cheapest high-leverage lesson is to add a small **Perform mode** that makes one fractal feel alive: hide UI, map one or two parameters to time/audio/motion, quick bookmark states, and record/share a short loop.

Do not copy Fraksl's assets, screenshots, name, exact UI, or trade dress. Copy the product pattern: "fractal explorer becomes reactive visual instrument."

## Fraksl evidence from Play listing

Observed listing data in `play-store-page.html`:

- App: **Fraksl** by Emiel Harmsen.
- Category: Art & Design.
- Store scale: listing header showed **500K+ downloads**, **4.7 star**, **6.87K reviews**; the ratings section for selected form factor showed **4.8** and **6.43K reviews**.
- Monetization: free core app with in-app purchases for more filters, mirrors, layers, modulators, capture, streaming, and save slots.
- Data safety: listing says it may share app info/performance and may collect location, personal info, and 4 other data types; data encrypted in transit; data cannot be deleted.
- Positioning: "real-time fractal visual engine" for live performances, music visuals, generative art, and creative exploration.

Fraksl's own listed feature groups:

1. Filters and mirrors.
2. Layers from camera, imported images/videos, and NDI streams.
3. Sequences: bookmark visual states, arrange hold/transition times, share sequences.
4. Modulators: audio, MIDI, beat clock, waveform/LFO, motion sensors, gamepad.
5. Capture: high-resolution screenshots and video recording with optional microphone audio.
6. NDI streaming.
7. Presets that save layers, modulators, mappings, sequences, and settings.
8. 9 languages.

Representative review themes from public Play reviews:

- Positive: "visually stunning," "dizzying effects," "beautiful," "mind-blowing," no ads, inexpensive pro unlock.
- Pain: controls are "awkward" and hard to use intentionally; users want more starting algorithms; one user explicitly asked for audio-reactive modulation.

## Comparison with Fractal Forge

Fractal Forge listing and README emphasize:

- 350–400+ fractal catalog breadth.
- GPU shaders, deep zoom, precision fallback.
- presets, parameter controls, export, accessibility.
- no ads, no tracking, no data collection.

That is a solid differentiator, but it reads like a tool/reference. Fraksl reads like a toy/instrument people can perform with. The opportunity is not to out-Fraksl Fraksl; it is to add a lightweight performance layer over our stronger fractal engine.

## Main themes

### 1. Full-screen output sells better than controls

Fraksl's screenshots are almost all full-bleed visuals, not UI. They communicate instantly: "this app makes beautiful things." Our catalog/deep-zoom claims need one-tap proof.

Improvement:

- Add **Perform mode** in viewer: one button hides chrome, keeps gesture navigation, exposes only a tiny exit/control pill.
- Update store screenshots to lead with full-bleed renders before catalog/UI.
- Keep accessibility labels and a clear escape path; do not make an inaccessible immersive trap.

### 2. Reactive modulation is the killer feature to borrow

Fraksl's modulators turn static exploration into live visuals. Academic background supports caring about fractal perception, but not any specific app design: Taylor et al., "Perceptual and Physiological Responses to Jackson Pollock's Fractals" (Frontiers in Human Neuroscience, 2011, DOI `10.3389/fnhum.2011.00060`) and Coburn et al., "Aesthetics and Psychological Effects of Fractal Based Design" (Frontiers in Psychology, 2021, DOI `10.3389/fpsyg.2021.699962`) are useful context for why fractal visuals can be compelling.

Lazy version to build first:

- One built-in **LFO modulator**: sine/triangle, speed, depth, target parameter.
- One **audio amplitude** option if microphone permission path is already stable.
- One **motion tilt** option if sensor access is already available.
- Skip MIDI, NDI, gamepad, beat-clock sync until users ask.

### 3. Sequences are presets plus time

Fraksl's sequences are just saved states with hold/transition durations. Fractal Forge already has presets/history/export models, so the minimal feature is small.

Improvement:

- Add **A/B morph** or **sequence of presets**: choose 2–5 saved presets, hold seconds, transition seconds, play/pause.
- Export the sequence as a short screen-recorded clip later.
- Start with viewer-only, no shareable sequence file format.

### 4. Layers/camera are powerful, but risky

Fraksl's camera/media/NDI layers are compelling for live performance. Fractal Forge PRD already mentions camera overlay and video export, but this is where complexity explodes.

Improvement:

- Build only **camera-as-background with fractal overlay opacity** first if camera permissions and lifecycle are already reliable.
- Skip imported media, chroma key, NDI, blend-mode matrix, and multi-layer editor until the basic camera overlay proves retained use.

### 5. Control intentionality is the gap Fraksl reviews expose

A positive Fraksl review still says controls are awkward and hard to do on purpose. This is where Fractal Forge can beat it: keep the visual magic but make exploration understandable.

Relevant usability background: Hoehle and Venkatesh, "Mobile Application Usability: Conceptualization and Instrument Development" (MIS Quarterly, 2015, DOI `10.25300/misq/2015/39.2.08`) and Harrison et al., "Usability of mobile applications: literature review and rationale for a new usability model" (Journal of Interaction Science, 2013, DOI `10.1186/2194-0827-1-1`) support treating mobile usability as a first-class quality dimension, not polish.

Improvement:

- Add a short **gesture coach overlay** the first time a user opens viewer: pan, pinch, rotate, reset.
- Add **randomize good-looking** separate from randomize-all.
- Add lock icons or chips for geometry/color/camera before randomization.

### 6. Store positioning: our privacy is a real advantage

Fraksl has more downloads, but its listing declares data collection/sharing. Fractal Forge's listing says no data shared and no data collected. That is worth keeping loud.

Improvement:

- Lead store copy with two lanes: **Create moving fractal art** + **No ads, no tracking, no account**.
- Move deep-zoom/400+ catalog after the first emotional hook.
- Store screenshots: 1 full-bleed hero, 2 live controls/perform mode, 3 catalog breadth, 4 export/share, 5 privacy/accessibility.

## Performance claims hygiene

- Treat "real-time," "4K," "high-resolution," and "live" as device-dependent. If we use these claims, tie them to tested devices/resolutions.
- Do not claim Fraksl achieves a technical performance level unless measured locally; this report only records public listing claims.
- For Fractal Forge, prefer claims like "GPU-powered where supported" and "tested at X on Y device" over universal speed claims.

## Evidence gaps

- No hands-on Fraksl session was run, so UI flow and latency are inferred from listing/reviews/screenshots.
- No install-funnel data for Fractal Forge was reviewed.
- No user testing compares "catalog explorer" vs "visual instrument" positioning.
- Fraksl's newest 3.0 update may have changed older review complaints.

## Implications for Fractal Forge

Priority order:

1. **Perform mode**: fullscreen, minimal HUD, one-tap randomize-good-looking, quick reset.
2. **One modulator**: LFO mapped to a visible parameter; then optional audio amplitude.
3. **Preset sequence MVP**: play through saved presets with hold/transition seconds.
4. **Store refresh**: full-bleed screenshots and copy that sells creation first, math second, privacy always.
5. **Camera overlay only after the above**: no multi-layer editor until proven necessary.

Shortest useful issue slice:

> Add Perform mode to viewer: hide UI, keep gestures, show exit pill, randomize-good-looking, and preserve screen-reader escape labels. Acceptance: user can enter/exit with one tap, no controls obscure the fractal, existing viewer tests pass.
