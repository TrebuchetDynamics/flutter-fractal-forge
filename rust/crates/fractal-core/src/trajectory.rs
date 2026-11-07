//! Pure fixed-step RK4 trajectories. Session ingress and cache policy are not owned here.

use std::{
    fmt,
    ops::{Add, Mul},
    sync::atomic::{AtomicBool, Ordering},
};

use serde::{Deserialize, Serialize};
use serde_json::Value;

pub const MAXIMUM_STEPS: u32 = 25_000;
pub const MAXIMUM_RETAINED_SAMPLES: u32 = 20_000;
pub const MAX_STEPS_PER_ADVANCE: u32 = 256;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum AttractorSystem {
    Thomas,
    FourWing,
    Lorenz2d,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum OrbitProjection {
    Xz,
    ThomasOblique,
}

#[derive(Debug, Clone, Copy, PartialEq, Serialize, Deserialize)]
#[serde(from = "[f64; 3]", into = "[f64; 3]")]
pub struct OrbitPoint {
    pub x: f64,
    pub y: f64,
    pub z: f64,
}

impl OrbitPoint {
    pub fn is_finite(self) -> bool {
        self.x.is_finite() && self.y.is_finite() && self.z.is_finite()
    }
}

impl From<[f64; 3]> for OrbitPoint {
    fn from([x, y, z]: [f64; 3]) -> Self {
        Self { x, y, z }
    }
}

impl From<OrbitPoint> for [f64; 3] {
    fn from(point: OrbitPoint) -> Self {
        [point.x, point.y, point.z]
    }
}

impl Add for OrbitPoint {
    type Output = Self;

    fn add(self, other: Self) -> Self {
        Self::from([self.x + other.x, self.y + other.y, self.z + other.z])
    }
}

impl Mul<f64> for OrbitPoint {
    type Output = Self;

    fn mul(self, scale: f64) -> Self {
        Self::from([self.x * scale, self.y * scale, self.z * scale])
    }
}

/// Validated version-1/rk4 settings. No mutable fields or unchecked deserialization.
/// Equality is numeric, not Dart cache-key string equivalence.
#[derive(Debug, Clone, Copy, PartialEq, Serialize, Deserialize)]
#[serde(try_from = "SettingsJson", into = "SettingsJson")]
pub struct OrbitTrajectorySettings {
    system: AttractorSystem,
    seed: OrbitPoint,
    step_size: f64,
    burn_in_steps: u32,
    retained_steps: u32,
    projection: OrbitProjection,
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
struct SettingsJson {
    version: u32,
    system: AttractorSystem,
    seed: OrbitPoint,
    integrator: String,
    step_size: f64,
    burn_in_steps: u32,
    retained_steps: u32,
    projection: OrbitProjection,
}

impl TryFrom<SettingsJson> for OrbitTrajectorySettings {
    type Error = TrajectoryError;

    fn try_from(value: SettingsJson) -> Result<Self, Self::Error> {
        if value.version != 1 || value.integrator != "rk4" {
            return Err(TrajectoryError::InvalidSettings);
        }
        Self::new(
            value.system,
            value.seed,
            value.step_size,
            value.burn_in_steps,
            value.retained_steps,
            value.projection,
        )
    }
}

impl From<OrbitTrajectorySettings> for SettingsJson {
    fn from(value: OrbitTrajectorySettings) -> Self {
        Self {
            version: value.version(),
            system: value.system,
            seed: value.seed,
            integrator: value.integrator().to_owned(),
            step_size: value.step_size,
            burn_in_steps: value.burn_in_steps,
            retained_steps: value.retained_steps,
            projection: value.projection,
        }
    }
}

impl OrbitTrajectorySettings {
    pub fn new(
        system: AttractorSystem,
        seed: OrbitPoint,
        step_size: f64,
        burn_in_steps: u32,
        retained_steps: u32,
        projection: OrbitProjection,
    ) -> Result<Self, TrajectoryError> {
        if !seed.is_finite()
            || !step_size.is_finite()
            || step_size <= 0.0
            || step_size > 0.1
            || retained_steps == 0
            || retained_steps > MAXIMUM_RETAINED_SAMPLES
            || burn_in_steps
                .checked_add(retained_steps)
                .is_none_or(|total| total > MAXIMUM_STEPS)
        {
            return Err(TrajectoryError::InvalidSettings);
        }
        Ok(Self {
            system,
            seed,
            step_size,
            burn_in_steps,
            retained_steps,
            projection,
        })
    }

    /// Only these exact module IDs have approved trajectory defaults.
    pub fn defaults_for(module_id: &str) -> Option<Self> {
        let (system, seed, projection) = match module_id {
            "thomas_attractor" => (
                AttractorSystem::Thomas,
                [0.1, 0.2, 0.3],
                OrbitProjection::ThomasOblique,
            ),
            "four_wing" => (
                AttractorSystem::FourWing,
                [1.0, 1.0, 1.0],
                OrbitProjection::Xz,
            ),
            "lorenz_2d" => (
                AttractorSystem::Lorenz2d,
                [0.1, 0.2, 0.3],
                OrbitProjection::Xz,
            ),
            _ => return None,
        };
        Self::new(system, seed.into(), 0.01, 5000, 20_000, projection).ok()
    }

    pub fn is_compatible_with(&self, module_id: &str) -> bool {
        Self::defaults_for(module_id).is_some_and(|defaults| {
            defaults.system == self.system && defaults.projection == self.projection
        })
    }

    pub fn version(&self) -> u32 {
        1
    }

    pub fn integrator(&self) -> &'static str {
        "rk4"
    }

    pub fn system(&self) -> AttractorSystem {
        self.system
    }

    pub fn seed(&self) -> OrbitPoint {
        self.seed
    }

    pub fn step_size(&self) -> f64 {
        self.step_size
    }

    pub fn burn_in_steps(&self) -> u32 {
        self.burn_in_steps
    }

    pub fn retained_steps(&self) -> u32 {
        self.retained_steps
    }

    pub fn projection(&self) -> OrbitProjection {
        self.projection
    }
}

/// Legacy null is absence, while malformed non-null representations are errors.
pub fn decode_orbit_trajectory_settings(
    value: &Value,
) -> Result<Option<OrbitTrajectorySettings>, serde_json::Error> {
    serde_json::from_value(value.clone())
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum TrajectoryError {
    InvalidSettings,
    InvalidIntegrationInputs,
    NonFiniteIntegration,
    SafetyBounds,
    Cancelled,
}

impl fmt::Display for TrajectoryError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(match self {
            Self::InvalidSettings => "Invalid trajectory representation or settings.",
            Self::InvalidIntegrationInputs => "Integration inputs must be finite and bounded.",
            Self::NonFiniteIntegration => "Attractor integration diverged to a non-finite state.",
            Self::SafetyBounds => "Attractor trajectory left the finite safety bounds.",
            Self::Cancelled => "Attractor trajectory cancelled.",
        })
    }
}

