# Flutter Fractals — Google Play Store Listing Draft

> Source notes: Written to match the project PRD/store-listing draft and the statements in `privacy-policy.html`. Avoids claims not supported there.

---

## Short description (max 80 chars)

**EN (66 chars):** Real-time fractal explorer with shaders, presets, exports, and AR.

**ES (72 chars):** Explora fractales en tiempo real con shaders, presets, exportación y AR.

---

## Full description (EN) (max 4000 chars)

Flutter Fractals is a free app for exploring the infinite beauty of mathematical fractals in real time.

Discover a growing catalog of fractals rendered with high‑performance fragment shaders, then pan/zoom/rotate and fine‑tune parameters with responsive controls. Save your favorite looks as presets and export what you create.

### Fractals you can explore
- Mandelbrot (2D)
- Julia (2D)
- Burning Ship (2D)
- Phoenix (2D)
- Tricorn (2D)
- Multibrot-3 (2D)
- Celtic (2D)
- Buffalo (2D)
- Nova (2D)
- Mandelbulb (3D)

### Create and customize
- Smooth touch gestures for navigation (pan/zoom for 2D, orbit/zoom for 3D)
- Schema‑driven sliders and controls for fractal parameters
- Palette / styling controls
- Randomize to discover new variations quickly
- Save your own presets locally on your device

### Export and share
- Export PNG images at selectable resolutions
- Optional transparent PNG export (when enabled)
- AR overlay mode (camera background + fractal overlay)
- Export short AR videos (up to 15 seconds)
- Three AR style presets (Neon, Soft, Mono)
- AR quality presets (Low, Medium, High) for performance tuning

### Privacy‑first
- No accounts
- No ads
- No tracking or analytics
- Works offline for core features

If you enable AR overlay, the camera is used only to show a live preview on your device and to render your chosen fractal overlay. Camera frames are not transmitted anywhere.

---

## Descripción completa (ES) (borrador)

Flutter Fractals es una app gratuita para explorar la belleza infinita de los fractales matemáticos en tiempo real.

Explora un catálogo creciente de fractales renderizados con shaders (fragment shaders) de alto rendimiento, navega con gestos y ajusta parámetros con controles responsivos. Guarda tus combinaciones favoritas como presets y exporta tus creaciones.

### Fractales disponibles
- Mandelbrot (2D)
- Julia (2D)
- Barco ardiente / Burning Ship (2D)
- Fénix / Phoenix (2D)
- Tricorn (2D)
- Multibrot-3 (2D)
- Celtic (2D)
- Buffalo (2D)
- Nova (2D)
- Mandelbulb (3D)

### Crea y personaliza
- Gestos suaves para navegar (pan/zoom en 2D, rotación/zoom en 3D)
- Sliders y controles para parámetros del fractal
- Paletas y opciones de estilo
- Aleatorizar para descubrir variaciones rápidamente
- Guarda tus presets localmente en el dispositivo

### Exporta y comparte
- Exporta imágenes PNG en resoluciones seleccionables
- Exportación opcional de PNG con transparencia
- Modo AR de superposición (cámara + fractal)
- Exporta videos cortos en AR (hasta 15 segundos)
- Tres presets de estilo AR (Neón, Suave, Mono)
- Presets de calidad AR (Bajo, Medio, Alto) para ajustar rendimiento

### Privacidad primero
- Sin cuentas
- Sin anuncios
- Sin rastreo ni analíticas
- Funciona sin internet para las funciones principales

Si activas el modo AR, la cámara se usa solo para mostrar una vista previa en tu dispositivo y superponer el fractal. Las imágenes de la cámara no se transmiten a ningún servidor.

---

## Feature bullets (for Play Console highlights)

- Real‑time fractal rendering with high‑performance fragment shaders
- 10 fractal modes (9 × 2D + 1 × 3D)
- Touch gestures: pan/zoom (2D) and orbit/zoom (3D)
- Parameter controls + palettes + randomize
- Save local presets
- Export PNG (optional transparent background)
- Optional AR overlay mode with short video export
- Privacy‑first: no accounts, no ads, no tracking/analytics

---

## Permissions & Data Safety (based on `privacy-policy.html`)

### Permissions (expected)
- **Camera (optional):** Used only for the AR overlay mode (live preview + fractal overlay). Not recorded/saved unless you explicitly export.
- **Photos/Media/Files (storage access, where applicable):** Used to save your exported images/videos and to store your local presets/configuration.

> Note: Exact permission names vary by Android version (e.g., MediaStore / Photos & Videos). Describe them in Play Console according to the manifest.

### Data collection & sharing
- **Data collected:** None (no personal data collection stated).
- **Data shared:** None.
- **Tracking:** None.

### Data handling
- **On-device processing:** Fractal rendering and camera overlay processing happen on-device.
- **Local storage only:** Presets/config and exports are stored locally and remain under user control.

---

## Keywords / ASO ideas

Primary:
- fractals
- fractal explorer
- mandelbrot
- julia set
- mandelbulb
- shader
- glsl
- generative art
- mathematical art
- abstract visuals

Secondary:
- augmented reality overlay
- ar camera
- real-time rendering
- png export
- transparent png
- presets
- palette

---

## Release checklist (Google Play)

### Store listing
- [ ] App name, short description (≤80 chars), full description (≤4000 chars)
- [ ] Feature graphic + screenshots (phone + tablet if supported)
- [ ] Promo video (optional)
- [ ] Localization: EN + ES store listing
- [ ] Link privacy policy URL (host `privacy-policy.html` somewhere public)

### App content / compliance
- [ ] Declare **Data Safety** answers consistent with privacy policy (no collection, no sharing, no tracking)
- [ ] Declare **Permissions** with clear justification (camera only for AR overlay; media/files only for export)
- [ ] Content rating (IARC) questionnaire completed

### Build & QA
- [ ] Verify AR mode behavior when camera permission is denied (graceful disable)
- [ ] Test exports: PNG and AR video on at least 2 real devices
- [ ] Confirm exported files go to the intended directory and are visible to the user
- [ ] Confirm app works offline (no required network for core features)
- [ ] Smoke test: startup, shader compilation, navigation, no crashes during slider scrubbing

### Release
- [ ] VersionCode/VersionName bumped
- [ ] Upload AAB, complete pre-launch report review
- [ ] Create release notes (EN/ES)
- [ ] Rollout strategy set (internal → closed/open testing → production)
