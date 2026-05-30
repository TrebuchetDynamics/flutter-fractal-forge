# PRD — Cymatic Composer (Flutter / Flutter Fractal Forge Tech Stack)

## 1) Product Statement
A real-time interactive wave‑interference playground that generates music from the interference patterns you create. Users place ripple sources on a canvas, watch GPU‑rendered cymatic patterns, and hear synchronized audio derived from the same wave field.

## 2) Goals / Non‑Goals
### Goals
- Real‑time wave interference visuals via fragment shaders.
- Musical audio output tied directly to wave sources or sampled field probes.
- Intuitive touch interactions: add, move, remove sources and probes.
- Built‑in presets and a short guided tutorial.
- Export screen+audio recording as a shareable video.
- Android Play Store release.

### Non‑Goals (MVP)
- iOS release.
- Cloud sync or accounts.
- Multiplayer or collaborative sessions.
- Advanced waveform types beyond sine (square/triangle can be Phase 2).
- No desktop or web version in MVP (possible future WebGL/Web Audio demo for marketing).

## 3) Target Users & Use Cases
- Artists and musicians exploring generative visuals and sound.
- Educators demonstrating wave interference and harmony.
- Casual users seeking mesmerizing, tactile experiences.

Use cases:
1. “Play” the canvas like an instrument using touch gestures.
2. Create an aesthetic scene using presets and record a short clip.
3. Explore math/physics concepts via visible interference patterns.

## 3.1 User Experience Narrative (Launch → Play → Share)
- **First glance:** full‑screen dark canvas with gentle idle wave motion; minimal toolbar (Add Source, Presets, Settings, Record). Subtle wave‑speed slider and palette indicator.
- **Default scene:** two sources at complementary notes (e.g., C + G) creating a calm dyad and visible interference bands.
- **Add + arrange:** tap or double‑tap to add a glowing source; drag to move; long‑press to remove. Notes quantized to scale (pentatonic default) for immediate harmony.
- **Visual feedback:** circular wavefronts, evolving interference, amplitude‑mapped color gradients; palette swipe to change color sets; pinch‑zoom to inspect patterns.
- **Audio modes:**
  - **Harmonic Mode:** each source is a sine oscillator; combined sound is the mix.
  - **Probe Mode:** drag a listener dot; sampled wave amplitude modulates synth parameters (volume/pitch/filter).
- **Expressive polish:** optional reverb/delay toggle; instantaneous audio response from low‑latency engine.
- **Presets:** themed scenes (Calm Flow, Energy Burst, Meditation, Cosmic Dance, Fibonacci Spiral, Golden Spiral, Octave Drone, Pentatonic Cascade) with one‑tap load.
- **Preset overlay:** short math/music explanation (e.g., “3:2 ratio — perfect fifth”).
- **Share:** record 5/10/15s clips or snapshot PNGs.
- **Feel:** playful, meditative, and smart; no scoring, just exploration and creation.

## 4) Core Experience
### 4.1 Visuals (GPU)
- Fragment shader computes superposition of circular waves.
- Each source has position (x,y), frequency, phase, amplitude, and optional damping.
- Color maps amplitude to a palette (hot/cold, neon, grayscale, etc.).
- Wave equation per pixel (concept):
  - `A(x,y) = Σ amplitude_i * sin(distance_i * frequency_i - time * speed + phase_i)`
- Visual modes inspired by public cymatics demos: particle‑field mode (nodal lines) and smooth scalar‑field mode.
- Performance target: 60 FPS on mid‑range Android with ≤ 10 sources.
- Optional “calm mode” limits brightness changes for photosensitivity.

### 4.2 Audio (CPU / Audio Thread)
- Two listening modes:
  - **Harmonic Mode:** each source is a sine oscillator; output is the mixed sum.
  - **Probe Mode:** sample wave amplitude at one or more probe points to modulate synth parameters (volume/pitch/filter).
- Optional reverb/delay toggle for spaciousness.
MVP supports two modes:
1. **Additive Synthesis**
   - Each wave source is mapped to an oscillator.
   - Frequencies quantized to a selected musical scale.
   - Amplitude from source amplitude or global controls.
2. **Probe‑Based Synthesis**
   - One or more listener probes sample the wave equation on CPU.
   - Probe amplitude drives oscillator pitch and/or volume.

Audio engine:
- Prefer Android Oboe / AAudio low‑latency path (per Android dev guidance): request low‑latency performance mode, exclusive sharing mode, avoid sample‑rate conversion by using device native rate (typically 48 kHz), and use data callbacks with no blocking work in the callback.
- Fallback to AudioTrack if Oboe/AAudio is unavailable.
- Buffer size tuned for “double‑buffer” (low latency, fewer glitches).

## 5) Key User Flows
1. Launch → default scene with 3 sources + 1 probe → audio starts.
2. Tap to add a source, drag to reposition, long‑press to remove.
3. Add/move probes to change musical output.
4. Adjust global sliders: wave speed, damping, palette, master volume.
5. Switch musical scale (major, minor, pentatonic).
6. Use preset scene (Ocean Harmonics, Fibonacci Spiral, Major Chord).
7. Record a 10s video (screen + audio) and share.

## 6) MVP Scope
### 6.1 Wave Sources
- Max sources: 8 (configurable).
- Each source has: position, frequency, phase, amplitude.
- Frequency is snapped to scale when scale mode enabled.

