//! Inert scalar/effect/Number Walls owner. No app routing, executor or storage.

#[path = "session_effects.rs"]
mod effects;
#[path = "session_number_wall.rs"]
mod number_wall;
pub use number_wall::{RequestGuard, RequestProgress, RequestToken};

use crate::{number_wall_frame::NumberWallFrame, number_wall_prime::NumberWallPrimeStatus};

use crate::{
    catalog_baseline::{
        CatalogBaseline, Dimension, Module, Parameter, ParameterKind, ParameterValue, Preset, View,
    },
    normalization::{FiniteView, RawScalar, ViewInput, normalize_parameter, normalize_view},
};
use std::{collections::BTreeMap, fmt, sync::Arc};

pub type RawParams = BTreeMap<String, RawScalar>;

const INITIAL_VIEW: ViewInput = ViewInput {
    zoom: 1.0,
    pan: [0.0; 2],
    rotation: [0.0; 3],
};

/// Trajectories have no candidate representation yet. Ingress must set the
/// presence flag for every non-null trajectory, so it is rejected, not dropped.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct CameraInput {
    pub view: ViewInput,
    pub has_trajectory: bool,
}

impl From<ViewInput> for CameraInput {
    fn from(view: ViewInput) -> Self {
        Self {
            view,
            has_trajectory: false,
        }
    }
}

#[derive(Debug, Clone, PartialEq)]
pub enum Command {
    Zoom(f64),
    Pan([f64; 2]),
    Rotation([f64; 3]),
    View {
        camera: CameraInput,
        adaptive: bool,
    },
    Param {
        id: String,
        value: RawScalar,
    },
    SelectModule {
        module_id: String,
        reset_view: bool,
        initial_params: RawParams,
    },
    Transparent(bool),
    GlowEnabled(bool),
    GlowSigma(f64),
    GlowIntensity(f64),
    FluidModeEnabled(bool),
    FluidStrength(f64),
    RotationLocked(bool),
    KaleidoscopeEnabled(bool),
    KaleidoscopeSectors(i64),
    KaleidoscopeMirror(bool),
    KaleidoscopeRotation(f64),
    KaleidoscopeMirrorMode(i64),
    /// Ordinary presets normalize against the current module. Number Walls
    /// presets instead stage a complete, certified module load, as in Dart.
    ApplyPreset {
        module_id: String,
        params: RawParams,
        camera: CameraInput,
    },
    /// Missing parameters use schema defaults, not the module default preset.
    Load {
        module_id: Option<String>,
        params: RawParams,
        camera: CameraInput,
        transparent: bool,
    },
    /// Exact text, never a schema-normalized or externally certified prime.
    NumberWallPrime(String),
    ResetParams,
    ResetView,
    ResetSession,
    Unsupported {
        operation: String,
    },
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum SessionError {
    WrongSession,
    StaleRevision,
    RevisionOverflow,
    DeferredOperation,
    UnsupportedModule(String),
    UnsupportedTrajectory,
    UnsupportedOperation(String),
    InvalidCatalog(String),
}

impl fmt::Display for SessionError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{self:?}")
    }
}
impl std::error::Error for SessionError {}

/// Detached immutable state. Getters cannot mutate the session or another snapshot.
#[derive(Debug, Clone, PartialEq)]
pub struct Snapshot {
    session_id: u64,
    revision: u64,
    module_id: String,
    params: BTreeMap<String, ParameterValue>,
    view: FiniteView,
    transparent_background: bool,
    last_adaptive_zoom: f64,
    effects: effects::Effects,
    pending: Option<RequestToken>,
    number_wall_status: Option<NumberWallPrimeStatus>,
    number_wall_frame: Option<Arc<NumberWallFrame>>,
}

impl Snapshot {
    pub fn session_id(&self) -> u64 {
        self.session_id
    }
    pub fn revision(&self) -> u64 {
        self.revision
    }
    pub fn module_id(&self) -> &str {
        &self.module_id
    }
    pub fn params(&self) -> &BTreeMap<String, ParameterValue> {
        &self.params
    }
    pub fn view(&self) -> FiniteView {
        self.view
    }
    pub fn transparent_background(&self) -> bool {
        self.transparent_background
    }
    pub fn last_adaptive_zoom(&self) -> f64 {
        self.last_adaptive_zoom
    }
}

