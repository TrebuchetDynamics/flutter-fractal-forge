# Fractal Forge Launch Ladder

> Updated: 2026-06-03
>
> Goal: grow Fractal Forge from a working open-source Flutter fractal app with 500+ downloads into a discoverable project with a web preview, stronger first impression, and staged social launch.

## Core launch message

**The core app is real; distribution and first impression are the bottleneck now.**

Recommended short positioning:

> Fractal Forge is an open-source GPU fractal explorer built with Flutter. Explore hundreds of Mandelbrot, Julia, Newton, strange-attractor, tiling, IFS, and 3D fractal systems on desktop, Android, and a browser web preview.

Use **browser web preview** instead of **full web app** until the web gaps below are closed.

## Current evidence

- Real product traction: 500+ downloads reported by project owner.
- Open-source basics exist: `LICENSE`, `CONTRIBUTING.md`, README, Play Store listing assets, privacy policy, and screenshots.
- Web JavaScript target is runtime-viable as a preview:
  - `flutter build web --release` succeeded.
  - Chrome widget/render tests passed.
  - Served `build/web` reached onboarding, catalog, and a GPU-labelled viewer.
  - Follow-up smoke after manifest-gated thumbnails reported `thumbnail404Count: 0` and `networkErrorCount: 0`.
  - See `docs/engineering/rendering/renderer_backend_matrix.md`.
- Web Wasm target is not viable yet:
  - `flutter build web --wasm` fails through `share_plus` / `dart:html` and transitive `ffi` / `win32` imports.

## Weaknesses to fix before a bigger launch

| Weakness | Why it matters | Launch impact | Minimum fix |
|---|---|---:|---|
| Catalog entries without exact thumbnails | Fallback thumbnails are acceptable for preview but weaker than curated visual assets | Medium | Generate or curate exact thumbnails for the first featured/top catalog entries. |
| README screenshots are weak/incomplete | GitHub is a primary landing page for open source | High | Replace placeholder screenshot table with real images/GIF and remove the README "not final marketing captures" disclaimer. |
| No public web URL yet | Users need a low-friction try-before-install path | High | Deploy web JS preview with clear caveats. |
| Web parity is unproven | Reddit/social users will test edge cases fast | High | Hide/label unsupported web flows; verify export/share/deep zoom separately. |
| Too many fractals without curation | New users need instant wow, not a wall of options | Medium | Lead with a Featured Launch Set of 10-20 beautiful, browser-reliable fractals, then mention the broader catalog as depth. |
| No short video/GIF package | Social posts need motion | Medium | Capture 15-30s catalog -> viewer -> zoom clip and 2 looping GIFs. |
| Hardware browser performance unknown | Headless smoke used software WebGL/SwiftShader warnings | Medium | Test Chrome on one normal desktop/laptop with hardware GPU before public deployment. |

## Stage 1 — Website preview

Objective: make a visitor able to understand, trust, and try Fractal Forge in under 30 seconds.

### Required launch page sections

1. Hero
   - Headline: **Open-source Flutter fractal explorer**
   - Subhead: **Explore hundreds of GPU-rendered fractals across Mandelbrot, Julia, Newton, tilings, IFS, strange attractors, and 3D systems.**
   - Primary CTA: **Try web preview**
   - Secondary CTA: **Download app**
   - Tertiary CTA: **View on GitHub**
2. Proof strip
   - **500+ downloads**
   - **1,585 production fractals** (1,592 debug/test registry modules including 7 diagnostics)
   - **MIT licensed**
   - **No ads / no tracking**
3. Visual gallery
   - Lead with a Featured Launch Set of 10-20 hand-picked fractals.
   - Treat the Featured Launch Set as marketing/docs/media scope for the first soft launch, not an in-app Featured tab yet.
   - Select manually by taste for visual wow, then evidence-gate every pick with Browser Web Preview smoke and media capture.
   - Prioritize Browser Web Preview reliability, not full taxonomy coverage or automated catalog ranking.
   - Include enough variety to avoid feeling narrow: Mandelbrot/Julia, Newton/root-finding, IFS/geometric, strange attractor, tiling, and one 3D example if hardware browser smoke passes.
   - Use 6-8 strongest screenshots from that set.
   - At least one short GIF/video showing interactive zoom.
