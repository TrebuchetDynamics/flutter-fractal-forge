# Retained candidate full-gate findings

## Initial disposition (historical)

The scoped reconciliation below supersedes this initial diagnosis's unchanged-Touches
and stop-for-scope restrictions only for the explicitly named comparison repairs.
It does not supersede immutable-evidence, acceptance or qualification requirements.

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
4. Apply the explicitly bounded comparison repair in the scoped reconciliation
   below, then repeat focused checks and the full gate. Further source deltas or
   prohibited fixture/evidence edits remain blockers. Do not refresh or strip
   hashes, shrink the source graph, weaken negative tests or change the clock-only
   transition. The supplement names the additional harness paths; it is not a
   general extension of bootstrap's pubspec/harness allowlist.

No new dependency follows from shared source paths or these concurrent failures.
No passing main check, native execution, human language review, release authority,
goal qualification or STOP / REVIEW release is claimed. Bootstrap's suggested
`FORCE_GPU_RENDER` aggregate command amendment is deferred: its report requests it
**after integration**, and this candidate has not integrated.

## Scoped reconciliation — 2026-11-10

### Evidence and authority

The latest held workers supplied the previously missing diagnosis:

- Accessibility: `slot-data/MAINT-A11Y-STATUS-COPY-01/attempt-1/report.json`
  and `MAINT-A11Y-STATUS-COPY-01-diagnostics.tar.gz` under the execution root.
  Base `021bf2ded098971bffc2c539af2f1e215bce1968`; uncommitted candidate tree
  `8faa284af3ae42e072a267184c7c6bea56a99eb2`. All seven affected migration
  modules pass individually on base and fail on candidate. Eleven complete
  document comparisons show identical nonbinding fields, no added/removed source
  paths, and changes only to the three generated localization Dart bindings.
- Bootstrap: `slot-data/RUST-CORE-BOOTSTRAP/attempt-1/report.json` and
  `evidence-current/{binding-comparison,semantic-comparison}.json` in place.
  Base `51007727592d8365dfea29eb3ae6a58adb5571b5`; tested tree
  `f6695984a8f22342526340768f03be66c003c56b`; final staged tree
  `da3d678a5be997959678a05ad29976cd1d8813d0` adds only a historical-check wording
  correction. Five affected modules pass individually on base and fail on
  candidate. Fresh exports show identical nonbinding fields. In addition to
  pubspec bindings, interpolation/randomization bind the changed replay test and
  new provenance helper. The required seven original archives and bootstrap
  sidecar conflict with the clock guard's complete baseline-file inventory.
- Neither latest attempt completed the full gate: accessibility timed out at
  1500 seconds, bootstrap at 1700 seconds. Neither has a terminal passing suite
  aggregate or an original gate JSON summary. The retained diagnostics are not
  accepted transition metadata and must not be promoted unchanged.

