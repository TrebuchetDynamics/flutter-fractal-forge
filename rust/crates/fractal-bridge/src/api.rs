//! Default-off probe and inert state transport; mathematical policies remain in core.
use std::{
    collections::{BTreeMap, HashMap},
    sync::{
        Arc, Mutex, OnceLock,
        atomic::{AtomicBool, AtomicU64, Ordering},
    },
};

use fractal_core::{
    catalog_baseline::{CatalogBaseline, ParameterValue},
    normalization::{RawScalar, ViewInput},
    number_wall_frame::NumberWallFrame,
    number_wall_grid::NumberWallSequence,
    number_wall_prime::NumberWallPrimeStatus,
    session::{
        CameraInput, Command, MorphTimelineToken, ParamTimelineToken, RequestGuard,
        RequestProgress, RequestToken, Session, Snapshot, TrajectoryCache, TrajectoryFrame,
        TrajectoryProgress,
    },
};

use flutter_rust_bridge::frb;
use fractal_core::trajectory::{
    AttractorSystem, OrbitProjection, OrbitTrajectorySettings, TrajectoryError,
};

/// Opaque persistent bootstrap ownership. Generated disposal releases the state.
#[frb(opaque)]
pub struct EngineHandle {
    inner: fractal_core::snapshot::EngineState,
}

/// Detached neutral probe snapshot; never applied to the Flutter viewer.
#[derive(Debug, Clone, PartialEq)]
pub struct EngineSnapshot {
    pub session_id: u64,
    pub revision: u64,
    pub view: ViewState,
}

#[derive(Debug, Clone, PartialEq)]
pub struct ViewState {
    pub center_x: f64,
    pub center_y: f64,
    pub zoom: f64,
    pub rotation_x: f64,
    pub rotation_y: f64,
    pub rotation_z: f64,
}

#[frb(sync)]
pub fn create_engine() -> Result<EngineHandle, String> {
    Ok(EngineHandle {
        inner: fractal_core::snapshot::EngineState::new(allocate_session_id(&LAST_SESSION_ID)?),
    })
}

#[frb(sync)]
pub fn engine_snapshot(engine: &EngineHandle) -> EngineSnapshot {
    let snapshot = engine.inner.snapshot();
    let view = snapshot.view;
    EngineSnapshot {
        session_id: snapshot.session_id,
        revision: snapshot.revision,
        view: ViewState {
            center_x: view.center_x,
            center_y: view.center_y,
            zoom: view.zoom,
            rotation_x: view.rotation_x,
            rotation_y: view.rotation_y,
            rotation_z: view.rotation_z,
        },
    }
}

/// An opaque legacy session; closing one handle never closes another.
#[frb(opaque)]
pub struct Engine {
    closed: AtomicBool,
}

pub struct Capabilities {
    pub rendering: bool,
}

#[frb(sync)]
pub fn engine_version() -> String {
    fractal_core::engine_version()
}

impl Engine {
    #[frb(sync)]
    pub fn new() -> Self {
        Self {
            closed: AtomicBool::new(false),
        }
    }

    #[frb(sync)]
    pub fn capabilities(&self) -> Result<Capabilities, String> {
        if self.closed.load(Ordering::SeqCst) {
            return Err("Rust engine session is closed".to_owned());
        }
        Ok(Capabilities {
            rendering: crate::engine_capabilities().rendering,
        })
    }

    #[frb(sync)]
    pub fn shutdown(&self) {
        self.closed.store(true, Ordering::SeqCst);
    }
}

impl Default for Engine {
    #[frb(ignore)]
    fn default() -> Self {
        Self::new()
    }
}

// Opaque typed payloads avoid adding Freezed/build_runner dependencies for Dart
// unions. Constructors convert once; no JSON command protocol or Dart math owner.
#[derive(Debug, Clone)]
#[frb(opaque)]
pub struct StateValue {
    inner: RawScalar,
}

impl StateValue {
    #[frb(sync)]
    pub fn from_float(value: f64) -> Self {
        Self {
            inner: RawScalar::Float(value),
        }
    }

    /// Exact JSON number representation, distinct from exact text parameters.
    #[frb(sync)]
    pub fn from_number(value: String) -> Result<Self, String> {
        Ok(Self {
            inner: RawScalar::Number(value.parse().map_err(|e| format!("Invalid number: {e}"))?),
        })
    }

    #[frb(sync)]
    pub fn from_boolean(value: bool) -> Self {
        Self {
            inner: RawScalar::Boolean(value),
        }
    }

    #[frb(sync)]
    pub fn from_text(value: String) -> Self {
        Self {
            inner: RawScalar::Text(value),
        }
    }

    #[frb(sync)]
    pub fn number(&self) -> Option<String> {
        match &self.inner {
            RawScalar::Number(value) => Some(value.to_string()),
            _ => None,
        }
    }

    #[frb(sync)]
    pub fn float(&self) -> Option<f64> {
        match self.inner {
            RawScalar::Float(value) => Some(value),
            _ => None,
        }
    }

    #[frb(sync)]
    pub fn boolean(&self) -> Option<bool> {
        match self.inner {
            RawScalar::Boolean(value) => Some(value),
            _ => None,
        }
    }

    #[frb(sync)]
    pub fn text(&self) -> Option<String> {
        match &self.inner {
            RawScalar::Text(value) => Some(value.clone()),
            _ => None,
        }
    }
}

#[derive(Debug, Clone)]
pub struct StateView {
    pub zoom: f64,
    pub pan_x: f64,
    pub pan_y: f64,
    pub rot_x: f64,
    pub rot_y: f64,
    pub rot_z: f64,
}

#[derive(Debug, Clone)]
pub struct StateCamera {
    pub view: StateView,
    pub has_trajectory: bool,
}

