# MAIN-STORE-CLAIMS-REPAIR-01 — restore the offline store-copy gate

## Source-bound diagnosis

Main `72b498df4fc38988471f808f21018c229fd8e7d8` is red after the
store campaign commits `920ac23a` and `404f3bc3` and their merges `6c6ecdec`
and `72b498df`. Last green: `56e7369d444c91d1ce932482e2a4f75268813104`.
Read the original bundle in place; do not copy it into a worktree or commit:

`/home/xel/git/trebuchet-dynamics/flutter-fractal-forge/.git/autowork-execution/main-evidence/72b498df4fc38988471f808f21018c229fd8e7d8`

- `main_check.json`: red, `TEST_FAILURE`, exactly the two cases below;
  `flaky=[]`, `flaky_history={}`, `repair_pending=[]`.
- `main-check.log`: dependency preflight and analyzer completed; lines 715–740
  show `test/modules/readme_catalog_claims_test.dart` failures:
  - `public production fractal counts match the registry`: line 48 expects
    `1051 production fractals`, but JSON metadata contains `1,000+ production fractals`.
  - `public copy does not advertise undeclared device capabilities`: the English
    full description mentions `Camera looper`; CAMERA is not declared.
- Final log result: `+3458 ~9 -2`, Some tests failed, naming only those cases.
- `main-check.exit`: 1. `main-check-reruns.log`: empty.
  `flaky_history.json`: `{}`. No isolated rerun or flakiness qualification exists.
  The chained check stopped at Flutter tests; later Python/Bats results are not supplied.

Only ACAD-013-4142ef42 is open in the inspected ledger. The completed
MAIN-SETTINGS-COUNT-REPAIR-01 addressed a different settings assertion; do not
reopen it. No existing open task covers these two failures.

## Minimal repair

1. Reproduce both cases with the pinned, checkout-local offline preflight.
2. Restore the canonical JSON `count` metadata to the actual registry-derived
   exact production count (1051 on the reported source), using the existing
   production filter. Keep the localized descriptions' durable 1,000+ promise:
   the same test already explicitly permits and verifies that campaign floor.
3. Reword store-facing looper references as animation/view navigation, retaining
   zoom, pan, parameter animation, preview and GIF functionality. Inspect all 15
   locales for the capability terms enumerated by the test, not just the first
   English failure. Do not add device permissions or weaken the capability guard.
4. Run `scripts/sync-store-copy.py` using the provisioned Python to regenerate
   Fastlane and English mirrors, then `--check`. Preserve all locale titles,
   text limits, screenshot bytes/digests and unrelated campaign promises.
5. Run the full claims test, listing Python tests and the unchanged full offline
   check from AGENTS.md. Record exact source, commands, exits and lockfile hashes.
   Preserve failure results; focused green does not qualify the full gate.

Touches comprises the failing test and affected copy/mirror/sync-test paths
from the campaign commits, plus this evidence/plan document. Screenshot,
composer, upload-checklist, manifest and changelog changes in those commits are
provenance only: this repair does not require editing them. No product, SDK,
permission, shader or registry change is indicated by these failures.

## Worker repair and focused verification

The worker reproduced both named failures at baseline
`d9a76106fda0f22a467a100e40fe8a60ca43beb7` before editing. The unchanged registry
filter yields 1051 production fractals. Canonical JSON now records
`1051 production fractals`; localized descriptions retain their 1,000+ campaign floor.
All 15 full descriptions now describe an animation looper, including compounds
and translations not matched by the guard. Zoom, pan, parameter animation,
loop preview and GIF export remain in every locale. The existing sync script
regenerated the English and Fastlane full descriptions. Titles, short descriptions,
screenshots, manifests, permissions, product code and test assertions are unchanged.
No new helper, dependency or duplicate test was needed.

Checks used the AGENTS.md process-local setup: `FLUTTER_ROOT` was
`$AUTOWORK_CACHE/flutter-3.47.9`, `PUB_CACHE` was `$AUTOWORK_CACHE/pub-cache`, and
`PATH` began with `$FLUTTER_ROOT/bin:/usr/bin`.

| Command | Result on repaired copy |
| --- | --- |
| `flutter --version` compared with `fdroid/flutter.version` | Flutter 3.47.9 matches; Dart 3.13.7. Exit 0. |
| `/usr/bin/python3 -c 'import sys, pytest, jinja2, markupsafe; print(sys.executable, sys.version, pytest.__version__, jinja2.__version__); assert callable(markupsafe.soft_str)'` | Python 3.12.3, pytest 9.0.2, Jinja2 3.1.6. Exit 0. |
| `flutter pub get --offline --enforce-lockfile` | Checkout-local package metadata regenerated. Exit 0. |
| `flutter test --no-pub test/modules/readme_catalog_claims_test.dart --reporter expanded` | Before: exactly the two named failures, exit 1. After: all 4 tests pass, exit 0. No skips. |
| `/usr/bin/python3 scripts/sync-store-copy.py` | 48 copies synced. Exit 0. |
| `/usr/bin/python3 scripts/sync-store-copy.py --check` | All 48 copies match. Exit 0. |
| `/usr/bin/python3 -m pytest test/scripts/test_play_store_listing.py -q` | 27 tests and 46 subtests pass, including screenshot manifest digests and copy limits. Exit 0. |

Repaired canonical JSON SHA-256:
`2d8d3ee2c735399bf806d3bc9930b102b4ee134a224d45a2f05b357dc60e1cb9`.
Unchanged claims test SHA-256:
`fedce35adbb9086aa87ebadfa9df96ff328c0ecce58e3d0ed942585571a64e90`.
`pubspec.lock` SHA-256 before and after:
`d759c63037e4d4f29a7c09b14886854fb8caa832c41f1172ec684a5cdcb7145b`.

The worker did not run the full offline gate. Worker instructions reserve that
unchanged gate for the runner on the merged tree before review. Focused green
is not full-gate, goal, device, browser or publication qualification.

## Verification limits

The original maintainer pass inspected evidence and created the repair contract.
It did not implement the repair or run Flutter/Python/Bats product suites.
No coordinator receipt, owner input, device access, publication, goal verification
or live qualification is needed or inferred. Preserve unrelated task closures,
existing live-worker contracts and all authorization boundaries.