4. Web-preview caveat
   - Copy: **The browser version is a preview. Some export/share and deep-zoom behavior may differ from the app.**
5. Contributor hook
   - Copy: **Want to help? Good first tasks include thumbnails, presets, shader polish, and web QA.**

### Featured Launch Set acceptance checklist

Each candidate must pass before it appears in launch media:

- [ ] Opens in Browser Web Preview without visible crash/error.
- [ ] Screenshot captured at a launch-worthy viewport.
- [ ] No obvious console network/render error during open.
- [ ] Has a usable thumbnail or acceptable fallback for soft launch.
- [ ] Has a one-line plain-language caption.

Preferred extra evidence:

- [ ] Short zoom/interaction clip for 3-5 top picks.
- [ ] Hardware browser pass for any 3D pick.

### Website preview ship gate

Local wrapper artifact: `web/landing.html` is the landing page for first-time visitors during the first soft launch. The current public URL is `https://fractal.trebuchetdynamics.com/`.

- [x] Public landing URL exists: `https://fractal.trebuchetdynamics.com/`.
- [ ] `flutter build web --release` passes.
- [ ] Automated browser smoke: onboarding -> catalog -> viewer.
- [ ] Pre-deploy hardware browser smoke on a normal desktop/laptop: landing -> Try web preview -> skip onboarding -> catalog visible -> open one 2D fractal -> open one 3D fractal -> no obvious console network/render errors.
- [ ] No obvious 404s in browser console for above-the-fold catalog assets.
- [ ] Hero has screenshots/video, not just text.
- [ ] GitHub, source-build/download, and web preview CTAs all work; do not imply an app-store download until a verified public URL exists.
- [ ] Privacy note is visible: no ads, no tracking, no account required.

## Stage 2 — Soft launch

Objective: get friendly testers and discover sharp edges before Reddit-scale traffic.

### Channels

- Personal social accounts.
- Flutter Discord / Flutter community spaces.
- Generative art / creative coding friends.
- Existing users if there is a store update channel.

### Ask

> I built an open-source Flutter fractal explorer and just put up a browser preview. I am looking for testers: does it load, does GPU rendering work, and which fractals look best or break?

### Soft-launch checklist

- [ ] Include web preview URL.
- [ ] Include GitHub URL.
- [ ] Include Android/download URL only after a verified public Play Store, GitHub Releases, or package URL exists; otherwise use the README source-build path.
- [ ] Include one GIF/video.
- [ ] Ask for browser/device/GPU info when people report bugs.
- [x] Provide a web-preview issue template that asks for URL, browser, OS/device, GPU, console errors, fractal name, and reproduction steps.
- [ ] Treat GitHub Issues as the feedback source of truth; copy actionable Discord/social reports into issues before triage.
- [ ] Track issues in GitHub with labels: `web-preview`, `thumbnail`, `performance`, `shader`, `onboarding`, `trust-breaking`.

## Stage 3 — Polish from feedback

Objective: fix trust-breaking issues before the bigger launch.

### Triage order

1. App/web crashes.
2. Web page fails to load or open viewer.
3. Broken/missing images on first catalog screen.
4. Confusing onboarding or too many controls.
5. Top fractals look bad, slow, or have poor presets.
6. Nice-to-have shader additions.

### Minimum polish gate

- [ ] Top 20 featured fractals have good thumbnails and presets.
- [ ] Web preview has a known-issues section.
- [ ] README screenshots and copy match the current app.
- [x] One-click web-preview feedback template exists at `.github/ISSUE_TEMPLATE/web-preview-feedback.yml`.
- [ ] GitHub issue labels are ready.
- [ ] Known browser/platform limitations are documented.

