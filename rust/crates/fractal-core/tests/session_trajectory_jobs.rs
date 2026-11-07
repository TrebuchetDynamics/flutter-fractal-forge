//! Composed public request/cache tests; the original kernel tests own RK4 numerics.
use fractal_core::{
    catalog_baseline::CatalogBaseline,
    normalization::{RawScalar, ViewInput},
    number_wall_prime::DEFAULT_MAX_TRIAL_DIVISIONS,
    session::{
        CameraInput, Command, RawParams, RequestGuard, RequestKind, RequestToken, Session,
        SessionError, Snapshot, TrajectoryCache, TrajectoryFrame, TrajectoryProgress,
    },
    trajectory::{OrbitTrajectorySettings, TrajectoryError, generate},
};
use std::sync::Arc;

fn session(id: u64, cache: TrajectoryCache) -> Session {
    let catalog = CatalogBaseline::from_jsons(
        include_str!("../../../../migration/baseline/modules.json"),
        include_str!("../../../../migration/baseline/parameters.json"),
        include_str!("../../../../migration/baseline/presets.json"),
        include_str!("../../../../migration/baseline/capabilities.json"),
    )
    .unwrap();
    Session::with_trajectory_cache(Arc::new(catalog), id, "thomas_attractor", cache).unwrap()
}
fn settings(seed: f64, steps: u32) -> OrbitTrajectorySettings {
    let d = OrbitTrajectorySettings::defaults_for("thomas_attractor").unwrap();
    OrbitTrajectorySettings::new(
        d.system(),
        [seed, 0.2, 0.3].into(),
        0.01,
        0,
        steps,
        d.projection(),
    )
    .unwrap()
}
fn apply(s: &mut Session, commands: &[Command]) -> Snapshot {
    let before = s.snapshot();
    s.apply_batch(before.session_id(), before.revision(), commands)
        .unwrap()
}
fn camera(trajectory: Option<OrbitTrajectorySettings>) -> CameraInput {
    CameraInput {
        trajectory,
        ..ViewInput {
            zoom: 1.0,
            pan: [0.0; 2],
            rotation: [0.0; 3],
        }
        .into()
    }
}
fn view(settings: OrbitTrajectorySettings) -> Command {
    Command::View {
        camera: camera(Some(settings)),
        adaptive: false,
    }
}
fn wall_load(prime: &str) -> Command {
    Command::Load {
        module_id: Some("number_wall".into()),
        params: [("prime".into(), RawScalar::Text(prime.into()))]
            .into_iter()
            .collect(),
        camera: camera(None),
        transparent: false,
    }
}
fn begin(s: &mut Session, guard: RequestGuard) -> RequestToken {
    let before = s.snapshot();
    s.begin_trajectory(before.session_id(), before.revision(), guard)
        .unwrap()
        .unwrap()
}
fn step(s: &mut Session, token: RequestToken) -> TrajectoryProgress {
    let before = s.snapshot();
    s.advance_trajectory(before.session_id(), before.revision(), token)
        .unwrap()
}
fn finish(s: &mut Session, token: RequestToken) -> Arc<TrajectoryFrame> {
    for _ in 0..100 {
        match step(s, token) {
            TrajectoryProgress::Pending { .. } => (),
            TrajectoryProgress::Finished(result) => return result.unwrap(),
        }
    }
    panic!("bounded trajectory did not terminate");
}
fn compute(s: &mut Session, settings: OrbitTrajectorySettings) -> Arc<TrajectoryFrame> {
    apply(s, &[view(settings)]);
    let token = begin(s, RequestGuard::new(true));
    finish(s, token)
}
fn cancelled() -> TrajectoryProgress {
    TrajectoryProgress::Finished(Err(TrajectoryError::Cancelled))
}

