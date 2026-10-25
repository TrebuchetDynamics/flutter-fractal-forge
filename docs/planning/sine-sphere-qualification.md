# SINEWARP-002-47 — Sine-sphere qualification

## Verdict and source binding

Local renderer/export qualification passed on the backends below. **This is not universal convergence, physical-device, human composition/source approval, integration or release acceptance.** No surface formula, requested depth, strength or ray budget was reduced.

Baseline: `641f3c675b45d77b50f5965843d8cb413c252e33`. These captures exercise the task candidate, identified by exact file SHA-256 values in [binding.json](sine-sphere-qualification/binding.json), not an invented tested commit. That inventory also binds the retained PNGs and unaltered observations. Native absolute scratch/export paths inside the observations are historical producer locations; the inventory maps the retained subset to repository-relative files. No source-video artwork is included.

| Target | Actual result | Limit |
| --- | --- | --- |
| Linux GTK / Skia OpenGL, AMD Radeon RX 6800 XT, radeonsi Mesa 25.2.8 | Two real integration cases passed; production-kernel oracle, full-frame classifications, catalog/viewer, preset restoration and real file exports | Debug build, Flutter 3.44.6 / Dart 3.12.2; native test binding intentionally disables animation ticker |
| Chromium 152.0.7977.75 / ANGLE Vulkan SwiftShader | One scoped production-web journey passed: advancing animation, reduced-motion freeze, visible palette edit, rendered session restoration, two HD downloads | Software backend, not AMD/hardware GPU; no browser hit/depth diagnostic qualification |
| Physical Android and other hardware/browser cells | Not run | Pending separate authorized target execution |
| Human composition and source-faithfulness review | Not performed | Captures/numerical tests do not supply that verdict |

[Native observations](sine-sphere-qualification/native-observations.json), [same-display GL/app backend inspection](sine-sphere-qualification/native-backend.json), [browser environment](sine-sphere-qualification/browser-environment.json), and [browser state/readback](sine-sphere-qualification/browser-observation.json) retain separate verdict inputs. The browser environment records the actual served `main.dart.js` hash and CDP renderer; the source binding covers the module, viewer, production kernel/shader, diagnostic, test code and unchanged lockfile.

## Geometry, camera and precision

The diagnostic embeds the byte-identical canonical production intersection kernel; `scripts/sync_sine_sphere_kernel.py` keeps it portable. The independent double recurrence scans 200,000 intervals across the finite enclosure, checks the retained first-crossing brackets, then bisects 64 times. It does not invoke the production marcher/model.

World basis is x/y/z; diagnostic ray directions are normalized. Sphere fixtures cover depth zero and zero strength, axis hits, just-inside/just-outside silhouette, interior origin and tangent. The two retained warped fixtures use depth 2, strength 0.8, radius 1, phase 0.4 and origins `(0,0,4)` / `(0.3,-0.4,4)` toward `(0,0,-1)`. Actual depths are compared with independently bracketed first crossings `4.089427178194093` / `3.989350571627848`. Budget exhaustion and large-origin float stagnation have separate real readbacks. Thirteen diagnostic rays pass.

Full-frame classifications are 960×720, top-left origin, pixel centers at half integers. Camera conversion matches the production GLSL column-major rotation basis: `uv=(pixel-resolution/2)*2/height`, origin `vec3(pan,0)+rotation*(0,0,3.2/zoom)`, direction `normalize(rotation*(uv,-1.5))`. Shipping camera rotation is `(0.3,-0.4,0)`, pan `(0,0)`, phase/time zero and palette 0. Default depth/strength/radius/steps/zoom are `3/0.8/1/256/1`; fine is `5/0.8/1/384/0.9`; maximum observation is `6/1/1/512/0.9`.

Shader arithmetic is float32. Opaque RGBA8 diagnostic encoding has distance quantum `1e-5`, residual quantum `1e-6`; declared independent distance/residual tolerances are `5e-4`. The 24-bit distance payload saturates at `167.77215`; the extreme-origin stagnation fixture checks status only, not its saturated distance. Center pixel `(480.5,360.5)` independently gives default depth `2.9700720291781204` (actual `2.96999`, residual `0.000222`) and fine depth `3.2826401476632023` (actual `3.28243`, residual `0.000332`). These checks cannot be replaced by viewer/export agreement.

## Captures, framing and convergence limits

The ordinary [sphere control](sine-sphere-qualification/native-sphere-control.png) is round. The [default](sine-sphere-qualification/native-default.png) is a nonblank asymmetric three-lobed warped surface. The [fine preset](sine-sphere-qualification/native-detail.png) adds smaller folds/bands. The original fine zoom 1.08 clipped 85 edge-content pixels in the initial 480×360 capture; zoom 0.9 fixes that demonstrated framing defect without changing geometry/quality controls. Final 960×720 sphere/default/fine captures have zero edge-content pixels.

At the **same** fine camera, the depth-3 [comparison capture](sine-sphere-qualification/native-detail-camera-depth3.png) has mean interior RGB Laplacian `0.7869673307`, versus `1.2887128103` at depth 5. The test excludes background/silhouette neighbors. This measures increased finite image detail, not a Hausdorff dimension or human source-faithfulness verdict.

| Full-frame production-kernel status | Default | Fine | Maximum |
| --- | ---: | ---: | ---: |
| Certified miss | 469,534 | 492,172 | 397,001 |
| Accepted hit | 220,072 | 192,613 | 212,989 |
| Budget exhausted, **not certified miss/hit** | 1,594 | 6,415 | 81,210 |
| Tangent | 0 | 0 | 0 |
| Float stagnation | 0 | 0 | 0 |
| Diagnostic/visible silhouette differences | 0 | 0 | 1 |

