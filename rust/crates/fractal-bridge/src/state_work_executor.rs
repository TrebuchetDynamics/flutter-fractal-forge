//! One pump per service. Queue bookkeeping never encloses Session locks or math.
use crate::api::*;
use fractal_core::{
    session::{
        Command, RequestGuard, RequestKind, RequestProgress, RequestToken, Session,
        TrajectoryProgress,
    },
    work_queue::{Permit, WorkKey, WorkQueue},
};
use std::panic::{AssertUnwindSafe, catch_unwind};
use std::sync::{Arc, Mutex, Weak};

type Pump = Box<dyn FnOnce() + Send>;
type Submitter = dyn Fn(Pump) + Send + Sync;

pub(crate) fn submit_to_frb(pump: Pump) {
    use flutter_rust_bridge::BaseThreadPool;
    crate::frb_generated::FLUTTER_RUST_BRIDGE_HANDLER
        .thread_pool()
        .execute(pump);
}

pub(crate) enum Operand {
    Trajectory,
    Wall(Command, u32),
}
impl Operand {
    fn kind(&self) -> RequestKind {
        match self {
            Self::Trajectory => RequestKind::Trajectory,
            Self::Wall(..) => RequestKind::NumberWall,
        }
    }
}
struct Execution {
    session: Weak<Mutex<Option<Session>>>,
    revision: u64,
    operand: Operand,
    token: Option<RequestToken>,
}
pub(crate) struct TicketData {
    executor: Weak<Executor>,
    key: WorkKey,
    guard: RequestGuard,
    cached: Mutex<StateWorkStatus>,
    execution: Mutex<Execution>,
}
impl TicketData {
    pub(crate) fn status(&self) -> StateWorkStatus {
        self.cached.lock().expect("status poisoned").clone()
    }
    pub(crate) fn cancel(&self) {
        if let Some(executor) = self.executor.upgrade() {
            let mut state = executor.state.lock().expect("executor poisoned");
            if let Some(i) = state
                .entries
                .iter()
                .position(|e| e.permit.key() == self.key)
            {
                state.entries.remove(i);
                self.cached.lock().expect("status poisoned").phase = StateWorkPhase::Cancelled;
            }
        }
        self.guard.revoke();
    }
    fn step(&self) -> Result<StateWorkStatus, String> {
        let mut execution = self.execution.lock().map_err(|_| "job lock poisoned")?;
        let owner = execution
            .session
            .upgrade()
            .ok_or("Rust state session dropped")?;
        let mut owner = owner
            .lock()
            .map_err(|_| "Rust state session lock poisoned")?;
        let session = owner.as_mut().ok_or("Rust state session is closed")?;
        if !self.guard.is_active() {
            return Err("Revoked".into());
        }
        let mut status = self.status();
        status.phase = StateWorkPhase::Running;
        let before = session.snapshot();
        if let Some(token) = execution.token {
            // Manual replacement/cancel/completion cannot become this ticket's result.
            let current = match execution.operand.kind() {
                RequestKind::Trajectory => before.trajectory_pending(),
                RequestKind::NumberWall => before.number_wall_pending(),
            };
            if current != Some(token) {
                return Err("Stale request".into());
            }
            match execution.operand {
                Operand::Trajectory => match session
                    .advance_trajectory(self.key.session_id, before.revision(), token)
                    .map_err(|e| e.to_string())?
                {
                    TrajectoryProgress::Pending { steps_completed } => {
                        status.steps_completed = Some(steps_completed)
                    }
                    TrajectoryProgress::Finished(result) => {
                        status.phase = StateWorkPhase::Finished;
                        if let Err(error) = result {
                            status.phase = StateWorkPhase::Failed;
                            status.error = Some(error.to_string());
                        }
                    }
                },
                Operand::Wall(..) => match session
                    .advance_number_wall(self.key.session_id, before.revision(), token, 256)
                    .map_err(|e| e.to_string())?
                {
                    RequestProgress::Pending => (),
                    RequestProgress::Finished(result) => {
                        status.phase = StateWorkPhase::Finished;
                        status.wall_status = Some(result.into());
                    }
                },
            }
        } else {
            let token = match &execution.operand {
                Operand::Trajectory => session.begin_trajectory(
                    self.key.session_id,
                    execution.revision,
                    self.guard.clone(),
                ),
                Operand::Wall(command, trials) => session.begin_number_wall(
                    self.key.session_id,
                    execution.revision,
                    command,
                    self.guard.clone(),
                    *trials,
                ),
            }
            .map_err(|e| e.to_string())?;
            execution.token = token;
            if token.is_none() {
                status.phase = StateWorkPhase::Finished;
            }
        }
        status.snapshot = Some(StateSnapshot {
            inner: session.snapshot(),
        });
        Ok(status)
    }
}
struct Entry {
    permit: Permit,
    ticket: Weak<TicketData>,
}
#[derive(Default)]
struct State {
    queue: WorkQueue,
    entries: Vec<Entry>,
    generation: u64,
    pumping: bool,
}
pub(crate) struct Executor {
    state: Mutex<State>,
    submitter: Box<Submitter>,
}
impl Executor {
    pub(crate) fn new(submit: impl Fn(Pump) + Send + Sync + 'static) -> Arc<Self> {
        Arc::new(Self {
            state: Mutex::new(State::default()),
            submitter: Box::new(submit),
        })
    }
    pub(crate) fn submit(
        self: &Arc<Self>,
        session: &StateSession,
        session_id: u64,
        revision: u64,
        operand: Operand,
        replace: Option<&StateWorkTicket>,
    ) -> Result<StateWorkTicket, String> {
        if session.id != session_id {
            return Err("WrongSession".into());
        }
        // Serializes registration with Session close, without taking the Session mutex.
        let mut registration = session
            .scheduled
            .lock()
            .map_err(|_| "scheduled subscriptions poisoned")?;
        let subscriptions = registration
            .as_mut()
            .ok_or("Rust state session is closed")?;
        let mut state = self.state.lock().expect("executor poisoned");
        let generation = state
            .generation
            .checked_add(1)
            .ok_or("Work generation exhausted")?;
        let key = WorkKey {
            session_id,
            kind: operand.kind(),
            generation,
        };
        let old = if let Some(old) = replace {
            if !Weak::ptr_eq(&old.inner.executor, &Arc::downgrade(self)) {
                return Err("Foreign ticket".into());
            }
            Some(
                state
                    .entries
                    .iter()
                    .position(|e| e.permit.key() == old.inner.key)
                    .ok_or("Stale ticket")?,
            )
        } else {
            None
        };
        let permit = match old {
            Some(i) => state.queue.replace(&state.entries[i].permit, key),
            None => state.queue.try_admit(key),
        }
        .map_err(|e| format!("{e:?}"))?;
        if let Some(i) = old
            && let Some(ticket) = state.entries.remove(i).ticket.upgrade()
        {
            ticket.cached.lock().expect("status poisoned").phase = StateWorkPhase::Cancelled;
        }
        state.generation = generation;
        let data = Arc::new(TicketData {
            executor: Arc::downgrade(self),
            key,
            guard: permit.guard(),
            cached: Mutex::new(StateWorkStatus {
                phase: StateWorkPhase::Queued,
                error: None,
                snapshot: None,
                wall_status: None,
                steps_completed: None,
            }),
            execution: Mutex::new(Execution {
                session: Arc::downgrade(&session.inner),
                revision,
                operand,
                token: None,
            }),
        });
        subscriptions.retain(|w| w.upgrade().is_some_and(|t| t.guard.is_active()));
        subscriptions.push(Arc::downgrade(&data));
        state.entries.push(Entry {
            permit,
            ticket: Arc::downgrade(&data),
        });
        let schedule = !state.pumping;
        state.pumping = true;
        drop(state);
        drop(registration);
        if schedule {
            let executor = self.clone();
            // Also release all permits if pool submission itself unwinds.
            if catch_unwind(AssertUnwindSafe(|| {
                (self.submitter)(Box::new(move || executor.pump()))
            }))
            .is_err()
            {
                self.close();
                self.state.lock().expect("executor poisoned").pumping = false;
                return Err("Pool submission panicked".into());
            }
        }
        Ok(StateWorkTicket { inner: data })
    }
    fn pump(&self) {
        while self.pump_turn() {}
    }
    fn pump_turn(&self) -> bool {
        let (turn, data) = {
            let mut state = self.state.lock().expect("executor poisoned");
            let Some(turn) = state.queue.next_turn() else {
                // Atomic with admission: a new job either belongs to this pump or schedules the next.
                state.pumping = false;
                return false;
            };
            let entry = state
                .entries
                .iter()
                .find(|e| e.permit.matches(&turn))
                .expect("admitted entry");
            let data = entry.ticket.upgrade();
            if data.is_none() {
                let i = state
                    .entries
                    .iter()
                    .position(|e| e.permit.matches(&turn))
                    .expect("admitted entry");
                state.entries.remove(i);
                return true;
            }
            (turn, data.expect("live ticket"))
        };
        self.run_turn(&turn, &data, || data.step());
        true
    }
    fn run_turn(
        &self,
        turn: &fractal_core::work_queue::Turn,
        data: &TicketData,
        step: impl FnOnce() -> Result<StateWorkStatus, String>,
    ) {
        let result = catch_unwind(AssertUnwindSafe(step))
            .unwrap_or_else(|_| Err("Scheduled job panicked".into()));
        let mut state = self.state.lock().expect("executor poisoned");
        if let Some(i) = state.entries.iter().position(|e| e.permit.matches(turn)) {
            let status = result.unwrap_or_else(|error| StateWorkStatus {
                phase: StateWorkPhase::Failed,
                error: Some(error),
                ..data.status()
            });
            let terminal = status.phase != StateWorkPhase::Running;
            *data.cached.lock().expect("status poisoned") = status;
            if terminal {
                state.entries.remove(i);
            }
        }
    }
    pub(crate) fn close(&self) {
        let mut state = self.state.lock().expect("executor poisoned");
        for entry in state.entries.drain(..) {
            let ticket = entry.ticket.upgrade();
            drop(entry);
            if let Some(ticket) = ticket {
                ticket.cached.lock().expect("status poisoned").phase = StateWorkPhase::Cancelled;
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
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
    fn trajectory(service: &StateWorkService, s: &StateSession) -> StateWorkTicket {
        let before = s.snapshot().unwrap();
        service
            .submit_trajectory(s, before.session_id(), before.revision())
            .unwrap()
    }
    #[test]
    fn turns_rotate_actual_jobs_and_bound_trajectory_chunks() {
        // Hold the injected pool closure; inspect each real pump turn deterministically.
        let service = StateWorkService::with_submitter(|_| ());
        let a = session("thomas_attractor");
        let b = session("lorenz_2d");
        let ta = trajectory(&service, &a);
        let tb = trajectory(&service, &b);
        assert!(service.inner.pump_turn()); // A: begin trajectory
        assert_eq!(ta.status().phase, StateWorkPhase::Running);
        assert_eq!(tb.status().phase, StateWorkPhase::Queued);
        assert!(service.inner.pump_turn()); // B: begin trajectory
        assert_eq!(tb.status().phase, StateWorkPhase::Running);
        let before = a.snapshot().unwrap();
        // A legacy diagnostic begin replaces the service-owned token.
        a.begin_trajectory_async(
            before.session_id(),
            before.revision(),
            &StateTrajectoryGuard::new(true),
        )
        .unwrap();
        let before = a.snapshot().unwrap();
        // Both kinds share a Session; the wall target is staged until its terminal turn.
        let wall = service
            .submit_number_wall(
                &a,
                before.session_id(),
                before.revision(),
                StateCommand::load(
                    Some("number_wall".into()),
                    [("prime".into(), StateValue::from_text("97".into()))].into(),
                    StateCamera {
                        view: StateView {
                            zoom: 1.0,
                            pan_x: 0.0,
                            pan_y: 0.0,
                            rot_x: 0.0,
                            rot_y: 0.0,
                            rot_z: 0.0,
                        },
                        has_trajectory: false,
                    },
                    false,
                ),
                100_000,
            )
            .unwrap();
        assert!(service.inner.pump_turn()); // A: wall, rotating kinds
        assert_ne!(wall.status().phase, StateWorkPhase::Queued);
        assert!(service.inner.pump_turn()); // B: one <=256-step chunk
        assert!(tb.status().steps_completed.is_some_and(|n| n <= 256));
        service.inner.pump();
        assert_eq!(ta.status().phase, StateWorkPhase::Failed);
        assert!(a.snapshot().unwrap().trajectory_frame().is_none());
        assert_eq!(tb.status().phase, StateWorkPhase::Finished);
        assert_eq!(wall.status().phase, StateWorkPhase::Finished);
        assert_eq!(
            wall.status().wall_status,
            Some(StateNumberWallStatus::VerifiedPrime)
        );
        assert!(
            wall.status()
                .snapshot
                .unwrap()
                .number_wall_frame()
                .is_some()
        );
        assert!(service.inner.state.lock().unwrap().queue.is_empty());
    }
    #[test]
    fn job_panic_releases_once_and_other_sessions_remain_usable() {
        let service = StateWorkService::with_submitter(|_| ());
        let a = session("thomas_attractor");
        let ticket = trajectory(&service, &a);
        let turn = service
            .inner
            .state
            .lock()
            .unwrap()
            .queue
            .next_turn()
            .unwrap();
        service.inner.run_turn(&turn, &ticket.inner, || {
            let _session_lock = a.inner.lock().unwrap();
            panic!("injected job failure");
        });
        assert_eq!(ticket.status().phase, StateWorkPhase::Failed);
        assert_eq!(
            ticket.status().error.as_deref(),
            Some("Scheduled job panicked")
        );
        ticket.cancel();
        assert!(service.inner.state.lock().unwrap().queue.is_empty());
        let b = session("thomas_attractor");
        let good = trajectory(&service, &b);
        service.inner.pump();
        assert_eq!(good.status().phase, StateWorkPhase::Finished);
    }
}
