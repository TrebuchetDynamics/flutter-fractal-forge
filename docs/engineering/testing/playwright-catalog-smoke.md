# Local Playwright catalog smoke

This focused browser smoke checks catalog rendering in the built Flutter web app. It is local-only; it does not deploy the app.

## Prerequisites

- Node.js 18 or newer (required by the locked Playwright 1.59.1 package).
- Flutter on `PATH`, or set `FLUTTER_BIN` to an executable Flutter binary.
- The Playwright Chromium browser installed locally. From the repository root, run `npm ci` to install the exact versions in `package-lock.json`, then `npx playwright install chromium`. The package script `npm run playwright:install` installs both Chromium and Firefox; it is not necessary to install Firefox for the Chromium-only invocation below.

## Build and run

From the repository root:

```sh
PLAYWRIGHT_PROJECT=chromium CATALOG_SMOKE_FILTER='^mandelbrot$' npm run test:web:catalog
```

The npm script runs `bash scripts/playwright-catalog-smoke.sh`. By default that script runs `flutter build web --release --no-wasm-dry-run`, using base href `/`, and defines `PLAYWRIGHT_CATALOG_SMOKE=true` plus `PLAYWRIGHT_CATALOG_SMOKE_MAX_GPU_ITERATIONS=10`. It then checks that `build/web` exists and that its `index.html` base href matches, before invoking Playwright with one worker. The config serves `build/web` locally at `http://127.0.0.1:4173` unless an external `PLAYWRIGHT_BASE_URL` is supplied.

`PLAYWRIGHT_PROJECT` defaults to `firefox`; set it to `chromium` as above, or `all` to run both configured projects. `CATALOG_SMOKE_FILTER` is a regular expression over catalog IDs; omit it to cover all IDs. `BASE_HREF` must be `/` or begin and end with `/`. `PLAYWRIGHT_SKIP_BUILD=1` skips the Flutter build, but then `build/web` must already exist and its base href must match `BASE_HREF`. `PLAYWRIGHT_CATALOG_SMOKE_MAX_GPU_ITERATIONS` defaults to `10`. The script accepts `FLUTTER_BIN` to select the Flutter executable; otherwise it uses `flutter` from `PATH`.

Playwright writes test results under `test/results/`, including `test/results/playwright-results.json`; failure screenshots and traces are retained there as configured. A successful run verifies only the selected browser and filtered catalog IDs, not every browser or fractal.
