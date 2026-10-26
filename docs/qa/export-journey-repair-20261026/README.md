# Edited native export journey repair — 2026-10-26 UTC

**QUAL-EXPORT-REPAIR-01:** the original complete Linux fixture now reaches official terminal protocol success and retains both real edited Mandelbrot/Mandelbulb PNG/state pairs. This is **local software-rendered functional/export evidence**, not physical-device, hardware-GPU or human visual qualification. No original live task or hold is closed here.

Authority and scope: [the unblock decision](../../tasks/UNBLOCK-20261026.md). The [previous failed packet](../delegated-qualification-20261025/README.md) and its private historical receipts are unchanged. This packet also preserves a fresh pre-fix diagnostic failure; it is not relabeled as success.

## Root cause: helper input reconnection, not catalog filtering

The diagnostic run used baseline `2201439bc8f13c70e9010b17cea8b0ea5dde636d` with **logging only** added to [the search helper](../../../integration_test/helpers/ui_test_helpers.dart). After the actual Mandelbrot edit/export and return, native output recorded:

```text
SEARCH_TRACE:before requested=Mandelbulb text=Mandelbrot focus=false bindingSame=true registered=false
SEARCH_TRACE:after requested=Mandelbulb text=Mandelbrot focus=false bindingSame=true registered=false
```

The full lines, primary focus, original diagnostic helper and patch are retained in `evidence/before/`. The journey then failed at `scrollUntilVisible` with `Bad state: No element`, as in QUAL-EVIDENCE-01. Its receipt is exit 1, protocol false, empty owned cleanup; only Mandelbrot exported.

Pinned Flutter 3.44.6 `WidgetTester.enterText` calls `showKeyboard`, which assigns `binding.focusedEditable`. That setter requests the keyboard **only when the EditableTextState changes** (`packages/flutter_test/lib/src/binding.dart`, `focusedEditable` setter). The native integration binding does not register TestTextInput; unlike the ordinary stub, native `clearClient` does not reset that cached binding field. After the export dialogs, the same field is mounted but unfocused/disconnected. Assigning it again does not reconnect input. The trace proves the requested text never reaches its controller; the catalog correctly continues to filter Mandelbrot. More debounce or scrolling would not repair this.

The minimal fix taps the search field like a user before `enterText`, reopening its real input connection, and asserts the requested controller text immediately. No product catalog code changed. No sleep, catch-and-ignore, module removal, pixel relaxation or export substitution was added. [The original full fixture](../../../integration_test/flows/user_flows_test.dart), including both journeys and all existing assertions, is byte-identical to baseline.

One focused [widget regression](../../../test/fractal/fractal_catalog_screen_widget_test.dart) uses the real catalog/viewer route and search helper. It disables the text-input stub to match the native binding and reproduces the observed unfocused return condition without running an expensive export. It failed with `Expected: Mandelbulb, Actual: Mandelbrot` before repair, then passed, checking the controller and fresh Mandelbulb/not-Mandelbrot results. Ordinary stubbed input or a return with focus still restored did not reproduce the fault; this distinction informed the regression rather than a production workaround.

## Actual execution and retained results

From the assigned checkout, with pinned SDK/cache and existing host tools:

```sh
export FLUTTER_ROOT="$AUTOWORK_CACHE/flutter-3.44.6"
export PUB_CACHE="$AUTOWORK_CACHE/pub-cache"
export PATH="$FLUTTER_ROOT/bin:/usr/bin:$PATH"
flutter pub get --offline --enforce-lockfile

autowork-run timeout --kill-after=10s 960 bash scripts/run-native-integration.sh \
  integration_test/flows/user_flows_test.dart --timeout 900 \
  --dart-define=FORCE_GPU_RENDER=true
```

Actual allocation: **20200–20299**. Both receipts observed only `127.0.0.1:20200`; Xvfb TCP was disabled. The supported wrapper/official SDK adapter and flags are unchanged. [Runbook](../../engineering/runbook.md) explains the terminal protocol and process ownership.

| Check | Final result |
|---|---|
| Focused helper regression | Pass after observed stale-query failure; both logs retained |
| Existing catalog search/debouncer + catalog screen widget targets | **54 passed, 1 existing skip** (live thumbnail readiness requires `FORCE_RUNTIME_CATALOG_THUMBNAILS`) |
| Analyzer on the two changed Dart files | No issues |
| Original full native user-flows fixture | **12 product cases passed, 1 existing skip**; terminal `+13 ~1` includes teardown |
| Official driver response and cleanup | `result: true`, `failureDetails: []`; `protocol_success: true`, **exit 0**, `remaining_pids: []` |
| Independent PNG/state/source/receipt readback | Both PNGs decode at **1280 × 720**, state and hashes reconcile |