### 6.2 Probes (Listeners)
- Max probes: 3.
- Each probe has: position and mode (pitch, volume, filter). Mode is assignable per probe; default is volume.

### 6.3 Controls
- Add source (tap).
- Move source (drag).
- Remove source (long‑press).
- Add/move probe (toggle “Probe Mode”).
- Sliders: wave speed, damping, amplitude, master volume.
- Palette selector.
- Scale selector: Major / Minor / Pentatonic / Chromatic; when changed, briefly display note names (C, D, E...) on sources.
- Randomize sources button.
- Performance toggle: “Low Power Mode” reduces source count and frame rate.
- Snapshot button (PNG capture).
- Snapshot gallery: save/load favorite scenes (source positions + settings) locally.

### 6.4 Presets + Tutorial
- Minimum 5 presets (examples: Calm Flow, Energy Burst, Meditation, Cosmic Dance, Fibonacci Spiral, Golden Spiral, Octave Drone, Pentatonic Cascade).
- Tapping a preset instantly sets up sources and frequencies; show a short overlay explaining the math/music (e.g., “3:2 ratio — perfect fifth”).
- 4‑step interactive tutorial (tap, drag, adjust scale, record).

### 6.5 Export
- Record screen + audio to MP4 (5s / 10s / 15s).
- Default 720p; optional 1080p on capable devices.
- Android native path: MediaCodec encoder + MediaMuxer for MP4 assembly.
- Decision needed: MediaRecorder/MediaProjection (simpler, includes UI) vs manual frame encoding from Flutter surface (more control).

## 7) Tech Stack (Reuse from Flutter Fractal Forge)
- Flutter + GLSL fragment shaders (`FragmentProgram`).
- Shader asset pipeline from Fractal Forge.
- Audio: Prefer Android Oboe / AAudio via platform channel; fallback AudioTrack.
- Export: MediaCodec + MediaMuxer (Android native), or reuse FFmpeg kit pipeline used by Fractal Forge.

## 8) Architecture
### 8.1 Data Model
- `WaveSource { id, position, frequency, phase, amplitude }`
- `Probe { id, position, mode }`
- `SceneState { sources, probes, palette, scale, speed, damping }`

### 8.2 Rendering Pipeline
- Flutter widget hosts shader.
- Uniform arrays pass wave source attributes to shader each frame.
- Time uniform advances per frame.
- GPU uniform limits: pack data into vec4 arrays to minimize uniform count.

### 8.3 Audio Pipeline
- Dedicated audio thread (callback‑driven when using Oboe/AAudio).
- For additive: sum sine waves of source frequencies.
- For probe‑based: compute wave amplitude at probe positions on CPU.
- Mixdown to stereo output.
- Avoid allocations or locks in the audio callback.

## 9) Performance Targets
- 60 FPS on mid‑range Android (≤ 10 sources).
- Audio latency target: ≤ 20 ms on devices supporting low‑latency audio; ≤ 50 ms otherwise.
- No frame drops when dragging sources.
- Battery: throttle frame rate to 30 FPS if idle for > 15s.

## 10) Quality Bar / Acceptance Criteria
- Shader renders correctly on target devices (no black screen).
- Audio runs glitch‑free for 10 minutes.
- Drag interactions stay smooth at 60 FPS.
- Presets load in < 200 ms.
- Exported video includes audio sync and correct palette colors.
- Low‑latency audio mode verifies: native sample rate in use, data callback path enabled, and no blocking operations in callback.

## 11) Risks / Constraints
- Shader uniform array size limits on some GPUs; must query GL_MAX_FRAGMENT_UNIFORM_VECTORS and cap source count at runtime.
- Audio latency variability across devices.
- Video export can be device‑specific; needs testing.
- Low‑latency audio callbacks require strict non‑blocking code paths.

## 12) Roadmap
### Phase 1 (MVP)
- Wave shader + source interactions.
- Additive synthesis mode.
- Basic controls + 5 presets.
- Video export.

### Phase 2
- Probe‑based synthesis.
- More palettes and scales.
- Waveform types (square, triangle).
- Grid resolution performance toggles.

### Phase 3
- Scan synthesis.
- Advanced recording and export settings.
- Community preset sharing.

## 13) Accessibility
- Large touch targets.
- Haptic feedback toggle.
- Reduce motion option (lower animation intensity).

## 14) Store Listing Hooks
- “Paint with sound waves.”
- “Real‑time cymatics meets interactive music.”
- “Create hypnotic visuals and musical textures with your fingertips.”

## 15) Research Notes (Evidence)
- Android low‑latency audio guidance recommends: low‑latency performance mode, exclusive sharing mode, native sample rate (often 48 kHz), callback‑based audio, avoid blocking operations, and tune buffer size for low latency. Source: Android Developers “Low latency audio”.
- Android audio latency can exceed 100 ms on many devices; low‑latency audio is critical for interactive music apps. Source: Superpowered “Android Audio’s 10 Millisecond Problem”.
- MediaCodec provides low‑level access to Android encoders/decoders; MediaMuxer assembles encoded audio/video into MP4 containers. Source: Android Developers MediaCodec + MediaMuxer references.
- Cymatics UX references: CymaVis highlights microphone/audio input, pattern modes, and sharing; cymatics.berrry.app highlights preset modes (Calm Flow, Energy Burst, Meditation, Cosmic Dance) and Snapshot control.
