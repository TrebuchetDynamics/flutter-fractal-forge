//! Public-seam ports of number_wall_state_test.dart; deterministic, no sleeps.
use fractal_core::{
    catalog_baseline::{CatalogBaseline, ParameterValue},
    normalization::{RawScalar, ViewInput},
    number_wall_prime::{DEFAULT_MAX_TRIAL_DIVISIONS, NumberWallPrimeStatus as Status},
    session::{
        CameraInput, Command, RawParams, RequestGuard, RequestProgress, RequestToken, Session,
        SessionError, Snapshot,
    },
};
use serde_json::{Value, json};
use std::sync::Arc;

fn session(id: u64, module: &str) -> Session {
    let catalog = CatalogBaseline::from_jsons(
        include_str!("../../../../migration/baseline/modules.json"),
        include_str!("../../../../migration/baseline/parameters.json"),
        include_str!("../../../../migration/baseline/presets.json"),
        include_str!("../../../../migration/baseline/capabilities.json"),
    )
    .unwrap();
    Session::new(Arc::new(catalog), id, module).unwrap()
}
fn params(value: Value) -> RawParams {
    value
        .as_object()
        .unwrap()
        .iter()
        .map(|(k, v)| {
            (
                k.clone(),
                RawScalar::from(serde_json::from_value::<ParameterValue>(v.clone()).unwrap()),
            )
        })
        .collect()
}
fn camera() -> CameraInput {
    ViewInput {
        zoom: 2.0,
        pan: [0.5, -0.5],
        rotation: [0.1, 0.2, 0.3],
    }
    .into()
}
fn load(prime: &str) -> Command {
    Command::Load {
        module_id: Some("number_wall".into()),
        params: params(
            json!({"prime":prime,"rows":4,"columns":16,"columnStart":3,"source":"rook"}),
        ),
        camera: camera(),
        transparent: true,
    }
}
fn begin(s: &mut Session, cmd: &Command, guard: RequestGuard) -> RequestToken {
    let before = s.snapshot();
    s.begin_number_wall(
        before.session_id(),
        before.revision(),
        cmd,
        guard,
        DEFAULT_MAX_TRIAL_DIVISIONS,
    )
    .unwrap()
    .unwrap()
}
fn step(s: &mut Session, token: RequestToken, work: usize) -> RequestProgress {
    let before = s.snapshot();
    s.advance_number_wall(before.session_id(), before.revision(), token, work)
        .unwrap()
}
fn finish(s: &mut Session, token: RequestToken) -> Status {
    for _ in 0..100_000 {
        if let RequestProgress::Finished(status) = step(s, token, 1024) {
            return status;
        }
    }
    panic!("request did not terminate");
}
fn apply(s: &mut Session, cmds: &[Command]) -> Snapshot {
    let before = s.snapshot();
    s.apply_batch(before.session_id(), before.revision(), cmds)
        .unwrap()
}
fn edit(id: &str, value: Value) -> Command {
    Command::Param {
        id: id.into(),
        value: params(json!({id:value})).remove(id).unwrap(),
    }
}

#[test]
fn guard_revocation_is_request_local_and_cannot_overwrite_successor() {
    // Source: revoked replay ownership cannot commit or cancel a newer request.
    for superseded in [false, true] {
        let mut s = session(1, "mandelbrot");
        let before = s.snapshot();
        let false_guard = RequestGuard::new(false);
        assert_eq!(
            s.begin_number_wall(1, 0, &load("97"), false_guard, DEFAULT_MAX_TRIAL_DIVISIONS)
                .unwrap(),
            None
        );
        assert_eq!(s.snapshot(), before);
        let guard = RequestGuard::new(true);
        let older = begin(&mut s, &load("97"), guard.clone());
        // Yield from real prime/grid stages before revoking ownership.
        assert_eq!(step(&mut s, older, 1024), RequestProgress::Pending);
        assert_eq!(step(&mut s, older, 1), RequestProgress::Pending);
        assert_eq!(s.snapshot().revision(), 1);
        guard.revoke();
        let newer = superseded.then(|| begin(&mut s, &load("101"), RequestGuard::new(true)));
        let retained = s.snapshot();
        assert_eq!(finish(&mut s, older), Status::Cancelled);
        if let Some(newer) = newer {
            assert_eq!(s.snapshot(), retained);
            assert_eq!(finish(&mut s, newer), Status::VerifiedPrime);
            let done = s.snapshot();
            assert_eq!(done.number_wall_frame().unwrap().grid().modulus(), "101");
            assert_eq!(done.revision(), 3);
            assert_eq!(finish(&mut s, older), Status::Cancelled);
            assert_eq!(s.snapshot(), done);
        } else {
            let done = s.snapshot();
            assert_eq!(done.module_id(), before.module_id());
            assert_eq!(done.params(), before.params());
            assert_eq!(done.view(), before.view());
            assert!(!done.transparent_background());
            assert!(done.number_wall_frame().is_none());
            assert_eq!(done.number_wall_status(), Some(Status::Cancelled));
            assert_eq!(done.revision(), 2);
        }
        assert!(retained.number_wall_pending().is_some());
        assert!(retained.number_wall_frame().is_none());
    }
}

