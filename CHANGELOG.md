# Changelog

All notable changes to Flutter Fractal Forge are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
- Smooth coloring and palette system improvements
- Perturbation theory for GPU deep zoom beyond float32 limits
- Improved auto-pilot navigation with manual correction acceptance
- Enhanced preset management (delete, rename, thumbnail generation)
- User-defined color palette support
- Bookmark/favorites system for fractal locations