#[test]
fn admission_is_inert_and_one_advance_is_one_chunk_with_detached_terminal_provenance() {
    let mut s = session(7, TrajectoryCache::default());
    let settings = settings(0.1, 512);
    let before = apply(&mut s, &[view(settings)]);
    let token = begin(&mut s, RequestGuard::new(true));
    let admitted = s.snapshot();
    assert_eq!(token.kind(), RequestKind::Trajectory);
    assert_eq!(admitted.trajectory_pending(), Some(token));
    assert_eq!(
        admitted.trajectory_generation(),
        before.trajectory_generation()
    );
    assert!(admitted.trajectory_frame().is_none());
    for steps in [256, 512] {
        assert_eq!(
            step(&mut s, token),
            TrajectoryProgress::Pending {
                steps_completed: steps
            }
        );
        assert_eq!(s.snapshot(), admitted);
    }
    // Scalar and palette changes neither cancel work nor get rolled back by completion.
    apply(
        &mut s,
        &[
            Command::Zoom(3.0),
            Command::Param {
                id: "colorScheme".into(),
                value: RawScalar::Float(2.0),
            },
        ],
    );
    let latest = s.snapshot();
    assert_ne!(latest.params(), admitted.params());
    let frame = finish(&mut s, token);
    assert_eq!(frame.token(), token);
    assert_eq!(frame.module_id(), "thomas_attractor");
    assert_eq!(frame.settings_generation(), before.trajectory_generation());
    assert!(!frame.cache_hit());
    assert_eq!(frame.trajectory().as_ref(), &generate(settings).unwrap());
    assert_eq!(s.snapshot().view(), latest.view());
    assert_eq!(s.snapshot().params(), latest.params());
    assert_eq!(s.snapshot().revision(), latest.revision() + 1);
    apply(&mut s, &[Command::ResetSession]);
    drop(s);
    assert_eq!(*frame.trajectory().settings(), settings);
    assert_eq!(frame.trajectory().points().len(), 512);
    assert!(frame.trajectory().bounds().is_finite());
}

#[test]
fn supersession_guards_and_exact_boundary_cancellation_cannot_publish_or_cache() {
    let cache = TrajectoryCache::default();
    let mut s = session(1, cache.clone());
    apply(&mut s, &[view(settings(0.1, 256))]);
    let before = s.snapshot();
    assert_eq!(
        s.begin_trajectory(1, before.revision(), RequestGuard::new(false))
            .unwrap(),
        None
    );
    assert_eq!(s.snapshot(), before);
    for supersede in [false, true] {
        let guard = RequestGuard::new(true);
        let a = begin(&mut s, guard.clone());
        assert_eq!(
            step(&mut s, a),
            TrajectoryProgress::Pending {
                steps_completed: 256
            }
        );
        let b = supersede.then(|| begin(&mut s, RequestGuard::new(true)));
        guard.revoke();
        let before = s.snapshot();
        assert_eq!(step(&mut s, a), cancelled());
        if let Some(b) = b {
            assert_eq!(s.snapshot(), before);
            assert!(!finish(&mut s, b).cache_hit());
        } else {
            assert!(s.snapshot().trajectory_frame().is_none());
        }
    }
    apply(&mut s, &[view(settings(0.2, 256))]);
    let token = begin(&mut s, RequestGuard::new(true));
    assert!(matches!(
        step(&mut s, token),
        TrajectoryProgress::Pending { .. }
    ));
    let before = s.snapshot();
    assert_eq!(
        s.cancel_trajectory(1, before.revision(), token).unwrap(),
        cancelled()
    );
    let after = s.snapshot();
    assert_eq!(step(&mut s, token), cancelled());
    assert_eq!(s.snapshot(), after);
    assert!(!compute(&mut session(2, cache), settings(0.2, 256)).cache_hit());
}

#[test]
fn identity_revision_and_request_kind_errors_preserve_both_owners_and_rollback() {
    let mut s = session(1, TrajectoryCache::default());
    let mut other = session(2, TrajectoryCache::default());
    let foreign = begin(&mut other, RequestGuard::new(true));
    let token = begin(&mut s, RequestGuard::new(true));
    let load = wall_load("97");
    let wall = s
        .begin_number_wall(
            1,
            s.snapshot().revision(),
            &load,
            RequestGuard::new(true),
            DEFAULT_MAX_TRIAL_DIVISIONS,
        )
        .unwrap()
        .unwrap();
    assert_eq!(wall.kind(), RequestKind::NumberWall);
    let before = s.snapshot();
    for (id, revision, error) in [
        (2, before.revision(), SessionError::WrongSession),
        (1, 0, SessionError::StaleRevision),
    ] {
        assert_eq!(
            s.begin_trajectory(id, revision, RequestGuard::new(true)),
            Err(error.clone())
        );
        assert_eq!(
            s.advance_trajectory(id, revision, token),
            Err(error.clone())
        );
        assert_eq!(s.cancel_trajectory(id, revision, token), Err(error));
    }
    assert_eq!(
        s.advance_trajectory(1, before.revision(), foreign),
        Err(SessionError::WrongSession)
    );
    assert_eq!(
        s.cancel_trajectory(1, before.revision(), foreign),
        Err(SessionError::WrongSession)
    );
    assert_eq!(step(&mut s, wall), cancelled());
    assert_eq!(
        s.cancel_trajectory(1, before.revision(), wall).unwrap(),
        cancelled()
    );
    assert!(matches!(
        s.advance_number_wall(1, before.revision(), token, 1)
            .unwrap(),
        fractal_core::session::RequestProgress::Finished(_)
    ));
    assert!(
        s.apply_batch(
            1,
            before.revision(),
            &[
                view(settings(0.2, 20)),
                Command::Unsupported {
                    operation: "reject".into()
                }
            ]
        )
        .is_err()
    );
    assert_eq!(s.snapshot(), before);
    // Trajectory completion must not lose an independent staged wall request.
    finish(&mut s, token);
    assert_eq!(s.snapshot().number_wall_pending(), Some(wall));
    loop {
        let revision = s.snapshot().revision();
        if matches!(
            s.advance_number_wall(1, revision, wall, 1024).unwrap(),
            fractal_core::session::RequestProgress::Finished(_)
        ) {
            break;
        }
    }
    assert_eq!(s.snapshot().module_id(), "number_wall");
    assert_eq!(s.snapshot().trajectory_pending(), None);
    assert_eq!(s.snapshot().trajectory(), None);
    assert_eq!(step(&mut s, token), cancelled());
}