#[test]
fn rejected_frames_retain_committed_state_and_hidden_effect_restore() {
    // Source: all replay ingress certifies decimal state and ignores forged status.
    let mut s = session(1, "kaleidoscope_basic");
    apply(&mut s, &[Command::KaleidoscopeSectors(12)]);
    let before = s.snapshot();
    for (prime, status) in [
        ("561", Status::Composite),
        ("1e2", Status::Invalid),
        (
            "170141183460469231731687303715884105727",
            Status::Unverified,
        ),
        ("00097", Status::VerifiedPrime),
    ] {
        let mut cmd = load(prime);
        if let Command::Load { params, .. } = &mut cmd {
            params.insert("primeVerified".into(), RawScalar::Boolean(true));
        }
        let token = begin(&mut s, &cmd, RequestGuard::new(true));
        assert_eq!(finish(&mut s, token), status);
        let after = s.snapshot();
        if status != Status::VerifiedPrime {
            assert_eq!(after.module_id(), before.module_id());
            assert_eq!(after.params(), before.params());
            assert_eq!(after.view(), before.view());
            assert_eq!(
                after.transparent_background(),
                before.transparent_background()
            );
            assert_eq!(after.kaleidoscope_sectors(), 12);
            assert!(after.number_wall_frame().is_none());
        }
    }
    let certified = s.snapshot();
    assert_eq!(
        certified.params()["prime"],
        ParameterValue::Text("97".into())
    );
    assert_eq!(certified.kaleidoscope_sectors(), 8); // restored pre-forced user state
    let frame = certified.number_wall_frame().unwrap();
    let mut invalid_grid = load("97");
    if let Command::Load { params, .. } = &mut invalid_grid {
        params.insert("rows".into(), RawScalar::Number(64.into()));
    }
    let token = begin(&mut s, &invalid_grid, RequestGuard::new(true));
    assert_eq!(finish(&mut s, token), Status::Invalid);
    let after = s.snapshot();
    assert_eq!(after.params(), certified.params());
    assert_eq!(after.view(), certified.view());
    assert!(Arc::ptr_eq(after.number_wall_frame().unwrap(), frame));
}

#[test]
fn source_edits_cancel_in_their_single_publication_but_normalized_noops_do_not() {
    // Source: active-module edits invalidate pending Number Walls replay.
    let mut s = session(1, "mandelbrot");
    let edits = [
        edit("iterations", json!(123)),
        Command::Rotation([0.1, 0.2, 0.3]),
        Command::Transparent(true),
        Command::RotationLocked(true),
        Command::GlowEnabled(true),
        Command::GlowSigma(2.0),
        Command::GlowIntensity(0.7),
        Command::FluidModeEnabled(true),
        Command::FluidStrength(0.5),
        Command::KaleidoscopeEnabled(true),
        Command::KaleidoscopeSectors(10),
        Command::KaleidoscopeMirror(false),
        Command::KaleidoscopeMirrorMode(1),
        Command::KaleidoscopeRotation(0.25),
        Command::ResetView,
        Command::ResetParams,
        Command::ResetSession,
        Command::SelectModule {
            module_id: "julia".into(),
            reset_view: false,
            initial_params: RawParams::new(),
        },
    ];
    for edit in edits {
        let token = begin(&mut s, &load("97"), RequestGuard::new(true));
        let revision = s.snapshot().revision();
        let after = apply(&mut s, &[edit]);
        assert_eq!(after.revision(), revision + 1);
        assert_eq!(after.number_wall_pending(), None);
        assert_eq!(finish(&mut s, token), Status::Cancelled);
        assert_eq!(s.snapshot(), after);
        assert!(after.number_wall_frame().is_none());
    }
    let token = begin(&mut s, &load("101"), RequestGuard::new(true));
    let before = s.snapshot();
    let noops = [
        Command::GlowSigma(f64::NAN),
        edit("unknown", json!(7)),
        Command::Transparent(false),
    ];
    let after = apply(&mut s, &noops);
    assert_eq!(after.revision(), before.revision() + 1);
    assert_eq!(after.number_wall_pending(), Some(token));
    assert_eq!(step(&mut s, token, 0), RequestProgress::Pending);
    assert_eq!(s.snapshot(), after);
    let guard = RequestGuard::new(false);
    assert_eq!(
        s.begin_number_wall(1, after.revision(), &load("103"), guard, 0)
            .unwrap(),
        None
    );
    assert_eq!(s.snapshot(), after);
    assert_eq!(finish(&mut s, token), Status::VerifiedPrime);
}

