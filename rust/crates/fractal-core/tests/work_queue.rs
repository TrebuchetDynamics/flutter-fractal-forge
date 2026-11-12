use fractal_core::{
    catalog_baseline::CatalogBaseline,
    normalization::{RawScalar, ViewInput},
    number_wall_prime::DEFAULT_MAX_TRIAL_DIVISIONS,
    session::{Command, RequestKind, RequestProgress, Session, TrajectoryProgress},
    work_queue::{AdmissionError as Error, WorkKey, WorkQueue},
};
use std::{
    panic::{AssertUnwindSafe, catch_unwind},
    sync::Arc,
};

fn key(session_id: u64, kind: RequestKind, generation: u64) -> WorkKey {
    WorkKey {
        session_id,
        kind,
        generation,
    }
}

#[test]
fn capacity_replacement_and_all_terminal_lifetimes_are_exact() {
    let q = WorkQueue::default();
    let mut permits: Vec<_> = (0..8)
        .map(|id| q.try_admit(key(id, RequestKind::Trajectory, 1)).unwrap())
        .collect();
    let turn = q.next_turn().unwrap();
    assert!(permits[0].matches(&turn));
    assert_eq!(q.len(), 8); // Selected/in-flight work still consumes admission.
    assert!(matches!(
        q.try_admit(key(8, RequestKind::NumberWall, 1)),
        Err(Error::Busy)
    ));
    assert!(matches!(
        q.try_admit(permits[0].key()),
        Err(Error::AlreadyAdmitted)
    ));
    assert!(matches!(
        q.replace(&permits[0], permits[0].key()),
        Err(Error::StalePermit)
    ));
    assert!(matches!(
        q.replace(&permits[0], key(1, RequestKind::Trajectory, 2)),
        Err(Error::StalePermit)
    ));
    assert!(matches!(
        q.replace(&permits[0], key(0, RequestKind::NumberWall, 2)),
        Err(Error::StalePermit)
    ));
    let other = WorkQueue::default();
    let foreign = other.try_admit(permits[0].key()).unwrap();
    assert!(!foreign.matches(&turn));
    assert_eq!(q.finish(&foreign), Err(Error::ForeignPermit));
    let replacement = q
        .replace(&permits[0], key(0, RequestKind::Trajectory, 2))
        .unwrap();
    assert!(!permits[0].guard().is_active());
    assert!(!replacement.matches(&turn));
    assert_eq!(q.finish(&permits[0]), Err(Error::StalePermit));
    permits[0] = replacement; // Old Drop cannot remove the replacement.
    assert_eq!(q.len(), 8);
    // Busy did not create a waiter or consume a turn; the original RR order survives.
    for id in 1..8 {
        assert_eq!(q.next_turn().unwrap().key().session_id, id);
    }
    assert_eq!(q.next_turn().unwrap().key(), permits[0].key());
    q.finish(&permits[0]).unwrap(); // success or error is the same terminal release
    assert_eq!(q.finish(&permits[0]), Err(Error::StalePermit));
    q.revoke(&permits[1]).unwrap();
    q.close(2);
    assert_eq!(q.revoke(&permits[2]), Err(Error::StalePermit));
    assert_eq!(q.len(), 5);
    permits.clear();
    assert!(q.is_empty());
    let result = catch_unwind(AssertUnwindSafe(|| {
        let _permit = q.try_admit(key(9, RequestKind::Trajectory, 1)).unwrap();
        panic!("job panic outside policy lock");
    }));
    assert!(result.is_err());
    assert!(q.is_empty());
    assert!(q.next_turn().is_none());
    assert!(q.try_admit(key(10, RequestKind::Trajectory, 1)).is_ok());
}

fn session(id: u64) -> Session {
    let catalog = CatalogBaseline::from_jsons(
        include_str!("../../../../migration/baseline/modules.json"),
        include_str!("../../../../migration/baseline/parameters.json"),
        include_str!("../../../../migration/baseline/presets.json"),
        include_str!("../../../../migration/baseline/capabilities.json"),
    )
    .unwrap();
    Session::new(Arc::new(catalog), id, "thomas_attractor").unwrap()
}
fn wall() -> Command {
    Command::Load {
        module_id: Some("number_wall".into()),
        params: [("prime".into(), RawScalar::Text("2147483647".into()))]
            .into_iter()
            .collect(),
        camera: ViewInput {
            zoom: 1.0,
            pan: [0.0; 2],
            rotation: [0.0; 3],
        }
        .into(),
        transparent: false,
    }
}

#[test]
fn real_jobs_rotate_sessions_and_kinds_one_bounded_chunk_without_publishing() {
    let q = WorkQueue::default();
    let mut sessions: Vec<_> = (0..3).map(session).collect();
    let mut jobs = Vec::new();
    for (id, s) in sessions.iter_mut().enumerate() {
        let id = id as u64;
        let trajectory = q.try_admit(key(id, RequestKind::Trajectory, 1)).unwrap();
        let token = s
            .begin_trajectory(id, s.snapshot().revision(), trajectory.guard())
            .unwrap()
            .unwrap();
        jobs.push((trajectory, token));
        let permit = q.try_admit(key(id, RequestKind::NumberWall, 1)).unwrap();
        let token = s
            .begin_number_wall(
                id,
                s.snapshot().revision(),
                &wall(),
                permit.guard(),
                DEFAULT_MAX_TRIAL_DIVISIONS,
            )
            .unwrap()
            .unwrap();
        jobs.push((permit, token));
    }
    let admitted: Vec<_> = sessions.iter().map(Session::snapshot).collect();
    for round in 0_u32..4 {
        for id in 0..3 {
            let turn = q.next_turn().unwrap();
            let kind = if round % 2 == 0 {
                RequestKind::NumberWall
            } else {
                RequestKind::Trajectory
            };
            assert_eq!(turn.key(), key(id, kind, 1));
            let (_, token) = jobs.iter().find(|(p, _)| p.matches(&turn)).unwrap();
            let s = &mut sessions[id as usize];
            let revision = s.snapshot().revision();
            match kind {
                RequestKind::NumberWall => assert_eq!(
                    s.advance_number_wall(id, revision, *token, 1).unwrap(),
                    RequestProgress::Pending
                ),
                RequestKind::Trajectory => assert_eq!(
                    s.advance_trajectory(id, revision, *token).unwrap(),
                    TrajectoryProgress::Pending {
                        steps_completed: round.div_ceil(2) * 256
                    }
                ),
            }
            assert_eq!(s.snapshot(), admitted[id as usize]);
            assert_eq!(q.len(), 6);
        }
    }
    // Replacing only wall revokes its actual Session guard, not trajectory's.
    let replacement = q
        .replace(&jobs[1].0, key(0, RequestKind::NumberWall, 2))
        .unwrap();
    let s = &mut sessions[0];
    let before = s.snapshot();
    s.advance_number_wall(0, before.revision(), jobs[1].1, 1)
        .unwrap();
    assert_eq!(
        s.snapshot().trajectory_pending(),
        before.trajectory_pending()
    );
    assert_eq!(s.snapshot().trajectory_frame(), before.trajectory_frame());
    assert_eq!(s.snapshot().number_wall_frame(), before.number_wall_frame());
    drop(replacement);
    q.close(0);
    let before = s.snapshot();
    assert!(matches!(
        s.advance_trajectory(0, before.revision(), jobs[0].1)
            .unwrap(),
        TrajectoryProgress::Finished(Err(_))
    ));
    assert_eq!(q.len(), 4);
    drop(jobs);
    assert!(q.is_empty());
}
