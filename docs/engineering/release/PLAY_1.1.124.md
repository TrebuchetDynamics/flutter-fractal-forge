# Google Play publication: 1.1.124 (124)

## Confirmed publication

- Package: `com.trebuchetdynamics.fractal.forge`.
- Destination: production, API status `completed`.
- Committed Play edit: `00835660386604848605`.
- Receipt timestamp: `2026-11-15T02:34:08.985608+00:00`.
- Release source: `586a3676d1becaf39f1c72d4e56a12ac8d4ed6ca`.
- Working tree recorded dirty: unrelated existing edits to `PRD.md` and
  `docs/planning/refactor-plan.md` were preserved, not committed with this release.
- AAB: **73,628,268 bytes**; SHA-256
  `82ddce0ad8461e96b6a256f10591bfede2289935b1d4b8f61cc75745cc7bbc28`.
- Upload certificate SHA-1:
  `1F:01:3D:4F:BE:48:4B:DA:4B:1F:49:3F:DF:0C:F0:37:1D:46:E0:58`;
  builder verified the expected fingerprint.

Fresh independent readback confirmed:

```json
{"found":true,"conflict":false,"versionCode":"124","track":"production","status":"completed","aabSha256":"82ddce0ad8461e96b6a256f10591bfede2289935b1d4b8f61cc75745cc7bbc28"}
```

Private evidence and the retained AAB are under
`/tmp/play-124-private-kuH7WG/artifacts/`, including
`release-play-evidence.json`, `play-publication-receipt.json`, and
`play-readback.json`. These temporary paths must be retained before host cleanup.

## Delta from published 1.1.123

The prepared 124 changelog describes quick-press randomization on Edit and Color,
long-press access to their sheets, clearer selected tools/descriptions/focus
rings, and a keyboard-reachable full-size deep-zoom CPU button. Source changes
also include shared modal/overlay layout improvements, localized accessibility
hints, reduced-motion splash handling, and tolerance for mistyped history
preferences. The Rust whole-session adapter remains inert/default-off; this is
not a migration activation claim.

This execution corrected a stale release-gate assertion: the restored Julia
canvas is now identified from its own semantics node, rather than requiring the
heading of a closed editing sheet. Eight matcher cases and updated isolated
safety fixtures reject catalog-only/other-canvas matches.

## Qualification

The final publishing invocation skipped no offline or device gate:

- Pinned Flutter **3.47.9**; Cargo fmt, warning-denying clippy and locked/offline
  tests passed; Flutter analysis passed.
- Flutter host suite: **3514 passed, 9 skipped**.
- Python: **653 passed, 1 skipped, 204 subtests passed**; Bats passed.
- Both Dart and Rust lockfiles remained unchanged; neither changed during build.
- Designated Waydroid `192.168.240.112:5555`, native model
  `WayDroid x86_64 Device`, boot complete; explicit matching disposable-device
  acknowledgement supplied under the standing target consent.
- Combined device suite: **12 passed, 8 skipped**; lifecycle restoration and
  offline journey each **1 passed**. Production installation, memory-pressure
  process restoration, accessibility, rendering and performance stages passed.
- Full **300-second** production soak passed: PSS first **137210 KiB**, peak/final
  **204769 KiB**, growth **67559 KiB**; final mature jank sample **0%** against
  the unchanged **10%** limit; thermal status **0**; crash/ANR checks passed.

### Retained unsuccessful attempts

Nothing was uploaded by these attempts:

1. Checkout-local evidence path was refused by the offline gate; output moved
   to a private directory outside the checkout.
2. Original device gate rejected a UI that actually contained the restored Julia
   canvas because it required `Edit fractal`. Fixed and regression-tested.
3. First host run after that fix exposed isolated test fixtures missing the new
   helper/current canvas semantics. Fixtures updated, then full gates rerun.
4. Two complete device runs lacked a mature Android View-frame sample despite
   continued app interaction. Evidence remains at
   `/tmp/play-124-private-iKW7QX/artifacts/` and
   `/tmp/play-124-private-GSodsW/artifacts/`. After confirming no other device
   test process, the existing Waydroid session alone was stopped/restarted and
   model/boot/ADB reverified. The final full pipeline passed without lowering
   duration, frame maturity or performance limits. No container reset occurred.

## Storefront observation and limits

At `2026-11-15T02:34:41+00:00`, the official track reported completed/124, but
**12/12** public storefront probes still showed **1.1.123**. The observer completed;
`play-live-check.sh` **failed propagation**, while track, version code and
storefront availability checks passed. Receipts: `play-observe.json` and
`play-live-check.json` in the final evidence directory. Do not reupload 124 to
address propagation delay.

A second read-only check at `2026-11-15T02:40:52+00:00` again reported
production/completed/124 and **12/12 storefronts still on 1.1.123**. Propagation
still failed the live checker. The hardened readback script also confirmed the
exact 124 AAB hash. Evidence: `/tmp/play-124-status-JYu8qW/`.
No bundle was uploaded by these checks.

Google review status is not observable through the public API and was not
confirmed in Console. End-user update availability remains pending observation.
Waydroid is container evidence, not physical-device/hardware-GPU qualification.
Other platform lanes, GitLab, listing copy and screenshots were not published by
this Play-only request. Release-code fixes and this record are local commits;
remote Git push is not part of the confirmed Play receipt.
