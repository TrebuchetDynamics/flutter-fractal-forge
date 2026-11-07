//! Staged, Rust-local Number Walls ingress; no callback or executor.

use super::*;
use crate::number_wall_frame::NumberWallFrameJob;
use std::sync::atomic::{AtomicBool, Ordering};

/// Session-local identity, allocated only by an accepted begin publication.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct RequestToken {
    pub(super) session_id: u64,
    pub(super) revision: u64,
    pub(super) kind: RequestKind,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum RequestKind {
    NumberWall,
    Trajectory,
}

impl RequestToken {
    pub fn kind(self) -> RequestKind {
        self.kind
    }
}

/// Monotonic revocation shared by the owner and its request, not foreign code.
#[derive(Debug, Clone)]
pub struct RequestGuard(pub(super) Arc<AtomicBool>);

impl RequestGuard {
    pub fn new(active: bool) -> Self {
        Self(Arc::new(AtomicBool::new(!active)))
    }
    pub fn revoke(&self) {
        self.0.store(true, Ordering::SeqCst);
    }
    pub fn is_active(&self) -> bool {
        !self.0.load(Ordering::SeqCst)
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum RequestProgress {
    Pending,
    Finished(NumberWallPrimeStatus),
}

#[derive(Debug)]
pub(super) struct PendingRequest {
    token: RequestToken,
    pub(super) target: Snapshot,
    guard: RequestGuard,
    job: NumberWallFrameJob,
}

impl Snapshot {
    pub fn number_wall_pending(&self) -> Option<RequestToken> {
        self.pending
    }
    pub fn number_wall_status(&self) -> Option<NumberWallPrimeStatus> {
        self.number_wall_status
    }
    /// Retained even when navigating away, as in the source controller.
    pub fn number_wall_frame(&self) -> Option<&Arc<NumberWallFrame>> {
        self.number_wall_frame.as_ref()
    }
}

impl Session {
    pub(super) fn check_owner(&self, session_id: u64, revision: u64) -> Result<(), SessionError> {
        if session_id != self.state.session_id {
            return Err(SessionError::WrongSession);
        }
        if revision != self.state.revision {
            return Err(SessionError::StaleRevision);
        }
        Ok(())
    }

    /// Stages one complete ingress, never drains work. Non-deferred commands use
    /// the ordinary transaction seam and return no request. An inactive guard
    /// has no effect, including on any existing request.
    pub fn begin_number_wall(
        &mut self,
        session_id: u64,
        expected_revision: u64,
        command: &Command,
        guard: RequestGuard,
        max_trial_divisions: u32,
    ) -> Result<Option<RequestToken>, SessionError> {
        self.check_owner(session_id, expected_revision)?;
        if !guard.is_active() {
            return Ok(None);
        }
        let mut candidate = self.state.clone();
        let target = plan_command(
            &self.catalog,
            &mut candidate,
            command,
            self.pending.as_ref().map(|p| &p.target),
        )?;
        let Some(target) = target else {
            self.apply_batch(session_id, expected_revision, std::slice::from_ref(command))?;
            return Ok(None);
        };
        // Reserve both admission and terminal publication before replacing work.
        expected_revision
            .checked_add(2)
            .ok_or(SessionError::RevisionOverflow)?;
        let revision = expected_revision + 1;
        let token = RequestToken {
            session_id,
            revision,
            kind: RequestKind::NumberWall,
        };
        let prime = match target.params.get("prime") {
            Some(ParameterValue::Text(prime)) => prime.as_str(),
            _ => "",
        };
        let job = NumberWallFrameJob::new(
            prime,
            target.params.clone(),
            candidate.number_wall_frame.as_deref(),
            max_trial_divisions,
        );
        if !guard.is_active() {
            return Ok(None);
        }
        candidate.revision = revision;
        candidate.pending = Some(token);
        candidate.number_wall_status = None;
        trajectory_jobs::invalidate_changed(&self.state, &mut candidate, revision);
        candidate.reserve_terminals(revision)?;
        self.pending = Some(PendingRequest {
            token,
            target,
            guard,
            job,
        });
        self.param_timeline = None;
        self.publish_candidate(candidate);
        Ok(Some(token))
    }

    /// One bounded frame step. Old tokens publish nothing, even after revocation.
    pub fn advance_number_wall(
        &mut self,
        session_id: u64,
        expected_revision: u64,
        token: RequestToken,
        work_limit: usize,
    ) -> Result<RequestProgress, SessionError> {
        self.check_owner(session_id, expected_revision)?;
        if token.session_id != session_id {
            return Err(SessionError::WrongSession);
        }
        let Some(request) = self.pending.as_mut().filter(|p| p.token == token) else {
            return Ok(RequestProgress::Finished(NumberWallPrimeStatus::Cancelled));
        };
        let result = request.job.advance(&request.guard.0, work_limit).cloned();
        if !request.guard.is_active() {
            return self.cancel_number_wall(session_id, expected_revision, token);
        }
        let Some(result) = result else {
            return Ok(RequestProgress::Pending);
        };
        // Ownership and the guard are checked again at the publication boundary.
        if self.state.pending != Some(token) {
            return Ok(RequestProgress::Finished(NumberWallPrimeStatus::Cancelled));
        }
        if !request.guard.is_active() {
            return self.cancel_number_wall(session_id, expected_revision, token);
        }
        let revision = expected_revision
            .checked_add(1)
            .ok_or(SessionError::RevisionOverflow)?;
        let request = self.pending.take().expect("current request");
        if let Some(frame) = result.frame() {
            let mut target = request.target;
            // A staged wall target must not resurrect or roll back trajectory ownership.
            target.trajectory_generation = self.state.trajectory_generation;
            target.trajectory_pending = self.state.trajectory_pending;
            target.trajectory_status = self.state.trajectory_status;
            target.trajectory_frame = self.state.trajectory_frame.clone();
            trajectory_jobs::invalidate_changed(&self.state, &mut target, revision);
            target.params = frame.params().clone();
            target.number_wall_frame = Some(Arc::new(frame.clone()));
            self.publish_candidate(target);
        }
        self.state.pending = None;
        self.state.number_wall_status = Some(result.status());
        self.state.revision = revision;
        Ok(RequestProgress::Finished(result.status()))
    }

    pub fn cancel_number_wall(
        &mut self,
        session_id: u64,
        expected_revision: u64,
        token: RequestToken,
    ) -> Result<RequestProgress, SessionError> {
        self.check_owner(session_id, expected_revision)?;
        if token.session_id != session_id {
            return Err(SessionError::WrongSession);
        }
        if self.state.pending == Some(token) {
            let revision = expected_revision
                .checked_add(1)
                .ok_or(SessionError::RevisionOverflow)?;
            cancel_state(&mut self.state);
            self.state.revision = revision;
            self.pending = None;
        }
        Ok(RequestProgress::Finished(NumberWallPrimeStatus::Cancelled))
    }
}

pub(super) fn cancel_state(state: &mut Snapshot) {
    if state.pending.take().is_some() {
        state.number_wall_status = Some(NumberWallPrimeStatus::Cancelled);
    }
}

fn raw_params(params: &BTreeMap<String, ParameterValue>) -> RawParams {
    params
        .iter()
        .map(|(k, v)| (k.clone(), v.clone().into()))
        .collect()
}

fn wall_target(
    catalog: &CatalogBaseline,
    state: &Snapshot,
    params: &RawParams,
    camera: CameraInput,
    transparent: bool,
) -> Result<Snapshot, SessionError> {
    let data = module_data(catalog, "number_wall")?;
    let mut target = state.clone();
    target.module_id = "number_wall".into();
    target.params = normalized_params(data.parameters, params);
    // Prime syntax must reach certification verbatim; schema fallback is no proof.
    let prime = match params.get("prime") {
        Some(RawScalar::Text(s)) => s.clone(),
        _ => String::new(),
    };
    target
        .params
        .insert("prime".into(), ParameterValue::Text(prime));
    target.effects.apply_module_policy("number_wall");
    set_view(&mut target, camera, false)?;
    target.transparent_background = transparent;
    Ok(target)
}

/// Pure transaction planning: Some is deferred, None is an immediate edit.
/// Neither failed planning nor rejected mixed batches can touch the live job.
pub(super) fn plan_command(
    catalog: &CatalogBaseline,
    state: &mut Snapshot,
    command: &Command,
    pending_target: Option<&Snapshot>,
) -> Result<Option<Snapshot>, SessionError> {
    let camera = CameraInput::from(ViewInput {
        zoom: state.view.zoom(),
        pan: state.view.pan(),
        rotation: state.view.rotation(),
    });
    let default = || -> Result<RawParams, SessionError> {
        Ok(raw_params(&default_params(
            &module_data(catalog, "number_wall")?,
            &RawParams::new(),
        )))
    };
    let target = match command {
        Command::Load {
            module_id,
            params,
            camera,
            transparent,
        } if module_id.as_deref().unwrap_or(&state.module_id) == "number_wall" => {
            Some(wall_target(catalog, state, params, *camera, *transparent)?)
        }
        Command::ApplyPreset {
            module_id,
            params,
            camera,
        } if module_id == "number_wall" => Some(wall_target(
            catalog,
            state,
            params,
            *camera,
            state.transparent_background,
        )?),
        Command::SelectModule {
            module_id,
            reset_view,
            initial_params,
        } if module_id == "number_wall" => {
            let data = module_data(catalog, "number_wall")?;
            let exposes_defaults = state.module_id != "number_wall" && initial_params.is_empty();
            if exposes_defaults {
                state.module_id = "number_wall".into();
                state.params = default_params(&data, initial_params);
                state.number_wall_frame = None;
                set_view(state, default_camera(data.default)?, false)?;
            }
            let mut params = default()?;
            params.extend(initial_params.clone());
            let view = if *reset_view || exposes_defaults {
                default_camera(data.default)?
            } else {
                camera
            };
            Some(wall_target(
                catalog,
                state,
                &params,
                view,
                state.transparent_background,
            )?)
        }
        Command::NumberWallPrime(prime) if state.module_id == "number_wall" => {
            let mut params = raw_params(&pending_target.unwrap_or(state).params);
            params.insert("prime".into(), RawScalar::Text(prime.clone()));
            Some(wall_target(
                catalog,
                state,
                &params,
                camera,
                state.transparent_background,
            )?)
        }
        Command::NumberWallPrime(_) => None,
        Command::Param { id, value } if state.module_id == "number_wall" => {
            let data = module_data(catalog, "number_wall")?;
            let Some(schema) = data
                .parameters
                .iter()
                .find(|p| p.id == *id && id != "prime")
            else {
                return Ok(None);
            };
            let value = normalize_parameter(schema, value);
            if let Some(frame) = state
                .number_wall_frame
                .as_ref()
                .and_then(|f| f.restyle(id, value.clone()))
            {
                cancel_state(state);
                state.params = frame.params().clone();
                state.number_wall_frame = Some(Arc::new(frame));
                return Ok(None);
            }
            let mut params = raw_params(&pending_target.unwrap_or(state).params);
            params.insert("prime".into(), state.params["prime"].clone().into());
            params.insert(id.clone(), value.into());
            if id == "rows" {
                let n = |key: &str| match &params[key] {
                    RawScalar::Number(n) => n.as_i64().expect("normalized integer"),
                    _ => unreachable!(),
                };
                params.insert(
                    "columnStart".into(),
                    RawScalar::Number((n("rows") - 1).max(n("columnStart")).into()),
                );
            }
            Some(wall_target(
                catalog,
                state,
                &params,
                camera,
                state.transparent_background,
            )?)
        }
        Command::ResetParams | Command::ResetSession if state.module_id == "number_wall" => {
            let reset = matches!(command, Command::ResetSession);
            Some(wall_target(
                catalog,
                state,
                &default()?,
                if reset {
                    default_camera(module_data(catalog, "number_wall")?.default)?
                } else {
                    camera
                },
                if reset {
                    false
                } else {
                    state.transparent_background
                },
            )?)
        }
        _ => {
            let before = state.clone();
            apply_command(catalog, state, command)?;
            let cancels = match command {
                Command::Zoom(_)
                | Command::Pan(_)
                | Command::Rotation(_)
                | Command::View { .. }
                | Command::SelectModule { .. }
                | Command::Load { .. }
                | Command::ApplyPreset { .. }
                | Command::ResetParams
                | Command::ResetView
                | Command::ResetSession => true,
                Command::Param { id, .. } => state.params.contains_key(id),
                _ => {
                    state.effects != before.effects
                        || state.transparent_background != before.transparent_background
                }
            };
            if cancels {
                cancel_state(state);
            }
            if matches!(command, Command::SelectModule { .. } | Command::Load { .. }) {
                state.number_wall_status = None;
            }
            None
        }
    };
    Ok(target)
}
