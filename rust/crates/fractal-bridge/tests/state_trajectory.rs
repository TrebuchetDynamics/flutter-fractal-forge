//! Public typed ingress and bounded normal-mode trajectory transport.
use fractal_bridge::api::*;
use std::collections::HashMap;

fn session(module: &str) -> StateSession {
    StateSession::new(
        include_str!("../../../../migration/baseline/modules.json").into(),
        include_str!("../../../../migration/baseline/parameters.json").into(),
        include_str!("../../../../migration/baseline/presets.json").into(),
        include_str!("../../../../migration/baseline/capabilities.json").into(),
        module.into(),
    )
    .unwrap()
}
fn view() -> StateView {
    StateView {
        zoom: 2.0,
        pan_x: 0.1,
        pan_y: 0.2,
        rot_x: 0.0,
        rot_y: 0.0,
        rot_z: 0.0,
    }
}
fn settings(
    system: StateAttractorSystem,
    projection: StateOrbitProjection,
    step: f64,
) -> Result<StateTrajectorySettings, String> {
    StateTrajectorySettings::new(
        1,
        "rk4".into(),
        system,
        StateOrbitPoint {
            x: 0.1,
            y: 0.2,
            z: 0.3,
        },
        step,
        10,
        600,
        projection,
    )
}
fn apply(s: &StateSession, command: StateCommand) -> Result<StateSnapshot, String> {
    let before = s.snapshot().unwrap();
    s.apply_batch(before.session_id(), before.revision(), vec![command])
}
fn begin(s: &StateSession, guard: &StateTrajectoryGuard) -> StateTrajectoryRequest {
    let before = s.snapshot().unwrap();
    s.begin_trajectory_async(before.session_id(), before.revision(), guard)
        .unwrap()
        .unwrap()
}
fn step(s: &StateSession, r: &StateTrajectoryRequest) -> StateTrajectoryProgress {
    let before = s.snapshot().unwrap();
    s.advance_trajectory_async(before.session_id(), before.revision(), r)
        .unwrap()
}

#[test]
fn typed_ingress_preserves_legacy_null_filters_incompatible_and_rejects_unrepresented_settings() {
    let s = session("thomas_attractor");
    assert!(s.snapshot().unwrap().trajectory().is_some());
    assert!(
        settings(
            StateAttractorSystem::Thomas,
            StateOrbitProjection::ThomasOblique,
            f64::NAN
        )
        .is_err()
    );
    assert!(
        StateTrajectorySettings::new(
            2,
            "rk4".into(),
            StateAttractorSystem::Thomas,
            StateOrbitPoint {
                x: 0.1,
                y: 0.2,
                z: 0.3
            },
            0.01,
            0,
            1,
            StateOrbitProjection::ThomasOblique
        )
        .is_err()
    );
    assert!(
        StateTrajectorySettings::new(
            1,
            "euler".into(),
            StateAttractorSystem::Thomas,
            StateOrbitPoint {
                x: 0.1,
                y: 0.2,
                z: 0.3
            },
            0.01,
            0,
            1,
            StateOrbitProjection::ThomasOblique
        )
        .is_err()
    );
    assert!(
        apply(
            &s,
            StateCommand::view(
                StateCamera {
                    view: view(),
                    has_trajectory: true
                },
                false
            )
        )
        .is_err()
    );
    let wrong = settings(
        StateAttractorSystem::FourWing,
        StateOrbitProjection::Xz,
        0.01,
    )
    .unwrap();
    assert!(
        apply(
            &s,
            StateCommand::view_trajectory(StateTrajectoryCamera::new(view(), Some(wrong)), false)
        )
        .unwrap()
        .trajectory()
        .is_none()
    );
    let typed = || {
        StateTrajectoryCamera::new(
            view(),
            Some(
                settings(
                    StateAttractorSystem::Thomas,
                    StateOrbitProjection::ThomasOblique,
                    0.01,
                )
                .unwrap(),
            ),
        )
    };
    let snap = apply(&s, StateCommand::view_trajectory(typed(), false)).unwrap();
    assert_eq!(snap.trajectory().unwrap().retained_steps(), 600);
    assert_eq!(snap.trajectory().unwrap().version(), 1);
    assert_eq!(snap.trajectory().unwrap().integrator(), "rk4");
    apply(
        &s,
        StateCommand::apply_preset_trajectory("thomas_attractor".into(), HashMap::new(), typed()),
    )
    .unwrap();
    apply(
        &s,
        StateCommand::load_trajectory(
            Some("thomas_attractor".into()),
            HashMap::new(),
            typed(),
            true,
        ),
    )
    .unwrap();
    let null = apply(
        &s,
        StateCommand::view_trajectory(StateTrajectoryCamera::new(view(), None), false),
    )
    .unwrap();
    assert!(null.trajectory().is_none());
    assert!(
        session("mandelbrot")
            .snapshot()
            .unwrap()
            .trajectory()
            .is_none()
    );
}