#[test]
fn wall_rejection_and_cancellation_preserve_independent_work_and_completed_frames() {
    use fractal_core::{
        number_wall_prime::NumberWallPrimeStatus as Status, session::RequestProgress,
    };
    for cancel_wall in [false, true] {
        for trajectory_first in [false, true] {
            let mut s = session(1, TrajectoryCache::default());
            let good = compute(&mut s, settings(0.1, 20));
            apply(&mut s, &[view(settings(0.2, 20))]);
            let trajectory = begin(&mut s, RequestGuard::new(true));
            let wall = s
                .begin_number_wall(
                    1,
                    s.snapshot().revision(),
                    &wall_load("561"),
                    RequestGuard::new(true),
                    DEFAULT_MAX_TRIAL_DIVISIONS,
                )
                .unwrap()
                .unwrap();
            let generation = s.snapshot().trajectory_generation();
            let retained = if trajectory_first {
                finish(&mut s, trajectory)
            } else {
                good
            };
            let result = if cancel_wall {
                s.cancel_number_wall(1, s.snapshot().revision(), wall)
                    .unwrap()
            } else {
                loop {
                    let progress = s
                        .advance_number_wall(1, s.snapshot().revision(), wall, 1024)
                        .unwrap();
                    if progress != RequestProgress::Pending {
                        break progress;
                    }
                }
            };
            assert_eq!(
                result,
                RequestProgress::Finished(if cancel_wall {
                    Status::Cancelled
                } else {
                    Status::Composite
                })
            );
            let after = s.snapshot();
            assert_eq!(after.module_id(), "thomas_attractor");
            assert_eq!(after.trajectory_generation(), generation);
            assert!(Arc::ptr_eq(after.trajectory_frame().unwrap(), &retained));
            if trajectory_first {
                assert_eq!(after.trajectory_status(), Some(Ok(())));
            } else {
                assert_eq!(after.trajectory_pending(), Some(trajectory));
                assert_eq!(
                    *finish(&mut s, trajectory).trajectory().settings(),
                    settings(0.2, 20)
                );
            }
        }
    }
}

#[test]
fn settings_module_and_reset_invalidation_are_atomic_even_for_round_trip_batches() {
    let mut s = session(1, TrajectoryCache::default());
    let good = compute(&mut s, settings(0.1, 20));
    let original_generation = s.snapshot().trajectory_generation();
    for commands in [
        vec![view(settings(0.2, 20)), view(settings(0.1, 20))],
        vec![Command::ResetView],
        vec![Command::ResetSession],
        vec![Command::SelectModule {
            module_id: "four_wing".into(),
            reset_view: false,
            initial_params: RawParams::new(),
        }],
    ] {
        apply(
            &mut s,
            &[Command::Load {
                module_id: Some("thomas_attractor".into()),
                params: RawParams::new(),
                camera: camera(Some(settings(0.1, 20))),
                transparent: false,
            }],
        );
        let token = begin(&mut s, RequestGuard::new(true));
        let changed = apply(&mut s, &commands);
        assert!(changed.trajectory_generation() > original_generation);
        assert_eq!(changed.trajectory_pending(), None);
        assert_eq!(step(&mut s, token), cancelled());
        assert_eq!(s.snapshot(), changed);
        assert!(Arc::ptr_eq(changed.trajectory_frame().unwrap(), &good));
    }
}

