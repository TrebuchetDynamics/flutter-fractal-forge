//! Seeded immediate targets and request-local wall undo; no entropy or timer.

use super::*;
use crate::{
    param_randomization::{general_targets, number_wall_targets},
    seeded_random::SeededRandom,
};

impl Snapshot {
    pub fn can_undo_number_wall_randomization(&self) -> bool {
        self.module_id == "number_wall" && self.number_wall_randomize_undo.is_some()
    }
}

impl Session {
    /// Ordinary modules commit immediately. Number Walls must use certified
    /// staged ingress; pure typed targets remain available for the timeline.
    pub fn randomize_params(
        &mut self,
        session_id: u64,
        expected_revision: u64,
        seed: i64,
    ) -> Result<Snapshot, SessionError> {
        self.check_owner(session_id, expected_revision)?;
        if self.state.module_id == "number_wall" {
            return Err(SessionError::DeferredOperation);
        }
        let data = module_data(&self.catalog, &self.state.module_id)?;
        let params = general_targets(
            data.parameters,
            &self.state.params,
            &mut SeededRandom::new(seed),
        )
        .map_err(SessionError::Randomization)?;
        let revision = expected_revision
            .checked_add(1)
            .ok_or(SessionError::RevisionOverflow)?;
        let mut candidate = self.state.clone();
        candidate.params = params;
        number_wall::cancel_state(&mut candidate);
        trajectory_jobs::invalidate_changed(&self.state, &mut candidate, revision);
        candidate.reserve_terminals(revision)?;
        candidate.revision = revision;
        self.param_timeline = None;
        self.pending = None;
        self.publish_candidate(candidate);
        Ok(self.snapshot())
    }

    /// Capture the current committed params/grid, not a pending target. The
    /// request alone owns this provenance until its successful publication.
    /// No committed wall or inactive ownership means no change, as in Dart.
    pub fn begin_number_wall_randomization(
        &mut self,
        session_id: u64,
        expected_revision: u64,
        seed: i64,
        guard: RequestGuard,
        max_trial_divisions: u32,
    ) -> Result<Option<RequestToken>, SessionError> {
        self.check_owner(session_id, expected_revision)?;
        if self.state.module_id != "number_wall" || !guard.is_active() {
            return Ok(None);
        }
        let Some(previous) = self.state.number_wall_frame.clone() else {
            return Ok(None);
        };
        let data = module_data(&self.catalog, "number_wall")?;
        let params = number_wall_targets(data.parameters, &self.state.params, seed)
            .map_err(SessionError::Randomization)?;
        let command = Command::Load {
            module_id: None,
            params: params.into_iter().map(|(k, v)| (k, v.into())).collect(),
            camera: ViewInput {
                zoom: self.state.view.zoom(),
                pan: self.state.view.pan(),
                rotation: self.state.view.rotation(),
            }
            .into(),
            transparent: self.state.transparent_background,
        };
        self.begin_number_wall_request(
            session_id,
            expected_revision,
            &command,
            guard,
            max_trial_divisions,
            Some(previous),
        )
    }

    /// Restore one exact frame atomically, keeping the current camera and
    /// transparency. A second undo is false and does not consume a revision.
    pub fn undo_number_wall_randomization(
        &mut self,
        session_id: u64,
        expected_revision: u64,
    ) -> Result<bool, SessionError> {
        self.check_owner(session_id, expected_revision)?;
        if !self.state.can_undo_number_wall_randomization() {
            return Ok(false);
        }
        let revision = expected_revision
            .checked_add(1)
            .ok_or(SessionError::RevisionOverflow)?;
        let mut candidate = self.state.clone();
        let previous = candidate
            .number_wall_randomize_undo
            .take()
            .expect("available undo");
        number_wall::cancel_state(&mut candidate);
        candidate.params = previous.params().clone();
        candidate.number_wall_frame = Some(previous);
        candidate.number_wall_status = Some(NumberWallPrimeStatus::VerifiedPrime);
        candidate.last_adaptive_zoom = candidate.view.zoom();
        candidate.reserve_terminals(revision)?;
        candidate.revision = revision;
        self.pending = None;
        self.param_timeline = None;
        self.publish_candidate(candidate);
        Ok(true)
    }
}
