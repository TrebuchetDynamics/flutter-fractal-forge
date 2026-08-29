# Changelog

All notable changes to Flutter Fractal Forge are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Official F-Droid catalog pipeline with ABI-specific APK validation,
  byte-for-byte reproducibility checks, signed reference binaries, pinned
  toolchains, tag CI, source-scanner gates, and Fastlane listing metadata.

### Fixed

- Android release minification now removes unused Flutter Play Store deferred-component
  references and omits APK dependency metadata so F-Droid binary scans remain clean.

### Removed

- Bundled FFmpeg and the Camera Looper MP4-with-music export. GIF export remains,
  avoiding FFmpeg's large native footprint and simplifying F-Droid review.

## [1.1.98] - 2026-08-28

### Added

- A redesigned cross-platform launcher icon and refreshed generated platform assets.
- Static catalog and viewer proof in the project README, with clearer platform,
  privacy, architecture, and contributor guidance.

### Fixed

- Distinct canonical registry hashes for the five shared-shader recursive objects,
  restoring the strict catalog deduplication invariant.
- Release ABI filtering and Play listing icon verification now match the current
  Android build pipeline and redesigned launcher icon.

## [1.1.93] - 2026-08-26

### Added

- Five original, sampler-free fractalish-motion visualizations spanning a
  chromatic arachnid lattice, radial sigils, recursive arcana frames, aurora
  tides, and a smoothly keyframed four-motif metamorphosis, bringing the
  working production catalog to 1009 fractals.
- Comprehensive ResearchForge provenance for the Deforum-inspired structural
  study, with an explicit boundary against third-party frames, prompts, LoRAs,
  model code, and media assets.
- Five original ray-marched recursive objects spanning ternary Cayley branching,
  multiscale gyroid membranes, Möbius echoes, Fibonacci cone IFS buds, and
  Chebyshev nodal sheets, bringing the working production catalog to 1014.
- A comprehensive MilkDrop/Carpathian structural study with an observation-only
  boundary: no preset, source shader, feedback texture, frame, music, or media
  asset is imported.

### Fixed

- One-finger panning now includes the movement used to cross touch slop, so
  deep-zoom drags start immediately and pinch-to-pan handoffs neither jump nor
  discard the next movement.

## [1.1.92] - 2026-08-24

### Added

- Thirty-four research-backed production fractals across complex dynamics,
  number theory, dynamical systems, geometric constructions, and stochastic
  fields, bringing the verified production catalog to 1000 fractals.
- Dedicated GPU shaders, formula/render regression tests, and provenance
  packages for the eighth, ninth, and tenth catalog research waves.
- Four static log-polar tessellation fractals with original procedural motifs,
  bringing the verified production catalog to 1004 fractals without bundling
  third-party image tiles.
- A bounded runtime-thumbnail render queue and reusable memory/disk thumbnail
  cache for smoother catalog browsing.

### Changed

- Share, image export, link sharing, and wallpaper actions now use one
  accessible Share & export menu, while Auto Explore uses the shared responsive
  bottom-sheet layout.
- Random fractal selection publishes its chosen module and palette atomically,
  preventing an intermediate default-palette flash.
- The CPU fallback renderer now shares optimized formula, viewport, iteration,
  and raster helpers to reduce duplicate work while retaining deterministic
  output across the supported catalog.

### Fixed

- Android production viewers no longer expose the desktop fractal-report FAB.
- Continuous Fractal Music camera motion tests now wait for the bounded rescan
  deadline instead of depending on an unloaded event loop.
- Physical-device integration gates now run serially with the configured Flutter
  toolchain, and Maestro flows follow the shared Share & export interaction
  without cross-device or stale-APK ambiguity.

## [1.1.90] - 2026-08-20

### Changed

- Viewer tools are now direct, accessible floating actions instead of being
  hidden behind a secondary More menu, with Auto Explore settings available
  from the same action rail.