/// Owns all supported candidate fields together; the validated catalog is shared
/// read-only. Identity allocation and mutation serialization belong to the caller.
#[derive(Debug)]
pub struct Session {
    catalog: Arc<CatalogBaseline>,
    state: Snapshot,
    pending: Option<number_wall::PendingRequest>,
}

impl Session {
    pub fn new(
        catalog: Arc<CatalogBaseline>,
        session_id: u64,
        module_id: &str,
    ) -> Result<Self, SessionError> {
        let data = module_data(&catalog, module_id)?;
        let view = normalize_view(default_camera(data.default)?.view, INITIAL_VIEW, module_id);
        let mut effects = effects::Effects::default();
        effects.apply_module_policy(module_id);
        let state = Snapshot {
            session_id,
            revision: 0,
            module_id: module_id.into(),
            params: default_params(&data, &RawParams::new()),
            view,
            transparent_background: false,
            last_adaptive_zoom: view.zoom(),
            effects,
            pending: None,
            number_wall_status: None,
            number_wall_frame: None,
        };
        Ok(Self {
            catalog,
            state,
            pending: None,
        })
    }

    pub fn snapshot(&self) -> Snapshot {
        self.state.clone()
    }

    /// Evaluate every command in order on a private copy, then publish once.
    /// Even empty batches check identity/revision; valid nonempty no-ops increment.
    pub fn apply_batch(
        &mut self,
        session_id: u64,
        expected_revision: u64,
        commands: &[Command],
    ) -> Result<Snapshot, SessionError> {
        self.check_owner(session_id, expected_revision)?;
        if commands.is_empty() {
            return Ok(self.snapshot());
        }
        let revision = self
            .state
            .revision
            .checked_add(1)
            .ok_or(SessionError::RevisionOverflow)?;
        let mut candidate = self.state.clone();
        for command in commands {
            if number_wall::plan_command(
                &self.catalog,
                &mut candidate,
                command,
                self.pending.as_ref().map(|p| &p.target),
            )?
            .is_some()
            {
                return Err(SessionError::DeferredOperation);
            }
        }
        if candidate.pending.is_some() && revision.checked_add(1).is_none() {
            return Err(SessionError::RevisionOverflow);
        }
        candidate.revision = revision;
        if candidate.pending.is_none() {
            self.pending = None;
        }
        self.state = candidate;
        Ok(self.snapshot())
    }
}

struct ModuleData<'a> {
    module: &'a Module,
    parameters: &'a [Parameter],
    default: &'a Preset,
}

fn supported(module_id: &str) -> Result<(), SessionError> {
    match module_id {
        "mandelbrot"
        | "julia"
        | "cantor_set"
        | "recursive_sine_sphere"
        | "kaleidoscope_basic"
        | "kaleidoscope_fractal"
        | "number_wall" => Ok(()),
        _ => Err(SessionError::UnsupportedModule(module_id.into())),
    }
}

fn module_data<'a>(catalog: &'a CatalogBaseline, id: &str) -> Result<ModuleData<'a>, SessionError> {
    supported(id)?;
    let missing = || SessionError::InvalidCatalog(id.into());
    Ok(ModuleData {
        module: catalog
            .modules()
            .payload
            .records
            .iter()
            .find(|m| m.id.as_str() == id)
            .ok_or_else(missing)?,
        parameters: &catalog
            .parameters()
            .payload
            .records
            .iter()
            .find(|p| p.module_id.as_str() == id)
            .ok_or_else(missing)?
            .parameters,
        default: &catalog
            .presets()
            .payload
            .records
            .iter()
            .find(|p| p.module_id.as_str() == id)
            .ok_or_else(missing)?
            .default,
    })
}

fn default_camera(preset: &Preset) -> Result<CameraInput, SessionError> {
    let View {
        zoom,
        pan_x,
        pan_y,
        rot_x,
        rot_y,
        rot_z,
        metadata,
    } = &preset.view;
    let n = |value: &serde_json::Number| {
        value
            .as_f64()
            .filter(|n| n.is_finite())
            .ok_or_else(|| SessionError::InvalidCatalog(preset.id.clone()))
    };
    let camera = CameraInput {
        view: ViewInput {
            zoom: n(zoom)?,
            pan: [n(pan_x)?, n(pan_y)?],
            rotation: [n(rot_x)?, n(rot_y)?, n(rot_z)?],
        },
        has_trajectory: metadata.get("trajectory").is_some_and(|v| !v.is_null()),
    };
    check_camera(camera)?;
    Ok(camera)
}