impl StateCamera {
    fn into_core(self) -> CameraInput {
        CameraInput {
            view: ViewInput {
                zoom: self.view.zoom,
                pan: [self.view.pan_x, self.view.pan_y],
                rotation: [self.view.rot_x, self.view.rot_y, self.view.rot_z],
            },
            // Public presence markers do not carry typed settings and still reject.
            trajectory: None,
            has_trajectory: self.has_trajectory,
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum StateAttractorSystem {
    Thomas,
    FourWing,
    Lorenz2d,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum StateOrbitProjection {
    Xz,
    ThomasOblique,
}

#[derive(Debug, Clone)]
pub struct StateOrbitPoint {
    pub x: f64,
    pub y: f64,
    pub z: f64,
}

#[derive(Debug, Clone)]
pub struct StateOrbitBounds {
    pub min_x: f64,
    pub max_x: f64,
    pub min_y: f64,
    pub max_y: f64,
}

/// Validated once by core; no unchecked fields or JSON command protocol.
#[derive(Debug, Clone)]
#[frb(opaque)]
pub struct StateTrajectorySettings {
    inner: OrbitTrajectorySettings,
}

impl StateTrajectorySettings {
    #[frb(sync)]
    #[allow(clippy::too_many_arguments)]
    pub fn new(
        version: u32,
        integrator: String,
        system: StateAttractorSystem,
        seed: StateOrbitPoint,
        step_size: f64,
        burn_in_steps: u32,
        retained_steps: u32,
        projection: StateOrbitProjection,
    ) -> Result<Self, String> {
        if version != 1 || integrator != "rk4" {
            return Err(TrajectoryError::InvalidSettings.to_string());
        }
        let system = match system {
            StateAttractorSystem::Thomas => AttractorSystem::Thomas,
            StateAttractorSystem::FourWing => AttractorSystem::FourWing,
            StateAttractorSystem::Lorenz2d => AttractorSystem::Lorenz2d,
        };
        let projection = match projection {
            StateOrbitProjection::Xz => OrbitProjection::Xz,
            StateOrbitProjection::ThomasOblique => OrbitProjection::ThomasOblique,
        };
        OrbitTrajectorySettings::new(
            system,
            [seed.x, seed.y, seed.z].into(),
            step_size,
            burn_in_steps,
            retained_steps,
            projection,
        )
        .map(|inner| Self { inner })
        .map_err(|e| e.to_string())
    }
    #[frb(sync)]
    pub fn version(&self) -> u32 {
        self.inner.version()
    }

    #[frb(sync)]
    pub fn integrator(&self) -> String {
        self.inner.integrator().into()
    }

    #[frb(sync)]
    pub fn seed(&self) -> StateOrbitPoint {
        {
            let p = self.inner.seed();
            StateOrbitPoint {
                x: p.x,
                y: p.y,
                z: p.z,
            }
        }
    }

    #[frb(sync)]
    pub fn step_size(&self) -> f64 {
        self.inner.step_size()
    }

    #[frb(sync)]
    pub fn burn_in_steps(&self) -> u32 {
        self.inner.burn_in_steps()
    }

    #[frb(sync)]
    pub fn retained_steps(&self) -> u32 {
        self.inner.retained_steps()
    }

    #[frb(sync)]
    pub fn system(&self) -> StateAttractorSystem {
        match self.inner.system() {
            AttractorSystem::Thomas => StateAttractorSystem::Thomas,
            AttractorSystem::FourWing => StateAttractorSystem::FourWing,
            AttractorSystem::Lorenz2d => StateAttractorSystem::Lorenz2d,
        }
    }

    #[frb(sync)]
    pub fn projection(&self) -> StateOrbitProjection {
        match self.inner.projection() {
            OrbitProjection::Xz => StateOrbitProjection::Xz,
            OrbitProjection::ThomasOblique => StateOrbitProjection::ThomasOblique,
        }
    }
}

/// Separate from StateCamera: null remains absence; bare markers still reject.
#[derive(Debug, Clone)]
#[frb(opaque)]
pub struct StateTrajectoryCamera {
    inner: CameraInput,
}

impl StateTrajectoryCamera {
    #[frb(sync)]
    pub fn new(view: StateView, trajectory: Option<StateTrajectorySettings>) -> Self {
        let mut inner = StateCamera {
            view,
            has_trajectory: false,
        }
        .into_core();
        inner.trajectory = trajectory.map(|s| s.inner);
        Self { inner }
    }
}

fn core_params(params: HashMap<String, StateValue>) -> BTreeMap<String, RawScalar> {
    params
        .into_iter()
        .map(|(id, value)| (id, value.inner))
        .collect()
}

#[derive(Debug, Clone)]
#[frb(opaque)]
pub struct StateCommand {
    inner: Command,
}

impl StateCommand {
    #[frb(sync)]
    pub fn view_trajectory(camera: StateTrajectoryCamera, adaptive: bool) -> Self {
        Self {
            inner: Command::View {
                camera: camera.inner,
                adaptive,
            },
        }
    }

    #[frb(sync)]
    pub fn apply_preset_trajectory(
        module_id: String,
        params: HashMap<String, StateValue>,
        camera: StateTrajectoryCamera,
    ) -> Self {
        Self {
            inner: Command::ApplyPreset {
                module_id,
                params: core_params(params),
                camera: camera.inner,
            },
        }
    }

    #[frb(sync)]
    pub fn load_trajectory(
        module_id: Option<String>,
        params: HashMap<String, StateValue>,
        camera: StateTrajectoryCamera,
        transparent: bool,
    ) -> Self {
        Self {
            inner: Command::Load {
                module_id,
                params: core_params(params),
                camera: camera.inner,
                transparent,
            },
        }
    }

    #[frb(sync)]
    pub fn zoom(value: f64) -> Self {
        Self {
            inner: Command::Zoom(value),
        }
    }

    #[frb(sync)]
    pub fn pan(x: f64, y: f64) -> Self {
        Self {
            inner: Command::Pan([x, y]),
        }
    }

    #[frb(sync)]
    pub fn rotation(x: f64, y: f64, z: f64) -> Self {
        Self {
            inner: Command::Rotation([x, y, z]),
        }
    }

    #[frb(sync)]
    pub fn view(camera: StateCamera, adaptive: bool) -> Self {
        Self {
            inner: Command::View {
                camera: camera.into_core(),
                adaptive,
            },
        }
    }

    #[frb(sync)]
    pub fn param(id: String, value: StateValue) -> Self {
        Self {
            inner: Command::Param {
                id,
                value: value.inner,
            },
        }
    }

    #[frb(sync)]
    pub fn number_wall_prime(value: String) -> Self {
        Self {
            inner: Command::NumberWallPrime(value),
        }
    }

    #[frb(sync)]
    pub fn select_module(
        module_id: String,
        reset_view: bool,
        initial_params: HashMap<String, StateValue>,
    ) -> Self {
        Self {
            inner: Command::SelectModule {
                module_id,
                reset_view,
                initial_params: core_params(initial_params),
            },
        }
    }

    #[frb(sync)]
    pub fn transparent(value: bool) -> Self {
        Self {
            inner: Command::Transparent(value),
        }
    }

    #[frb(sync)]
    pub fn glow_enabled(value: bool) -> Self {
        Self {
            inner: Command::GlowEnabled(value),
        }
    }

    #[frb(sync)]
    pub fn glow_sigma(value: f64) -> Self {
        Self {
            inner: Command::GlowSigma(value),
        }
    }

    #[frb(sync)]
    pub fn glow_intensity(value: f64) -> Self {
        Self {
            inner: Command::GlowIntensity(value),
        }
    }

    #[frb(sync)]
    pub fn fluid_mode_enabled(value: bool) -> Self {
        Self {
            inner: Command::FluidModeEnabled(value),
        }
    }

    #[frb(sync)]
    pub fn fluid_strength(value: f64) -> Self {
        Self {
            inner: Command::FluidStrength(value),
        }
    }

    #[frb(sync)]
    pub fn rotation_locked(value: bool) -> Self {
        Self {
            inner: Command::RotationLocked(value),
        }
    }

    #[frb(sync)]
    pub fn kaleidoscope_enabled(value: bool) -> Self {
        Self {
            inner: Command::KaleidoscopeEnabled(value),
        }
    }

    #[frb(sync)]
    pub fn kaleidoscope_sectors(value: i64) -> Self {
        Self {
            inner: Command::KaleidoscopeSectors(value),
        }
    }

    #[frb(sync)]
    pub fn kaleidoscope_mirror(value: bool) -> Self {
        Self {
            inner: Command::KaleidoscopeMirror(value),
        }
    }

    #[frb(sync)]
    pub fn kaleidoscope_rotation(value: f64) -> Self {
        Self {
            inner: Command::KaleidoscopeRotation(value),
        }
    }

    #[frb(sync)]
    pub fn kaleidoscope_mirror_mode(value: i64) -> Self {
        Self {
            inner: Command::KaleidoscopeMirrorMode(value),
        }
    }

    #[frb(sync)]
    pub fn apply_preset(
        module_id: String,
        params: HashMap<String, StateValue>,
        camera: StateCamera,
    ) -> Self {
        Self {
            inner: Command::ApplyPreset {
                module_id,
                params: core_params(params),
                camera: camera.into_core(),
            },
        }
    }

    #[frb(sync)]
    pub fn load(
        module_id: Option<String>,
        params: HashMap<String, StateValue>,
        camera: StateCamera,
        transparent: bool,
    ) -> Self {
        Self {
            inner: Command::Load {
                module_id,
                params: core_params(params),
                camera: camera.into_core(),
                transparent,
            },
        }
    }

    #[frb(sync)]
    pub fn reset_params() -> Self {
        Self {
            inner: Command::ResetParams,
        }
    }

    #[frb(sync)]
    pub fn reset_view() -> Self {
        Self {
            inner: Command::ResetView,
        }
    }

    #[frb(sync)]
    pub fn reset_session() -> Self {
        Self {
            inner: Command::ResetSession,
        }
    }

    #[frb(sync)]
    pub fn unsupported(operation: String) -> Self {
        Self {
            inner: Command::Unsupported { operation },
        }
    }
}

/// Independently revocable; no session lock or foreign callback is needed.
#[derive(Debug)]
#[frb(opaque)]
pub struct StateNumberWallGuard {
    inner: RequestGuard,
}

impl StateNumberWallGuard {
    #[frb(sync)]
    pub fn new(active: bool) -> Self {
        Self {
            inner: RequestGuard::new(active),
        }
    }

    #[frb(sync)]
    pub fn revoke(&self) {
        self.inner.revoke();
    }

    #[frb(sync)]
    pub fn is_active(&self) -> bool {
        self.inner.is_active()
    }
}

/// Only begin can create a request. Advance/cancel borrow it across bounded steps.
#[derive(Debug)]
#[frb(opaque)]
pub struct StateNumberWallRequest {
    inner: RequestToken,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum StateNumberWallStatus {
    VerifiedPrime,
    Composite,
    Invalid,
    Unverified,
    Cancelled,
}

impl From<NumberWallPrimeStatus> for StateNumberWallStatus {
    fn from(status: NumberWallPrimeStatus) -> Self {
        match status {
            NumberWallPrimeStatus::VerifiedPrime => Self::VerifiedPrime,
            NumberWallPrimeStatus::Composite => Self::Composite,
            NumberWallPrimeStatus::Invalid => Self::Invalid,
            NumberWallPrimeStatus::Unverified => Self::Unverified,
            NumberWallPrimeStatus::Cancelled => Self::Cancelled,
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum StateNumberWallSequence {
    SignedPagoda,
    Rook,
    ThueMorse,
    RudinShapiro,
    Fibonacci,
    Squares,
}

/// Owned read-only handle, constructible only from a certified core frame.
#[derive(Debug)]
#[frb(opaque)]
pub struct StateNumberWallFrame {
    inner: Arc<NumberWallFrame>,
}

impl StateNumberWallFrame {
    #[frb(sync)]
    pub fn params(&self) -> HashMap<String, StateValue> {
        self.inner
            .params()
            .iter()
            .map(|(id, value)| {
                (
                    id.clone(),
                    StateValue {
                        inner: value.clone().into(),
                    },
                )
            })
            .collect()
    }

    #[frb(sync)]
    pub fn sequence(&self) -> StateNumberWallSequence {
        match self.inner.grid().sequence() {
            NumberWallSequence::SignedPagoda => StateNumberWallSequence::SignedPagoda,
            NumberWallSequence::Rook => StateNumberWallSequence::Rook,
            NumberWallSequence::ThueMorse => StateNumberWallSequence::ThueMorse,
            NumberWallSequence::RudinShapiro => StateNumberWallSequence::RudinShapiro,
            NumberWallSequence::Fibonacci => StateNumberWallSequence::Fibonacci,
            NumberWallSequence::Squares => StateNumberWallSequence::Squares,
        }
    }

    #[frb(sync)]
    pub fn modulus(&self) -> String {
        self.inner.grid().modulus().to_owned()
    }

    #[frb(sync)]
    pub fn row_count(&self) -> u32 {
        self.inner
            .grid()
            .row_count()
            .try_into()
            .expect("bounded core grid rows")
    }

    #[frb(sync)]
    pub fn column_count(&self) -> u32 {
        self.inner
            .grid()
            .column_count()
            .try_into()
            .expect("bounded core grid columns")
    }

    #[frb(sync)]
    pub fn column_start(&self) -> i64 {
        self.inner.grid().column_start()
    }

    #[frb(sync)]
    pub fn support_start(&self) -> i64 {
        self.inner.grid().support().0
    }

    #[frb(sync)]
    pub fn support_end(&self) -> i64 {
        self.inner.grid().support().1
    }

    /// Complete detached decimal-string grid; never narrowed through floating point.
    #[frb(sync)]
    pub fn values(&self) -> Vec<Vec<String>> {
        self.inner.grid().values().to_vec()
    }
}

/// Progress and its detached snapshot are captured under the same session lock.
#[derive(Debug)]
#[frb(opaque)]
pub struct StateNumberWallProgress {
    inner: RequestProgress,
    snapshot: Snapshot,
}

impl StateNumberWallProgress {
    #[frb(sync)]
    pub fn is_pending(&self) -> bool {
        self.inner == RequestProgress::Pending
    }

    #[frb(sync)]
    pub fn status(&self) -> Option<StateNumberWallStatus> {
        match self.inner {
            RequestProgress::Pending => None,
            RequestProgress::Finished(status) => Some(status.into()),
        }
    }

    #[frb(sync)]
    pub fn snapshot(&self) -> StateSnapshot {
        StateSnapshot {
            inner: self.snapshot.clone(),
        }
    }
}

#[derive(Debug)]
#[frb(opaque)]
pub struct StateTrajectoryGuard {
    inner: RequestGuard,
}

impl StateTrajectoryGuard {
    #[frb(sync)]
    pub fn new(active: bool) -> Self {
        Self {
            inner: RequestGuard::new(active),
        }
    }
    #[frb(sync)]
    pub fn revoke(&self) {
        self.inner.revoke();
    }
    #[frb(sync)]
    pub fn is_active(&self) -> bool {
        self.inner.is_active()
    }
}

#[derive(Debug)]
#[frb(opaque)]
pub struct StateTrajectoryRequest {
    inner: RequestToken,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum StateTrajectoryStatus {
    Success,
    InvalidSettings,
    InvalidIntegrationInputs,
    NonFiniteIntegration,
    SafetyBounds,
    Cancelled,
}

fn trajectory_status(result: Result<(), TrajectoryError>) -> StateTrajectoryStatus {
    match result {
        Ok(()) => StateTrajectoryStatus::Success,
        Err(TrajectoryError::InvalidSettings) => StateTrajectoryStatus::InvalidSettings,
        Err(TrajectoryError::InvalidIntegrationInputs) => {
            StateTrajectoryStatus::InvalidIntegrationInputs
        }
        Err(TrajectoryError::NonFiniteIntegration) => StateTrajectoryStatus::NonFiniteIntegration,
        Err(TrajectoryError::SafetyBounds) => StateTrajectoryStatus::SafetyBounds,
        Err(TrajectoryError::Cancelled) => StateTrajectoryStatus::Cancelled,
    }
}

/// Detached terminal frame with sample settings and publication provenance.
#[derive(Debug)]
#[frb(opaque)]
pub struct StateTrajectoryFrame {
    inner: Arc<TrajectoryFrame>,
    session_id: u64,
}

impl StateTrajectoryFrame {
    #[frb(sync)]
    pub fn module_id(&self) -> String {
        self.inner.module_id().into()
    }

    #[frb(sync)]
    pub fn session_id(&self) -> u64 {
        self.session_id
    }

    #[frb(sync)]
    pub fn settings_generation(&self) -> u64 {
        self.inner.settings_generation()
    }

    #[frb(sync)]
    pub fn cache_hit(&self) -> bool {
        self.inner.cache_hit()
    }

    #[frb(sync)]
    pub fn settings(&self) -> StateTrajectorySettings {
        StateTrajectorySettings {
            inner: *self.inner.trajectory().settings(),
        }
    }

    #[frb(sync)]
    pub fn points(&self) -> Vec<StateOrbitPoint> {
        self.inner
            .trajectory()
            .points()
            .iter()
            .map(|p| StateOrbitPoint {
                x: p.x,
                y: p.y,
                z: p.z,
            })
            .collect()
    }

    #[frb(sync)]
    pub fn bounds(&self) -> StateOrbitBounds {
        {
            let b = self.inner.trajectory().bounds();
            StateOrbitBounds {
                min_x: b.min_x,
                max_x: b.max_x,
                min_y: b.min_y,
                max_y: b.max_y,
            }
        }
    }
}

/// Progress and snapshot captured under the same lock.
#[derive(Debug)]
#[frb(opaque)]
pub struct StateTrajectoryProgress {
    inner: TrajectoryProgress,
    snapshot: Snapshot,
}

impl StateTrajectoryProgress {
    #[frb(sync)]
    pub fn is_pending(&self) -> bool {
        matches!(self.inner, TrajectoryProgress::Pending { .. })
    }
    #[frb(sync)]
    pub fn steps_completed(&self) -> Option<u32> {
        match self.inner {
            TrajectoryProgress::Pending { steps_completed } => Some(steps_completed),
            _ => None,
        }
    }
    #[frb(sync)]
    pub fn status(&self) -> Option<StateTrajectoryStatus> {
        match &self.inner {
            TrajectoryProgress::Pending { .. } => None,
            TrajectoryProgress::Finished(result) => Some(trajectory_status(
                result.as_ref().map(|_| ()).map_err(|e| *e),
            )),
        }
    }
    #[frb(sync)]
    pub fn frame(&self) -> Option<StateTrajectoryFrame> {
        match &self.inner {
            TrajectoryProgress::Finished(Ok(frame)) => Some(StateTrajectoryFrame {
                inner: frame.clone(),
                session_id: self.snapshot.session_id(),
            }),
            _ => None,
        }
    }
    #[frb(sync)]
    pub fn snapshot(&self) -> StateSnapshot {
        StateSnapshot {
            inner: self.snapshot.clone(),
        }
    }
}

/// Detached immutable core copy; collection getters return further detached copies.
#[derive(Debug, Clone)]
#[frb(opaque)]
pub struct StateSnapshot {
    pub(crate) inner: Snapshot,
}

impl StateSnapshot {
    #[frb(sync)]
    pub fn is_morphing(&self) -> bool {
        self.inner.is_morphing()
    }

    #[frb(sync)]
    pub fn morph_progress(&self) -> f64 {
        self.inner.morph_progress()
    }

    #[frb(sync)]
    pub fn previous_module_id(&self) -> Option<String> {
        self.inner.previous_module_id().map(str::to_owned)
    }

    #[frb(sync)]
    pub fn morph_timeline_token(&self) -> Option<StateMorphTimelineToken> {
        self.inner
            .morph_timeline_token()
            .map(|inner| StateMorphTimelineToken { inner })
    }

    #[frb(sync)]
    pub fn can_undo_number_wall_randomization(&self) -> bool {
        self.inner.can_undo_number_wall_randomization()
    }

    #[frb(sync)]
    pub fn trajectory(&self) -> Option<StateTrajectorySettings> {
        self.inner
            .trajectory()
            .map(|inner| StateTrajectorySettings { inner })
    }
    #[frb(sync)]
    pub fn trajectory_generation(&self) -> u64 {
        self.inner.trajectory_generation()
    }
    #[frb(sync)]
    pub fn trajectory_pending(&self) -> bool {
        self.inner.trajectory_pending().is_some()
    }
    #[frb(sync)]
    pub fn trajectory_status(&self) -> Option<StateTrajectoryStatus> {
        self.inner.trajectory_status().map(trajectory_status)
    }
    #[frb(sync)]
    pub fn trajectory_frame(&self) -> Option<StateTrajectoryFrame> {
        self.inner
            .trajectory_frame()
            .map(|inner| StateTrajectoryFrame {
                inner: inner.clone(),
                session_id: self.inner.session_id(),
            })
    }

    /// Fixed detached debug instrumentation; release builds explicitly refuse.
    /// Not a security boundary or a production identity source.
    #[frb(sync)]
    pub fn debug_u64_fixtures(&self) -> Result<Vec<StateSnapshot>, String> {
        #[cfg(debug_assertions)]
        {
            Ok(self
                .inner
                .debug_u64_fixtures()
                .into_iter()
                .map(|inner| StateSnapshot { inner })
                .collect())
        }
        #[cfg(not(debug_assertions))]
        Err("High-u64 snapshot fixtures require debug assertions".into())
    }

    #[frb(sync)]
    pub fn session_id(&self) -> u64 {
        self.inner.session_id()
    }

    #[frb(sync)]
    pub fn revision(&self) -> u64 {
        self.inner.revision()
    }

    #[frb(sync)]
    pub fn module_id(&self) -> String {
        self.inner.module_id().into()
    }

    #[frb(sync)]
    pub fn params(&self) -> HashMap<String, StateValue> {
        self.inner
            .params()
            .iter()
            .map(|(id, value)| {
                (
                    id.clone(),
                    StateValue {
                        inner: value.clone().into(),
                    },
                )
            })
            .collect()
    }

    #[frb(sync)]
    pub fn view(&self) -> StateView {
        let view = self.inner.view();
        StateView {
            zoom: view.zoom(),
            pan_x: view.pan()[0],
            pan_y: view.pan()[1],
            rot_x: view.rotation()[0],
            rot_y: view.rotation()[1],
            rot_z: view.rotation()[2],
        }
    }

    #[frb(sync)]
    pub fn transparent_background(&self) -> bool {
        self.inner.transparent_background()
    }

    #[frb(sync)]
    pub fn glow_enabled(&self) -> bool {
        self.inner.glow_enabled()
    }

    #[frb(sync)]
    pub fn glow_sigma(&self) -> f64 {
        self.inner.glow_sigma()
    }

    #[frb(sync)]
    pub fn glow_intensity(&self) -> f64 {
        self.inner.glow_intensity()
    }

    #[frb(sync)]
    pub fn fluid_mode_enabled(&self) -> bool {
        self.inner.fluid_mode_enabled()
    }

    #[frb(sync)]
    pub fn fluid_strength(&self) -> f64 {
        self.inner.fluid_strength()
    }

    #[frb(sync)]
    pub fn rotation_locked(&self) -> bool {
        self.inner.rotation_locked()
    }

    #[frb(sync)]
    pub fn kaleidoscope_enabled(&self) -> bool {
        self.inner.kaleidoscope_enabled()
    }

    #[frb(sync)]
    pub fn kaleidoscope_sectors(&self) -> i64 {
        self.inner.kaleidoscope_sectors()
    }

    #[frb(sync)]
    pub fn kaleidoscope_mirror(&self) -> bool {
        self.inner.kaleidoscope_mirror()
    }

    #[frb(sync)]
    pub fn kaleidoscope_rotation(&self) -> f64 {
        self.inner.kaleidoscope_rotation()
    }

    #[frb(sync)]
    pub fn kaleidoscope_mirror_mode(&self) -> i64 {
        self.inner.kaleidoscope_mirror_mode()
    }

    #[frb(sync)]
    pub fn last_adaptive_zoom(&self) -> f64 {
        self.inner.last_adaptive_zoom()
    }

    #[frb(sync)]
    pub fn number_wall_pending(&self) -> bool {
        self.inner.number_wall_pending().is_some()
    }

    #[frb(sync)]
    pub fn number_wall_status(&self) -> Option<StateNumberWallStatus> {
        self.inner.number_wall_status().map(Into::into)
    }

    #[frb(sync)]
    pub fn number_wall_frame(&self) -> Option<StateNumberWallFrame> {
        self.inner
            .number_wall_frame()
            .map(|frame| StateNumberWallFrame {
                inner: Arc::clone(frame),
            })
    }
}

/// Session-bound capabilities: no caller-built identity or generation.
#[derive(Debug)]
#[frb(opaque)]
pub struct StateParamTimelineToken {
    inner: ParamTimelineToken,
}

#[derive(Debug)]
#[frb(opaque)]
pub struct StateMorphTimelineToken {
    inner: MorphTimelineToken,
}

/// Token and detached snapshot captured under one Session lock.
pub struct StateParamTimelineStart {
    token: StateParamTimelineToken,
    snapshot: StateSnapshot,
}

impl StateParamTimelineStart {
    #[frb(sync)]
    pub fn token(&self) -> StateParamTimelineToken {
        StateParamTimelineToken {
            inner: self.token.inner,
        }
    }

    #[frb(sync)]
    pub fn snapshot(&self) -> StateSnapshot {
        StateSnapshot {
            inner: self.snapshot.inner.clone(),
        }
    }
}

pub struct StateNumberWallUndo {
    changed: bool,
    snapshot: StateSnapshot,
}

impl StateNumberWallUndo {
    #[frb(sync)]
    pub fn changed(&self) -> bool {
        self.changed
    }

    #[frb(sync)]
    pub fn snapshot(&self) -> StateSnapshot {
        StateSnapshot {
            inner: self.snapshot.inner.clone(),
        }
    }
}

static TRAJECTORY_CACHE: OnceLock<TrajectoryCache> = OnceLock::new();

static LAST_SESSION_ID: AtomicU64 = AtomicU64::new(0);

fn allocate_session_id(last: &AtomicU64) -> Result<u64, String> {
    last.fetch_update(Ordering::SeqCst, Ordering::SeqCst, |value| {
        value.checked_add(1)
    })
    .map(|previous| previous + 1)
    .map_err(|_| "Rust state session identity exhausted".into())
}

#[derive(Debug)]
#[frb(opaque)]
pub struct StateSession {
    // A single lock linearizes transactions, snapshots and shutdown. Dropping the
    // option releases the catalog/state; a poisoned lock never exposes last-good state.
    pub(crate) inner: Arc<Mutex<Option<Session>>>,
    pub(crate) id: u64,
    pub(crate) scheduled:
        Mutex<Option<Vec<std::sync::Weak<crate::state_work_executor::TicketData>>>>,
}

impl StateSession {
    /// Explicit animation option; default batch semantics are unchanged.
    pub fn apply_batch_with_module_animation(
        &self,
        session_id: u64,
        expected_revision: u64,
        commands: Vec<StateCommand>,
        animate: bool,
    ) -> Result<StateSnapshot, String> {
        let mut guard = self
            .inner
            .lock()
            .map_err(|_| "Rust state session lock poisoned")?;
        let session = guard.as_mut().ok_or("Rust state session is closed")?;
        let commands: Vec<_> = commands.into_iter().map(|command| command.inner).collect();
        session
            .apply_batch_with_module_animation(session_id, expected_revision, &commands, animate)
            .map(|inner| StateSnapshot { inner })
            .map_err(|e| e.to_string())
    }

    pub fn start_param_timeline(
        &self,
        session_id: u64,
        expected_revision: u64,
        target: HashMap<String, StateValue>,
    ) -> Result<StateParamTimelineStart, String> {
        let mut guard = self
            .inner
            .lock()
            .map_err(|_| "Rust state session lock poisoned")?;
        let session = guard.as_mut().ok_or("Rust state session is closed")?;
        let target = target
            .into_iter()
            .map(|(id, value)| {
                let value = match value.inner {
                    RawScalar::Number(n) => ParameterValue::Number(n),
                    // Debug spelling retains floating-point kind (including 3.0/-0.0).
                    RawScalar::Float(n) => ParameterValue::Number(
                        format!("{n:?}")
                            .parse()
                            .map_err(|_| "Non-finite timeline target")?,
                    ),
                    RawScalar::Boolean(b) => ParameterValue::Boolean(b),
                    RawScalar::Text(s) => ParameterValue::Text(s),
                };
                Ok((id, value))
            })
            .collect::<Result<BTreeMap<_, _>, String>>()?;
        let inner = session
            .start_param_timeline(session_id, expected_revision, target)
            .map_err(|e| e.to_string())?;
        Ok(StateParamTimelineStart {
            token: StateParamTimelineToken { inner },
            snapshot: StateSnapshot {
                inner: session.snapshot(),
            },
        })
    }

    pub fn start_seeded_param_timeline(
        &self,
        session_id: u64,
        expected_revision: u64,
        seed: i64,
    ) -> Result<StateParamTimelineStart, String> {
        let mut guard = self
            .inner
            .lock()
            .map_err(|_| "Rust state session lock poisoned")?;
        let session = guard.as_mut().ok_or("Rust state session is closed")?;
        let inner = session
            .start_seeded_param_timeline(session_id, expected_revision, seed)
            .map_err(|e| e.to_string())?;
        Ok(StateParamTimelineStart {
            token: StateParamTimelineToken { inner },
            snapshot: StateSnapshot {
                inner: session.snapshot(),
            },
        })
    }

    pub fn randomize_params(
        &self,
        session_id: u64,
        expected_revision: u64,
        seed: i64,
    ) -> Result<StateSnapshot, String> {
        let mut guard = self
            .inner
            .lock()
            .map_err(|_| "Rust state session lock poisoned")?;
        let session = guard.as_mut().ok_or("Rust state session is closed")?;
        session
            .randomize_params(session_id, expected_revision, seed)
            .map(|inner| StateSnapshot { inner })
            .map_err(|e| e.to_string())
    }

    pub fn tick_param_timeline(
        &self,
        session_id: u64,
        expected_revision: u64,
        token: &StateParamTimelineToken,
    ) -> Result<StateSnapshot, String> {
        let mut guard = self
            .inner
            .lock()
            .map_err(|_| "Rust state session lock poisoned")?;
        let session = guard.as_mut().ok_or("Rust state session is closed")?;
        session
            .tick_param_timeline(session_id, expected_revision, token.inner)
            .map(|inner| StateSnapshot { inner })
            .map_err(|e| e.to_string())
    }

    pub fn cancel_param_timeline(
        &self,
        session_id: u64,
        expected_revision: u64,
        token: &StateParamTimelineToken,
    ) -> Result<StateSnapshot, String> {
        let mut guard = self
            .inner
            .lock()
            .map_err(|_| "Rust state session lock poisoned")?;
        let session = guard.as_mut().ok_or("Rust state session is closed")?;
        session
            .cancel_param_timeline(session_id, expected_revision, token.inner)
            .map(|inner| StateSnapshot { inner })
            .map_err(|e| e.to_string())
    }

    pub fn tick_morph_timeline(
        &self,
        session_id: u64,
        expected_revision: u64,
        token: &StateMorphTimelineToken,
    ) -> Result<StateSnapshot, String> {
        let mut guard = self
            .inner
            .lock()
            .map_err(|_| "Rust state session lock poisoned")?;
        let session = guard.as_mut().ok_or("Rust state session is closed")?;
        session
            .tick_morph_timeline(session_id, expected_revision, token.inner)
            .map(|inner| StateSnapshot { inner })
            .map_err(|e| e.to_string())
    }

    pub fn cancel_morph_timeline(
        &self,
        session_id: u64,
        expected_revision: u64,
        token: &StateMorphTimelineToken,
    ) -> Result<StateSnapshot, String> {
        let mut guard = self
            .inner
            .lock()
            .map_err(|_| "Rust state session lock poisoned")?;
        let session = guard.as_mut().ok_or("Rust state session is closed")?;
        session
            .cancel_morph_timeline(session_id, expected_revision, token.inner)
            .map(|inner| StateSnapshot { inner })
            .map_err(|e| e.to_string())
    }

    pub fn undo_number_wall_randomization(
        &self,
        session_id: u64,
        expected_revision: u64,
    ) -> Result<StateNumberWallUndo, String> {
        let mut guard = self
            .inner
            .lock()
            .map_err(|_| "Rust state session lock poisoned")?;
        let session = guard.as_mut().ok_or("Rust state session is closed")?;
        let changed = session
            .undo_number_wall_randomization(session_id, expected_revision)
            .map_err(|e| e.to_string())?;
        Ok(StateNumberWallUndo {
            changed,
            snapshot: StateSnapshot {
                inner: session.snapshot(),
            },
        })
    }

    /// Normal-mode FRB dispatch; captures settings without running integration.
    pub fn begin_trajectory_async(
        &self,
        session_id: u64,
        expected_revision: u64,
        request_guard: &StateTrajectoryGuard,
    ) -> Result<Option<StateTrajectoryRequest>, String> {
        let mut guard = self
            .inner
            .lock()
            .map_err(|_| "Rust state session lock poisoned")?;
        let session = guard.as_mut().ok_or("Rust state session is closed")?;
        session
            .begin_trajectory(session_id, expected_revision, request_guard.inner.clone())
            .map(|r| r.map(|inner| StateTrajectoryRequest { inner }))
            .map_err(|e| e.to_string())
    }

    /// Exactly one core chunk (<=256 steps), never a drain loop or a new runtime.
    pub fn advance_trajectory_async(
        &self,
        session_id: u64,
        expected_revision: u64,
        request: &StateTrajectoryRequest,
    ) -> Result<StateTrajectoryProgress, String> {
        let mut guard = self
            .inner
            .lock()
            .map_err(|_| "Rust state session lock poisoned")?;
        let session = guard.as_mut().ok_or("Rust state session is closed")?;
        let inner = session
            .advance_trajectory(session_id, expected_revision, request.inner)
            .map_err(|e| e.to_string())?;
        Ok(StateTrajectoryProgress {
            inner,
            snapshot: session.snapshot(),
        })
    }

    pub fn cancel_trajectory_async(
        &self,
        session_id: u64,
        expected_revision: u64,
        request: &StateTrajectoryRequest,
    ) -> Result<StateTrajectoryProgress, String> {
        let mut guard = self
            .inner
            .lock()
            .map_err(|_| "Rust state session lock poisoned")?;
        let session = guard.as_mut().ok_or("Rust state session is closed")?;
        let inner = session
            .cancel_trajectory(session_id, expected_revision, request.inner)
            .map_err(|e| e.to_string())?;
        Ok(StateTrajectoryProgress {
            inner,
            snapshot: session.snapshot(),
        })
    }

    /// Consume and validate all four original envelopes once, not per command/frame.
    #[frb(sync)]
    pub fn new(
        modules: String,
        parameters: String,
        presets: String,
        capabilities: String,
        module_id: String,
    ) -> Result<Self, String> {
        let catalog = CatalogBaseline::from_jsons(&modules, &parameters, &presets, &capabilities)
            .map_err(|e| e.to_string())?;
        let session = Session::with_trajectory_cache(
            Arc::new(catalog),
            allocate_session_id(&LAST_SESSION_ID)?,
            &module_id,
            TRAJECTORY_CACHE
                .get_or_init(TrajectoryCache::default)
                .clone(),
        )
        .map_err(|e| e.to_string())?;
        Ok(Self {
            id: session.snapshot().session_id(),
            inner: Arc::new(Mutex::new(Some(session))),
            scheduled: Mutex::new(Some(Vec::new())),
        })
    }

    #[frb(sync)]
    pub fn snapshot(&self) -> Result<StateSnapshot, String> {
        self.snapshot_impl()
    }

    /// Normal-mode FRB transport: runs on the existing pool, not the UI thread.
    pub fn snapshot_async(&self) -> Result<StateSnapshot, String> {
        self.snapshot_impl()
    }

    fn snapshot_impl(&self) -> Result<StateSnapshot, String> {
        let guard = self
            .inner
            .lock()
            .map_err(|_| "Rust state session lock poisoned")?;
        let session = guard.as_ref().ok_or("Rust state session is closed")?;
        Ok(StateSnapshot {
            inner: session.snapshot(),
        })
    }

    #[frb(sync)]
    pub fn apply_batch(
        &self,
        session_id: u64,
        expected_revision: u64,
        commands: Vec<StateCommand>,
    ) -> Result<StateSnapshot, String> {
        let mut guard = self
            .inner
            .lock()
            .map_err(|_| "Rust state session lock poisoned")?;
        let session = guard.as_mut().ok_or("Rust state session is closed")?;
        let commands: Vec<_> = commands.into_iter().map(|command| command.inner).collect();
        session
            .apply_batch(session_id, expected_revision, &commands)
            .map(|inner| StateSnapshot { inner })
            .map_err(|e| e.to_string())
    }

    /// Stages a complete ingress or applies an immediate command; never drains work.
    #[frb(sync)]
    pub fn begin_number_wall(
        &self,
        session_id: u64,
        expected_revision: u64,
        command: StateCommand,
        request_guard: &StateNumberWallGuard,
        max_trial_divisions: u32,
    ) -> Result<Option<StateNumberWallRequest>, String> {
        self.begin_number_wall_impl(
            session_id,
            expected_revision,
            command,
            request_guard,
            max_trial_divisions,
        )
    }

    /// Normal-mode FRB transport: runs on the existing pool, not the UI thread.
    pub fn begin_number_wall_async(
        &self,
        session_id: u64,
        expected_revision: u64,
        command: StateCommand,
        request_guard: &StateNumberWallGuard,
        max_trial_divisions: u32,
    ) -> Result<Option<StateNumberWallRequest>, String> {
        self.begin_number_wall_impl(
            session_id,
            expected_revision,
            command,
            request_guard,
            max_trial_divisions,
        )
    }

    fn begin_number_wall_impl(
        &self,
        session_id: u64,
        expected_revision: u64,
        command: StateCommand,
        request_guard: &StateNumberWallGuard,
        max_trial_divisions: u32,
    ) -> Result<Option<StateNumberWallRequest>, String> {
        let mut guard = self
            .inner
            .lock()
            .map_err(|_| "Rust state session lock poisoned")?;
        let session = guard.as_mut().ok_or("Rust state session is closed")?;
        session
            .begin_number_wall(
                session_id,
                expected_revision,
                &command.inner,
                request_guard.inner.clone(),
                max_trial_divisions,
            )
            .map(|token| token.map(|inner| StateNumberWallRequest { inner }))
            .map_err(|e| e.to_string())
    }

    /// Exactly one bounded core step, including revocation observation at zero work.
    #[frb(sync)]
    pub fn advance_number_wall(
        &self,
        session_id: u64,
        expected_revision: u64,
        request: &StateNumberWallRequest,
        work_limit: u32,
    ) -> Result<StateNumberWallProgress, String> {
        self.advance_number_wall_impl(session_id, expected_revision, request, work_limit)
    }

    /// Normal-mode FRB transport: runs on the existing pool, not the UI thread.
    pub fn advance_number_wall_async(
        &self,
        session_id: u64,
        expected_revision: u64,
        request: &StateNumberWallRequest,
        work_limit: u32,
    ) -> Result<StateNumberWallProgress, String> {
        self.advance_number_wall_impl(session_id, expected_revision, request, work_limit)
    }

    fn advance_number_wall_impl(
        &self,
        session_id: u64,
        expected_revision: u64,
        request: &StateNumberWallRequest,
        work_limit: u32,
    ) -> Result<StateNumberWallProgress, String> {
        let work_limit = usize::try_from(work_limit).map_err(|_| "Work limit exceeds usize")?;
        let mut guard = self
            .inner
            .lock()
            .map_err(|_| "Rust state session lock poisoned")?;
        let session = guard.as_mut().ok_or("Rust state session is closed")?;
        let inner = session
            .advance_number_wall(session_id, expected_revision, request.inner, work_limit)
            .map_err(|e| e.to_string())?;
        Ok(StateNumberWallProgress {
            inner,
            snapshot: session.snapshot(),
        })
    }

    #[frb(sync)]
    pub fn cancel_number_wall(
        &self,
        session_id: u64,
        expected_revision: u64,
        request: &StateNumberWallRequest,
    ) -> Result<StateNumberWallProgress, String> {
        self.cancel_number_wall_impl(session_id, expected_revision, request)
    }

    /// Normal-mode FRB transport: runs on the existing pool, not the UI thread.
    pub fn cancel_number_wall_async(
        &self,
        session_id: u64,
        expected_revision: u64,
        request: &StateNumberWallRequest,
    ) -> Result<StateNumberWallProgress, String> {
        self.cancel_number_wall_impl(session_id, expected_revision, request)
    }

    fn cancel_number_wall_impl(
        &self,
        session_id: u64,
        expected_revision: u64,
        request: &StateNumberWallRequest,
    ) -> Result<StateNumberWallProgress, String> {
        let mut guard = self
            .inner
            .lock()
            .map_err(|_| "Rust state session lock poisoned")?;
        let session = guard.as_mut().ok_or("Rust state session is closed")?;
        let inner = session
            .cancel_number_wall(session_id, expected_revision, request.inner)
            .map_err(|e| e.to_string())?;
        Ok(StateNumberWallProgress {
            inner,
            snapshot: session.snapshot(),
        })
    }

    #[frb(sync)]
    pub fn shutdown(&self) -> Result<(), String> {
        self.shutdown_impl()
    }

    /// Normal-mode FRB transport: runs on the existing pool, not the UI thread.
    pub fn shutdown_async(&self) -> Result<(), String> {
        self.shutdown_impl()
    }

    fn shutdown_impl(&self) -> Result<(), String> {
        self.cancel_scheduled();
        self.inner
            .lock()
            .map_err(|_| "Rust state session lock poisoned")?
            .take();
        Ok(())
    }
}

/// Inert bounded scheduling domain, using the existing generated FRB pool.
#[frb(opaque)]
pub struct StateWorkService {
    pub(crate) inner: Arc<crate::state_work_executor::Executor>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum StateWorkPhase {
    Queued,
    Running,
    Finished,
    Cancelled,
    Failed,
}

/// Detached cached progress. Reading it never locks a Session or advances work.
#[derive(Debug, Clone)]
pub struct StateWorkStatus {
    pub phase: StateWorkPhase,
    pub error: Option<String>,
    pub snapshot: Option<StateSnapshot>,
    pub wall_status: Option<StateNumberWallStatus>,
    pub steps_completed: Option<u32>,
}

#[frb(opaque)]
pub struct StateWorkTicket {
    pub(crate) inner: Arc<crate::state_work_executor::TicketData>,
}

impl StateWorkService {
    #[frb(sync)]
    pub fn new() -> Self {
        Self::with_submitter(crate::state_work_executor::submit_to_frb)
    }

    #[frb(ignore)]
    pub fn with_submitter(
        submit: impl Fn(Box<dyn FnOnce() + Send>) + Send + Sync + 'static,
    ) -> Self {
        Self {
            inner: crate::state_work_executor::Executor::new(submit),
        }
    }

    #[frb(sync)]
    pub fn submit_trajectory(
        &self,
        session: &StateSession,
        session_id: u64,
        expected_revision: u64,
    ) -> Result<StateWorkTicket, String> {
        self.inner.submit(
            session,
            session_id,
            expected_revision,
            crate::state_work_executor::Operand::Trajectory,
            None,
        )
    }

    #[frb(sync)]
    pub fn replace_trajectory(
        &self,
        session: &StateSession,
        session_id: u64,
        expected_revision: u64,
        replace: &StateWorkTicket,
    ) -> Result<StateWorkTicket, String> {
        self.inner.submit(
            session,
            session_id,
            expected_revision,
            crate::state_work_executor::Operand::Trajectory,
            Some(replace),
        )
    }

    #[frb(sync)]
    pub fn submit_number_wall(
        &self,
        session: &StateSession,
        session_id: u64,
        expected_revision: u64,
        command: StateCommand,
        max_trial_divisions: u32,
    ) -> Result<StateWorkTicket, String> {
        self.inner.submit(
            session,
            session_id,
            expected_revision,
            crate::state_work_executor::Operand::Wall(command.inner, max_trial_divisions),
            None,
        )
    }

    #[frb(sync)]
    #[allow(clippy::too_many_arguments)]
    pub fn replace_number_wall(
        &self,
        session: &StateSession,
        session_id: u64,
        expected_revision: u64,
        command: StateCommand,
        max_trial_divisions: u32,
        replace: &StateWorkTicket,
    ) -> Result<StateWorkTicket, String> {
        self.inner.submit(
            session,
            session_id,
            expected_revision,
            crate::state_work_executor::Operand::Wall(command.inner, max_trial_divisions),
            Some(replace),
        )
    }
}

impl Default for StateWorkService {
    #[frb(ignore)]
    fn default() -> Self {
        Self::new()
    }
}
impl Drop for StateWorkService {
    fn drop(&mut self) {
        self.inner.close();
    }
}
impl StateWorkTicket {
    #[frb(sync)]
    pub fn status(&self) -> StateWorkStatus {
        self.inner.status()
    }
    #[frb(sync)]
    pub fn cancel(&self) {
        self.inner.cancel();
    }
}
impl Drop for StateWorkTicket {
    fn drop(&mut self) {
        self.inner.cancel();
    }
}
impl StateSession {
    pub(crate) fn cancel_scheduled(&self) {
        for ticket in self
            .scheduled
            .lock()
            .expect("scheduled subscriptions poisoned")
            .take()
            .into_iter()
            .flatten()
            .filter_map(|w| w.upgrade())
        {
            ticket.cancel();
        }
    }
}
impl Drop for StateSession {
    fn drop(&mut self) {
        self.cancel_scheduled();
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn checked_identity_exhaustion_is_unique_even_under_contention() {
        let last = Arc::new(AtomicU64::new(u64::MAX - 2));
        let workers: Vec<_> = (0..4)
            .map(|_| {
                let last = last.clone();
                std::thread::spawn(move || allocate_session_id(&last))
            })
            .collect();
        let mut ids: Vec<_> = workers
            .into_iter()
            .filter_map(|w| w.join().unwrap().ok())
            .collect();
        ids.sort_unstable();
        assert_eq!(ids, vec![u64::MAX - 1, u64::MAX]);
        assert!(allocate_session_id(&last).is_err());
        assert_eq!(last.load(Ordering::SeqCst), u64::MAX);
    }

    #[test]
    fn generated_rust_u64_codec_preserves_large_identity_and_revision_operands() {
        use crate::frb_generated::SseEncode;
        use flutter_rust_bridge::for_generated::SseSerializer;
        let id = (1_u64 << 53) + 1;
        let catalog = CatalogBaseline::from_jsons(
            include_str!("../../../../migration/baseline/modules.json"),
            include_str!("../../../../migration/baseline/parameters.json"),
            include_str!("../../../../migration/baseline/presets.json"),
            include_str!("../../../../migration/baseline/capabilities.json"),
        )
        .unwrap();
        // Private setup only: no public identity/revision setter is exposed.
        let session = StateSession {
            id,
            scheduled: Mutex::new(Some(Vec::new())),
            inner: Arc::new(Mutex::new(Some(
                Session::new(Arc::new(catalog), id, "mandelbrot").unwrap(),
            ))),
        };
        assert_eq!(session.snapshot().unwrap().session_id(), id);
        assert_eq!(
            session.apply_batch(id - 1, 0, vec![]).unwrap_err(),
            "WrongSession"
        );
        assert_eq!(
            session.apply_batch(id, id, vec![]).unwrap_err(),
            "StaleRevision"
        );
        assert_eq!(session.apply_batch(id, 0, vec![]).unwrap().session_id(), id);
        // The same generated u64 codec serves snapshot identity/revision and
        // apply_batch operands. This is Rust-side evidence, not executed Dart/native proof.
        // Core's existing private revision-exhaustion test covers large actual revisions.
        for value in [
            session.snapshot().unwrap().session_id(),
            u64::MAX - 1,
            u64::MAX,
        ] {
            let mut serializer = SseSerializer::new();
            value.sse_encode(&mut serializer);
            assert_eq!(serializer.cursor.into_inner(), value.to_ne_bytes());
        }
    }

    #[test]
    fn opaque_sessions_close_idempotently_and_independently() {
        assert_eq!(engine_version(), "0.1.0");
        let probe = create_engine().unwrap();
        let other = create_engine().unwrap();
        let snapshot = engine_snapshot(&probe);
        assert_eq!(snapshot, engine_snapshot(&probe));
        assert_eq!(snapshot.revision, 0);
        assert_ne!(snapshot.session_id, engine_snapshot(&other).session_id);
        assert_eq!(engine_snapshot(&other).revision, 0);
        let first = Engine::new();
        let second = Engine::new();
        assert!(!first.capabilities().unwrap().rendering);
        first.shutdown();
        first.shutdown();
        assert_eq!(
            first.capabilities().err().as_deref(),
            Some("Rust engine session is closed")
        );
        assert!(!second.capabilities().unwrap().rendering);
        second.shutdown();
        assert!(second.capabilities().is_err());
    }
}
