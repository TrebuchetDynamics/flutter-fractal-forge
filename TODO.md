# Flutter Fractal Forge - TODO & Roadmap

> Last updated: 2026-02-11
>
> A prioritized list of improvements, features, and ideas for the Flutter Fractal Forge app.

---

## 🔴 High Priority - Core Improvements

### Performance & Stability
- [ ] **Implement shader caching** — Currently shaders are loaded each time; cache compiled programs for faster module switching
- [ ] **Add GPU memory management** — Monitor and limit shader memory usage on low-end devices
- [x] **Frame rate optimization for AR mode** — AR quality presets now cover all 10 fractal modules with per-module iteration/step tuning; removed no-op GPU filters
- [ ] **Add graceful degradation** — Detect GPU capabilities and adjust iteration counts automatically

### Missing Core Features
- [ ] **Preset deletion** — Users can save presets but cannot delete them (only loading exists in `PresetSheet`)
- [ ] **Preset editing** — Allow users to rename or update existing presets
- [ ] **Preset thumbnails** — Generate and display preview images for saved presets
- [ ] **Undo/Redo system** — Track parameter changes and allow reverting to previous states
- [ ] **Bookmark favorite locations** — Quick-save interesting zoom locations separate from full presets

### Error Handling & UX
- [ ] **Improve shader error messages** — The current error display is technical; add user-friendly explanations
- [ ] **Add onboarding/tutorial** — First-time user guide explaining gestures and controls
- [ ] **Add haptic feedback** — Subtle vibration on slider snapping and button presses
- [ ] **Better loading states** — Show shader compilation progress, not just "Loading shaders..."

---

## 🟡 Medium Priority - Feature Enhancements

### New Fractal Types
- [ ] **Sierpiński Triangle/Carpet** — Classic recursive fractals (could be 2D shader-based)
- [ ] **Newton Fractal** — Root-finding visualization with beautiful basins
- [ ] **Lyapunov Fractal** — Chaos theory visualization
- [ ] **Tricorn/Mandelbar** — Conjugate Mandelbrot variation
- [ ] **Barnsley Fern** — IFS-based botanical fractal
- [ ] **Menger Sponge (3D)** — 3D fractal with infinite holes
- [ ] **Apollonian Gasket** — Circle packing fractal

### Color & Rendering
- [ ] **Custom color palette editor** — Let users define their own gradients
- [ ] **Color palette presets library** — Curated collection of palettes (sunset, nebula, forest, etc.)
- [ ] **Anti-aliasing toggle** — Super-sampling option for higher quality exports
- [ ] **Animation mode** — Auto-animate parameters over time (color cycling, slow zoom)
- [ ] **Interior coloring for Mandelbrot** — Add distance estimation for inside-set coloring
- [ ] **Orbit traps** — Alternative coloring method using geometric shapes

### Export & Sharing
- [ ] **Batch export** — Export multiple resolutions at once
- [ ] **Animation/GIF export** — Export zoom animations or parameter sweeps
- [ ] **Video export with native encoding** — Replace GIF fallback with proper MP4/WebM
- [ ] **Direct social media sharing** — Pre-configured sizes for Instagram, Twitter, etc.
- [ ] **Export presets as shareable links** — Generate URLs or QR codes for preset sharing
- [ ] **EXIF metadata in exports** — Embed fractal parameters in image metadata for reproduction

### AR Mode Improvements
- [x] **AR back button and l10n** — Added explicit back navigation; replaced hardcoded strings with localized keys
- [ ] **AR recording with audio** — Option to capture device audio during video export
- [ ] **Multiple overlay shapes** — Circle, square, hexagon frame options
- [ ] **Blend modes** — Multiply, overlay, screen blending with camera feed
- [ ] **AR face tracking** — Position fractal overlay relative to detected faces
- [ ] **Save AR compositions** — Store favorite AR setups (fractal + style + position)

---

## 🟢 Low Priority - Nice to Have

### User Experience
- [ ] **Dark/Light theme toggle** — Currently only dark theme exists
- [ ] **Tablet/Desktop layout** — Responsive design for larger screens
- [ ] **Keyboard shortcuts (desktop)** — Arrow keys for pan, +/- for zoom
- [ ] **Pinch-to-zoom sensitivity setting** — Adjustable gesture sensitivity
- [ ] **Quick-access control bar** — Mini controls without opening the full sheet
- [ ] **History/recent fractals list** — Track recently viewed fractals and locations