## Stage 4 — Bigger launch

Objective: reach users who care about Flutter, fractals, generative art, and open source.

### Candidate communities

Reddit and larger public forums are blocked until the soft-launch feedback wave is triaged. Use them only after the Browser Web Preview has a public URL, a hardware browser smoke pass, and no known trust-breaking first-impression defects.

- `r/FlutterDev`
- `r/fractals`
- `r/generative`
- `r/opensource`
- Hacker News / Lobsters only after the web preview is stable enough.

### Bigger-launch blocker policy

Block Reddit/larger public launch on trust-breaking first-impression defects:

- landing page does not load;
- **Try web preview** fails;
- app boot/onboarding blocks catalog access;
- catalog cannot open;
- opening Featured Launch Set fractals crashes, blanks, or shows obvious render failure;
- featured path logs obvious console/network errors;
- severe jank on normal hardware;
- copy misleads users about web parity, downloads, or known limitations.

Do not block bigger launch solely for documented preview limitations:

- deep-zoom limitations;
- export/share gaps;
- WebAssembly failure;
- non-featured fractal visual bugs;
- missing exact thumbnails outside the Featured Launch Set.

### Bigger-launch gate

- [ ] Website preview gate passed.
- [ ] Small friendly tester wave completed and GitHub issue feedback triaged.
- [ ] No open `trust-breaking` first-impression defects.
- [ ] Short video/GIF is ready.
- [ ] README is polished with screenshots and links.
- [ ] Known limitations are explicit.
- [ ] A maintainer is ready to respond for 24-48 hours.

## Draft social copy

### Personal / general

> I built Fractal Forge, an open-source fractal explorer in Flutter. It renders hundreds of Mandelbrot, Julia, Newton, tiling, IFS, strange-attractor, and 3D fractals with GPU shaders.
>
> It already has 500+ downloads, and I am preparing a browser preview so people can try it without installing. Feedback welcome, especially on web rendering, thumbnails, and which fractals look best.

### Flutter-focused

> I made an open-source Flutter app that uses fragment shaders to explore hundreds of fractals in real time. The desktop/mobile app works, and I am now testing a web preview in Chrome.
>
> If you like Flutter graphics, shaders, or generative art, I would love feedback.

### Reddit `r/fractals`

> I built an open-source fractal explorer called Fractal Forge. It includes hundreds of fractal systems: Mandelbrot/Julia variants, Newton basins, tilings, IFS, strange attractors, and 3D raymarched fractals.
>
> I am looking for feedback on the most interesting presets and where the UI gets in the way of exploration.

### Known-limitations footer

> Web preview note: the browser build is still a preview. Some thumbnails, export/share flows, deep zoom, and performance behavior may differ from the installable app.

## Success metrics

Track for each launch stage:

- Website visits.
- Web preview successful loads.
- Click-through to app download.
- GitHub stars/forks/watchers.
- Issues opened with useful reproduction details.
- Social comments mentioning first-impression blockers.
- Crash reports or top recurring failures.

## Immediate next implementation backlog

1. Polish README screenshots and first 10 seconds of messaging. ✅ initial web-smoke screenshots added; dedicated store/social captures still needed.
2. Build a tiny website/landing page or deploy the Flutter web preview with a landing wrapper. ✅ static local wrapper added at `web/landing.html`; manual GitHub Pages config/runbook added; deployment still pending explicit approval.
3. Capture a short video/GIF package. ✅ initial smoke GIF added at `docs/assets/launch/web_preview_loop.gif`; polished social video still needed.
4. Curate a marketing/docs/media Featured Launch Set of 10-20 browser-reliable, visually strong fractals for first-time users; select manually by taste, then evidence-gate with browser smoke and media capture; defer an in-app Featured tab unless tester feedback asks for it.
5. Generate or curate exact thumbnails for the Featured Launch Set.
6. Run soft launch and collect feedback before bigger Reddit posts.
