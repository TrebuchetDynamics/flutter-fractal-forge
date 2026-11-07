//! Public typed transport contract, using original envelopes and direct core jobs.
use fractal_bridge::api::{
    StateCamera, StateCommand, StateNumberWallGuard, StateNumberWallProgress,
    StateNumberWallRequest, StateNumberWallSequence, StateNumberWallStatus as Status, StateSession,
    StateSnapshot, StateValue, StateView,
};
use fractal_core::{
    catalog_baseline::{CatalogBaseline, ParameterValue},
    normalization::{RawScalar, ViewInput},
    session::{CameraInput, Command, RequestGuard, RequestProgress, Session},
};
use std::{collections::HashMap, sync::Arc};

const MODULES: &str = include_str!("../../../../migration/baseline/modules.json");
const PARAMETERS: &str = include_str!("../../../../migration/baseline/parameters.json");
const PRESETS: &str = include_str!("../../../../migration/baseline/presets.json");
const CAPABILITIES: &str = include_str!("../../../../migration/baseline/capabilities.json");

struct Transport {
    normal: bool,
    inner: StateSession,
}

impl std::ops::Deref for Transport {
    type Target = StateSession;
    fn deref(&self) -> &Self::Target {
        &self.inner
    }
}

// Reuse every existing public-seam assertion for both entry points.
impl Transport {
    fn snapshot(&self) -> Result<StateSnapshot, String> {
        if self.normal {
            self.inner.snapshot_async()
        } else {
            self.inner.snapshot()
        }
    }
    fn shutdown(&self) -> Result<(), String> {
        if self.normal {
            self.inner.shutdown_async()
        } else {
            self.inner.shutdown()
        }
    }
    fn begin_number_wall(
        &self,
        id: u64,
        rev: u64,
        command: StateCommand,
        guard: &StateNumberWallGuard,
        budget: u32,
    ) -> Result<Option<StateNumberWallRequest>, String> {
        if self.normal {
            self.inner
                .begin_number_wall_async(id, rev, command, guard, budget)
        } else {
            self.inner
                .begin_number_wall(id, rev, command, guard, budget)
        }
    }
    fn advance_number_wall(
        &self,
        id: u64,
        rev: u64,
        request: &StateNumberWallRequest,
        work: u32,
    ) -> Result<StateNumberWallProgress, String> {
        if self.normal {
            self.inner.advance_number_wall_async(id, rev, request, work)
        } else {
            self.inner.advance_number_wall(id, rev, request, work)
        }
    }
    fn cancel_number_wall(
        &self,
        id: u64,
        rev: u64,
        request: &StateNumberWallRequest,
    ) -> Result<StateNumberWallProgress, String> {
        if self.normal {
            self.inner.cancel_number_wall_async(id, rev, request)
        } else {
            self.inner.cancel_number_wall(id, rev, request)
        }
    }
}

fn session(normal: bool) -> Transport {
    Transport {
        normal,
        inner: StateSession::new(
            MODULES.into(),
            PARAMETERS.into(),
            PRESETS.into(),
            CAPABILITIES.into(),
            "mandelbrot".into(),
        )
        .unwrap(),
    }
}
fn camera() -> StateCamera {
    StateCamera {
        view: StateView {
            zoom: 2.0,
            pan_x: 0.5,
            pan_y: -0.5,
            rot_x: 0.1,
            rot_y: 0.2,
            rot_z: 0.3,
        },
        has_trajectory: false,
    }
}
fn load(prime: &str) -> StateCommand {
    StateCommand::load(
        Some("number_wall".into()),
        HashMap::from([
            ("prime".into(), StateValue::from_text(prime.into())),
            ("rows".into(), StateValue::from_number("4".into()).unwrap()),
            (
                "columns".into(),
                StateValue::from_number("16".into()).unwrap(),
            ),
            (
                "columnStart".into(),
                StateValue::from_number("3".into()).unwrap(),
            ),
            ("source".into(), StateValue::from_text("rook".into())),
        ]),
        camera(),
        true,
    )
}
fn begin(
    s: &Transport,
    command: StateCommand,
    guard: &StateNumberWallGuard,
) -> StateNumberWallRequest {
    let before = s.snapshot().unwrap();
    s.begin_number_wall(
        before.session_id(),
        before.revision(),
        command,
        guard,
        100_000,
    )
    .unwrap()
    .unwrap()
}
fn step(s: &Transport, request: &StateNumberWallRequest, work: u32) -> StateNumberWallProgress {
    let before = s.snapshot().unwrap();
    s.advance_number_wall(before.session_id(), before.revision(), request, work)
        .unwrap()
}
fn finish(s: &Transport, request: &StateNumberWallRequest) -> StateNumberWallProgress {
    for _ in 0..100_000 {
        let progress = step(s, request, 1024);
        if !progress.is_pending() {
            return progress;
        }
    }
    panic!("bounded request did not terminate");
}
fn apply(s: &Transport, commands: Vec<StateCommand>) -> StateSnapshot {
    let before = s.snapshot().unwrap();
    s.apply_batch(before.session_id(), before.revision(), commands)
        .unwrap()
}
fn params(snapshot: &StateSnapshot) -> HashMap<String, String> {
    snapshot
        .params()
        .into_iter()
        .map(|(k, v)| (k, format!("{v:?}")))
        .collect()
}

