//! Session-owned bounded requests and an explicit shared completed-sample cache.
use super::*;
use crate::trajectory::{AttractorTrajectory, TrajectoryError, TrajectoryJob};
use std::{collections::VecDeque, sync::Mutex};

/// Clone this service into multiple Sessions (one process service for the bridge).
/// Only completed successes are cached; independent misses are not deduplicated.
#[derive(Debug, Clone, Default)]
pub struct TrajectoryCache(Arc<Mutex<VecDeque<Arc<AttractorTrajectory>>>>);

impl TrajectoryCache {
    fn lookup(&self, settings: OrbitTrajectorySettings) -> Option<Arc<AttractorTrajectory>> {
        let mut entries = self.0.lock().expect("trajectory cache poisoned");
        // Validated settings equality includes every field, with numeric float equality.
        let index = entries
            .iter()
            .position(|entry| *entry.settings() == settings)?;
        let entry = entries.remove(index).expect("cache index");
        entries.push_back(entry.clone());
        Some(entry)
    }

    fn insert(&self, trajectory: Arc<AttractorTrajectory>) {
        let mut entries = self.0.lock().expect("trajectory cache poisoned");
        entries.retain(|entry| entry.settings() != trajectory.settings());
        entries.push_back(trajectory);
        if entries.len() > 3 {
            entries.pop_front();
        }
    }
}

/// Detached immutable samples/bounds plus the provenance of this publication.
#[derive(Debug, Clone, PartialEq)]
pub struct TrajectoryFrame {
    token: RequestToken,
    module_id: String,
    settings_generation: u64,
    trajectory: Arc<AttractorTrajectory>,
    cache_hit: bool,
}

impl TrajectoryFrame {
    pub fn token(&self) -> RequestToken {
        self.token
    }
    pub fn module_id(&self) -> &str {
        &self.module_id
    }
    pub fn settings_generation(&self) -> u64 {
        self.settings_generation
    }
    pub fn trajectory(&self) -> &Arc<AttractorTrajectory> {
        &self.trajectory
    }
    pub fn cache_hit(&self) -> bool {
        self.cache_hit
    }
}

#[derive(Debug, Clone, PartialEq)]
pub enum TrajectoryProgress {
    Pending { steps_completed: u32 },
    Finished(Result<Arc<TrajectoryFrame>, TrajectoryError>),
}

#[derive(Debug)]
pub(super) struct PendingTrajectory {
    token: RequestToken,
    module_id: String,
    generation: u64,
    settings: OrbitTrajectorySettings,
    guard: RequestGuard,
    work: TrajectoryWork,
}

#[derive(Debug)]
enum TrajectoryWork {
    Cached(Arc<AttractorTrajectory>),
    Job(Box<TrajectoryJob>),
}

impl Snapshot {
    pub fn trajectory_generation(&self) -> u64 {
        self.trajectory_generation
    }
    pub fn trajectory_pending(&self) -> Option<RequestToken> {
        self.trajectory_pending
    }
    pub fn trajectory_status(&self) -> Option<Result<(), TrajectoryError>> {
        self.trajectory_status
    }
    /// Last good frame, retained on cancellation, divergence and metadata changes.
    /// Its settings/generation describe its samples, not necessarily the current view.
    pub fn trajectory_frame(&self) -> Option<&Arc<TrajectoryFrame>> {
        self.trajectory_frame.as_ref()
    }

    pub(super) fn reserve_terminals(&self, revision: u64) -> Result<(), SessionError> {
        revision
            .checked_add(
                u64::from(self.pending.is_some()) + u64::from(self.trajectory_pending.is_some()),
            )
            .ok_or(SessionError::RevisionOverflow)?;
        Ok(())
    }
}

impl Session {
    pub(super) fn publish_candidate(&mut self, candidate: Snapshot) {
        if self
            .trajectory_request
            .as_ref()
            .is_some_and(|r| candidate.trajectory_pending != Some(r.token))
        {
            self.trajectory_request = None;
        }
        self.state = candidate;
    }

