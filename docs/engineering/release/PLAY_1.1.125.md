# Google Play publication: 1.1.125 (125)

## Confirmed publication

- Package: `com.trebuchetdynamics.fractal.forge`.
- Destination: production, API status `completed`.
- Committed Play edit: `17337675384849297736`.
- Receipt timestamp: `2026-11-20T05:03:47.979521+00:00`.
- Release source: `6f63c28b9b2d795e5c4aeddd8ee6fd7f563f8cf2`, clean isolated
  branch `release/play-125-current`, based on PR-repaired `2b76f770`.
- AAB: **75,386,527 bytes**; SHA-256
  `9461eacb0e22a837aade2e4724ab0f05865f66a742da84d7b01a8f719583ce99`.
- Upload certificate SHA-1:
  `1F:01:3D:4F:BE:48:4B:DA:4B:1F:49:3F:DF:0C:F0:37:1D:46:E0:58`;
  builder verified the expected fingerprint.

Fresh independent readback confirmed the exact code, track, status and hash;
the parent repeated that readback and independently hashed the retained AAB:

```json
{"found":true,"conflict":false,"versionCode":"125","track":"production","status":"completed","aabSha256":"9461eacb0e22a837aade2e4724ab0f05865f66a742da84d7b01a8f719583ce99"}
```

Private evidence and the retained AAB are under
`/tmp/play-125-current-retry-private-KfLoak/artifacts/`, including
`release-play-evidence.json`, `play-publication-receipt.json`, `play-readback.json`,
`parent-play-readback.json`, `play-observe.json` and `play-live-check.json`.
Full output is `../pipeline.log`; gate logs are
`../release-play-1.1.125-gJb2QS/gates/`.

The AAB, receipts, complete successful gate logs/pipeline output and all four
failed-attempt gate logs/pipeline outputs were copied to private persistent local
storage before cleanup:
`/home/xel/.local/state/fractal-forge/releases/play-1.1.125/source-6f63c28b/`.
The archived AAB hash was verified again. This local archive is not a public
artifact download or remote Git publication.

## Delta from published 1.1.124

Native saved-preset batch export now awaits preset application and restoration.
Viewer export frames do not enter history or saved sessions; keyboard navigation
is blocked during export, directory-picker failure releases ownership, and
user-gesture-yielded auto-explore stays paused. GPU-health failures receive a
confirmation probe; cached shader recovery clears prior failure state. History
navigation, preset keyboard access and responsive-overlay test coverage improve.
The Rust whole-session adapter remains default-off; no migration activation or
hardware-GPU performance claim follows from this publication.

The two initial source-bound migration failures were repaired by preserving
historical hashes and appending narrowly scoped source transitions. PR24's
integration preserves both branches' immutable receipts, with explicit archived
viewer custody and an active successor after native batch export. No oracle,
image, earlier receipt or lockfile refresh was used to make the checks pass.

## Qualification

The successful pipeline skipped no offline or device gate:

- Pinned Flutter **3.47.9** / Dart **3.13.7**; Cargo fmt, warning-denying clippy
  and locked/offline tests passed (**127 Rust tests**); analyzer: no issues.
- Flutter host suite: **3586 passed, 9 skipped**.
- Python: **700 passed, 1 skipped, 204 subtests passed**; Bats: **34 passed**.
- All eight offline stages exited zero; both lockfiles remained byte-identical.
- Designated Waydroid `192.168.240.112:5555`, native model
  `WayDroid x86_64 Device`, boot complete; matching explicit disposable-device
  acknowledgement recorded the standing target consent.
- Combined device suite: **12 passed, 8 skipped**; runtime-thumbnail performance
  and offline journey each **1 passed**. Production installation, restoration,
  rendering/accessibility and other required device stages passed.
- Full **300-second** soak passed with unchanged limits: terminal **50 Android
  View frames**, **2 janky (4%)**, below the **10%** ceiling and above the
  **10-frame** maturity minimum. PSS first **141189 KiB**, last **210904 KiB**,
  peak **212219 KiB**, growth **69715 KiB**; thermal status **0**; crash/ANR
  markers **0**.

The gate now captures a timestamped terminal sample after the full timeout and
Monkey cleanup, retaining periodic samples and all failure rules. Monkey uses
fixed seed **1**, verbose event evidence and unchanged event exclusions/throttle.
This improves coverage and reproducibility; it does not prove why previous
native View redraw counts were sparse or equate them to Flutter surface frames.
Waydroid remains container evidence, not physical-device/hardware-GPU proof.

## Retained unsuccessful attempts

Nothing was uploaded by these attempts:

1. Initial source-binding failures (3565 Flutter passed, 9 skipped, 2 failed):
   `/tmp/play-125-private-B5ObDs/`. Focused failures reproduced before repair;
   245 focused/regression tests and two identical twelve-document exports passed
   afterward (`/tmp/play125-exports-39tNPQ/`).
2. Earlier source `67eb5cf6` passed full offline/device journeys but produced only
   **6**, then **4** cumulative View frames in separate full 300-second soaks:
   `/tmp/play-125-retry-private-ABdQkl/` and
   `/tmp/play-125-final-private-dQaBOd/`. An exclusive existing-session stop/start
   between attempts succeeded; no container reset or threshold change occurred.
3. First current-candidate run stopped at eight new Python fixture failures:
   `/tmp/play-125-current-private-2MaXUL/`. Tests incorrectly assumed private gate
   logs lived under the fixture lane despite ambient external `TMPDIR`. Commit
   `6f63c28b` follows the wrapper's reported path and tests external placement;
   94 safety/pipeline tests passed under private external scratch, then the full
   release pipeline above was rerun successfully. No production limit changed.

## Storefront observation and limits

At `2026-11-20T05:05:45+00:00`, the observer reported production/completed/125,
while **12/12 probed storefronts still showed 1.1.124**. The observer exited zero;
the live checker exited one for pending propagation. Track, version-code and
storefront-availability checks passed. Do not reupload to address propagation.

Google review and end-user update availability remain unconfirmed. Publication,
review, propagation and per-device availability are separate states. Other
platform lanes, GitLab, listing copy and screenshots were not republished.