#[test]
fn each_step_and_complete_exact_frame_match_direct_core() {
    for normal in [false, true] {
        check_each_step_and_complete_exact_frame_match_direct_core(normal);
    }
}
fn check_each_step_and_complete_exact_frame_match_direct_core(normal: bool) {
    let s = session(normal);
    let before = s.snapshot().unwrap();
    let mut core = Session::new(
        Arc::new(CatalogBaseline::from_jsons(MODULES, PARAMETERS, PRESETS, CAPABILITIES).unwrap()),
        before.session_id(),
        "mandelbrot",
    )
    .unwrap();
    let command = Command::Load {
        module_id: Some("number_wall".into()),
        params: [
            ("prime", RawScalar::Text("00097".into())),
            ("rows", RawScalar::Number(4.into())),
            ("columns", RawScalar::Number(16.into())),
            ("columnStart", RawScalar::Number(3.into())),
            ("source", RawScalar::Text("rook".into())),
        ]
        .into_iter()
        .map(|(k, v)| (k.into(), v))
        .collect(),
        camera: CameraInput::from(ViewInput {
            zoom: 2.0,
            pan: [0.5, -0.5],
            rotation: [0.1, 0.2, 0.3],
        }),
        transparent: true,
    };
    let token = core
        .begin_number_wall(
            before.session_id(),
            0,
            &command,
            RequestGuard::new(true),
            100_000,
        )
        .unwrap()
        .unwrap();
    let request = begin(&s, load("00097"), &StateNumberWallGuard::new(true));
    let staged = s.snapshot().unwrap();
    assert!(staged.number_wall_pending());
    assert_eq!(staged.number_wall_status(), None);
    assert!(staged.number_wall_frame().is_none());
    assert_eq!(params(&staged), params(&before));
    assert_eq!(staged.module_id(), "mandelbrot");
    for work in [0, 1].into_iter().chain(std::iter::repeat_n(1024, 100_000)) {
        let expected = core
            .advance_number_wall(
                before.session_id(),
                core.snapshot().revision(),
                token,
                work as usize,
            )
            .unwrap();
        let progress = step(&s, &request, work);
        let snapshot = progress.snapshot();
        assert_eq!(snapshot.revision(), core.snapshot().revision());
        assert_eq!(
            snapshot.number_wall_pending(),
            core.snapshot().number_wall_pending().is_some()
        );
        assert_eq!(progress.is_pending(), expected == RequestProgress::Pending);
        if expected == RequestProgress::Pending {
            continue;
        }
        assert_eq!(progress.status(), Some(Status::VerifiedPrime));
        assert_eq!(snapshot.number_wall_status(), progress.status());
        assert_eq!(snapshot.module_id(), "number_wall");
        assert_eq!(snapshot.view().zoom, 2.0);
        assert!(snapshot.transparent_background());
        let frame = snapshot.number_wall_frame().unwrap();
        let direct = core.snapshot();
        let grid = direct.number_wall_frame().unwrap().grid();
        assert_eq!(frame.sequence(), StateNumberWallSequence::Rook);
        assert_eq!(frame.modulus(), grid.modulus());
        assert_eq!(frame.row_count(), grid.row_count() as u32);
        assert_eq!(frame.column_count(), grid.column_count() as u32);
        assert_eq!(frame.column_start(), grid.column_start());
        assert_eq!((frame.support_start(), frame.support_end()), grid.support());
        assert_eq!(frame.values(), grid.values());
        for (id, value) in frame.params() {
            assert_eq!(
                format!("{value:?}"),
                format!("{:?}", snapshot.params()[&id])
            );
        }
        assert_eq!(snapshot.params()["prime"].text().as_deref(), Some("97"));
        assert_eq!(direct.params()["prime"], ParameterValue::Text("97".into()));
        let mut detached = frame.values();
        detached[0][0] = "mutated".into();
        assert_eq!(frame.values(), grid.values());
        let mut detached_params = frame.params();
        detached_params.clear();
        assert!(!frame.params().is_empty());
        assert!(staged.number_wall_pending());
        assert!(staged.number_wall_frame().is_none());
        return;
    }
    panic!("direct and bridge jobs did not terminate");
}