impl std::error::Error for TrajectoryError {}

#[derive(Debug, Clone, Copy, PartialEq)]
pub struct ProjectedOrbitPoint {
    pub x: f64,
    pub y: f64,
}

pub fn project(point: OrbitPoint, projection: OrbitProjection) -> ProjectedOrbitPoint {
    match projection {
        OrbitProjection::Xz => ProjectedOrbitPoint {
            x: point.x,
            y: point.z,
        },
        OrbitProjection::ThomasOblique => ProjectedOrbitPoint {
            x: (point.x - point.y) / 2.0_f64.sqrt(),
            y: (point.x + point.y - 2.0 * point.z) / 6.0_f64.sqrt(),
        },
    }
}

/// Independent integration retains Dart's finite-only guard, without generation's
/// step-size/work caps or 1e12 coordinate limit. Unsigned steps exclude negatives.
pub fn integrate(
    system: AttractorSystem,
    initial: OrbitPoint,
    dt: f64,
    steps: u32,
) -> Result<OrbitPoint, TrajectoryError> {
    if !initial.is_finite() || !dt.is_finite() || dt <= 0.0 {
        return Err(TrajectoryError::InvalidIntegrationInputs);
    }
    let mut state = initial;
    for _ in 0..steps {
        state = rk4(system, state, dt);
        if !state.is_finite() {
            return Err(TrajectoryError::NonFiniteIntegration);
        }
    }
    Ok(state)
}

fn rk4(system: AttractorSystem, point: OrbitPoint, dt: f64) -> OrbitPoint {
    let k1 = derivative(system, point);
    let k2 = derivative(system, point + k1 * (dt / 2.0));
    let k3 = derivative(system, point + k2 * (dt / 2.0));
    let k4 = derivative(system, point + k3 * dt);
    point + (k1 + k2 * 2.0 + k3 * 2.0 + k4) * (dt / 6.0)
}

fn derivative(system: AttractorSystem, p: OrbitPoint) -> OrbitPoint {
    match system {
        AttractorSystem::Thomas => OrbitPoint::from([
            p.y.sin() - 0.208186 * p.x,
            p.z.sin() - 0.208186 * p.y,
            p.x.sin() - 0.208186 * p.z,
        ]),
        AttractorSystem::FourWing => OrbitPoint::from([
            0.2 * p.x + p.y * p.z,
            0.01 * p.x - 0.4 * p.y - p.x * p.z,
            -p.z - p.x * p.y + 0.6,
        ]),
        AttractorSystem::Lorenz2d => OrbitPoint::from([
            10.0 * (p.y - p.x),
            p.x * (28.0 - p.z) - p.y,
            p.x * p.y - (8.0 / 3.0) * p.z,
        ]),
    }
}