- Google Play copy across all 15 supported locales now leads with the app’s
  completely free, ad-free, offline experience and documents the current
  export, creative, privacy, and accessibility capabilities.
- Play publication now preserves the optimized localized title and applies all
  localized listing text atomically with the verified production bundle.

### Fixed

- Auto Explore animation-controller initialization now follows the widget
  lifecycle explicitly.

## [1.1.89] - 2026-08-15

### Changed

- Viewer bottom sheets now fit phone viewports more consistently, use one drag
  handle, present a balanced Kaleidoscope grid, and keep all More actions
  reachable with accessible touch targets.
- Report Notes appears as a complete field before symptom choices, and Export
  guidance now matches the visible Save image and Save & share actions.

### Fixed

- The Text Overlay editor and Report sheet remain visible and usable while the
  Android keyboard is open, with one shared keyboard-inset owner.
- Opening the Controls HUD removes the overlapping floating-action rail from
  both painting and accessibility semantics.
- Kaleidoscope choices retain 48 dp targets at narrow 360-pixel phone widths,
  and the Text Overlay subtitle is localized in English and Spanish.

## [1.1.88] - 2026-08-14

### Added

- Live renderer-derived Fourier spectra for the effective visible frame, with
  responsive spatial/spectrum layouts, localized accessibility labels, and
  truthful retained-frame status when a current capture is unavailable.
- A finite-grid uncertainty laboratory with exact Cantor and Sierpiński masks,
  arbitrary-size unitary FFT support, and explicit numerical-experiment limits.
- Optional bounded Fourier Music modulation that preserves deterministic score
  identity and requests replacement handoffs at observed music-bar transitions.

### Changed

- GPU Fourier analysis now renders immutable effective renderer snapshots,
  including precision routing, palette transitions, animation time, fluid state,
  active compare pane, and current module state, in a long-lived latest-wins
  analysis worker.
- English and Spanish Fourier and uncertainty guidance now document the transform
  convention, finite viewport interpretation, and the exact disclaimer:
  “Finite numerical experiment—not a mathematical proof.”

### Fixed

- Generation-scoped activation, capture, compare-pane, lifecycle, and music
  publication ownership prevent stale asynchronous results from replacing newer
  renderer or score state.
- Blank, failed, hidden-app, and shader-transition captures retain the last valid
  displayed spectrum while clearing stale Fourier Music modulation.
- Release integration tests no longer acquire an unused semantics handle across
  multi-file physical-device runs.

## [1.1.87] - 2026-08-10

### Added

- Durable, versioned viewer-session restoration with lifecycle, process-death,
  deep-link, and stale-work safeguards.
- Coordinated, cancellable image, batch, video, and looper exports with
  background processing and partial-output cleanup.
- Measured frame, memory, long-frame, and first-frame diagnostics, plus bounded
  shader-resource caching and Android memory-pressure handling.
- Deterministic Android release evidence: signed AAB and target-specific APK
  validation, checksums, SBOM, third-party notices, provenance, and a
  manifest-bound publication snapshot.

### Changed

- Renderer ticking now follows explicit reviewed module capabilities and active
  runtime effects, so static modules settle while animated effects keep moving.
- Viewer controls, Back behavior, focus traversal, semantics, high-contrast
  presentation, large-text layouts, and touch targets were hardened.
- Catalog metadata, aliases, ranking, taxonomy, stable preset identities, and
  reviewed native Flutter goldens were updated.
- The app, adaptive launcher, and Play Store icons now use a high-detail Julia
  render produced by Fractal Forge itself, zoomed into one infinite spiral,
  rotated 180 degrees, and graded purple/blue with green and red accents.
- Web export now truthfully uses JPEG instead of presenting PNG bytes as WebP.
- CI actions are pinned to immutable revisions and release workflows use
  Flutter 3.44.6.

### Fixed