fn check_camera(camera: CameraInput) -> Result<(), SessionError> {
    if camera.has_trajectory {
        Err(SessionError::UnsupportedTrajectory)
    } else {
        Ok(())
    }
}

fn normalized_params(
    parameters: &[Parameter],
    values: &RawParams,
) -> BTreeMap<String, ParameterValue> {
    parameters
        .iter()
        .map(|p| {
            let default = RawScalar::from(p.default.clone());
            (
                p.id.clone(),
                normalize_parameter(p, values.get(&p.id).unwrap_or(&default)),
            )
        })
        .collect()
}

fn default_params(
    data: &ModuleData<'_>,
    overrides: &RawParams,
) -> BTreeMap<String, ParameterValue> {
    let mut values: RawParams = data
        .default
        .params
        .iter()
        .map(|(k, v)| (k.clone(), v.clone().into()))
        .collect();
    values.extend(overrides.clone());
    normalized_params(data.parameters, &values)
}

fn set_view(state: &mut Snapshot, camera: CameraInput, adaptive: bool) -> Result<(), SessionError> {
    check_camera(camera)?;
    let current = ViewInput {
        zoom: state.view.zoom(),
        pan: state.view.pan(),
        rotation: state.view.rotation(),
    };
    state.view = normalize_view(camera.view, current, &state.module_id);
    if !adaptive {
        state.last_adaptive_zoom = state.view.zoom();
    }
    Ok(())
}

fn reset_view(state: &mut Snapshot) {
    state.view = normalize_view(INITIAL_VIEW, INITIAL_VIEW, &state.module_id);
    state.last_adaptive_zoom = state.view.zoom();
}

fn apply_command(
    catalog: &CatalogBaseline,
    state: &mut Snapshot,
    command: &Command,
) -> Result<(), SessionError> {
    match command {
        Command::Zoom(zoom) => {
            let camera = ViewInput {
                zoom: *zoom,
                pan: state.view.pan(),
                rotation: state.view.rotation(),
            };
            set_view(state, camera.into(), true)?;
            adaptive_iterations(catalog, state)?;
        }
        Command::Pan(pan) => {
            let camera = ViewInput {
                zoom: state.view.zoom(),
                pan: *pan,
                rotation: state.view.rotation(),
            };
            set_view(state, camera.into(), false)?;
        }
        Command::Rotation(rotation) => {
            let camera = ViewInput {
                zoom: state.view.zoom(),
                pan: state.view.pan(),
                rotation: *rotation,
            };
            set_view(state, camera.into(), false)?;
        }
        Command::View { camera, adaptive } => {
            set_view(state, *camera, *adaptive)?;
            if *adaptive {
                adaptive_iterations(catalog, state)?;
            }
        }
        Command::Param { id, value } => {
            let data = module_data(catalog, &state.module_id)?;
            if let Some(schema) = data.parameters.iter().find(|p| p.id == *id) {
                state
                    .params
                    .insert(id.clone(), normalize_parameter(schema, value));
            }
        }
        Command::SelectModule {
            module_id,
            reset_view: reset,
            initial_params,
        } => {
            let data = module_data(catalog, module_id)?;
            if state.module_id != *module_id {
                state.module_id = module_id.clone();
                state.params = default_params(&data, initial_params);
                set_view(state, default_camera(data.default)?, false)?;
                state.effects.apply_module_policy(module_id);
            }
            if *reset {
                reset_view(state);
            }
        }
        Command::Transparent(value) => state.transparent_background = *value,
        Command::GlowEnabled(value) => state.effects.glow_enabled = *value,
        Command::GlowSigma(value) => {
            state.effects.glow_sigma = effects::bounded(*value, state.effects.glow_sigma, 0.1, 5.0);
        }
        Command::GlowIntensity(value) => {
            state.effects.glow_intensity =
                effects::bounded(*value, state.effects.glow_intensity, 0.0, 1.0);
        }
        Command::FluidModeEnabled(value) => state.effects.fluid_mode_enabled = *value,
        Command::FluidStrength(value) => {
            state.effects.fluid_strength =
                effects::bounded(*value, state.effects.fluid_strength, 0.0, 2.0);
        }
        Command::RotationLocked(value) => state.effects.rotation_locked = *value,
        Command::KaleidoscopeEnabled(value) => {
            state.effects.kaleidoscope.enabled =
                *value || effects::is_forced_module(&state.module_id);
        }
        Command::KaleidoscopeSectors(value) => {
            let clamped = (*value).clamp(4, 16);
            state.effects.kaleidoscope.sectors = clamped - clamped % 2;
        }
        Command::KaleidoscopeMirror(value) => state.effects.kaleidoscope.mirror = *value,
        Command::KaleidoscopeRotation(value) => {
            if value.is_finite() {
                state.effects.kaleidoscope.rotation = *value;
            }
        }
        Command::KaleidoscopeMirrorMode(value) => {
            state.effects.kaleidoscope.mirror_mode = (*value).clamp(0, 3);
        }
        Command::ApplyPreset {
            module_id,
            params,
            camera,
        } => {
            supported(module_id)?;
            let data = module_data(catalog, &state.module_id)?;
            state.params = normalized_params(data.parameters, params);
            set_view(state, *camera, false)?;
        }
        Command::Load {
            module_id,
            params,
            camera,
            transparent,
        } => {
            let id = module_id.as_deref().unwrap_or(&state.module_id);
            let data = module_data(catalog, id)?;
            state.module_id = id.into();
            state.effects.apply_module_policy(&state.module_id);
            state.params = normalized_params(data.parameters, params);
            set_view(state, *camera, false)?;
            state.transparent_background = *transparent;
        }
        Command::ResetParams => {
            state.params =
                default_params(&module_data(catalog, &state.module_id)?, &RawParams::new());
        }
        Command::ResetView => reset_view(state),
        Command::ResetSession => {
            state.params =
                default_params(&module_data(catalog, &state.module_id)?, &RawParams::new());
            reset_view(state);
            state.transparent_background = false;
            state.effects.rotation_locked = false;
        }
        Command::NumberWallPrime(_) => {
            return Err(SessionError::DeferredOperation);
        }
        Command::Unsupported { operation } => {
            return Err(SessionError::UnsupportedOperation(operation.clone()));
        }
    }
    Ok(())
}

