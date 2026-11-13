# Inert whole-session adapter

## Boundary and use

`RustStateSessionAdapter` is an implemented diagnostic facade, not a production
route or an owner switch. It follows the
[inert adapter plan](RUST-PLAN-10.md#inert-whole-session-adapter),
[planned engine boundary](../engineering/spec.md#planned-rust-engine-boundary),
[ADR 0005](../adr/0005-rust-owns-all-mathematical-domain-logic.md) and
[ADR 0006](../adr/0006-native-demonstration-performance-is-target-specific.md).
The existing neutral probe and production controllers, stores, renderer and startup
remain unchanged. No timer, domain calculation, renderer binding or controller
mirror is added.

Creation defaults to `enabled: false`, independently of `RUST_CORE`. Both real Web
and an injected Web refusal return null before invoking a loader. Native callers
must explicitly supply a loader. There is no implicit catalog or work service.
The native factory lives in
[`rust_state_session_backend_native.dart`](../../lib/core/services/engine/rust_state_session_backend_native.dart).
The composition owner must first initialize the existing bridge, create one shared
`StateWorkService`, and supply that service and the four original catalog envelopes
to `createRustStateSessionBackend`. The factory creates exactly one owned
`StateSession`; Rust validates the envelopes. For example, after composition setup:

```dart
final adapter = await RustStateSessionAdapter.create(
  enabled: true,
  loader: () async => createRustStateSessionBackend(
    service: sharedService,
    modules: modulesEnvelope,
    parameters: parametersEnvelope,
    presets: presetsEnvelope,
    capabilities: capabilitiesEnvelope,
    moduleId: 'julia',
  ),
);
```

The backend borrows the service. Adapter disposal cancels/releases its tickets,
releases timeline token handles, shuts down its Session and disposes that Session.
It never closes or disposes the shared service. The composition owner must keep
the service alive until all borrowing adapters have closed.

## Ordered admission and reads

`apply`, `refresh`, `schedule` and `poll` share one admission slot. A second call
returns `SessionAdmission.busy` before any backend call. There is no hidden queue,
retry, input coalescing or input consumption on Busy. Callers must retain raw
incremental events and retry them in their original order. This awaitable seam is
not lossless production gesture capture. Other rejections do not promise that a
native mutation was never committed: a transport/detachment failure can occur after
commit. Read/reconcile before deciding whether to retry those inputs.

Typed `SessionCommand` constructors cover editor params, module selection,
preset/load/view, effects, transparency and unsupported-operation rejection.
Decoded history and deep-link-shaped loads use this same entry without live stores.
`SessionEvent` carries an exact BigInt sequence, optional source clock, consumed bit
and typed `SessionInput` (wheel, pointer, key, focus, pump, wall or disposal).
`SessionAction` also forwards seeded randomization, parameter timeline start/tick/
cancel, morph tick/cancel and wall undo. No clock is synthesized. Timeline tokens
are borrowed by callers from the adapter; callers must not close these owned handles.

`SessionValue.number` preserves the original decimal string and is distinct from
`SessionValue.text`, boolean and floating-point values. Revisions, Session identity,
physical generations and trajectory generations remain BigInt. Trajectory settings,
view records and bridge enums remain typed; no conversion through JSON or double
is used for exact values.

Only matching Session identity and nondecreasing revision/trajectory generation can
replace `checkpoint`. Equal-revision reads are valid. Frames must also match their
Session and settings generation. The native backend omits obsolete cached frames;
the facade refuses malformed detached frame identity/generation. Wrong-owner,
older, superseded and post-close replies do not publish. Errors retain last-good
presentation state. Late reply handles are released. Replacement, cancellation and
disposal release each owned handle once, including a ticket returned after close.

## Scheduled work

`SessionWork.wall(command)` and `SessionWork.trajectory()` use only the borrowed
service's submit/replace methods. `poll` reads cached ticket status. `cancelWork`
invalidates an awaited poll and closes its ticket without admitting another
mutation. Replacement uses the existing service ticket as its replacement operand.
There is no begin/advance/drain path in this backend. Ordinary batch/timeline APIs
retain Rust's deferred-operation refusal for expensive wall inputs: use scheduled
wall ingress instead. Scheduled wall randomization is still pending.

A Finished phase is not prime certification. Inspect `wallStatus` or
`SessionWorkRead.verifiedPrime`; composite, invalid and unverified terminal results
are not prime success. Failed/error ticket replies do not replace last-good state.

External diagnostic bypasses remain available: direct `StateSession.applyBatch`,
`beginNumberWall`/`advanceNumberWall`/`cancelNumberWall`, their async variants,
`beginTrajectoryAsync`/`advanceTrajectoryAsync`/`cancelTrajectoryAsync`, and direct
core/replay entry points. Other callers can construct other services. This facade
therefore makes no process-wide execution-limit or full-migration claim.

## Detached compatibility checkpoint

`SessionCheckpoint.data` is a recursively immutable read tree. Native detachment
copies all supported snapshot fields: module ID, exact typed params, view,
trajectory settings, transparency, rotation lock, adaptive zoom, all effects,
morph progress/previous module, wall undo availability, wall/trajectory pending
and terminal status, and available frames. Wall frames retain exact decimal grid
strings, params, modulus, sequence and support bounds. Trajectory frames retain
identity/generation, module, typed settings, points, bounds and cache-hit status.
Physical generation is also available on native replies and in the native read tree.
Opaque snapshot/frame/settings/value handles are released after detachment.

The checkpoint stays usable after adapter close. It is not FractalPreset JSON,
a second mutable engine, a persistence format, a restore API or proof of rollback.
`hiddenOwners` identifies pending service/request ownership, parameter/morph tokens,
Session-owned physical/pump state, parameter target/progress and randomization undo
state. Some markers are conservative because these hidden states are not exposed
by the generated snapshot API. A retained checkpoint records that limitation even
after its original owner closes. Before a future owner switch, quiesce these owners
or retain the original Session. No switch, restore or saved-format migration occurs.

## Verification and remaining proof

This retry reuses the task-scoped adapter, backend and eight detached test cases
from candidate `92493bdc8c38f589b027a66976b847db283dc0be`. Inspection found no
required implementation change against baseline
`d5daea080c3c3bbea7ebc99dc146c0c830a2465c`. It reuses the generated typed bridge
and shared work-service APIs without adding dependencies or production consumers.

All checks below were rerun in this retry with the provisioned
Flutter 3.47.9/Dart 3.13.7 and Rust 1.95.0. In particular, the Rust script and paired
Web builds reached passing results, rather than relying on earlier report claims:

- The three required migration test files: 13 tests passed, including eight detached
  adapter cases. They cover default-off/Web, Busy/retry, ordered typed inputs,
  unsupported errors, stale/equal reads, exact immutable retention, service routes,
  token lifecycle and delayed responses/tickets.
- Focused engine/test analysis: no issues.
- `scripts/ci/rust-check.sh`: formatting, warning-denying clippy and workspace tests.
- Both root debug Web builds (`RUST_CORE=false` and `true`) passed. The existing FRB
  Wasm dry-run warning remains; these are JavaScript debug builds, not Wasm proof.
- Protected production/generated/native paths are unchanged; whitespace and this
  note's local-link/readback checks passed.

These tests inject detached backend values, never fake native opaque objects.
Native forwarding assertions are unexecuted here. The root Web builds do not make
this unused adapter a production consumer. Full check: runner gate.

The [remaining proof](RUST-PLAN-10.md#remaining-proof-and-continuation) stays intact:
full module admission, scheduled wall randomization, lossless capture/external
ticks, snapshot-only legacy rendering, production consumers, quiesced rollback,
native fixture execution and platform/browser/hardware/performance qualification
remain pending. Original replay, exact-value, last-good and default-off gates are
not weakened. This task does not claim full M2 or native performance acceptance.
