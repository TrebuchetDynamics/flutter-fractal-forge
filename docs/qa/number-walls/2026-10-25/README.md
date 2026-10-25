# Number Walls host evidence — 2026-10-25

## Result and boundary

Production sources: `9c8b4902e2b44e435646d1001acf83ef9515bade`, plus the two new journey targets. No production Dart/shader changes, font substitution, fake exporter or placeholder viewer were used. `verification.json` pins both journey files by SHA-256. The release JavaScript bundle SHA-256 is `ad084f445288e2403c36b1e248bb889cb6441a116cd86c6de6b22c7d03855208`.

- **Native supplemental execution passed:** one composed journey plus integration teardown, `01:43 +2: All tests passed!`. Flutter 3.44.6 / Dart 3.12.2, Linux/Xvfb, Mesa llvmpipe (see `native/glxinfo.txt`), production GPU-sampler path. The runner emitted `integration_test plugin was not detected` and failed to start its VM-service HTTP listener (`Address already in use`, 127.0.0.1:20401); no successful VM-service attachment is claimed. The application still executed the journey to its terminal aggregate. This is **not** a passing `flutter test ... -d linux` receipt. Its supported fixed-port limitation remains an environment gap.
- **Production Chromium journey passed:** one selected test, one worker, 3.8 minutes, Chromium 147.0.7727.15, ANGLE/SwiftShader software graphics. Renderer sandboxing was requested through Playwright's `chromiumSandbox: true` and the provisioned sandbox helper; CDP separately reports the software GPU process as `sandboxed: false`. This is not hardware-GPU evidence.
- **Readback passed:** eight paired native/browser artwork states, 18,560 matching exact cells, all 16 primary PNGs at requested 1280×720, and all 40 retained PNGs decoded. Additional invalid/unfinished replay and post-cancellation browser exports also passed the journey's all-cell readback.
- **Focused offline regression passed:** nine state, style/export and randomizer tests. Scoped Dart analysis, Dart formatting, Node syntax and the offline lockfile-enforced dependency preflight passed. The release web build passed with the existing missing Cupertino-icons-font warning; no font was replaced to conceal it. The merged-tree full gate is coordinator-owned and was not run here.

These are host qualification observations, not release, Android, physical-device, screen-reader, process-memory ceiling or leak certification.

## Reproduce

