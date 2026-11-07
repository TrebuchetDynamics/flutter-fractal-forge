# Burning Ship software-readback prerequisite

## Evidence and contract boundary

RUST-M0-IMAGES attempt 1 was blocked, not completed. Read in place:

- `.git/autowork-execution/slot-data/RUST-M0-IMAGES/attempt-1/report.json`
  and `contract.txt` in the repository common Git directory.
- `/var/tmp/aw-1000-48137133-2/burning_ship_readback_test.dart` and
  `burning-ship-isolated.log`: the independent existing catalog draw/readback
  seam produced exactly 65,536 opaque black pixels at 256×256, time zero,
  unmodified `burning_ship` defaults. It did not use the candidate capture helper.
- The report records ten other reference states and seven existing catalog
  health cases passing, Burning Ship image health failing, and no complete
  manifest, artifact promotion or commit. The full gate and two completed
  reference captures were not delivered.

Reported source revision: `8345b8e2e296211c2d596eaeb4e451793e16d742`.
Reported registered shader SHA-256:
`3056d5a7b226ae13f049a8da9c6f49c073a2589a85b25ff212904f44ba8db7a3`.
The worker's pinned environment preflight and focused analysis passed; those
results are not a renderer or full-gate pass. Scratch paths are historical local
evidence, not portable artifacts or required coordinator receipts.

Sources: [accepted migration invariant and baseline](../planning/refactor-plan.md#flutter-shell-and-rust-engine-migration),
[rendering interface](../engineering/spec.md#rendering-interface), and
[failure behavior](../engineering/spec.md#failure-behavior).
The accepted baseline names this actual module/default; substitution or accepting
black output would hide a failure. A pre-existing implementation defect can be
repaired without changing the intended formula or introducing a new product.
Keep that repair in RUST-M0-SHIP-REPAIR, not in the capture task, whose original
Scope, Acceptance, Checks, Touches and production-change prohibition stay intact.
RUST-M0-IMAGES consumes the repaired renderer and refreshed source-bound inventory;
its added dependency is a real producer prerequisite, not overlap scheduling.

## Bounded implementation approach

1. Reproduce the reported failure with a new standalone
   `test/modules/burning_ship_default_render_health_test.dart`, using the real
   registry descriptor, registered FragmentProgram, uniform setter and existing
   catalog readback seam. Keep the shader alive through readback. Retain exact
   command, source, backend, dimensions, state, alpha and pixel-health evidence.
   No dependency on the unfinished image harness or its uncommitted files.
2. Diagnose the registered
   `shaders/escape_time_family/families/burning_ship/parameter_plane/burning_ship_gpu.frag`.
   Source inspection identifies `z = vec2(0.0)` followed by `cpowReal(abs(z), power)`;
   `cpowReal` clamps radius but still evaluates `atan(z.y, z.x)` at the origin.
   Undefined zero-angle evaluation is a hypothesis, not an established root cause.
   Confirm or reject it experimentally before editing. If confirmed, use the
   smallest mathematically equivalent zero/power handling, accounting for the
   derivative's `power - 1.0` exponent as well as the ordinary recurrence.
   Preserve nonzero behavior, fractional/integer power semantics, palette modes,
   pan orientation, default values, uniform ABI and module identity. No alternate
   shader, CPU fallback, changed view or backend substitution.
3. Require failing-before/passing-after real default readback and an independent
   recurrence/classification check at selected interior and escaping samples.
   Include representative integer/fractional powers and normal-map mode so a
   default-only shortcut cannot disable existing controls. Keep classification
   checks separate from palette equality and from mathematical qualification.
   Run existing pan, consolidation, degree and CPU regressions unchanged.
4. A shader edit changes hashes in all five baseline inventory documents:
   `modules.json`, `parameters.json`, `presets.json`, `capabilities.json`, and
   `shader-contracts.json`. Use the existing MIGRATION_BASELINE_OUT exporter twice
   into private empty scratch directories, compare, review the actual source/hash
   diff and explicitly promote. Descriptor/defaults/capability payloads and binding
   layouts must stay unchanged; only justified shader-source/provenance hashes
   change. Do not hand-edit hashes or refresh unrelated replay expectations.
5. Record the actual diagnosis, before/after results and limitations here, run the
   focused commands and unchanged pinned offline gate in the task Checks, and
   preserve pubspec.lock. A missing tool, timeout, SDK-only defect or a repair
   requiring formula/default/ABI changes remains a precise blocker; this contract
   supplies no authority for those changes or SDK/host modification.

## Capture continuation

After the repair lands, RUST-M0-IMAGES must independently rerun all its original
checks, finish both captures and measured variance, and explicitly promote the
complete manifest and PNGs. Preserve the idle uncommitted candidate in
`.worktrees/autowork-RUST-M0-IMAGES`; adopting it requires a fresh activity check.
Do not close either task or qualify RUST-ENGINE-001 from this planning document.
Software readback is not device/browser, hardware-GPU or mathematical acceptance.

Maintainer verification: repository/source/report inspection only; no Flutter
checks were executed by the maintainer. This document is a repair plan, not proof
that the hypothesis or the proposed repair passes.
