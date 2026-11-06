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

## Verification limits

This maintainer pass inspects evidence and creates an executable repair contract;
it does not implement the repair or run Flutter/Python/Bats product suites.
No coordinator receipt, owner input, device access, publication, goal verification
or live qualification is needed or inferred. Preserve unrelated task closures,
existing live-worker contracts and all authorization boundaries.