#[test]
fn mathematical_edits_merge_latest_candidate_use_committed_prime_and_styles_reuse_grid() {
    // Source: successive edits merge latest owned candidate; non-prime edits
    // cancel uncommitted modulus, row edits raise the minimum column origin.
    let mut s = session(1, "mandelbrot");
    let initial = begin(&mut s, &load("97"), RequestGuard::new(true));
    assert_eq!(finish(&mut s, initial), Status::VerifiedPrime);
    let retained = s.snapshot();
    let prime = begin(
        &mut s,
        &Command::NumberWallPrime("101".into()),
        RequestGuard::new(true),
    );
    let source = begin(
        &mut s,
        &edit("source", json!("thueMorse")),
        RequestGuard::new(true),
    );
    let rows = begin(&mut s, &edit("rows", json!(5)), RequestGuard::new(true));
    assert_eq!(finish(&mut s, prime), Status::Cancelled);
    assert_eq!(finish(&mut s, source), Status::Cancelled);
    assert_eq!(finish(&mut s, rows), Status::VerifiedPrime);
    let after = s.snapshot();
    assert_eq!(after.params()["prime"], ParameterValue::Text("97".into()));
    assert_eq!(
        after.params()["source"],
        ParameterValue::Text("thueMorse".into())
    );
    assert_eq!(after.number_wall_frame().unwrap().grid().row_count(), 5);
    assert_eq!(after.number_wall_frame().unwrap().grid().column_start(), 4);
    assert!(after.transparent_background());
    let older = begin(
        &mut s,
        &Command::NumberWallPrime("103".into()),
        RequestGuard::new(true),
    );
    let styled = apply(&mut s, &[edit("colorMode", json!(1))]);
    assert_eq!(styled.number_wall_status(), Some(Status::Cancelled));
    assert!(Arc::ptr_eq(
        styled.number_wall_frame().unwrap().grid(),
        after.number_wall_frame().unwrap().grid()
    ));
    assert_eq!(
        styled.number_wall_frame().unwrap().params(),
        styled.params()
    );
    assert_eq!(finish(&mut s, older), Status::Cancelled);
    assert_eq!(retained.number_wall_frame().unwrap().grid().row_count(), 4);
    assert_eq!(
        retained.params()["source"],
        ParameterValue::Text("rook".into())
    );
}