- Physical image exports now preserve device-pixel dimensions.
- Formula Lab keeps the last valid preview and reports invalid formulas without
  corrupting renderer state.
- Shader loading, cache ownership, export cancellation, offline recovery,
  lifecycle restoration, and publication failure propagation no longer leave
  stale work or silently accept incomplete release evidence.
- Fractal Music now composes off the UI isolate, hands replacement loops over
  without an avoidable stop gap, preserves the rotating scanner phase across
  view changes, rejects stale rescans, reacts to all identity-driving image
  features with a shorter settled-view debounce, uses diatonic chord qualities
  and phrase-anchored lead voice-leading without cumulative register drift,
  preserves tempo in short exports, and performs as a five-part ensemble with
  bass, warm pad/strings, lead, high texture, and a fractal-driven kick, snare,
  and closed-hi-hat section while retaining safe headroom.
- Camera Looper can export synchronized MPEG-4/AAC video with deterministic
  render-derived music, cancellation cleanup, codec-safe dimensions, seamless
  loop sampling, and an explicit GIF fallback; unsupported Web MP4 export is
  hidden rather than failing after selection.

## [1.1.86] - 2026-08-06

### Changed

- App icon now features a real full-set Mandelbrot render (2160×2160, from the
  app's own shader at x=-0.5, zoom 0.35, 600 iterations), blended into the
  brand background #0A0520, across every platform: Android adaptive + legacy
  mipmaps, iOS AppIcon set, web, Windows, macOS, and the in-app logo.

## [1.1.85] - 2026-08-06

### Fixed

- FadeIn animations no longer leak a pending timer when the widget is disposed
  before its delay elapses (a cancellable timer replaces the un-cancellable
  `Future.delayed`), fixing test-framework timer-strict failures and a real
  lifecycle leak on fast navigation.

### Added

- Stable `Key('fractalViewerRoot')` on the viewer root, enabling reliable
  per-fractal viewer assertions.
- Exhaustive viewer walkthrough test that opens every registered module
  (973 escape-time, 3D raymarched, custom, and diagnostics fractals) in the
  real viewer widget tree and asserts no exceptions.

### Changed

- The Playwright catalog smoke now extracts module IDs from the live catalog
  sources (previously stale paths limited coverage to 7 custom modules). The
  web catalog walk now covers all 531 production modules and passes end-to-end
  in a real browser.

## [1.1.84] - 2026-08-03

### Fixed

- Looper GIF exports now encode reliable frames from iteration data, preserve
  successful saves when sharing fails, and report save and sharing failures
  accurately.

## [1.1.83] - 2026-07-31

### Added

- Added Fractint's YinFinite Julia fractal with its source viewport and
  normal-map palette.
- Added a Source code link to Settings → About.

### Changed

- Camera loops now ease smoothly into and out of saved waypoints.
- The camera-path editor now guides the A → B workflow and announces each
  state to assistive technology.

### Fixed

- Looper GIF export now reports directory-selection and sharing failures
  accurately while preserving successful saved files.

## [1.1.82] - 2026-07-30

### Added

- Expanded and re-audited the ray-marched 3D catalog with distinct,
  source-backed identities including Juliabulb, Cantor Dust 3D, Quaternion
  Mandelbrot, Tetrabrot, Arrowheadbrot, Mousebrot, Turtlebrot, and
  Hourglassbrot.
- Added formula-specific CPU oracles and strict GPU image-health evidence for
  the new 3D identities.

### Changed

- Removed parameter-only 3D catalog clones while preserving useful powers,
  scales, and constants as controls or presets on canonical modules.
- Removed the obsolete onboarding flow so the app opens directly into the
  product.
- Completed another accessibility and localization pass across viewer reports,
  Formula Lab, settings, presets, history, controls, and status surfaces.

### Fixed

- Kept export controls, sheets, dialogs, and viewer HUD controls usable on
  compact screens, landscape layouts, and large accessibility text.
- Aligned palette previews with rendered relief colors and randomized the
  palette when choosing a random fractal.
- Stopped valid fractals with black centers from triggering GPU fallback.
- Improved wallpaper error reporting, batch export results, looper controls,
  Shader Lab previews, and deterministic screenshot targeting.

## [1.1.81] - 2026-07-29

### Added

- **Riemann Zeta Newton Basins**, a new fractal: Newton's method applied to the
  Riemann zeta function, so the basins are the zeta zeros themselves. It opens
  framed on the critical line where the first nontrivial zeros sit. The catalog
  is now 978 fractals.

### Fixed

- The Arnold cat map drew as flat noise. It now shows the diagonal shearing the
  map is known for.

## [1.1.80] - 2026-07-28

### Fixed

- Many strange attractors — Lorenz, Halvorsen, Rössler, Chen, Aizawa, the
  Sprott family and others — rendered as flat colour washes with no visible
  shape. Three separate causes: the viewport sampled too small a slice of each
  system to tell one pixel from another, the colouring averaged the whole
  trajectory and so came out the same everywhere, and a dozen fractals were
  framed off-centre and zoomed far past their own detail. They now show their
  actual structure.
- The Cantor set drew as a near-black frame, because the set itself is
  vanishingly thin. It now draws the familiar construction: each row removing
  another middle third.
- Fractal Music sounded thin in its upper register on bright fractals. The
  chords now bridge the gap to the bass instead of sitting far above it, and
  a high melody is reinforced an octave below so the line has body.

## [1.1.79] - 2026-07-26

### Fixed

- The catalog's filter bar clipped its own contents at the largest
  accessibility text size, cutting off the bottom of the category chips. The
  bar now grows with the text instead of staying a fixed height.
- Fractal Music sounded hollow on bright fractals: the chords and melody both
  moved up an extra octave while the bass stayed put, leaving a gap in the
  middle of the sound. The chords now stay closer to the bass and bridge it.

### Added

- The privacy policy is published with the site at
  https://fractal.trebuchetdynamics.com/privacy-policy

## [1.1.78] - 2026-07-26

### Fixed

- Fractal Music added a rhythmic flourish at the end of every bar whenever the
  view moved at all, however slightly, so the music was busier than intended
  while exploring and the quieter phrasing rarely came through. The flourish
  now waits for a substantial change of view, which is what it was meant to
  respond to: hold still or adjust gently and the phrasing stays open, make a
  real jump and the rhythm picks up.

## [1.1.77] - 2026-07-26

### Fixed

- Fractal Music made too many fractals sound alike. The thresholds deciding
  tempo, major or minor, octave, and which chord progression to use were set
  against a sample that turned out not to be representative, so most fractals
  landed on the same choices — roughly half the catalog shared a single chord
  progression. They are now set from a measurement of 85 real renders across
  the catalog, so the full range of each is actually reached and two different
  fractals are far more likely to sound genuinely different.

## [1.1.76] - 2026-07-25

### Changed

- Fractal Music now composes from an explicit score instead of generating audio
  a sample at a time. Notes have their own start, length, and voice, so they
  overlap and ring on rather than being cut off at each beat.
- Fixed four-voice ensemble (bass, pad, lead, texture), each with its own
  envelope and tone. The image chooses how it is played, not what plays.
- Tempo now follows the image: 60-100 BPM from how much fine detail it holds,
  where every fractal previously played at a fixed 40 BPM.
- Brightness sets the register in octave steps, and picks major or minor.
- Harmony draws on eight chord progressions per mode, chosen by colour
  saturation, where there were previously only two progressions in total.
- Melody lands on chord tones on strong beats and passes through the scale on
  weak ones, so the line reads as a melody rather than a broken chord.
- Key, mode, tempo, register, and progression now hold steady until the image
  changes substantially, so panning and zooming re-voice the same piece instead
  of restarting a different one.
- Moving the view fills the end of each bar with a pickup into the next chord;
  a still view keeps the rest, leaving the cadence audible.

### Fixed

- The whole arrangement briefly faded to silence at every beat, because one
  envelope was applied to the entire mix.
- Dark regions of a fractal dropped out completely. A Mandelbrot is mostly
  black, so roughly half its loop was silent; the chord now holds through
  those regions and only the melody rests. A wholly empty view is still silent.
- Small movements no longer restart the music: whether to regenerate is now
  decided from the measured image features rather than a hash of every pixel.
- Desktop screenshot capture produced black fractals, because the runner did
  not force GPU rendering and so captured the test placeholder surface.
- The Fractal Music preview tool checked audio against a stale loop length and
  reported every clip as failing.

## [1.1.75] - 2026-07-24

Consolidated notes for the 1.1.1-56 through 1.1.75 build series (2026-07-01 to
2026-07-24), which shipped without individual entries. Those builds were dense
increments rather than distinct releases, so they are summarised here by theme
instead of reconstructed one by one.

### Added

- Fractal Music: first version of the feature, turning the fractal on screen
  into sound, with a visible scanner and colour-driven harmony.
- Fluid warp mode, with runtime controls and feedback.
- New fractal families: folded fractals, plus IFS, cellular, and root-finding
  shaders.
- Wallpaper export, and a single unified sheet for the export and share actions.
- Render audit metrics for checking catalog-wide rendering health.

### Fixed

- Blank renders and inaccurate catalog entries found by the render audit.
- Wallpaper and high-resolution export falling back incorrectly.
- Export and wallpaper flows, and modal and viewer control state, all
  stabilised.
- Fractal Music playback and refresh hardened, including on Android.
- Catalog thumbnails reused from the manifest while scrolling instead of being
  re-rendered.
- GPU load reduced on mobile, and Rule 150 rendering optimised.
- Edge-to-edge display compatibility preserved.

## [1.1.0+24] - 2026-02-25

### Added

- Improved fractal catalog with comprehensive 196+ entry collection
- Enhanced visual assets for better user experience

### Changed

- Updated store listing descriptions with accurate fractal counts
- Improved onboarding flow with reduced page count and better landscape layout

### Fixed

- Fixed project memory access counts and last accessed timestamps
- Corrected fractal count from 350+ to 196+ across all documentation
- Resolved lint analyzer hints in fractal viewer screen

## [1.0.0+23] - 2026-02-15

### Added

- GPU-accelerated fractal rendering with 196+ fractal types
- Deep zoom with multi-precision rendering (float32 GPU, double-float GPU emulation, CPU fallback)
- 60+ colour schemes with sRGB-correct rendering
- Dual Mandelbrot/Julia viewer with real-time seed parameter adjustment
- Auto-Explore mode with intelligent zoom navigation
- 50+ built-in presets for famous fractal regions
- PNG export with optional transparency and up to 4K resolution
- WCAG AAA accessibility features (high-contrast theme, reduced-motion support, screen reader labels)
- English and Spanish localization
- Privacy-first design with no ads, tracking, or data collection

### Architecture

- Modular fractal system with 196+ GPU-rendered fragment shaders
- Three-tier precision engine for extreme zoom capabilities
- Real-time shader rendering up to 60 FPS
- Adaptive quality rendering for various device capabilities
- In-app diagnostic logging with export functionality
- Persistent history and preset management

## [Unreleased]

### Planned

- Smooth coloring across the remaining escape-time shaders (done in the
  perturbation shader)
- Improved auto-pilot navigation with manual correction acceptance
- Enhanced preset management (delete, rename, thumbnail generation)
- User-defined color palette support
- Bookmark/favorites system for fractal locations

Perturbation for GPU deep zoom beyond float32 has shipped and is no longer
planned work; see the Extended GPU Preview entry in CONTEXT.md.