#[test]
fn bounded_requests_share_cache_and_retain_frames_across_cancel_supersede_stale_and_close() {
    let s = session("lorenz_2d");
    let configure = |s: &StateSession| {
        apply(
            s,
            StateCommand::view_trajectory(
                StateTrajectoryCamera::new(
                    view(),
                    Some(
                        settings(
                            StateAttractorSystem::Lorenz2d,
                            StateOrbitProjection::Xz,
                            0.009,
                        )
                        .unwrap(),
                    ),
                ),
                false,
            ),
        )
        .unwrap()
    };
    configure(&s);
    let guard = StateTrajectoryGuard::new(true);
    let before = s.snapshot().unwrap();
    assert!(
        s.begin_trajectory_async(
            before.session_id(),
            before.revision(),
            &StateTrajectoryGuard::new(false)
        )
        .unwrap()
        .is_none()
    );
    let request = begin(&s, &guard);
    let pending = step(&s, &request);
    assert!(pending.is_pending());
    assert_eq!(pending.steps_completed(), Some(256));
    let captured = pending.snapshot();
    assert!(
        s.advance_trajectory_async(captured.session_id(), before.revision(), &request)
            .is_err()
    );
    let other = session("lorenz_2d");
    let other_snapshot = other.snapshot().unwrap();
    assert!(
        other
            .advance_trajectory_async(
                other_snapshot.session_id(),
                other_snapshot.revision(),
                &request
            )
            .is_err()
    );
    assert!(step(&s, &request).is_pending());
    let done = step(&s, &request);
    assert_eq!(done.status(), Some(StateTrajectoryStatus::Success));
    let frame = done.frame().unwrap();
    assert_eq!(frame.points().len(), 600);
    assert_eq!(frame.session_id(), captured.session_id());
    assert_eq!(
        frame.settings_generation(),
        captured.trajectory_generation()
    );
    assert_eq!(frame.module_id(), "lorenz_2d");
    assert!(!frame.cache_hit());
    let d = frame.settings();
    let expected = fractal_core::trajectory::generate(
        fractal_core::trajectory::OrbitTrajectorySettings::new(
            fractal_core::trajectory::AttractorSystem::Lorenz2d,
            [0.1, 0.2, 0.3].into(),
            0.009,
            10,
            600,
            fractal_core::trajectory::OrbitProjection::Xz,
        )
        .unwrap(),
    )
    .unwrap();
    for (actual, expected) in frame.points().iter().zip(expected.points()) {
        assert_eq!(
            [actual.x, actual.y, actual.z],
            [expected.x, expected.y, expected.z]
        );
    }
    assert_eq!(frame.bounds().min_x, expected.bounds().min_x);
    assert_eq!(d.step_size(), 0.009);
    let mut detached = frame.points();
    detached[0].x = 0.0;
    assert_ne!(frame.points()[0].x, 0.0);
    configure(&other);
    let cached = step(&other, &begin(&other, &guard));
    assert!(cached.frame().unwrap().cache_hit());
    let obsolete = begin(&s, &guard);
    let current = begin(&s, &guard);
    assert_eq!(
        step(&s, &obsolete).status(),
        Some(StateTrajectoryStatus::Cancelled)
    );
    assert!(s.snapshot().unwrap().trajectory_pending());
    guard.revoke();
    assert!(!guard.is_active());
    assert_eq!(
        step(&s, &current).status(),
        Some(StateTrajectoryStatus::Cancelled)
    );
    let active = StateTrajectoryGuard::new(true);
    let cancel = begin(&s, &active);
    let snap = s.snapshot().unwrap();
    assert_eq!(
        s.cancel_trajectory_async(snap.session_id(), snap.revision(), &cancel)
            .unwrap()
            .status(),
        Some(StateTrajectoryStatus::Cancelled)
    );
    let edit_request = begin(&s, &active);
    apply(
        &s,
        StateCommand::view_trajectory(StateTrajectoryCamera::new(view(), None), false),
    )
    .unwrap();
    assert_eq!(
        step(&s, &edit_request).status(),
        Some(StateTrajectoryStatus::Cancelled)
    );
    s.shutdown_async().unwrap();
    assert!(s.snapshot_async().is_err());
    assert!(
        s.advance_trajectory_async(captured.session_id(), captured.revision(), &request)
            .is_err()
    );
    assert_eq!(frame.points().len(), 600);
    assert_eq!(
        done.snapshot().trajectory_frame().unwrap().points().len(),
        600
    );
    assert_eq!(captured.trajectory().unwrap().retained_steps(), 600);
}