The native skip remains the existing Barnsley Fern runtime/declaration default-view mismatch, not the repaired journey. `pubspec.lock` is unchanged (SHA-256 `22b29dbd8f71276012a54b9bdc62ba88408f967a86b34075986c17e1c4506ec3`). The full merged-tree offline gate belongs to the coordinator and was not run here.

### Retained real output

| Module | Decoded output | Every-fourth-pixel RGB samples | Observed edited view |
|---|---|---|---|
| [Mandelbrot PNG](evidence/after/exports/fractal_mandelbrot_1792981654165.png) / [state](evidence/after/exports/fractal_mandelbrot_1792981654165.png.state.json) | 1280 × 720 RGBA; alpha 255 throughout | 57,600 samples; **975** distinct RGB; 48,189 nonblack | pan `(-0.6523809523809524, -0.0761904761904762)`, zoom `0.35`, rotation `(0,0,0)` |
| [Mandelbulb PNG](evidence/after/exports/fractal_mandelbulb_1792981663866.png) / [state](evidence/after/exports/fractal_mandelbulb_1792981663866.png.state.json) | 1280 × 720 RGBA; alpha 255 throughout | 57,600 samples; **2,683** distinct RGB; 57,600 nonblack | pan `(0,0)`, zoom `1`, rotation `(0.2162241959042722, -0.5178097245096173, 0)` |

These are original saved bytes and sidecars, not re-encoded or reconstructed exports. The fixture asserts a gesture changes each view, formula/qualification is visible, HD output has more than 16 sampled colors, export preserves the edited view, and favorites/user preset survive both journeys. Sidecars record the actual post-export parameters and view. They do **not** record every effect/export toggle, an unedited baseline image or independent mathematical fidelity. A varied opaque PNG does not establish the selected transparency option or human composition quality.

## Source, SDK, backend and readback

[manifest.json](manifest.json) hashes all retained evidence and records complete observed state, PNG hashes, independently decoded RGBA hashes and measurements. `evidence/source-inputs.json` binds **1,085** runtime/test source inputs; `candidate.patch.gz` binds the two-file working-tree delta. Wrapper receipts correctly name pre-commit HEAD, not a fabricated final commit. Product source, shaders, native driver and original fixture match that baseline; documentation was assembled afterward. Decompressing and applying the candidate patch to that revision recovers the tested repair. The readback intentionally rejects later source drift rather than repinning historical evidence.

SDK: Flutter **3.44.6**, framework `ee80f08bbf97172ec030b8751ceab557177a34a6`, engine `83675ed27633283e7fc296c8bca22e841224c096`, Dart **3.12.2**. The owned process's executable/library hashes and selected environment are in `runtime-observations.json`; the collector is retained for provenance. A GL probe on that process's owned display reports **Mesa llvmpipe (LLVM 20.1.2, 256 bits), Mesa 25.2.8, Accelerated: no**. The app used its `gpu` shader path; this is neither hardware acceleration nor its CPU-formula fallback. The probe is not an in-app GL_RENDERER query.

All evidence below this directory travels with the commit, including the failed reproduction and official terminal response. Driver transcript copies remove only the expired VM-service authentication URL path; raw transcript hashes and the redaction are declared in the manifest. Files with native trailing whitespace (including patches and transcripts) are retained losslessly in `.gz` files; compressed and uncompressed hashes are recorded, and readback decompresses them. No active endpoint or credentials are required for readback. Original raw scratch logs are not a portable retention dependency.

Using the existing Pillow decoder (no installation):

```sh
/usr/bin/python3 docs/qa/export-journey-repair-20261026/verify.py
```

This verifies retained file bytes, current tested-source bindings, unchanged fixture, both decodes/state/measurements, protocol response, allocated listener, cleanup and local README links. It does not rerun the native journey. Pinned SDK tools and Pillow are separate decoders: the fixture used Dart `image`, readback used Pillow **10.4.0**.

## Scoped Docs Sync Maintain and remaining qualification

Maintained this task-scoped evidence owner against the actual before/after logs, source delta, sidecars and receipts. Inspected the existing [accepted release journey/test-plan](../../engineering/test-plan.md), [native runbook](../../engineering/runbook.md), task authority and prior failure packet. The runbook already covers the unchanged wrapper; dated test-plan results remain historical. No architecture, product requirement, dependency or shared history rewrite is warranted for a test-helper repair. The coordinator receives the CHANGELOG proposal separately and owns task/global closeout. Docs Sync role-manifest check/stale report no manifest; scoped source/content/link readback supplies the substantive check here.

Remaining: physical Android/MediaStore, screen-reader/rotation, hardware-GPU and production-font checks; browser qualification, Spanish and inspired/unverified samples; attributable human composition/mathematical review. This task does not close those original gates. Numerical image checks cannot supply them.

Revisit with a separately source-bound run when the helper, fixture, product/shader inputs, SDK/backend or edited state changes. Keep this failure/success pair and the earlier failed receipts intact; never overwrite them with later results.
