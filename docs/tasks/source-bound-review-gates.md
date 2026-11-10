# Retained candidate full-gate findings

## Disposition

This is a documentation-only diagnosis for `MAINT-A11Y-STATUS-COPY-01` and
`RUST-CORE-BOOTSTRAP`, not acceptance, a fixture refresh, an engineering-incident
reset or release of a hold. Keep both IDs, every Acceptance item, Scope, Touches,
Dependencies, ordering and authorization. Neither candidate is an ancestor of
this checkout's `fe172312`; neither task is closed. The retained slots are held,
not running, and their recorded worker PIDs (10559 and 1859411) were absent at
inspection. No candidate, runtime state or other writer's work was changed.

The repair to Checks makes the already mandatory full gate explicit at worker
closeout, with retained diagnostics. Focused successes alone must not be submitted
again as resolution of these findings. This does **not** establish that the
provenance failures can be repaired within either unchanged contract.

## Evidence retained in place

Paths below are host-local evidence, not files copied into this checkout.

- Execution root: `/home/xel/git/trebuchet-dynamics/flutter-fractal-forge/.git/autowork-execution/`.
  Read `slot-data/<ID>/attempt-{1,2}/report.json`, `slots/<ID>.json`, and
  the validation receipts/logs below.
- Review root: `/home/xel/.local/state/pi-autowork/481371330a53e93e/`.
  Read `review-findings/<ID>.json` and `full-check/<ID>-merged.log`.
  These persistent merged logs preserve the failing stage and a truncated list of
  failed tests, unlike the summary-only validation receipts.
- The two original `/var/tmp/.../offline-gate.json` paths in the findings are
  absent. Their full test logs are therefore unavailable; do not invent assertion
  messages, the omitted test names, isolated reruns or a definitive root cause.

### MAINT-A11Y-STATUS-COPY-01

- Candidate `2916058ad467e32dcd80f08b4c55fbb5d443d0b6`; reviewed integration
  `258d9b3cf274e53798a35cca5d5a833af85f6f89`.
- Validation receipt/log: `4b7ff04a4fc74e0d8eea0d49fc9f0927.{json,log}` under
  the execution root. Finding: full check exits 1 where base passes; summary
  `/var/tmp/aw-b-2472010-w6urexky/offline-gate-oAtbtG/offline-gate.json`.
- Persistent merged log: pub-get/analyze pass; Flutter tests exit 1, final
  aggregate `+3468 ~9 -9`. Named failures are
  `test/migration/baseline_contracts_test.dart`,
  `test/migration/param_interpolation_oracle_test.dart`,
  `test/migration/physical_events_oracle_test.dart`, and
  `test/migration/randomization_oracle_test.dart`; five more are omitted.
- Worker attempt 2 reports 23 focused accessibility cases passing, genuine
  failing-before copy/semantics cases, deterministic generated localization and
  unchanged lock. It explicitly did not diagnose the earlier full-gate failure.
- Current `baseline_inventory.dart` imports `app_localizations_en.dart`;
  `param_interpolation_oracle_test.dart` imports it and uses replay bindings;
  the physical oracle imports `app_localizations.dart`. Localization source
  changes can thus affect transitive hashes outside the visible settings screen.
  This is a source-supported investigation lead, not proof that all nine failures
  are hash-only or permission to exclude localization from provenance.

### RUST-CORE-BOOTSTRAP

- Candidate `b351b97c6f3d0befe6cb4d11ea889facfe1a60d6`; reviewed integration
  `1cd250751501ae4d0187910108e2392e0237abd1`.
- Validation receipt/log: `34024ae5022240b9ad036db8373c9241.{json,log}` under
  the execution root. Finding: full check exits 1 where base passes; summary
  `/var/tmp/aw-r-2460759-99lcr4hx/offline-gate-Y99DKF/offline-gate.json`.
- Persistent merged log: pub-get, Cargo fmt/clippy/test and analyze pass;
  Flutter tests exit 1, final aggregate `+3470 ~9 -6`. Named failures are
  interpolation, physical-events and randomization oracle tests above, and
  `test/migration/reference_render_test.dart` `(setUpAll)`; two more are omitted.
- Attempt 1 identified exact capture-harness binding incompatibilities; attempt 2
  reports passing baseline/replay, adapter, builds and additive gate/Bats checks,
  but no successful complete offline gate. Those results do not dispose of the
  remaining source-bound oracle/capture failures.
- `replay_codec.dart` and `physical_events_oracle.dart` bind `pubspec.lock`.
  The three named oracle tests compare complete documents including source maps.
  `ReferenceCapture.prepare` also compares freshly built inventory documents
  byte-for-byte with retained fixtures before checking both capture manifests.
- Current source additionally has `reference_source_transition.dart`, introduced
  for the completed physical-oracle task. Its exact clock-seam allowlist and
  immutable fixture anchor are **not** a generic FRB/localization transition.
  Preserve this newer planning/implementation rather than applying the earlier
  worker's proposed capture amendment wholesale.

## Required next execution and boundaries

1. Revalidate the current base and retained candidate without discarding either.
   Use the pinned SDK/cache and Python binding in root `AGENTS.md`; install
   nothing for the accessibility task. Bootstrap also uses its accepted Rust/cache
   setup. Regenerate checkout-local package metadata offline, preserving locks.
2. Run the unchanged common full gate from the actual candidate checkout, retaining
   its complete stage logs and JSON in private scratch outside the checkout. Use
   its supported `--log-dir "$TMPDIR/<ID>-full-gate"` option; retain or export
   diagnostics before runner scratch cleanup. Record revision, command, stage
   exits, terminal aggregate and complete failed-test/assertion list. No skips,
   SDK override, reduced test selection or passing focused-run substitution.
3. Run named failing modules individually to distinguish source binding drift,
   semantic drift and load/isolation effects. Compare complete binding maps and
   semantic fields read-only; enumerate changed/added/removed paths against the
   task's exact existing allowlist. Compare base/candidate under the same setup.
4. Repair only a demonstrated defect already permitted by Scope and Touches, then
   repeat focused checks and the full gate. If resolving the mismatch requires
   prohibited fixture/evidence edits or source paths outside the approved contract,
   retain the exact delta as the blocker for scoped reconciliation. Do not refresh
   or strip hashes, shrink the source graph, weaken negative tests, change the
   clock-only transition or silently extend bootstrap's pubspec/harness allowlist.

No new dependency follows from shared source paths or these concurrent failures.
No passing main check, native execution, human language review, release authority,
goal qualification or STOP / REVIEW release is claimed. Bootstrap's suggested
`FORCE_GPU_RENDER` aggregate command amendment is deferred: its report requests it
**after integration**, and this candidate has not integrated.