Thus even default/fine are not hole-free or universally convergent. Their otherwise-background pixels include known exhausted rays; these are explicitly classified, not silently called misses. [Maximum](sine-sphere-qualification/native-maximum.png) is exploratory: 267 edge-content pixels clip and about 11.75% of rays exhaust the budget. The finite cap does not guarantee convergence or FPS.

One maximum pixel `(520,505)` is foreground in production but budget-exhausted in the separately compiled full-frame diagnostic. Arbitrary-ray readback reports a hit at `4.01557`, residual `0.000350`; independent first crossing is `4.015759373080293`. This is a bounded float acceptance/budget boundary exception, not a blanket silhouette waiver: the test requires zero differences for default/fine, at most one for maximum, diagnostic status 2 versus visible foreground, and independent depth/residual agreement within `5e-4`.

Measured one-shot debug **capture + PNG encode** times were default `118.569 ms`, fine `417.344 ms`, maximum `446.352 ms`. Full-frame diagnostic draw/readback times were `39.628 / 16.526 / 23.828 ms`. These include readback, scheduling and host load; they are not steady-state GPU frame times or FPS thresholds. No timing pass threshold was invented.

## Saved state, freeze and actual PNGs

The native catalog journey edits phase/depth/strength/radius/palette to `0.4/2/0.65/1.2/2` and camera pan `(0.15,-0.1)`, zoom `1.05`, rotation `(0.45,-0.2,0.1)`. It saves through `PresetStore`, reloads the store, applies the saved preset and requires byte-equal decoded render pixels. It captures and commits production `ExportService` PNGs for sphere/default/fine/restored/animation-off and opaque/transparent frozen states; **no synthetic capture/rasterizer is injected**. All seven 960×720 exports decode identically to the same-state real renderer captures.

[Opaque frozen export](sine-sphere-qualification/native-frozen-opaque.png) contains no transparent pixels; [transparent frozen export](sine-sphere-qualification/native-frozen-transparent.png) contains 442,851 transparent pixels and 248,349 foreground pixels. Filename bytes, dimensions, content/alpha counts and SHA-256 values are bound in the observations/inventory. The new shared viewer gate honors both in-app and system reduced motion, including compare panes. Freeze resets renderer time to zero; this does **not** claim to preserve a previous animated tick.

The browser journey uses the same edited geometry with animation opted in, edits palette 2→3 through the visible control, then freezes via system reduced motion. Retained [advancing frame A](sine-sphere-qualification/browser-sine-animated-a.png) and [B](sine-sphere-qualification/browser-sine-animated-b.png) differ. Its unobstructed 600×400 crop [before reload](sine-sphere-qualification/browser-sine-edited-before-reload.png) equals the [restored frozen crop](sine-sphere-qualification/browser-sine-frozen-a.png), proving actual rendering restoration rather than merely unchanged localStorage. Two real 1280×720 downloads ([A](sine-sphere-qualification/browser-sine-sphere-frozen-a-edited.png), [B](sine-sphere-qualification/browser-sine-sphere-frozen-b-edited.png)) decode to identical RGBA SHA-256 `080bbb75860c3b0c5c3a9ce4550a2a17bf5ca6d06e7c3c5af9d6f7caf58bcaed`; the saved state is unchanged by export.

## Reproduction and remaining checks

Use the pinned SDK/cache setup in root `AGENTS.md`. Native test prerequisites include an authorized display/GL backend and host `sha256sum`. `SINE_SPHERE_EVIDENCE_DIR` (Dart define) chooses an artifact directory; otherwise it uses a subdirectory of `Directory.systemTemp`. `SINE_SPHERE_BACKEND` records the operator-supplied backend label; obtain it from real backend inspection, never infer hardware from the label alone.

```sh
flutter test integration_test/rendering/recursive_sine_sphere_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded
flutter test test/modules/recursive_sine_sphere_test.dart test/modules/raymarched_3d_pan_target_test.dart test/catalog/catalog_id_integrity_test.dart --reporter expanded
flutter test --no-pub test/shaders/recursive_sine_sphere_kernel_test.dart test/viewer/viewer_session_store_test.dart test/preset/preset_store_test.dart test/fractal/fractal_preset_json_test.dart test/export/export_service_test.dart test/features/renderer/renderer_ticker_policy_test.dart test/fractal/fractal_viewer_screen_widget_test.dart --reporter expanded
flutter analyze
flutter build web --release --no-pub --no-wasm-dry-run --dart-define=FORCE_GPU_RENDER=true
PLAYWRIGHT_PORT="$AUTOWORK_PORT_BASE" node node_modules/playwright/cli.js test test/playwright/web-image-creation-journey.spec.mjs --grep 'sine sphere' --project chromium
```

The executed Playwright command additionally used a scratch config under `$TMPDIR` to select `/usr/bin/chromium --no-sandbox`, put outputs under `$TMPDIR`, and keep the repository server cwd; it did not change project configuration or port policy. Long commands used `autowork-run` and explicit timeouts. Focused module/catalog tests passed 24 cases; existing shader/saved-state/export/viewer guards passed 304 cases; analyzer passed. The coordinator's merged-tree full gate is separate and was not run by this worker.

Remaining: physical-device execution; other backend/aspect/performance cells (including browser independent hit/depth readbacks); human composition/source review of these captures and the independently linked source study. Convergence limits above remain disclosed limitations, not a completed all-rays guarantee or a request to reduce detail. Coordinator-owned task/history closeout remains separate from this scoped evidence update.