Commands and reserved-port setup are in [the verification plan](../../../engineering/test-plan.md#composed-number-walls-host-journeys-num-wall-04). Native must run before the browser: the browser decodes its own actual PNG downloads and compares the recovered residue matrix with native records, not a second JavaScript implementation of the algorithm. The browser bundle was rebuilt after the journey; its SHA-256 remained identical to the tested bundle.

The executed native wrapper used `autowork-run timeout 480 xvfb-run -a -s '-screen 0 1600x1200x24 -nolisten tcp' /usr/bin/python3 "$TMPDIR/run-native.py"`. It ran the plan's explicit-port `flutter run` command on port 20401, retained the terminal test aggregate and terminated only its owned process group. Native preferences/export storage were isolated under `$TMPDIR`; the real export Save action wrote files there before decode/copy. The browser used port 20400 with an owned HTTP server, the plan's exact Playwright target, `timeout 1000`, and output `$TMPDIR/browser-final`. Both owned servers/runners were stopped; no persistent service or shared user profile was changed.

Read back the retained artifacts from the checkout root (requires the provisioned Pillow):

```sh
/usr/bin/python3 docs/qa/number-walls/2026-10-25/verify_artifacts.py \
  docs/qa/number-walls/2026-10-25/native \
  docs/qa/number-walls/2026-10-25/browser \
  "$TMPDIR/number-wall-verification.json" &&
cmp docs/qa/number-walls/2026-10-25/verification.json \
  "$TMPDIR/number-wall-verification.json"
```

The verifier decodes real PNG pixels, checks every primary exported cell against the full native residue-colour table with RGB tolerance ±1 LSB and exact alpha, rejects ambiguous residue matches, checks browser matrix identity, and inventories every retained PNG with dimensions/hashes. This tolerance is not a zero-mask or residue tolerance. Both runtime journeys also sample actual displayed cells; browser `*-viewer-samples.json` retains the unobscured samples. Native checks the plot boundary before exporting; UI overlays are intentionally excluded from that plot-only readback.

## Inputs and measured observations

The six source records use the actual documented default budget: 96×32, column origin 64, p=2. `replay-97` and `styled-97` use 16×4, origin 64, p=97 with residue colouring. Each JSON records complete committed parameters, view, exact matrix, full residue-colour table and backend. The default signed-Pagoda matrix contains 1,019 zero and 2,053 nonzero cells, 414 fully visible nonzero-framed zero windows (including size-one windows), and a largest visible zero square of side nine. These are observations of this finite crop, not a general square-window theorem.

| Observation | Native debug/Xvfb | Chromium release/SwiftShader |
|---|---:|---:|
| Catalog tap to default ready | 3,229 ms | 16,921 ms |
| Completed squares mod 2, 256×64 | 7,127 ms | 71,222 ms |
| Large-prime cancellation | 53 ms timer delivery / 53 ms settlement | 700 ms Apply-to-cancellation feedback |
| Worst-grid cancellation | 57 ms timer delivery / 59 ms settlement | 2,033 ms preset-open-to-cancellation feedback |
| Separate no-stale-result observation | 200 ms after awaited settlement | 2,016 / 2,089 ms, 19 stored-state samples each, then displayed-cell readback |

Native per-job measurements begin when the completion helper starts polling, so a zero means the request had already completed, not zero-cost computation. Browser timings include UI navigation/semantics/reconstruction; they are not isolated arithmetic benchmarks. Native cancellation bounds both delivery of a scheduled 50 ms event-loop timer and settlement after delivery by a generous two-second debug-host regression budget. Browser cancellation uses real Cancel/camera actions and a separate two-second state observation before any new replay/export can advance job ownership. Neither runtime committed a stale result in these observations.

Recorded native current RSS spans 501,235,712–627,765,248 bytes, with sampled maximum RSS reaching 648,253,440 bytes. Browser sampled used JS heap spans 78,145,620–138,491,855 bytes; the completed worst-grid sample is 119,007,100 bytes. The grid cap remains finite at 256×64; these samples do not establish a hard RSS/JS/GPU bound, exhaustive memory profiling or leak freedom. Full observations and software-renderer details are in the two `environment.json` files. No unlimited zoom, latency/FPS score or new grid limit is claimed.

## Replay, persistence and labels

Both journeys reject composite 561 and unfinished `170141183460469231731687303715884105727` without replacing the committed wall, then apply the outside-quick-pick p=97 replay and export matching cells. Native round-trips real PresetStore JSON and reopens the saved style through a new store instance; browser imports persisted preset JSON through actual preset cards and verifies edited session restoration after page reload. Native replay/store actions use public controller/store APIs, not a claim that every save/import dialog was exercised. Randomize/Undo uses the real controls; browser Undo activates the exposed accessibility click action because Flutter's scroll-semantics overlay intercepts pointer hit-testing. This does not qualify pointer or screen-reader usability of that action.

The catalog capture shows a computed finite-field preview, not a pending tile. Inspector captures identify the actual p=97 cell at m=2, n=72 and its residue; the export matrix agrees. The backend says exact integer field with GPU **display**, not GPU determinant arithmetic. Controls retain the conservative unverified-formula disclosure; this journey does not confer mathematical review. Android gallery/MediaStore labels and persisted gallery images are not covered by desktop files or browser downloads.

## Visual classifications and remaining qualification

Retained captures include native EN/ES at 320×900, 2× text and high contrast, native desktop EN, browser desktop EN, and browser ES at 320×900/high contrast/1× text. These are actual app typography and software-rendered frames, with synthetic viewport/accessibility inputs. Browser 2× text, physical display behavior, hardware GPUs and assistive-technology operation are not inferred.

- **Observed, medium — backend indicator/chrome overlap:** `native/inspector-en.png`, `native/narrow-en-high-contrast-2x.png`, `native/narrow-es-high-contrast-2x.png`, and `browser/narrow-es-high-contrast.png` show Back/title obscuring the top-left backend text. The backend remains exposed in semantics; visual legibility is not accepted as clean.
- **Observed, low — inspector under open HUD:** native narrow captures show the bottom inspector behind the controls HUD. The HUD is scrollable; content below the current scroll position is not counted as a RenderFlex overflow. No RenderFlex overflow was reported in the native capture states, but this is not a blanket clipping/accessibility pass.
- **Not qualified:** a prior supplemental Rook cold-session bootstrap probe timed out at 180 seconds. The completed six-source switching journey does not convert that cold-start probe into a pass.
- **Pending environment:** the pinned native `flutter test` driver rejects `--host-vmservice-port` before tests start and otherwise leaves its raw VM listener unbound by the caller. The explicit-port supplemental run does not waive that named gate.
- **Pending live:** physical GPU/device, Android gallery/MediaStore/TalkBack (NUM-WALL-05), human visual/accessibility review and release acceptance. No publication or device acceptance occurred.

DOCS-MAINTAINER/coordinator follow-up: retain these visual/cold-start gaps under the existing Number Walls goal without changing its acceptance, and reconcile shared task/history owners after integration. Worker scope does not authorize edits to `tasks/`, `TODO.archive.md` or `CHANGELOG.md`.