#[test]
fn uncertified_results_retain_last_good_frame_and_settings() {
    for normal in [false, true] {
        check_uncertified_results_retain_last_good_frame_and_settings(normal);
    }
}
fn check_uncertified_results_retain_last_good_frame_and_settings(normal: bool) {
    let s = session(normal);
    let request = begin(&s, load("97"), &StateNumberWallGuard::new(true));
    let good = finish(&s, &request).snapshot();
    let frame = good.number_wall_frame().unwrap();
    for (prime, expected, budget) in [
        ("561", Status::Composite, 100_000),
        ("1e2", Status::Invalid, 100_000),
        (
            "170141183460469231731687303715884105727",
            Status::Unverified,
            0,
        ),
    ] {
        let before = s.snapshot().unwrap();
        let request = s
            .begin_number_wall(
                before.session_id(),
                before.revision(),
                StateCommand::number_wall_prime(prime.into()),
                &StateNumberWallGuard::new(true),
                budget,
            )
            .unwrap()
            .unwrap();
        let progress = finish(&s, &request);
        assert_eq!(progress.status(), Some(expected));
        let after = progress.snapshot();
        assert_eq!(after.number_wall_status(), Some(expected));
        assert_eq!(params(&after), params(&good));
        assert_eq!(after.number_wall_frame().unwrap().values(), frame.values());
        assert_eq!(after.number_wall_frame().unwrap().modulus(), "97");
        assert_eq!(after.view().pan_x, good.view().pan_x);
        assert!(!after.number_wall_pending());
    }
}

