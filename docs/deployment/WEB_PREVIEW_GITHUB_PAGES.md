# Web Preview Deployment

> Current public URL: https://fractal.trebuchetdynamics.com/
>
> This page documents production deployment under the [standing release defaults](../../PRD.md#standing-release-defaults). An explicit release request supplies deployment authority after qualification; no second approval is needed for a web-only qualified subset.
>
> The preview is served from Cloudflare Pages. A manual GitHub Pages workflow
> existed alongside it but never deployed successfully -- GitHub Pages was
> never enabled on the repository, so its deploy job failed 404 on both of its
> two runs -- and it was removed rather than left as a broken second path.

## What is prepared

- Landing wrapper: `web/landing.html`
- Flutter app entrypoint: `web/index.html`
- Landing media: `web/landing-assets/`
- Build script: `scripts/build-web-preview.sh` (takes the base href as its argument)
- Deploy stage: `scripts/release.sh website`

There is no push-triggered deploy. An explicit release request authorizes production deployment of the qualified web artifact. Ordinary pushes, coding, planning and prepare-only requests do not authorize deployment.

## Public URL

Canonical public preview URL:

```text
https://fractal.trebuchetdynamics.com/
```

The generated Flutter app entrypoint remains `index.html` in the deployed web build.

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

## Deploy prerequisites

1. `wrangler` installed and on `PATH`.
2. `CLOUDFLARE_API_TOKEN` set, or `CLOUDFLARE_API_KEY` present in `.env` at the
   project root, which the website stage falls back to.
3. `CLOUDFLARE_PAGES_PROJECT` if the target is not the default
   `flutter-fractal-forge`.

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

For an explicit release request, proceed once the prepared artifact, release evidence and pre-deploy hardware smoke pass. Do not ask again because other platforms remain blocked:

1. Push the prepared branch/commit to `main`.
2. Preview what would happen without publishing:

   ```bash
   scripts/release.sh website --dry-run
   ```

3. Use root `release.sh --best-effort --publish=<version> --build-number=<build>` with the exact prepared artifact directory and campaign file. Follow the [independent-platform release procedure](../engineering/release/MULTIPLATFORM.md#independent-platform-release-campaign). GitLab remains excluded. Bare `scripts/release.sh website` is a dry run, not publication. Do not set `GITLAB_CI=true` locally to bypass the public entry point.

4. Wait for deployment and verify remote identity and asset hashes. An ambiguous result requires readback before any retry.
5. Open the canonical landing URL and smoke test:
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
- WebAssembly builds locally on Flutter 3.44.6, but has not completed browser smoke testing.
- Export/share, CPU precision fallback, deep zoom, and real hardware GPU performance still need browser QA.

## Rollback

If the public preview is bad:

1. Roll back the deployment in the Cloudflare Pages dashboard, or rerun the
   website stage from a known-good commit.
2. Keep the README/social copy pointed at the installable app until the web preview is fixed.
3. File regressions with the `web-preview` label.
