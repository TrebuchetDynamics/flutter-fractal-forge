# Linux retained-image qualification — 2026-10-29

## Result

Six supplemental native journeys passed: English and Spanish for Mandelbrot
(2D), Mandelbulb (3D), and Milnor–Brieskorn Orbit (2D, explicitly Inspired).
This closes the automated locale, inspired-entry, retained-image and edited
preview/export comparison gaps. **Human composition/readability/source review
remains pending.** No platform publication or human verdict follows from these
automated checks.

The fixture is
[`integration_test/flows/linux_image_evidence_test.dart`](../../integration_test/flows/linux_image_evidence_test.dart).
It browses the real catalog, changes camera and iterations through the UI,
checks localized formula/qualification text, explicitly selects HD, and saves
through the production export flow. Time is frozen with the existing reduced
motion setting. Native fonts and real shader paths remain enabled.

## Measured evidence

- Six journeys, no skipped cases. The final `+7` includes binding teardown and
  must not be reported as seven journeys.
- 36 genuine native PNGs and six state JSONs retained, all 1280×720. Each case
  includes renderer preview, repeat preview, saved export, edited viewer,
  formula/qualification controls and export options.
- All six preview/repeat pairs and all six preview/saved-export pairs are
  identical across **921,600 pixels / 3,686,400 decoded RGBA channels**. No crop,
  rescale, ignored pixels or tolerance is used. Encoded PNG file hashes may differ.
- Independent Pillow decoding and parent/reviewer checks confirmed dimensions,
  hashes and equality. Sampled RGB counts are 849 for Mandelbrot, 2148 for
  Mandelbulb and 1867 for Milnor in both locales.
- Native protocol receipt: official `allTestsPassed: true`, exit 0 and empty
  owned-process cleanup. The only listener was the fresh leased IPv4 loopback
  endpoint; no historical range or random service listener was substituted.
- Backend: Mesa llvmpipe, software rendering. Production GPU/shader-path
  execution is **not hardware-GPU qualification**.

## Source and verification boundaries

The original exact tested fixture commit is
`89140e4c8c9ccb5b38ff1799269cae938af13932`, SHA-256
`89bc23dfb57db8496e30c295dff04748524a5f977c006ca4935acc4945aaa076`.
A platform-dispatch correction at
`99953c5f4e517f5705924a5556da3a0f6dc5cb4d`, SHA-256
`4529bcbfcc3c8f9dfbe9a24cf9b128b13b13669694139881e675a4e1bb88427b`,
was replayed on its exact commit: all six Linux cases passed with zero skips,
protocol success and empty cleanup. The fixture skips unsupported OS/web targets
without dropping any Linux assertion. Actual Android/web execution was not
performed. Both source-bound runs and their independent image audits are retained.

Pinned SDK: Flutter 3.44.6 / Dart 3.12.2. The app-runtime anchor for these captures is
`8fa9b06cc1bc2fa22b21b7da77c884e816ab5714`. All 993 runtime-file hashes and the
`lib`, `shaders`, `assets`, `pubspec.yaml` and `pubspec.lock` Git objects match.
This is component equality, not whole-commit or production-artifact identity.
The original release campaign was not repinned or rewritten.

The canonical full `user_flows_test.dart` receipt at app source `8fa9b06c` was
separately checked: protocol success, exit 0 and empty cleanup. These supplemental
captures do not replace that full journey, archive/download checks, actual
hardware requirements or human review.

The implementer's optional 900-second full host-suite attempt timed out at
`+2891 ~7` and remains failed/incomplete. Its named log-viewer rerun passed 18
cases, but that does not convert the timed-out suite into success. The parent
independently passed the full offline gate on release repair `28e03349`
(3,121 Flutter cases, 448 Python cases and 25 Bats cases). Those are separate,
source-bound results rather than a claimed full-suite pass on fixture `89140e4c`.

## Reproduce and review

Use the [supported native driver and real port-lease procedure](../engineering/runbook.md#owned-linux-runtime-with-reserved-ports):

```sh
bash scripts/run-native-integration.sh \
  integration_test/flows/linux_image_evidence_test.dart \
  --timeout 900 --dart-define=FORCE_GPU_RENDER=true
```

This command requires the pinned SDK, checkout-local resolved packages, fresh
private scratch and a genuinely held `AUTOWORK_PORT_BASE` lease. It is a command
declaration, not proof of a new run. Preserve the printed evidence directory's
`run.json`, `protocol-success.json`, `driver.log` and
`outputs/linux-image-journey/{en,es}-{module}/` files. Inspect original-resolution
viewer, formula and saved PNGs for the required human review. A resized contact
sheet is only a navigation aid, not the numerical comparison input.

Actual exact-commit logs, source inventory, 36 original PNGs, six state files,
independent audit and the failed diagnostic were retained privately. No human
actor or review outcome has been invented; missing review remains a release gate.
