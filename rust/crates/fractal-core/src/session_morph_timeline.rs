//! Source-derived module morph callbacks; no clock, haptics or app routing.
use super::*;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct MorphTimelineToken {
    session_id: u64,
    generation: u64,
}

#[derive(Debug, Clone, PartialEq)]
pub(super) struct MorphTimeline {
    generation: u64,
    step: u32,
    previous: Option<String>,
    progress: f64,
}

impl Default for MorphTimeline {
    fn default() -> Self {
        Self {
            generation: 0,
            step: 36,
            previous: None,
            progress: 1.0,
        }
    }
}

impl Snapshot {
    pub fn is_morphing(&self) -> bool {
        self.morph.previous.is_some()
    }
    pub fn morph_progress(&self) -> f64 {
        self.morph.progress
    }
    pub fn previous_module_id(&self) -> Option<&str> {
        self.morph.previous.as_deref()
    }
    pub fn morph_timeline_token(&self) -> Option<MorphTimelineToken> {
        self.is_morphing().then_some(MorphTimelineToken {
            session_id: self.session_id,
            generation: self.morph.generation,
        })
    }
}

pub(super) fn selection(
    before: &Snapshot,
    candidate: &mut Snapshot,
    command: &Command,
    animate: Option<bool>,
) -> Result<(), SessionError> {
    // number_wall selection/load never calls _startMorphTransition. Same-ID
    // selection and nonanimated loads leave an existing timer alone too.
    let starts = match command {
        Command::SelectModule { .. } => animate.unwrap_or(true),
        Command::Load { .. } => animate.unwrap_or(false),
        _ => false,
    };
    if starts && before.module_id != candidate.module_id && candidate.module_id != "number_wall" {
        candidate.morph = MorphTimeline {
            generation: candidate
                .morph
                .generation
                .checked_add(1)
                .ok_or(SessionError::RevisionOverflow)?,
            step: 0,
            previous: Some(before.module_id.clone()),
            progress: 0.0,
        };
    }
    Ok(())
}

impl Session {
    /// Consume one of the source's 36 cubic callbacks. Tokens are independent
    /// of parameter interpolation generations; stale tokens are inert.
    pub fn tick_morph_timeline(
        &mut self,
        session_id: u64,
        expected_revision: u64,
        token: MorphTimelineToken,
    ) -> Result<Snapshot, SessionError> {
        self.check_owner(session_id, expected_revision)?;
        if token.session_id != session_id {
            return Err(SessionError::WrongSession);
        }
        if self.state.morph_timeline_token() != Some(token) {
            return Ok(self.snapshot());
        }
        let revision = expected_revision
            .checked_add(1)
            .ok_or(SessionError::RevisionOverflow)?;
        self.state.reserve_terminals(revision)?;
        let morph = &mut self.state.morph;
        morph.step += 1;
        morph.progress = 1.0 - (1.0 - f64::from(morph.step) / 36.0).powi(3);
        if morph.step == 36 {
            morph.previous = None;
            morph.progress = 1.0;
        }
        self.state.revision = revision;
        Ok(self.snapshot())
    }

    /// Explicit generation-specific cancellation, not an implicit load/reset rule.
    pub fn cancel_morph_timeline(
        &mut self,
        session_id: u64,
        expected_revision: u64,
        token: MorphTimelineToken,
    ) -> Result<Snapshot, SessionError> {
        self.check_owner(session_id, expected_revision)?;
        if token.session_id != session_id {
            return Err(SessionError::WrongSession);
        }
        if self.state.morph_timeline_token() == Some(token) {
            let revision = expected_revision
                .checked_add(1)
                .ok_or(SessionError::RevisionOverflow)?;
            self.state.reserve_terminals(revision)?;
            self.state.morph.previous = None;
            self.state.morph.progress = 1.0;
            self.state.morph.step = 36;
            self.state.revision = revision;
        }
        Ok(self.snapshot())
    }
}
