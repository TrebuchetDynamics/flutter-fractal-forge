# Changelog

All notable changes to Flutter Fractal Forge are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

### Changed
- Synced README, AGENTS, status, TODO, privacy, and store-listing docs with the current 370-module catalog and release scope
- Clarified that current release docs should not advertise camera/AR or video export features

### Planned
- Smooth coloring and palette system improvements
- Perturbation theory for GPU deep zoom beyond float32 limits
- Improved auto-pilot navigation with manual correction acceptance
- Enhanced preset management (delete, rename, thumbnail generation)
- User-defined color palette support
- Bookmark/favorites system for fractal locations
