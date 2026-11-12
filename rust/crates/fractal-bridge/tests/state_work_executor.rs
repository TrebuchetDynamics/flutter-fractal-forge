//! Deterministic public admission seam; no FRB runtime or extra worker pool.
use fractal_bridge::api::*;
use std::sync::{Arc, Mutex};

type Pump = Box<dyn FnOnce() + Send>;
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
fn submit(service: &StateWorkService, session: &StateSession) -> Result<StateWorkTicket, String> {
    let s = session.snapshot().unwrap();
    service.submit_trajectory(session, s.session_id(), s.revision())
}
fn counted() -> (StateWorkService, Arc<Mutex<Vec<Pump>>>) {
    let pumps = Arc::new(Mutex::new(Vec::new()));
    let sink = pumps.clone();
    (
        StateWorkService::with_submitter(move |pump| sink.lock().unwrap().push(pump)),
        pumps,
    )
}
fn run(pumps: &Mutex<Vec<Pump>>) {
    let pump = pumps.lock().unwrap().pop().unwrap();
    pump();
}

#[test]
fn capacity_is_reserved_before_one_submission_and_replacement_is_atomic() {
    let (service, pumps) = counted();
    let sessions: Vec<_> = (0..9).map(|_| session("thomas_attractor")).collect();
    let mut tickets: Vec<_> = sessions[..8]
        .iter()
        .map(|s| submit(&service, s).unwrap())
        .collect();
    assert_eq!(
        submit(&service, &sessions[8]).err().as_deref(),
        Some("Busy")
    );
    assert_eq!(pumps.lock().unwrap().len(), 1);
    assert!(
        tickets
            .iter()
            .all(|t| t.status().phase == StateWorkPhase::Queued)
    );
    assert_eq!(sessions[0].snapshot().unwrap().revision(), 0);
    let s = sessions[0].snapshot().unwrap();
    let replacement = service
        .replace_trajectory(&sessions[0], s.session_id(), s.revision(), &tickets[0])
        .unwrap();
    assert_eq!(tickets[0].status().phase, StateWorkPhase::Cancelled);
    tickets[0] = replacement;
    run(&pumps);
    assert!(
        tickets
            .iter()
            .all(|t| t.status().phase == StateWorkPhase::Finished)
    );
    assert!(
        tickets[0]
            .status()
            .snapshot
            .unwrap()
            .trajectory_frame()
            .is_some()
    );
    assert!(pumps.lock().unwrap().is_empty());
    let next = submit(&service, &sessions[8]).unwrap();
    assert_eq!(pumps.lock().unwrap().len(), 1);
    next.cancel();
    run(&pumps);
}

#[test]
fn concurrent_admission_and_empty_exit_never_lose_a_wake() {
    let (service, pumps) = counted();
    for _ in 0..16 {
        let a = session("thomas_attractor");
        let b = session("thomas_attractor");
        let first = submit(&service, &a).unwrap();
        let (second, replacement) = std::thread::scope(|scope| {
            let pump = pumps.lock().unwrap().pop().unwrap();
            scope.spawn(pump);
            let replacement =
                service.replace_trajectory(&a, a.snapshot().unwrap().session_id(), 0, &first);
            let replacement = match replacement {
                Ok(ticket) => Some(ticket),
                Err(error) => {
                    assert_eq!(error, "Stale ticket");
                    None
                }
            };
            (submit(&service, &b).unwrap(), replacement)
        });
        while !pumps.lock().unwrap().is_empty() {
            run(&pumps);
        }
        assert!(matches!(
            first.status().phase,
            StateWorkPhase::Finished | StateWorkPhase::Cancelled
        ));
        if let Some(replacement) = replacement {
            // Revision zero can have become stale while the first begin was running.
            assert!(matches!(
                replacement.status().phase,
                StateWorkPhase::Finished | StateWorkPhase::Failed
            ));
        }
        assert_eq!(second.status().phase, StateWorkPhase::Finished);
    }
}

#[test]
fn cancellation_close_drop_and_stale_jobs_release_capacity_without_late_publication() {
    let (service, pumps) = counted();
    let s = session("thomas_attractor");
    let dropped = submit(&service, &s).unwrap();
    drop(dropped);
    let cancelled = submit(&service, &s).unwrap();
    cancelled.cancel();
    let stale = submit(&service, &s).unwrap();
    let before = s.snapshot().unwrap();
    s.apply_batch(
        before.session_id(),
        before.revision(),
        vec![StateCommand::zoom(2.0)],
    )
    .unwrap();
    run(&pumps);
    assert_eq!(stale.status().phase, StateWorkPhase::Failed);
    assert!(s.snapshot().unwrap().trajectory_frame().is_none());
    let closed = submit(&service, &s).unwrap();
    s.shutdown().unwrap();
    assert_eq!(
        service
            .submit_trajectory(&s, before.session_id(), 0)
            .err()
            .as_deref(),
        Some("Rust state session is closed")
    );
    assert_eq!(closed.status().phase, StateWorkPhase::Cancelled);
    run(&pumps);
    let gone = session("thomas_attractor");
    let ticket = submit(&service, &gone).unwrap();
    drop(gone);
    assert_eq!(ticket.status().phase, StateWorkPhase::Cancelled);
    run(&pumps);
    let fresh = session("thomas_attractor");
    let last = submit(&service, &fresh).unwrap();
    run(&pumps);
    assert_eq!(last.status().phase, StateWorkPhase::Finished);
}