### Educational Features
- [ ] **Math info panel** — Explain the mathematics behind each fractal
- [ ] **Iteration visualization mode** — Show how iterations converge/diverge
- [ ] **Coordinate display** — Show current complex plane coordinates
- [ ] **Zoom depth indicator** — Display how deep the current zoom is
- [ ] **Tour mode** — Guided exploration of famous fractal locations

### Social & Community
- [ ] **Gallery of user creations** — Optional cloud gallery for sharing
- [ ] **Preset sharing community** — Browse and download community presets
- [ ] **Wallpaper mode** — Generate device wallpapers at correct aspect ratio
- [ ] **Widget support** — Home screen widget showing animated fractals

### Technical Improvements
- [ ] **Add comprehensive code documentation** — Expand dartdoc coverage
- [ ] **Increase test coverage** — Current tests are mostly widget tests; add more unit tests for services
- [ ] **Performance benchmarking** — Automated FPS testing across devices
- [ ] **Accessibility audit** — Ensure proper semantics and screen reader support
- [ ] **CI/CD pipeline** — Automated testing and deployment

---

## 💡 Discovered Feature Ideas

These ideas emerged while exploring the codebase:

### Based on Current Architecture
1. **Fractal comparison mode** — Split screen showing two fractals or parameters side by side
2. **Parameter linking** — Link zoom to iterations automatically for optimal quality
3. **Session recording** — Record and replay exploration sessions
4. **Fractal morphing** — Smooth transitions between different fractal types
5. **Julia set from Mandelbrot** — Tap a point in Mandelbrot to see its corresponding Julia set

### Shader Enhancements
1. **Custom shader upload** — Power users can load their own GLSL shaders
2. **Shader parameters via uniforms** — Expose more shader values to UI controls
3. **Post-processing effects** — Blur, vignette, chromatic aberration as overlays
4. **Ray marching enhancements (3D)** — Ambient occlusion, soft shadows for Mandelbulb

### Integration Ideas
1. **Apple Watch companion** — Remote control for exploration
2. **Nearby device sync** — Explore the same fractal on multiple devices
3. **VR/AR headset support** — Immersive 3D fractal exploration
4. **Procedural music generation** — Create ambient soundscapes from fractal data

---

## 🗓️ Suggested Roadmap

### Phase 1: Polish & Stability (Weeks 1-2)
- Preset deletion and editing
- Improved error handling
- Shader caching
- Onboarding flow

### Phase 2: Content Expansion (Weeks 3-4)
- Add 2-3 new fractal types (Newton, Tricorn, Sierpiński)
- Custom color palette editor
- Animation mode basics

### Phase 3: Export & Sharing (Weeks 5-6)
- Native video export
- Batch export
- Social media presets
- Preset sharing links

### Phase 4: Advanced Features (Weeks 7-8)
- Julia set picker from Mandelbrot
- Comparison mode
- Educational content
- Tablet/desktop layout

### Phase 5: Community & Polish (Weeks 9+)
- Gallery features
- Accessibility improvements
- Performance optimization
- Documentation

---

## 📋 Technical Debt

- [ ] The `translateByDouble` and `scaleByDouble` Matrix4 extensions in AR screen could be extracted to a utility
- [x] `ArVideoExporter` cleaned up: removed dead FFmpeg enum and unused cleanup method
- [x] Color filter matrices in `ArOverlayScreen` optimized: soft preset returns null (skips GPU), neon/mono remain as constants
- [ ] `FractalControlsSheet` hardcodes "Actions" label instead of using l10n
- [ ] Several widgets have similar press animation logic; extract to a reusable mixin
- [ ] Test coverage for `export_service.dart` is limited
- [ ] The `CrashReporter` is local-only; consider optional cloud reporting

---

## 📝 Notes

- No existing TODO/FIXME comments were found in the codebase — it's clean!
- The architecture is solid with good separation of concerns
- Localization is well-implemented with English and Spanish support
- The modular fractal system makes adding new types straightforward
- Shader code uses good practices (LOD, branchless operations)
- AR mode (AR-0: camera overlay) is well-implemented with quality presets for all modules, three style presets, gesture controls, and three export modes


improve image /home/xel/git/flutter-fractal-forge/assets/icon/ic_launcher.png