#[test]
fn inactive_revoke_supersede_edit_navigation_and_cancel_preserve_ownership() {
    for normal in [false, true] {
        check_inactive_revoke_supersede_edit_navigation_and_cancel_preserve_ownership(normal);
    }
}
fn check_inactive_revoke_supersede_edit_navigation_and_cancel_preserve_ownership(normal: bool) {
    let s = session(normal);
    let inactive = StateNumberWallGuard::new(false);
    assert!(!inactive.is_active());
    let before = s.snapshot().unwrap();
    assert!(
        s.begin_number_wall(before.session_id(), 0, load("97"), &inactive, 1)
            .unwrap()
            .is_none()
    );
    assert_eq!(s.snapshot().unwrap().revision(), 0);
    let guard = StateNumberWallGuard::new(true);
    let old = begin(&s, load("97"), &guard);
    assert!(step(&s, &old, 1).is_pending());
    guard.revoke();
    guard.revoke();
    assert!(!guard.is_active());
    let revoked = step(&s, &old, 0);
    assert_eq!(revoked.status(), Some(Status::Cancelled));
    assert!(!revoked.snapshot().number_wall_pending());
    let superseded_guard = StateNumberWallGuard::new(true);
    let superseded = begin(&s, load("103"), &superseded_guard);
    assert!(step(&s, &superseded, 1).is_pending());
    let successor = begin(&s, load("101"), &StateNumberWallGuard::new(true));
    superseded_guard.revoke();
    let pending = s.snapshot().unwrap();
    assert!(
        s.begin_number_wall(
            pending.session_id(),
            pending.revision(),
            load("107"),
            &superseded_guard,
            1,
        )
        .unwrap()
        .is_none()
    );
    assert_eq!(
        s.cancel_number_wall(pending.session_id(), pending.revision(), &superseded)
            .unwrap()
            .status(),
        Some(Status::Cancelled)
    );
    assert_eq!(step(&s, &superseded, 0).status(), Some(Status::Cancelled));
    assert_eq!(s.snapshot().unwrap().revision(), pending.revision());
    assert!(s.snapshot().unwrap().number_wall_pending());
    assert_eq!(finish(&s, &successor).status(), Some(Status::VerifiedPrime));
    let good = s.snapshot().unwrap();
    for edit in [
        StateCommand::transparent(false),
        StateCommand::select_module("julia".into(), false, HashMap::new()),
    ] {
        let request = begin(&s, load("103"), &StateNumberWallGuard::new(true));
        let after = apply(&s, vec![edit]);
        assert!(!after.number_wall_pending());
        assert_eq!(step(&s, &request, 0).status(), Some(Status::Cancelled));
        assert_eq!(s.snapshot().unwrap().revision(), after.revision());
    }
    let request = begin(&s, load("107"), &StateNumberWallGuard::new(true));
    let before = s.snapshot().unwrap();
    let cancelled = s
        .cancel_number_wall(before.session_id(), before.revision(), &request)
        .unwrap();
    assert_eq!(cancelled.status(), Some(Status::Cancelled));
    assert_eq!(cancelled.snapshot().revision(), before.revision() + 1);
    assert_eq!(
        cancelled.snapshot().number_wall_frame().unwrap().values(),
        good.number_wall_frame().unwrap().values()
    );
    // Immediate begin still consumes a fresh command but allocates no request.
    let before = s.snapshot().unwrap();
    assert!(
        s.begin_number_wall(
            before.session_id(),
            before.revision(),
            StateCommand::zoom(3.0),
            &StateNumberWallGuard::new(true),
            1
        )
        .unwrap()
        .is_none()
    );
    assert_eq!(s.snapshot().unwrap().view().zoom, 3.0);
}

#[test]
fn normal_calls_check_revision_and_close_at_execution_in_channel_order() {
    use std::{sync::mpsc::channel, thread};

    let s = session(true);
    let request = begin(&s, load("97"), &StateNumberWallGuard::new(true));
    let retained = finish(&s, &request).snapshot();
    let frame = retained.number_wall_frame().unwrap();
    let values = frame.values();
    let guard = StateNumberWallGuard::new(true);
    let old = begin(&s, load("101"), &guard);
    let captured = s.snapshot().unwrap();
    thread::scope(|scope| {
        let (ready_tx, ready_rx) = channel();
        let (run_tx, run_rx) = channel();
        let (s, captured, guard, old) = (&s, &captured, &guard, &old);
        let worker = scope.spawn(move || {
            ready_tx.send(()).unwrap();
            run_rx.recv().unwrap();
            let id = captured.session_id();
            let rev = captured.revision();
            assert_eq!(
                s.begin_number_wall(id, rev, load("107"), guard, 1)
                    .unwrap_err(),
                "StaleRevision"
            );
            assert_eq!(
                s.advance_number_wall(id, rev, old, 1).unwrap_err(),
                "StaleRevision"
            );
            assert_eq!(
                s.cancel_number_wall(id, rev, old).unwrap_err(),
                "StaleRevision"
            );
            let current = s.snapshot().unwrap();
            let cancelled = s
                .advance_number_wall(id, current.revision(), old, 0)
                .unwrap();
            assert_eq!(cancelled.status(), Some(Status::Cancelled));
            assert_eq!(cancelled.snapshot().revision(), current.revision());
            assert!(cancelled.snapshot().number_wall_pending());
            ready_tx.send(()).unwrap();
            run_rx.recv().unwrap();
            assert!(s.snapshot().unwrap_err().contains("session is closed"));
            assert!(
                s.begin_number_wall(id, current.revision(), load("109"), guard, 1)
                    .unwrap_err()
                    .contains("session is closed")
            );
            assert!(
                s.advance_number_wall(id, current.revision(), old, 0)
                    .unwrap_err()
                    .contains("session is closed")
            );
            assert!(
                s.cancel_number_wall(id, current.revision(), old)
                    .unwrap_err()
                    .contains("session is closed")
            );
            s.shutdown().unwrap();
        });
        ready_rx.recv().unwrap();
        let successor = begin(s, load("103"), &StateNumberWallGuard::new(true));
        guard.revoke();
        run_tx.send(()).unwrap();
        ready_rx.recv().unwrap();
        // The worker's step completed before close; its detached result survived.
        s.shutdown().unwrap();
        run_tx.send(()).unwrap();
        worker.join().unwrap();
        assert!(
            s.advance_number_wall_async(captured.session_id(), 0, &successor, 0)
                .is_err()
        );
    });
    assert_eq!(frame.values(), values);
    assert_eq!(retained.number_wall_frame().unwrap().values(), values);
    assert_eq!(frame.modulus(), "97");
}