fn adaptive_iterations(
    catalog: &CatalogBaseline,
    state: &mut Snapshot,
) -> Result<(), SessionError> {
    let zoom = state.view.zoom();
    let zooming_in = zoom > state.last_adaptive_zoom * 1.01;
    state.last_adaptive_zoom = zoom;
    let data = module_data(catalog, &state.module_id)?;
    if !zooming_in || !matches!(data.module.dimension, Dimension::TwoD) {
        return Ok(());
    }
    let Some(schema) = data
        .parameters
        .iter()
        .find(|p| p.id == "iterations" && p.kind == ParameterKind::Integer)
    else {
        return Ok(());
    };
    let numeric = |value: &ParameterValue| match value {
        ParameterValue::Number(n) => n.as_f64(),
        _ => None,
    };
    let (Some(base), Some(min), Some(max), Some(current)) = (
        numeric(&schema.default),
        schema.min.as_f64(),
        schema.max.as_f64(),
        state.params.get("iterations").and_then(numeric),
    ) else {
        return Ok(());
    };
    let (base, min, max, current) = (base.round(), min.round(), max.round(), current.round());
    if ![base, min, max, current].iter().all(|n| n.is_finite()) || min > max {
        return Ok(());
    }
    let extra = ((zoom.max(1.0).ln() / std::f64::consts::LN_2) * 48.0)
        .round()
        .max(0.0);
    let target = (((base + extra + 3.0) / 4.0).trunc() * 4.0).clamp(min, max);
    if target <= current {
        return Ok(());
    }
    let delta = target - current;
    let step = if delta >= 256.0 {
        64.0
    } else if delta >= 96.0 {
        32.0
    } else if delta >= 32.0 {
        16.0
    } else {
        8.0
    };
    let next = (current + step).clamp(min, max);
    if next > current {
        state.params.insert(
            "iterations".into(),
            normalize_parameter(schema, &RawScalar::Float(next)),
        );
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn pending_requests_reserve_terminal_revision_capacity() {
        let catalog = Arc::new(
            CatalogBaseline::from_jsons(
                include_str!("../../../../migration/baseline/modules.json"),
                include_str!("../../../../migration/baseline/parameters.json"),
                include_str!("../../../../migration/baseline/presets.json"),
                include_str!("../../../../migration/baseline/capabilities.json"),
            )
            .unwrap(),
        );
        let command = Command::Load {
            module_id: Some("number_wall".into()),
            params: [
                ("prime", RawScalar::Text("97".into())),
                ("rows", RawScalar::Number(4.into())),
                ("columns", RawScalar::Number(16.into())),
                ("columnStart", RawScalar::Number(3.into())),
            ]
            .into_iter()
            .map(|(k, v)| (k.into(), v))
            .collect(),
            camera: INITIAL_VIEW.into(),
            transparent: true,
        };
        for termination in ["complete", "edit", "cancel"] {
            let mut session = Session::new(catalog.clone(), 1, "mandelbrot").unwrap();
            // Only white-box setup; all mutations under test use production seams.
            session.state.revision = u64::MAX - 2;
            let token = session
                .begin_number_wall(1, u64::MAX - 2, &command, RequestGuard::new(true), 100_000)
                .unwrap()
                .unwrap();
            let pending = session.snapshot();
            assert_eq!(pending.revision(), u64::MAX - 1);
            assert_eq!(
                session.begin_number_wall(
                    1,
                    u64::MAX - 1,
                    &command,
                    RequestGuard::new(true),
                    100_000
                ),
                Err(SessionError::RevisionOverflow)
            );
            assert_eq!(
                session.apply_batch(1, u64::MAX - 1, &[Command::Transparent(false)]),
                Err(SessionError::RevisionOverflow)
            );
            assert_eq!(session.snapshot(), pending);
            if termination == "cancel" {
                assert_eq!(
                    session.cancel_number_wall(1, u64::MAX - 1, token).unwrap(),
                    RequestProgress::Finished(NumberWallPrimeStatus::Cancelled)
                );
                let done = session.snapshot();
                assert_eq!(
                    session.cancel_number_wall(1, u64::MAX, token).unwrap(),
                    RequestProgress::Finished(NumberWallPrimeStatus::Cancelled)
                );
                assert_eq!(session.snapshot(), done);
            } else if termination == "edit" {
                let done = session
                    .apply_batch(1, u64::MAX - 1, &[Command::Rotation([0.0; 3])])
                    .unwrap();
                assert_eq!(
                    done.number_wall_status(),
                    Some(NumberWallPrimeStatus::Cancelled)
                );
                assert_eq!(
                    session
                        .advance_number_wall(1, u64::MAX, token, 1024)
                        .unwrap(),
                    RequestProgress::Finished(NumberWallPrimeStatus::Cancelled)
                );
            } else {
                loop {
                    match session
                        .advance_number_wall(1, u64::MAX - 1, token, 1024)
                        .unwrap()
                    {
                        RequestProgress::Pending => assert_eq!(session.snapshot(), pending),
                        RequestProgress::Finished(status) => {
                            assert_eq!(status, NumberWallPrimeStatus::VerifiedPrime);
                            break;
                        }
                    }
                }
            }
            assert_eq!(session.snapshot().revision(), u64::MAX);
            assert_eq!(session.snapshot().number_wall_pending(), None);
        }
        for revision in [u64::MAX - 1, u64::MAX] {
            let mut session = Session::new(catalog.clone(), 1, "mandelbrot").unwrap();
            session.state.revision = revision;
            let before = session.snapshot();
            assert_eq!(
                session.begin_number_wall(1, revision, &command, RequestGuard::new(true), 100_000),
                Err(SessionError::RevisionOverflow)
            );
            assert_eq!(session.snapshot(), before);
        }
    }

    #[test]
    fn revision_exhaustion_rejects_at_the_transaction_seam() {
        let catalog = CatalogBaseline::from_jsons(
            include_str!("../../../../migration/baseline/modules.json"),
            include_str!("../../../../migration/baseline/parameters.json"),
            include_str!("../../../../migration/baseline/presets.json"),
            include_str!("../../../../migration/baseline/capabilities.json"),
        )
        .unwrap();
        let mut session = Session::new(Arc::new(catalog), 1, "mandelbrot").unwrap();
        // White-box setup only: production construction always starts at zero.
        session.state.revision = u64::MAX - 1;
        let last = session
            .apply_batch(1, u64::MAX - 1, &[Command::Transparent(false)])
            .unwrap();
        assert_eq!(last.revision(), u64::MAX);
        assert_eq!(session.apply_batch(1, u64::MAX, &[]), Ok(last.clone()));
        assert_eq!(
            session.apply_batch(1, u64::MAX, &[Command::Zoom(32.0), Command::ResetSession]),
            Err(SessionError::RevisionOverflow)
        );
        assert_eq!(session.snapshot(), last);
    }
}
