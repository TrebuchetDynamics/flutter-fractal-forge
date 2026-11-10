//! Pure Precision Ladder policy. Dart remains the renderer owner and parity oracle.
//! Capability facts come from the caller, not a second module registry.

use crate::catalog_baseline::Dimension;
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Copy, Deserialize)]
#[serde(rename_all = "camelCase", deny_unknown_fields)]
pub struct Capabilities {
    pub native_cpu: bool,
    pub perturbation: bool,
}

/// Raw policy operands: deliberately not normalized through the camera's ceiling.
#[derive(Debug, Clone, Copy)]
pub struct Sample<'a> {
    pub module_id: &'a str,
    pub dimension: &'a Dimension,
    pub zoom: f64,
    pub power: f64,
    pub capabilities: Capabilities,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize)]
#[serde(rename_all = "camelCase")]
pub enum RenderPath {
    GpuFloat,
    GpuDoubleFloat,
    GpuPerturbation,
    Cpu,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize)]
#[serde(rename_all = "camelCase")]
pub enum Tier {
    RealtimeGpu,
    ExtendedGpu,
    PrecisionRefine,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize)]
#[serde(rename_all = "camelCase")]
pub enum Exactness {
    Approximate,
    ExtendedGpuPreview,
    CpuPrecision,
}

#[derive(Debug)]
pub struct Decision<'a> {
    pub module_id: &'a str,
    pub dimension: &'a Dimension,
    pub zoom: f64,
    pub render_path: RenderPath,
    pub tier: Tier,
    pub exactness: Exactness,
    pub cpu_fallback_pending: bool,
}

impl Decision<'_> {
    pub fn uses_cpu_renderer(&self) -> bool {
        self.render_path == RenderPath::Cpu
    }

    pub fn uses_double_float_gpu(&self) -> bool {
        self.render_path == RenderPath::GpuDoubleFloat
    }

    pub fn uses_perturbation_gpu(&self) -> bool {
        self.render_path == RenderPath::GpuPerturbation
    }

    pub fn uses_extended_gpu(&self) -> bool {
        self.uses_double_float_gpu() || self.uses_perturbation_gpu()
    }

    pub fn show_precision_indicator(&self) -> bool {
        self.tier != Tier::RealtimeGpu || self.cpu_fallback_pending
    }

    pub fn status_label(&self) -> &'static str {
        match self.tier {
            Tier::RealtimeGpu if self.cpu_fallback_pending => "Precision pending",
            Tier::RealtimeGpu => "GPU",
            Tier::ExtendedGpu => "Deep GPU preview",
            Tier::PrecisionRefine => "CPU Precision",
        }
    }

    pub fn debug_renderer_label(&self) -> &'static str {
        match self.render_path {
            RenderPath::GpuFloat => "GPU",
            RenderPath::GpuDoubleFloat => "GPU-DF2",
            RenderPath::GpuPerturbation => "GPU-PERTURB",
            RenderPath::Cpu => "CPU",
        }
    }
}

fn cpu_threshold(module_id: &str) -> f64 {
    match module_id {
        "mandelbrot" => 1e12,
        "julia" | "celtic" | "buffalo" | "burning_ship" | "burning_ship_julia" | "tricorn"
        | "multibrot3" | "multibrot4" | "multibrot5" | "phoenix" => 1e9,
        "weierstrass_p" => 1e5,
        _ => 1e7,
    }
}

pub fn decide(sample: Sample<'_>, cpu_fallback_active: bool) -> Decision<'_> {
    let mut decision = Decision {
        module_id: sample.module_id,
        dimension: sample.dimension,
        zoom: sample.zoom,
        render_path: RenderPath::GpuFloat,
        tier: Tier::RealtimeGpu,
        exactness: Exactness::Approximate,
        cpu_fallback_pending: false,
    };
    if !matches!(sample.dimension, Dimension::TwoD) {
        return decision;
    }

    // Only Burning Ship's path decision is quadratic-only; its ceiling is not.
    let perturbation = (sample.module_id != "burning_ship" || sample.power == 2.0)
        && sample.capabilities.perturbation
        && sample.zoom >= 5e6
        && sample.zoom < 1e30;
    let double_float = sample.module_id == "mandelbrot" && sample.zoom >= 5e6 && sample.zoom < 1e12;
    if perturbation || double_float {
        decision.render_path = if perturbation {
            RenderPath::GpuPerturbation
        } else {
            RenderPath::GpuDoubleFloat
        };
        decision.tier = Tier::ExtendedGpu;
        decision.exactness = Exactness::ExtendedGpuPreview;
        return decision;
    }

    let needs_cpu =
        sample.zoom >= cpu_threshold(sample.module_id) && sample.capabilities.native_cpu;
    if needs_cpu && cpu_fallback_active {
        decision.render_path = RenderPath::Cpu;
        decision.tier = Tier::PrecisionRefine;
        decision.exactness = Exactness::CpuPrecision;
    } else {
        decision.cpu_fallback_pending = needs_cpu;
    }
    decision
}

pub fn gpu_renderable_ceiling_zoom(module_id: &str, capabilities: Capabilities) -> f64 {
    if capabilities.perturbation {
        1e30
    } else {
        cpu_threshold(module_id)
    }
}

pub fn scaled_gpu_iterations(base_iterations: i64, zoom: f64) -> i64 {
    let base = base_iterations.clamp(4, 2000);
    let depth = if zoom.is_nan() || zoom <= 1.0 {
        0.0
    } else if zoom.is_infinite() {
        30.0
    } else {
        (zoom.ln() / std::f64::consts::LN_10).clamp(0.0, 30.0)
    };
    if depth == 0.0 {
        return base;
    }
    ((base as f64 * (1.0 + 0.35 * depth)).round() as i64).clamp(4, 2000)
}

#[derive(Debug, Default, Clone, PartialEq, Eq, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct HysteresisState {
    pub module_id: Option<String>,
    pub above_threshold_count: u64,
    pub cpu_active: bool,
}

impl HysteresisState {
    pub fn next(&self, module_id: &str, over_threshold: bool, activation_frames: u64) -> Self {
        assert!(activation_frames > 0, "activation_frames must be positive");
        let current_count = if self.module_id.as_deref() == Some(module_id) {
            self.above_threshold_count
        } else {
            0
        };
        let count = if over_threshold { current_count + 1 } else { 0 };
        Self {
            module_id: Some(module_id.into()),
            above_threshold_count: count,
            cpu_active: over_threshold && count >= activation_frames,
        }
    }
}

#[derive(Debug, Default)]
pub struct Hysteresis {
    state: HysteresisState,
}

impl Hysteresis {
    pub fn state(&self) -> &HysteresisState {
        &self.state
    }

    pub fn update<'a>(&mut self, sample: Sample<'a>) -> Decision<'a> {
        let candidate = decide(sample, true);
        self.state = self
            .state
            .next(sample.module_id, candidate.uses_cpu_renderer(), 2);
        decide(sample, self.state.cpu_active)
    }

    pub fn reset(&mut self) {
        self.state = HysteresisState::default();
    }
}