#[test]
fn shared_cache_hits_touch_three_entry_lru_without_deduplicating_independent_misses() {
    let cache = TrajectoryCache::default();
    let mut a = session(1, cache.clone());
    let mut b = session(2, cache);
    let first = compute(&mut a, settings(0.1, 20));
    apply(
        &mut b,
        &[
            view(settings(0.1, 20)),
            Command::Zoom(4.0),
            Command::Param {
                id: "colorScheme".into(),
                value: RawScalar::Float(3.0),
            },
        ],
    );
    let token = begin(&mut b, RequestGuard::new(true));
    let hit = finish(&mut b, token);
    assert!(hit.cache_hit());
    assert_ne!(a.snapshot().params(), b.snapshot().params());
    assert!(Arc::ptr_eq(hit.trajectory(), first.trajectory()));
    for seed in [0.2, 0.3] {
        assert!(!compute(&mut a, settings(seed, 20)).cache_hit());
    }
    assert!(compute(&mut b, settings(0.1, 20)).cache_hit()); // touches oldest
    assert!(!compute(&mut a, settings(0.4, 20)).cache_hit());
    for seed in [0.3, 0.1, 0.4] {
        assert!(compute(&mut b, settings(seed, 20)).cache_hit());
    }
    assert!(!compute(&mut a, settings(0.2, 20)).cache_hit()); // fourth evicted exactly 0.2
    apply(&mut a, &[view(settings(0.5, 256))]);
    apply(&mut b, &[view(settings(0.5, 256))]);
    let ta = begin(&mut a, RequestGuard::new(true));
    let tb = begin(&mut b, RequestGuard::new(true));
    assert!(!finish(&mut a, ta).cache_hit());
    assert!(!finish(&mut b, tb).cache_hit());
    assert!(compute(&mut a, settings(0.5, 256)).cache_hit());
}

#[test]
fn cache_keys_use_all_validated_settings_and_divergence_retains_last_good() {
    let mut s = session(1, TrajectoryCache::default());
    let base = settings(0.1, 20);
    let good = compute(&mut s, base);
    for (seed, dt, burn, retained) in [
        ([0.1, 0.25, 0.3], 0.01, 0, 20),
        ([0.1, 0.2, 0.35], 0.01, 0, 20),
        ([0.1, 0.2, 0.3], 0.02, 0, 20),
        ([0.1, 0.2, 0.3], 0.01, 1, 20),
        ([0.1, 0.2, 0.3], 0.01, 0, 21),
    ] {
        let variant = OrbitTrajectorySettings::new(
            base.system(),
            seed.into(),
            dt,
            burn,
            retained,
            base.projection(),
        )
        .unwrap();
        assert!(!compute(&mut s, variant).cache_hit());
        assert!(compute(&mut s, variant).cache_hit());
    }
    for module in ["four_wing", "lorenz_2d"] {
        apply(
            &mut s,
            &[Command::SelectModule {
                module_id: module.into(),
                reset_view: false,
                initial_params: RawParams::new(),
            }],
        );
        let token = begin(&mut s, RequestGuard::new(true));
        assert!(!finish(&mut s, token).cache_hit());
    }
    let last = s.snapshot().trajectory_frame().unwrap().clone();
    let d = OrbitTrajectorySettings::defaults_for("lorenz_2d").unwrap();
    let divergent = OrbitTrajectorySettings::new(
        d.system(),
        [1e13, 1e13, 1e13].into(),
        0.01,
        0,
        20,
        d.projection(),
    )
    .unwrap();
    apply(&mut s, &[view(divergent)]);
    for _ in 0..2 {
        let token = begin(&mut s, RequestGuard::new(true));
        assert_eq!(
            step(&mut s, token),
            TrajectoryProgress::Finished(Err(TrajectoryError::SafetyBounds))
        );
        assert!(Arc::ptr_eq(s.snapshot().trajectory_frame().unwrap(), &last));
    }
    // A finite bounded seed whose first safety failure is step 257, just after a full chunk.
    let boundary = OrbitTrajectorySettings::new(
        d.system(),
        [1e-300, 1e-300, -1e10].into(),
        9.323e-6,
        0,
        1024,
        d.projection(),
    )
    .unwrap();
    apply(&mut s, &[view(boundary)]);
    let token = begin(&mut s, RequestGuard::new(true));
    assert_eq!(
        step(&mut s, token),
        TrajectoryProgress::Pending {
            steps_completed: 256
        }
    );
    assert_eq!(
        step(&mut s, token),
        TrajectoryProgress::Finished(Err(TrajectoryError::SafetyBounds))
    );
    assert!(Arc::ptr_eq(s.snapshot().trajectory_frame().unwrap(), &last));
    assert_eq!(good.trajectory().as_ref(), &generate(base).unwrap());
}