#[test]
fn identity_revision_atomic_rejection_and_closed_lifecycle() {
    for normal in [false, true] {
        check_identity_revision_atomic_rejection_and_closed_lifecycle(normal);
    }
}
fn check_identity_revision_atomic_rejection_and_closed_lifecycle(normal: bool) {
    let s = session(normal);
    let other = session(normal);
    let foreign = begin(&other, load("103"), &StateNumberWallGuard::new(true));
    let request = begin(&s, load("97"), &StateNumberWallGuard::new(true));
    let before = s.snapshot().unwrap();
    for (id, rev, error) in [
        (
            other.snapshot().unwrap().session_id(),
            before.revision(),
            "WrongSession",
        ),
        (before.session_id(), 0, "StaleRevision"),
    ] {
        assert_eq!(
            s.begin_number_wall(id, rev, load("101"), &StateNumberWallGuard::new(true), 1)
                .unwrap_err(),
            error
        );
        assert_eq!(
            s.advance_number_wall(id, rev, &request, 1).unwrap_err(),
            error
        );
        assert_eq!(s.cancel_number_wall(id, rev, &request).unwrap_err(), error);
    }
    assert_eq!(
        s.advance_number_wall(before.session_id(), before.revision(), &foreign, 1)
            .unwrap_err(),
        "WrongSession"
    );
    assert_eq!(
        s.cancel_number_wall(before.session_id(), before.revision(), &foreign)
            .unwrap_err(),
        "WrongSession"
    );
    assert_eq!(
        s.apply_batch(
            before.session_id(),
            before.revision(),
            vec![StateCommand::glow_enabled(true), load("101")]
        )
        .unwrap_err(),
        "DeferredOperation"
    );
    assert_eq!(s.snapshot().unwrap().revision(), before.revision());
    assert!(!s.snapshot().unwrap().glow_enabled());
    let terminal = finish(&s, &request);
    let retained = terminal.snapshot();
    let frame = retained.number_wall_frame().unwrap();
    let pending = begin(&s, load("101"), &StateNumberWallGuard::new(true));
    let before_close = s.snapshot().unwrap();
    s.shutdown().unwrap();
    s.shutdown().unwrap();
    let id = before_close.session_id();
    let rev = before_close.revision();
    assert!(s.snapshot().is_err());
    assert!(s.apply_batch(id, rev, vec![]).is_err());
    assert!(
        s.begin_number_wall(id, rev, load("103"), &StateNumberWallGuard::new(true), 1)
            .is_err()
    );
    assert!(s.advance_number_wall(id, rev, &pending, 0).is_err());
    assert!(s.cancel_number_wall(id, rev, &pending).is_err());
    assert_eq!(terminal.status(), Some(Status::VerifiedPrime));
    assert_eq!(
        terminal.snapshot().number_wall_status(),
        Some(Status::VerifiedPrime)
    );
    assert_eq!(
        frame.values(),
        retained.number_wall_frame().unwrap().values()
    );
    assert_eq!(frame.modulus(), "97");
    assert!(before_close.number_wall_pending());
    assert!(other.snapshot().unwrap().number_wall_pending());
}