#[derive(Debug, Clone, Copy, PartialEq)]
pub struct OrbitBounds {
    pub min_x: f64,
    pub max_x: f64,
    pub min_y: f64,
    pub max_y: f64,
}

impl OrbitBounds {
    pub fn is_finite(self) -> bool {
        self.min_x.is_finite()
            && self.max_x.is_finite()
            && self.min_y.is_finite()
            && self.max_y.is_finite()
    }

    fn include(&mut self, point: ProjectedOrbitPoint) {
        self.min_x = self.min_x.min(point.x);
        self.max_x = self.max_x.max(point.x);
        self.min_y = self.min_y.min(point.y);
        self.max_y = self.max_y.max(point.y);
    }
}

/// Owned terminal samples. Only shared slices and copies of scalar values escape.
#[derive(Debug, Clone, PartialEq)]
pub struct AttractorTrajectory {
    settings: OrbitTrajectorySettings,
    points: Vec<OrbitPoint>,
    bounds: OrbitBounds,
}

impl AttractorTrajectory {
    pub fn settings(&self) -> &OrbitTrajectorySettings {
        &self.settings
    }

    pub fn points(&self) -> &[OrbitPoint] {
        &self.points
    }

    pub fn bounds(&self) -> OrbitBounds {
        self.bounds
    }
}

/// Bounded generation with terminal success, divergence or cancellation.
#[derive(Debug)]
pub struct TrajectoryJob {
    settings: OrbitTrajectorySettings,
    state: OrbitPoint,
    steps_completed: u32,
    points: Vec<OrbitPoint>,
    bounds: OrbitBounds,
    result: Option<Result<AttractorTrajectory, TrajectoryError>>,
}

impl TrajectoryJob {
    pub fn new(settings: OrbitTrajectorySettings) -> Self {
        Self {
            settings,
            state: settings.seed,
            steps_completed: 0,
            points: Vec::with_capacity(settings.retained_steps as usize),
            bounds: OrbitBounds {
                min_x: f64::INFINITY,
                max_x: f64::NEG_INFINITY,
                min_y: f64::INFINITY,
                max_y: f64::NEG_INFINITY,
            },
            result: None,
        }
    }

    pub fn steps_completed(&self) -> u32 {
        self.steps_completed
    }

    pub fn result(&self) -> Option<&Result<AttractorTrajectory, TrajectoryError>> {
        self.result.as_ref()
    }

    pub(crate) fn into_result(self) -> Option<Result<AttractorTrajectory, TrajectoryError>> {
        self.result
    }

    /// At most 256 integration steps, including burn-in. Bounds are accumulated
    /// per retained point. An exact chunk boundary yields before final publication.
    /// Cancellation is checked at every step and immediately before publication.
    /// Terminal results never change on subsequent advances.
    pub fn advance(
        &mut self,
        is_cancelled: &AtomicBool,
    ) -> Option<&Result<AttractorTrajectory, TrajectoryError>> {
        if self.result.is_some() {
            return self.result();
        }
        let total = self.settings.burn_in_steps + self.settings.retained_steps;
        for _ in 0..MAX_STEPS_PER_ADVANCE {
            if is_cancelled.load(Ordering::Relaxed) {
                self.points = Vec::new();
                self.result = Some(Err(TrajectoryError::Cancelled));
                return self.result();
            }
            if self.steps_completed == total {
                // Move the already-owned buffer; no final scan or sample copy.
                self.result = Some(Ok(AttractorTrajectory {
                    settings: self.settings,
                    points: std::mem::take(&mut self.points),
                    bounds: self.bounds,
                }));
                return self.result();
            }
            self.state = rk4(self.settings.system, self.state, self.settings.step_size);
            self.steps_completed += 1;
            if !self.state.is_finite()
                || self.state.x.abs() > 1e12
                || self.state.y.abs() > 1e12
                || self.state.z.abs() > 1e12
            {
                self.points = Vec::new();
                self.result = Some(Err(TrajectoryError::SafetyBounds));
                return self.result();
            }
            if self.steps_completed > self.settings.burn_in_steps {
                self.bounds
                    .include(project(self.state, self.settings.projection));
                self.points.push(self.state);
            }
        }
        None
    }
}

/// Synchronous generation drives exactly the same bounded kernel.
pub fn generate(settings: OrbitTrajectorySettings) -> Result<AttractorTrajectory, TrajectoryError> {
    let mut job = TrajectoryJob::new(settings);
    let is_cancelled = AtomicBool::new(false);
    while job.advance(&is_cancelled).is_none() {}
    job.result.expect("terminal job result")
}
