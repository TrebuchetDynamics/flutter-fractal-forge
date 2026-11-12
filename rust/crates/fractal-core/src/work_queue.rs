//! Pure admission and selection policy. The consumer executes one bounded chunk per turn.
//! No Session state, executor, hidden waiters, or completed-result registry lives here.
use crate::session::{RequestGuard, RequestKind};
use std::{
    collections::VecDeque,
    sync::{Arc, Mutex},
};

pub const DEFAULT_CAPACITY: usize = 8;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct WorkKey {
    pub session_id: u64,
    pub kind: RequestKind,
    pub generation: u64,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum AdmissionError {
    Busy,
    AlreadyAdmitted,
    ForeignPermit,
    StalePermit,
    TicketOverflow,
}

/// Opaque selection identity; selecting does not release its permit.
#[derive(Debug, Clone)]
pub struct Turn {
    key: WorkKey,
    ticket: u64,
    identity: Arc<()>,
}
impl PartialEq for Turn {
    fn eq(&self, other: &Self) -> bool {
        self.key == other.key
            && self.ticket == other.ticket
            && Arc::ptr_eq(&self.identity, &other.identity)
    }
}
impl Eq for Turn {}
impl Turn {
    pub fn key(&self) -> WorkKey {
        self.key
    }
}

#[derive(Debug)]
struct Entry {
    turn: Turn,
    guard: RequestGuard,
}
#[derive(Debug)]
struct SessionWork {
    id: u64,
    entries: [Option<Entry>; 2],
    next_kind: usize,
}
#[derive(Debug, Default)]
struct State {
    sessions: VecDeque<SessionWork>,
    ticket: u64,
}
impl State {
    fn len(&self) -> usize {
        self.sessions
            .iter()
            .flat_map(|s| &s.entries)
            .flatten()
            .count()
    }
    fn entry(&self, key: WorkKey) -> Option<&Entry> {
        self.sessions
            .iter()
            .find(|s| s.id == key.session_id)?
            .entries[kind_index(key.kind)]
        .as_ref()
    }
    fn remove(&mut self, turn: &Turn) -> bool {
        let Some(index) = self
            .sessions
            .iter()
            .position(|s| s.id == turn.key.session_id)
        else {
            return false;
        };
        let slot = &mut self.sessions[index].entries[kind_index(turn.key.kind)];
        if !slot.as_ref().is_some_and(|entry| entry.turn == *turn) {
            return false;
        }
        slot.take().expect("matching entry").guard.revoke();
        if self.sessions[index].entries.iter().all(Option::is_none) {
            self.sessions.remove(index);
        }
        true
    }
}
fn kind_index(kind: RequestKind) -> usize {
    match kind {
        RequestKind::NumberWall => 0,
        RequestKind::Trajectory => 1,
    }
}

/// Clone shares one fixed eight-job admission domain. Use one serialized chunk consumer.
#[derive(Debug, Clone, Default)]
pub struct WorkQueue(Arc<Mutex<State>>);

/// Non-cloneable ownership: drop, including panic unwind, revokes exactly this job.
#[derive(Debug)]
pub struct Permit {
    queue: WorkQueue,
    turn: Turn,
    guard: RequestGuard,
}
impl Permit {
    pub fn key(&self) -> WorkKey {
        self.turn.key
    }
    pub fn guard(&self) -> RequestGuard {
        self.guard.clone()
    }
    pub fn matches(&self, turn: &Turn) -> bool {
        self.turn == *turn && self.guard.is_active()
    }
}
impl Drop for Permit {
    fn drop(&mut self) {
        self.queue
            .0
            .lock()
            .expect("work queue poisoned")
            .remove(&self.turn);
    }
}
impl WorkQueue {
    pub fn len(&self) -> usize {
        self.0.lock().expect("work queue poisoned").len()
    }
    pub fn is_empty(&self) -> bool {
        self.len() == 0
    }

    pub fn try_admit(&self, key: WorkKey) -> Result<Permit, AdmissionError> {
        self.admit(key, None)
    }

    /// Atomic matching replacement, even at capacity. Older generations cannot replace.
    pub fn replace(&self, old: &Permit, key: WorkKey) -> Result<Permit, AdmissionError> {
        self.admit(key, Some(old))
    }

    fn admit(&self, key: WorkKey, old: Option<&Permit>) -> Result<Permit, AdmissionError> {
        let mut state = self.0.lock().expect("work queue poisoned");
        if let Some(old) = old {
            self.validate(&state, old)?;
            if old.key().session_id != key.session_id
                || old.key().kind != key.kind
                || key.generation <= old.key().generation
            {
                return Err(AdmissionError::StalePermit);
            }
        } else {
            if state.entry(key).is_some() {
                return Err(AdmissionError::AlreadyAdmitted);
            }
            if state.len() == DEFAULT_CAPACITY {
                return Err(AdmissionError::Busy);
            }
        }
        // Reserve before any revocation/mutation. Exhaustion never wraps or loses old work.
        let ticket = state
            .ticket
            .checked_add(1)
            .ok_or(AdmissionError::TicketOverflow)?;
        let turn = Turn {
            key,
            ticket,
            identity: Arc::new(()),
        };
        let guard = RequestGuard::new(true);
        if !state.sessions.iter().any(|s| s.id == key.session_id) {
            state.sessions.push_back(SessionWork {
                id: key.session_id,
                entries: [None, None],
                next_kind: 0,
            });
        }
        let session = state
            .sessions
            .iter_mut()
            .find(|s| s.id == key.session_id)
            .expect("admitted session");
        let slot = &mut session.entries[kind_index(key.kind)];
        if let Some(entry) = slot.take() {
            entry.guard.revoke();
        }
        *slot = Some(Entry {
            turn: turn.clone(),
            guard: guard.clone(),
        });
        state.ticket = ticket;
        Ok(Permit {
            queue: self.clone(),
            turn,
            guard,
        })
    }

    fn validate(&self, state: &State, permit: &Permit) -> Result<(), AdmissionError> {
        if !Arc::ptr_eq(&self.0, &permit.queue.0) {
            return Err(AdmissionError::ForeignPermit);
        }
        if !state
            .entry(permit.key())
            .is_some_and(|e| e.turn == permit.turn)
        {
            return Err(AdmissionError::StalePermit);
        }
        Ok(())
    }

    /// Select only; never executes math. Every admitted Session is runnable until removed.
    /// The consumer must finish/revoke or drop on terminal/error/cancel/Session close.
    pub fn next_turn(&self) -> Option<Turn> {
        let mut state = self.0.lock().expect("work queue poisoned");
        let mut session = state.sessions.pop_front()?;
        let kind = if session.entries[session.next_kind].is_some() {
            session.next_kind
        } else {
            1 - session.next_kind
        };
        let turn = session.entries[kind]
            .as_ref()
            .expect("nonempty session")
            .turn
            .clone();
        session.next_kind = 1 - kind;
        state.sessions.push_back(session);
        Some(turn)
    }

    pub fn finish(&self, permit: &Permit) -> Result<(), AdmissionError> {
        self.revoke(permit)
    }
    pub fn revoke(&self, permit: &Permit) -> Result<(), AdmissionError> {
        let mut state = self.0.lock().expect("work queue poisoned");
        self.validate(&state, permit)?;
        state.remove(&permit.turn);
        Ok(())
    }

    /// Session close. Outstanding permits become stale; other Sessions are untouched.
    pub fn close(&self, session_id: u64) {
        let mut state = self.0.lock().expect("work queue poisoned");
        if let Some(index) = state.sessions.iter().position(|s| s.id == session_id) {
            for entry in state
                .sessions
                .remove(index)
                .expect("session index")
                .entries
                .into_iter()
                .flatten()
            {
                entry.guard.revoke();
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn ticket_exhaustion_is_atomic() {
        let queue = WorkQueue::default();
        let key = WorkKey {
            session_id: 1,
            kind: RequestKind::Trajectory,
            generation: 1,
        };
        let old = queue.try_admit(key).unwrap();
        queue.0.lock().unwrap().ticket = u64::MAX;
        assert!(matches!(
            queue.replace(
                &old,
                WorkKey {
                    generation: 2,
                    ..key
                }
            ),
            Err(AdmissionError::TicketOverflow)
        ));
        assert!(old.guard().is_active());
        assert_eq!(queue.len(), 1);
        assert!(matches!(
            queue.try_admit(WorkKey {
                session_id: 2,
                ..key
            }),
            Err(AdmissionError::TicketOverflow)
        ));
    }
}