The accepted [provenance plan](../planning/refactor-plan.md#baseline-provenance-transition-and-builder-disposition)
identifies hash-only prerequisites and returns further deltas for scoped
reconciliation. The standing autonomous-local-progress policy and this maintainer
request permit repairing those check consumers within the existing outcomes.
This supplement supplies that engineering contract, not a new product decision,
fixture refresh, review acceptance, live authority or release of STOP / REVIEW.
At this inspection both slots were held, both recorded worker PIDs were absent,
and neither latest report had a commit waiting to land. Candidates remain intact.

### Exact comparison scope

Both existing tasks may adapt only these comparison/helper files under
`test/migration/`, in addition to their original Touches:

- `baseline_contracts_test.dart`
- `state_replay_test.dart`
- `param_interpolation_oracle_test.dart`
- `physical_events_oracle_test.dart`
- `randomization_oracle_test.dart`
- `reference_source_transition_test.dart`
- `support/reference_capture.dart`
- `support/provenance_transition.dart`

Reuse the bootstrap's planned helper for composition, not a second provenance
framework. Accessibility may add only
`migration/oracles/a11y-status-copy-source-transitions.json` for its transition;
bootstrap retains its already-declared
`migration/baseline/provenance-transitions.json` and exact seven archive paths.
If the helper already exists on the actual base, extend it compatibly and retain
all existing stages and tests. No producer dependency follows from sharing it.

For accessibility the only permitted non-harness source-map deltas are
`lib/l10n/app_localizations.dart`, `lib/l10n/app_localizations_en.dart`, and
`lib/l10n/app_localizations_es.dart`, generated from its scoped ARB additions.
The original eight application/a11y paths remain the entire copy/semantics repair.
For bootstrap the non-harness map deltas remain only `pubspec.yaml` and
`pubspec.lock`. Each task's additional harness binding allowlist is exactly the
eight files above; paths not actually collected must not be invented in a map.
For each map record the exact observed changed/added sets, not just an allowed
superset; removals are rejected. This does not authorize changes to source
collectors, replay_codec.dart, production mathematics/controller/renderer,
shaders, SDK or other evidence. Baseline/replay and oracle collectors must still
traverse and hash their complete existing source graphs, including new imports.

### Implementation and verification contract

1. Preserve every existing baseline/oracle JSON, PNG, manifest, receipt and
   `migration/oracles/reference-source-transitions.json` byte-for-byte. Keep
   `support/reference_source_transition.dart` unchanged: its clock-only changed/
   added allowlists and independent original-fixture anchor are not broadened.
   Bootstrap still materializes its exact pinned original archives, not refreshed
   semantic substitutes. Existing Acceptance items remain verbatim.
2. At the named consumers, replace impossible current-document-versus-historical-
   bytes equality with two separate assertions: retained canonical bytes and
   immutability, plus equality of **every** nonbinding field and validation of
   complete recorded before/after binding maps and derived digests. Do not drop
   metadata/runtime/backend checks, inputs/expected/payload comparisons, image
   readback/variance checks or existing mutation negatives.
3. For both reference manifests, compose retained sources -> recorded clock-after
   using the unchanged clock validator, then clock-after -> current through the
   separate per-task stage(s). Check adjacency of complete maps and final equality
   with freshly collected sources. Do not feed a historical map to the clock
   validator and omit the subsequent current-map validation. Preserve earlier
   integrated stages; each new stage has its own task-specific allowlist, never
   the union of both tasks' production deltas. Either task can run first; shared
   writes use normal serialized integration and merged-candidate revalidation,
   not a new dependency or permission to overwrite a sibling transition.
4. Partition custody at the composition layer, not in the clock validator:
   inventory **every** baseline file, validate the complete original set against
   its unchanged independent anchor, and separately validate exactly bootstrap's
   seven declared archives against the task's pinned Git bytes/hashes plus its
   named new sidecar. Reject unknown additions, missing originals and changed
   bytes. No `original/**`, directory or JSON-wide exclusions. The accessibility
   sidecar lives outside the baseline fixture tree. New transition documents are
   structurally validated metadata, not replacements for historical fixtures.
5. Finalize comparator/helper source before recording maps. Two identical private
   scratch exports must prove all nonbinding fields equal and enumerate complete
   before/after maps for five inventories, two replays, three oracles, and reference
   sources for both manifests. Record base/candidate identities, original fixture
   hashes, per-map exact changed/added/removed sets and task/change reference in
   runtime-read sidecars. Do not embed maps in source files they hash, a sidecar
   checksum in its hashed helper, or a sidecar's own hash inside itself. This
   avoids circular provenance without shrinking collection. Retained worker maps
   precede comparator edits and therefore cannot substitute for these exports.
6. Preserve existing negatives and add cases rejecting changed/added/removed
   unlisted bindings, broken stage adjacency, semantic/metadata drift, altered
   retained bytes, clock-sidecar/anchor mutation, changed/missing archive bytes
   and unknown baseline additions. Reject self-consistent sidecar mutations that
   attempt to authorize unrelated source or fixture changes. Demonstrate the
   source-bound failures before the comparator repair and passing cases after it;
   run all seven migration modules individually, analyze/format changed handwritten
   Dart, verify deterministic transition exports and run `git diff --check`.
7. Run the unchanged mandatory full offline gate with complete persistent stage
   diagnostics. A timeout, isolated passes or a truncated aggregate is not success.
   Keep actual device/browser/native, human-language, production, goal and
   aggregate Rust qualification separate. Report any further out-of-contract
   delta precisely; this supplement grants no blanket evidence-rebinding power.

### Documentation-only validation

Task records are amended through the task CLI, retaining IDs, Acceptance,
Dependencies, ownership, section/rank, resources and all authorization. No source,
fixture, retained candidate or runtime state is edited by this reconciliation.
Only ledger validation, contract-preservation assertions and whitespace checks
are performed here; implementation and full-gate proof remain with the workers.

## ACAD-015 quiet theme and crosshair localization

ACAD-015 records a schema-2 stage in
`migration/oracles/acad-015-source-transitions.json`, based on
`797b4fc69c0755a1ee14bd965e621386100f1252`. Its exact policy permits only:

- `lib/core/theme/app_theme.dart`
- `lib/features/viewer/overlays/auto_pilot_alignment_overlay.dart`
- `lib/l10n/app_localizations.dart`
- `lib/l10n/app_localizations_en.dart`
- `lib/l10n/app_localizations_es.dart`
- `test/migration/support/provenance_transition.dart`

Dark and OLED use their existing `textSecondary`, `border`, `surfaceVariant`
and `surfaceElevated` tokens for the four quiet roles. High contrast is unchanged.
The crosshair uses the generated `autoPilotAlignmentLabel` in English and Spanish,
with the English fallback when localizations are absent. The focused contrast
case checks the four roles and the 4.5:1 body/secondary surface contrast floor;
the overlay widget tests cover Spanish semantics and the English fallback.

### ACAD-015 baseline provenance repair

The retained stages' terminal physical-event map differs from the admitted base
in these ten paths, already changed by `9436d5cd` (shared overlays), `7888bfc6`
(HUD toggle removal) and `8e5d7cd6` (viewer chrome):

- `lib/features/controls/widgets/number_wall_style_controls.dart`
- `lib/features/presets/preset_sheet.dart`
- `lib/features/viewer/chrome/fractal_controls_hud.dart`
- `lib/features/viewer/chrome/fractal_view_controls.dart`
- `lib/features/viewer/chrome/viewer_tools.dart`
- `lib/features/viewer/diagnostics/viewer_debug_report.dart`
- `lib/features/viewer/export/viewer_export_overlay.dart`
- `lib/features/viewer/fractal_viewer_screen.dart`
- `lib/features/viewer/gaussian_moat_map.dart`
- `lib/features/viewer/overlays/viewer_hud.dart`

`migration/oracles/acad-015-baseline-source-transitions.json` records a separate
`ACAD-015-BASELINE` stage with exactly this policy. Its before maps are the
complete terminal maps of the retained stages; its after hashes use Git bytes
at the admitted base, not candidate bytes. Only the physical-event map changes;
all other maps are explicit identities. The ACAD-015 stage begins at these
baseline-after maps and applies only its own six-path policy, not their union.

Both stages retain all eleven complete binding maps, exact delta sets and the
canonical SHA-256 identity of their after maps. Composition consumes adjacent
identity stages before advancing; missing stages, competing successors,
unauthorized deltas and final current-map mismatches still fail. The focused
comparator test covers composition and rejects policy widening or a missing stage.
Retained fixtures, earlier sidecars, PNGs, manifests, custody anchors, collectors
and the independent clock validator stay unchanged. Private repeated exports and
migration checks validate complete current bindings and all nonbinding fields;
this is not a fixture refresh or a hash-only waiver. The worker report records
executed checks; the full offline check remains the runner gate. No device,
production or human-language qualification is claimed.

## MAINT-PRESET-KEYBOARD-01 keyboard access

Issue #2 explicitly extends this held task's source-bound delivery to exactly:

- `lib/features/presets/preset_sheet.dart`
- `test/preset/preset_sheet_keyboard_test.dart`
- `test/migration/support/provenance_transition.dart`
- `test/migration/baseline_source_reconciliation_test.dart`
- `migration/oracles/preset-keyboard-source-transitions.json`
- this document

The implementation and keyboard regression are retained from candidate
`9a5dc735baaaeedbbe87028ccf0fd565d191db8c`. The admitted base is
`059cc9783fe26bd65266c0f8c5cb3b3a244a607a`; its complete collector maps match
all eleven ACAD-015 terminal maps. No baseline-repair stage is needed or authorized.
The retained assembled failure at `/tmp/offline-gate-RTeNCo/flutter-tests.log`
is `Provenance: complete current map mismatch for physical-events`, before
semantic comparison. This failure was reproduced with the retained preset source
on the admitted base, rather than substituting a historical passing result.

The new schema-2 stage is named **MAINT-PRESET-KEYBOARD-01** and references this
section. Its binding allowlist is exactly:

- `lib/features/presets/preset_sheet.dart`
- `test/migration/support/provenance_transition.dart`

Neither ACAD-015 nor any earlier policy is widened. The new sidecar's before maps
are the complete retained terminal maps; after maps replace only collected
occurrences of these two paths with final on-disk SHA-256 values. The preset changes
physical-events; the helper changes param-interpolation, physical-events,
precision-replay, randomization, reference and state-replay. All five inventory
maps are explicit identities at the terminal cursor. No paths are added or
removed; uncollected keyboard-test, focused-test and documentation paths do not
appear in the maps. Exact sorted delta sets and canonical after-map identity are
recorded, not an allowed superset. The existing adjacency algorithm is unchanged:
terminal identities compose, while competing identities remain ambiguous.

Finalize the helper before constructing this sidecar. Bootstrap claims by copying
the retained terminal maps and replacing only collected allowed-path hashes;
these provisional claims are not acceptance evidence. Unchanged collectors and
comparators must independently prove complete current-map equality and every
nonbinding field before `MIGRATION_TRANSITION_OUT` records any observation. Two
private validated exports must each contain exactly twelve expected documents,
match the sidecar's after maps (both manifests use reference), and agree byte for
byte. Any additional source delta, import or semantic mismatch stops this bounded
reconciliation; it does not expand the allowlist.

The original regression checks Tab/Shift-Tab traversal, visible focus,
Enter/Space single application and return to Viewer, nested rename/delete without
application, pointer actions, English/Spanish, 320px width and 3x text. Rename's
controller lives through the dialog exit transition. Focused source-stage tests
add self-consistent policy/delta/removal/gap mutations, missing/duplicate/unknown
stages, wrong identities/anchors and competing terminal identities. Existing
semantic/runtime/metadata, image, independent clock and archive-custody negatives
remain mandatory, as do all preset tests, individual migration modules and the
unchanged full offline gate on the final assembled candidate.

Historical fixtures, images, manifests, receipts, seven original archives, hash
tables, earlier sidecars and both lockfiles remain immutable. In particular the
physical oracle remains SHA-256
`ec46427fff067ec864540506827ebd47ae6d083b176ee945b80ddd8f7d6a95ec` and the
independently validated clock sidecar remains
`3f0ef636f99c644a924df893ef673977f95c4a0558a5fdff29d4d6b8668e65a5`.
This is neither an oracle refresh nor automatic admission of future changes;
Android, browser/hardware qualification and production publication are excluded.


## History commit replay

**HISTORY-COMMIT-REPLAY-01**, admitted base
`08f3040d990d5df04de6c3f3834ccf30e592235a`, deepens the existing provider/replay
commit seam. Its dedicated schema-2 stage is
`migration/oracles/history-commit-replay-source-transitions.json`; its exact sorted
allowlist is:

- `lib/features/history/history_provider.dart`
- `lib/features/history/history_replay.dart`
- `lib/features/viewer/fractal_viewer_screen.dart`
- `test/migration/support/provenance_transition.dart`

The first three paths are collected recursively by the unchanged physical-events
collector; the helper is already collected. `history.dart` and `history_sheet.dart`
are uncollected and must not be inserted. `navigation/viewer_history.dart` stays
unchanged. Documentation and tests are outside these maps. No additions/removals
are authorized. All eleven before maps copy the retained keyboard-stage terminal
maps; after maps change only collected occurrences of the four allowed paths.
Five inventory maps remain explicit identities. Exact delta sets and canonical
full after-bundle identity are required. Earlier sidecars, original archives,
fixtures/images/manifests/receipts/hash anchors and both locks remain immutable.

### Successor ordering decision

The historical preset-keyboard report above describes the then-current per-map
ordering. A second successor exposes its ambiguity: several individually
unchanged inventory maps cannot distinguish those stages. This bounded amendment
orders **complete eleven-map bundles**, without changing schema or any prior
policy/sidecar. First validate every selected stage, unique tasks, complete keys,
exact deltas/identity and existing anchors. Reject any stage identical across its
entire bundle. Find exactly one before bundle not produced by another selected
stage, then consume exactly one adjacent complete-bundle successor at each step.
Never break ties using filename, task name or supplied order. Reject branches,
gaps, cycles, disconnected/unused stages, competing successors and zero/multiple
roots. Track visited full bundles as well: a rooted chain such as
`A -> B -> C -> B` must fail even though each stage is consumed only once.
Only then can per-map identities compose in that uniquely ordered chain.
For the requested map, the first before must equal the caller's supplied map,
every edge must agree and the terminal after must equal fresh collection.
Reference still starts at the unchanged independent clock validator's after map.
Semantic/metadata comparison, current digest and custody guards are unchanged.

Focused reconciliation tests compose retained keyboard plus history stages for
all eleven maps in reversed/permuted order. They reject real full-bundle
branch/no-op/gap/cycle and missing/duplicate stages, plus self-consistent policy,
anchor, unlisted-path/removal and identity mutations. Original competing-identity
negatives and keyboard base/two-path policy/historical deltas remain. Intermediate
helper bindings stay historical; only the final history stage is compared with
current helper bytes.

Finalize handwritten source/helper before making provisional claims from retained
terminal maps. Those claims alone are not evidence: unchanged collectors and the
amended guard-preserving comparator must validate them before the existing
post-validation observer exports anything. Run the seven migration modules
individually, then two exports with `MIGRATION_TRANSITION_OUT` in private external
scratch directories. Each export must contain exactly twelve expected documents,
whose current maps equal this stage's after maps (both manifests use reference).
Require byte-for-byte `diff -ru` equality. Run the mandatory unskipped offline gate
and retain actual commands/exits, full logs and lock/evidence readback. No result
here claims live platform qualification. Visual-richness issue #9's separate
isolated worktree/contract is not edited; any later base integration must retain
both stages and their guards rather than widen this history-only policy.

### Executed local evidence (run_id=9b7fcf3b)

- The initial composed provider regression failed against eager cursor movement;
  the final focused history/Number Walls/viewer command passed **288 tests**.
  A modal-pop regression also failed before the route-current guard and passed
  after it, proving cancellation before sheet exit animation finishes.
- Focused reconciliation checks passed, including policy-valid full-bundle
  branch/cycle negatives. All seven required migration modules ran individually
  with exit 0; the final candidate also passed them through both exports.
- Both final validated exports contained exactly all twelve expected documents;
  complete current maps matched this stage's after maps, with both manifests
  mapped to reference. Map readback and `diff -ru` each exited 0.
- The exact root AGENTS offline gate, under the provisioned SDK/cache and private
  mode-0700 TMPDIR, exited **0**, terminal verdict `passed`, `failed_stage: null`.
  Pub-get, Cargo fmt/clippy/test, Flutter analyze/test, Python and Bats all exited
  0; no families were bypassed. Flutter passed 3541 tests (9 existing skips),
  Python passed 644 tests plus 204 subtests (1 existing skip), Bats passed 34.
- Final lock readback and `git diff --check` passed. Unchanged earlier evidence,
  controller, viewer history hook and Number Walls ingress assertions were
  retained. Full local logs and the validated exports are in the excluded run
  artifacts; no browser/device/hardware qualification or screenshot is claimed.

### Independent review correction (round 1)

A policy-valid rooted cycle (`A -> B -> C -> B`) initially passed the new
ordering comparator. A focused regression reproduced that acceptance (exit 1:
expected `StateError`, returned normally). The comparator now rejects any
revisited complete bundle, including the terminal bundle. The regression checks
all eleven maps in two input orders; the original rootless-cycle and competing
identity checks remain unchanged.

After this bounded helper correction, reconciliation passed all six tests and
focused analysis reported no issues (both exit 0). Two fresh validated exports
ran all seven migration modules (10 plus 12 tests per export, all exit 0),
contained exactly twelve expected documents, matched every final stage after
map, and were byte-identical (`diff -ru` exit 0). Only this task's sidecar helper
hashes and candidate identity were updated; prior sidecars and both lockfiles
remain unchanged. Complete review logs and exports are in the excluded run
artifacts. The full offline gate above predates this review correction; it was
not rerun during review. Current-head CI remains the merge authority, and no
live platform qualification is claimed.