#[test]
fn mixed_deferred_batches_and_wrong_or_stale_operations_preserve_pending_and_effects() {
    let mut s = session(1, "kaleidoscope_basic");
    let mut other = session(2, "mandelbrot");
    let foreign = begin(&mut other, &load("103"), RequestGuard::new(true));
    let other_before = other.snapshot();
    let token = begin(&mut s, &load("97"), RequestGuard::new(true));
    let before = s.snapshot();
    assert_eq!(
        s.apply_batch(
            1,
            before.revision(),
            &[Command::KaleidoscopeSectors(12), load("101")]
        ),
        Err(SessionError::DeferredOperation)
    );
    assert_eq!(
        s.apply_batch(
            1,
            before.revision(),
            &[
                Command::KaleidoscopeSectors(12),
                Command::Unsupported {
                    operation: "randomize".into()
                }
            ]
        ),
        Err(SessionError::UnsupportedOperation("randomize".into()))
    );
    for (id, revision, error) in [
        (2, before.revision(), SessionError::WrongSession),
        (1, 0, SessionError::StaleRevision),
    ] {
        assert_eq!(
            s.begin_number_wall(id, revision, &load("103"), RequestGuard::new(true), 1),
            Err(error.clone())
        );
        assert_eq!(
            s.advance_number_wall(id, revision, token, 1024),
            Err(error.clone())
        );
        assert_eq!(
            s.cancel_number_wall(id, revision, token),
            Err(error.clone())
        );
        assert_eq!(
            s.apply_batch(id, revision, &[Command::ResetSession]),
            Err(error)
        );
    }
    assert_eq!(
        s.advance_number_wall(1, before.revision(), foreign, 1),
        Err(SessionError::WrongSession)
    );
    assert_eq!(
        s.cancel_number_wall(1, before.revision(), foreign),
        Err(SessionError::WrongSession)
    );
    assert_eq!(s.snapshot(), before);
    let mut trajectory = camera();
    trajectory.has_trajectory = true;
    assert_eq!(
        s.begin_number_wall(
            1,
            before.revision(),
            &Command::Load {
                module_id: Some("number_wall".into()),
                params: RawParams::new(),
                camera: trajectory,
                transparent: true,
            },
            RequestGuard::new(true),
            1
        ),
        Err(SessionError::UnsupportedTrajectory)
    );
    assert_eq!(s.snapshot(), before);
    assert_eq!(finish(&mut s, token), Status::VerifiedPrime);
    assert_eq!(s.snapshot().kaleidoscope_sectors(), 8);
    assert_eq!(other.snapshot(), other_before);
}

#[test]
fn module_selection_exposes_defaults_only_without_overrides_and_resets_stage_complete_state() {
    let mut s = session(1, "mandelbrot");
    let selected = begin(
        &mut s,
        &Command::SelectModule {
            module_id: "number_wall".into(),
            reset_view: false,
            initial_params: RawParams::new(),
        },
        RequestGuard::new(true),
    );
    let pending = s.snapshot();
    assert_eq!(pending.module_id(), "number_wall");
    assert!(pending.number_wall_pending().is_some());
    assert!(pending.number_wall_frame().is_none());
    assert_eq!(finish(&mut s, selected), Status::VerifiedPrime);
    for cmd in [Command::ResetParams, Command::ResetSession] {
        let token = begin(&mut s, &load("97"), RequestGuard::new(true));
        assert_eq!(finish(&mut s, token), Status::VerifiedPrime);
        let reset = begin(&mut s, &cmd, RequestGuard::new(true));
        assert_eq!(finish(&mut s, reset), Status::VerifiedPrime);
        let done = s.snapshot();
        assert_eq!(done.params()["prime"], ParameterValue::Text("2".into()));
        assert_eq!(
            done.transparent_background(),
            matches!(cmd, Command::ResetParams)
        );
        assert_eq!(
            done.view().zoom(),
            if matches!(cmd, Command::ResetParams) {
                2.0
            } else {
                1.0
            }
        );
    }
    let mut ordinary = session(3, "mandelbrot");
    let before = ordinary.snapshot();
    let token = begin(
        &mut ordinary,
        &Command::SelectModule {
            module_id: "number_wall".into(),
            reset_view: false,
            initial_params: params(json!({"prime":"561"})),
        },
        RequestGuard::new(true),
    );
    assert_eq!(ordinary.snapshot().module_id(), before.module_id());
    assert_eq!(finish(&mut ordinary, token), Status::Composite);
    assert_eq!(ordinary.snapshot().params(), before.params());

    // Same-module selection with no frame preserves the current view unless reset.
    let mut startup = session(4, "number_wall");
    apply(
        &mut startup,
        &[Command::View {
            camera: camera(),
            adaptive: false,
        }],
    );
    let selected = begin(
        &mut startup,
        &Command::SelectModule {
            module_id: "number_wall".into(),
            reset_view: false,
            initial_params: RawParams::new(),
        },
        RequestGuard::new(true),
    );
    assert_eq!(finish(&mut startup, selected), Status::VerifiedPrime);
    assert_eq!(startup.snapshot().view().zoom(), 2.0);
}
