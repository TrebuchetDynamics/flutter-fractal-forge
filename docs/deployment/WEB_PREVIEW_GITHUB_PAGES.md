# Web Preview GitHub Pages Deployment

> Status: prepared, not deployed.
>
> This page documents how to publish the Fractal Forge browser preview after an owner explicitly approves deployment.

## What is prepared

- Landing wrapper: `web/landing.html`
- Flutter app entrypoint: `web/index.html`
- Landing media: `web/landing-assets/`
- Local/CI build verifier: `scripts/build-web-preview.sh`
- Manual-only GitHub Pages workflow: `.github/workflows/web-preview-pages.yml`

The workflow has **no push trigger**. It only runs from GitHub Actions `workflow_dispatch` and requires typing `deploy-web-preview` in the confirmation input.

## Expected public URL

If the repository is published with GitHub Pages at the owner/user site default, the canonical public preview URL is the landing page:

```text
https://xelhaku.github.io/flutter-fractal-forge/landing.html
```

The Flutter app itself should be one click away from the landing page via:

```text
https://xelhaku.github.io/flutter-fractal-forge/index.html
```

For the first soft launch, keep `/landing.html` as the shared URL and leave `index.html` as the generated Flutter app entrypoint. Do not move the app to `/app/` or make the repository root serve the landing page until after the first feedback loop.

Do not share the app URL as the primary first-time visitor link until the browser build has stronger parity proof.

## Local build verification

Run from the repository root:

```bash
scripts/build-web-preview.sh /flutter-fractal-forge/
```

Expected output includes:

```text
✓ Built build/web
web_preview_build_ok {'baseHref': '/flutter-fractal-forge/', ...}
```

This verifies:

- `build/web/index.html` exists.
- `build/web/landing.html` exists.
- local landing images exist.
- landing image tags include dimensions and alt text.
- local landing links resolve.
- Flutter `base href` matches `/flutter-fractal-forge/`.

## GitHub repository settings

Before running the workflow:

1. Open repository **Settings → Pages**.
2. Set **Build and deployment → Source** to **GitHub Actions**.
3. Ensure Actions are enabled for the repository.
4. Confirm the repository name is still `flutter-fractal-forge`; otherwise update the base href used by the workflow and expected URL.

## Pre-deploy hardware smoke

Before public deployment, run one hardware browser smoke on a normal desktop/laptop, not only headless Chromium:

1. Run `scripts/build-web-preview.sh /flutter-fractal-forge/`.
2. Serve `build/web` locally.
3. Open the landing page in Chrome/Chromium with hardware acceleration enabled.
4. Click **Try web preview**.
5. Skip onboarding.
6. Confirm the catalog is visible.
7. Open one 2D fractal.
8. Return to catalog and open one 3D fractal.
9. Confirm the browser console has no obvious network or render errors.

This does not prove full web parity. Export/share, CPU precision fallback, and deep zoom can remain known limitations for the Browser Web Preview.

## Manual deploy steps

Only after explicit owner approval to deploy and after the pre-deploy hardware smoke passes:

1. Push the prepared branch/commit to `main`.
2. Go to **Actions → Web preview GitHub Pages**.
3. Click **Run workflow**.
4. Enter confirmation exactly:

   ```text
   deploy-web-preview
   ```

5. Wait for the deploy job to finish.
6. Open the canonical landing URL and smoke test:
   - landing page loads;
   - **Try web preview** opens the Flutter app;
   - onboarding can be skipped;
   - catalog renders;
   - a catalog card opens the viewer;
   - browser console has no obvious network errors.

## Download CTA rule

For the first soft launch, the download/install CTA should remain a source-build path unless a verified public Play Store, GitHub Releases, or package URL is available. Do not invent or imply an app-store download URL.

## Known limitations to keep visible

Do not market this as full web parity yet:

- Web JavaScript target is runtime viable in Chrome smoke tests.
- WebAssembly build is currently blocked by dependency imports (`share_plus`, `dart:html`, `ffi`, `win32`).
- Export/share, CPU precision fallback, deep zoom, and real hardware GPU performance still need browser QA.

## Rollback

If the public preview is bad:

1. Disable GitHub Pages in **Settings → Pages**, or rerun the workflow from a known-good commit.
2. Keep the README/social copy pointed at the installable app until the web preview is fixed.
3. File regressions with the `web-preview` label.
