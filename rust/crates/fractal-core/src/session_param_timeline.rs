//! Explicit ordered parameter callbacks, with no clock, timer or bridge route.

use super::*;
use crate::param_interpolation::interpolate_parameters;

type Params = BTreeMap<String, ParameterValue>;

/// Generation allocated by a successful start/replacement publication.
/// Identity allocation, like Session itself, belongs to the caller.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct ParamTimelineToken {
    session_id: u64,
    revision: u64,
}

#[derive(Debug, Clone, PartialEq)]
pub(super) struct ParamTimeline {
    token: ParamTimelineToken,
    from: Params,
    target: Params,
    step: u32,
}

impl Session {
    /// Start or replace from current live parameters (step zero). The complete
    /// typed target must already satisfy the current module's schema; it is not
    /// normalized on admission or final assignment. Number Walls uses its own
    /// certified-frame ingress, never this ordinary randomization timeline.
    pub fn start_param_timeline(
        &mut self,
        session_id: u64,
        expected_revision: u64,
        target: Params,
    ) -> Result<ParamTimelineToken, SessionError> {
        self.check_owner(session_id, expected_revision)?;
        if self.state.module_id == "number_wall" {
            return Err(SessionError::UnsupportedOperation(
                "Number Walls parameter timeline".into(),
            ));
        }
        let data = module_data(&self.catalog, &self.state.module_id)?;
        if target.len() != data.parameters.len() {
            return Err(SessionError::InvalidParameterTarget(
                "expected complete schema parameters".into(),
            ));
        }
        for schema in data.parameters {
            let valid = target
                .get(&schema.id)
                .is_some_and(|value| normalize_parameter(schema, &value.clone().into()) == *value);
            if !valid {
                return Err(SessionError::InvalidParameterTarget(schema.id.clone()));
            }
        }
        let revision = expected_revision
            .checked_add(1)
            .ok_or(SessionError::RevisionOverflow)?;
        let token = ParamTimelineToken {
            session_id,
            revision,
        };
        self.param_timeline = Some(ParamTimeline {
            token,
            from: self.state.params.clone(),
            target,
            step: 0,
        });
        number_wall::cancel_state(&mut self.state);
        self.pending = None;
        self.state.revision = revision;
        Ok(token)
    }

    /// Consume exactly one callback, publishing one revision. No elapsed-time
    /// catch-up or externally computed intermediate map is accepted. Stopped,
    /// completed and replaced generations are no-ops; foreign tokens are errors.
    pub fn tick_param_timeline(
        &mut self,
        session_id: u64,
        expected_revision: u64,
        token: ParamTimelineToken,
    ) -> Result<Snapshot, SessionError> {
        self.check_owner(session_id, expected_revision)?;
        if token.session_id != session_id {
            return Err(SessionError::WrongSession);
        }
        let Some(timeline) = self.param_timeline.as_ref().filter(|t| t.token == token) else {
            return Ok(self.snapshot());
        };
        let revision = expected_revision
            .checked_add(1)
            .ok_or(SessionError::RevisionOverflow)?;
        let data = module_data(&self.catalog, &self.state.module_id)?;
        let step = timeline.step + 1;
        let params =
            interpolate_parameters(data.parameters, &timeline.from, &timeline.target, step);
        self.state.params = params;
        self.state.revision = revision;
        if step == 36 {
            self.param_timeline = None;
        } else {
            self.param_timeline.as_mut().expect("current timeline").step = step;
        }
        Ok(self.snapshot())
    }

    /// Idempotent, generation-specific cancellation; never cancels a replacement.
    pub fn cancel_param_timeline(
        &mut self,
        session_id: u64,
        expected_revision: u64,
        token: ParamTimelineToken,
    ) -> Result<Snapshot, SessionError> {
        self.check_owner(session_id, expected_revision)?;
        if token.session_id != session_id {
            return Err(SessionError::WrongSession);
        }
        if self
            .param_timeline
            .as_ref()
            .is_some_and(|t| t.token == token)
        {
            let revision = expected_revision
                .checked_add(1)
                .ok_or(SessionError::RevisionOverflow)?;
            self.param_timeline = None;
            self.state.revision = revision;
        }
        Ok(self.snapshot())
    }
}

pub(super) fn cancelled_by(state: &Snapshot, command: &Command) -> bool {
    match command {
        Command::Param { id, .. } => state.params.contains_key(id),
        Command::ApplyPreset { .. }
        | Command::Load { .. }
        | Command::SelectModule { .. }
        | Command::ResetParams
        | Command::ResetSession => true,
        // Camera adaptation can edit iterations but does not stop the source timer.
        _ => false,
    }
}