    /// Capture the current typed settings, never run integration. Even cache hits
    /// publish only on advance. Inactive guards leave existing requests untouched.
    pub fn begin_trajectory(
        &mut self,
        session_id: u64,
        expected_revision: u64,
        guard: RequestGuard,
    ) -> Result<Option<RequestToken>, SessionError> {
        self.check_owner(session_id, expected_revision)?;
        if !guard.is_active() {
            return Ok(None);
        }
        let settings = self
            .state
            .trajectory
            .ok_or(SessionError::UnsupportedTrajectory)?;
        let revision = expected_revision
            .checked_add(1)
            .ok_or(SessionError::RevisionOverflow)?;
        let token = RequestToken {
            session_id,
            revision,
            kind: RequestKind::Trajectory,
        };
        let mut candidate = self.state.clone();
        candidate.revision = revision;
        candidate.trajectory_pending = Some(token);
        candidate.trajectory_status = None;
        candidate.reserve_terminals(revision)?;
        let work = self.trajectory_cache.lookup(settings).map_or_else(
            || TrajectoryWork::Job(Box::new(TrajectoryJob::new(settings))),
            TrajectoryWork::Cached,
        );
        if !guard.is_active() {
            return Ok(None);
        }
        self.trajectory_request = Some(PendingTrajectory {
            token,
            module_id: self.state.module_id.clone(),
            generation: self.state.trajectory_generation,
            settings,
            guard,
            work,
        });
        self.publish_candidate(candidate);
        Ok(Some(token))
    }

    /// At most one existing <=256-step kernel chunk; no drain loop. Scalar edits
    /// may advance the revision without replacing the captured settings generation.
    pub fn advance_trajectory(
        &mut self,
        session_id: u64,
        expected_revision: u64,
        token: RequestToken,
    ) -> Result<TrajectoryProgress, SessionError> {
        self.check_owner(session_id, expected_revision)?;
        if token.session_id != session_id {
            return Err(SessionError::WrongSession);
        }
        let Some(request) = self
            .trajectory_request
            .as_mut()
            .filter(|r| r.token == token)
        else {
            return Ok(TrajectoryProgress::Finished(Err(
                TrajectoryError::Cancelled,
            )));
        };
        if !request.guard.is_active()
            || self.state.trajectory_pending != Some(token)
            || self.state.trajectory_generation != request.generation
            || self.state.module_id != request.module_id
            || self.state.trajectory != Some(request.settings)
        {
            return self.cancel_trajectory(session_id, expected_revision, token);
        }
        // Check capacity before consuming even the final chunk.
        let revision = expected_revision
            .checked_add(1)
            .ok_or(SessionError::RevisionOverflow)?;
        if let TrajectoryWork::Job(job) = &mut request.work {
            let pending = job.advance(&request.guard.0).is_none();
            if !request.guard.is_active() {
                return self.cancel_trajectory(session_id, expected_revision, token);
            }
            if pending {
                return Ok(TrajectoryProgress::Pending {
                    steps_completed: job.steps_completed(),
                });
            }
        }
        if !request.guard.is_active() {
            return self.cancel_trajectory(session_id, expected_revision, token);
        }
        let request = self
            .trajectory_request
            .take()
            .expect("current trajectory request");
        let cache_hit = matches!(request.work, TrajectoryWork::Cached(_));
        let result = match request.work {
            TrajectoryWork::Cached(trajectory) => Ok(trajectory),
            TrajectoryWork::Job(job) => job
                .into_result()
                .expect("terminal trajectory")
                .map(Arc::new),
        };
        let result = result.map(|trajectory| {
            if !cache_hit {
                self.trajectory_cache.insert(trajectory.clone());
            }
            Arc::new(TrajectoryFrame {
                token,
                module_id: request.module_id,
                settings_generation: request.generation,
                trajectory,
                cache_hit,
            })
        });
        self.state.trajectory_pending = None;
        self.state.trajectory_status = Some(result.as_ref().map(|_| ()).map_err(|error| *error));
        if let Ok(frame) = &result {
            self.state.trajectory_frame = Some(frame.clone());
        }
        self.state.revision = revision;
        Ok(TrajectoryProgress::Finished(result))
    }

    pub fn cancel_trajectory(
        &mut self,
        session_id: u64,
        expected_revision: u64,
        token: RequestToken,
    ) -> Result<TrajectoryProgress, SessionError> {
        self.check_owner(session_id, expected_revision)?;
        if token.session_id != session_id {
            return Err(SessionError::WrongSession);
        }
        if self.state.trajectory_pending == Some(token) {
            let revision = expected_revision
                .checked_add(1)
                .ok_or(SessionError::RevisionOverflow)?;
            self.state.trajectory_pending = None;
            self.state.trajectory_status = Some(Err(TrajectoryError::Cancelled));
            self.state.revision = revision;
            self.trajectory_request = None;
        }
        Ok(TrajectoryProgress::Finished(Err(
            TrajectoryError::Cancelled,
        )))
    }
}

/// Called for each privately planned command, so A->B->A still invalidates A.
pub(super) fn invalidate_changed(before: &Snapshot, candidate: &mut Snapshot, revision: u64) {
    if before.trajectory != candidate.trajectory
        || (before.module_id != candidate.module_id && before.trajectory.is_some())
    {
        candidate.trajectory_generation = revision;
        if candidate.trajectory_pending.take().is_some() {
            candidate.trajectory_status = Some(Err(TrajectoryError::Cancelled));
        }
    }
}
