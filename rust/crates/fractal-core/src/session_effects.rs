//! Source-matched inert effect state; private child of the session owner.

use super::Snapshot;
use crate::normalization::clamp;

#[derive(Debug, Clone, Copy, PartialEq)]
pub(super) struct Kaleidoscope {
    pub enabled: bool,
    pub sectors: i64,
    pub mirror: bool,
    pub rotation: f64,
    pub mirror_mode: i64,
}

#[derive(Debug, Clone, PartialEq)]
pub(super) struct Effects {
    pub glow_enabled: bool,
    pub glow_sigma: f64,
    pub glow_intensity: f64,
    pub fluid_mode_enabled: bool,
    pub fluid_strength: f64,
    pub rotation_locked: bool,
    pub kaleidoscope: Kaleidoscope,
    restore_after_forced_module: Option<Kaleidoscope>,
}

impl Default for Effects {
    fn default() -> Self {
        Self {
            glow_enabled: false,
            glow_sigma: 1.0,
            glow_intensity: 0.35,
            fluid_mode_enabled: false,
            fluid_strength: 1.0,
            rotation_locked: false,
            kaleidoscope: Kaleidoscope {
                enabled: false,
                sectors: 8,
                mirror: true,
                rotation: 0.0,
                mirror_mode: 0,
            },
            restore_after_forced_module: None,
        }
    }
}

pub(super) fn is_forced_module(id: &str) -> bool {
    // Only these original catalog IDs are supported, not arbitrary prefix matches.
    matches!(id, "kaleidoscope_basic" | "kaleidoscope_fractal")
}

impl Effects {
    pub fn apply_module_policy(&mut self, id: &str) {
        if is_forced_module(id) {
            self.restore_after_forced_module
                .get_or_insert(self.kaleidoscope);
            self.kaleidoscope.enabled = true;
            self.kaleidoscope.sectors = 16;
            self.kaleidoscope.mirror_mode = 3;
        } else if let Some(restore) = self.restore_after_forced_module.take() {
            self.kaleidoscope = restore;
        }
    }
}

pub(super) fn bounded(candidate: f64, current: f64, min: f64, max: f64) -> f64 {
    let fallback = if current.is_nan() { min } else { current };
    clamp(
        if candidate.is_nan() {
            fallback
        } else {
            candidate
        },
        min,
        max,
    )
}

impl Snapshot {
    pub fn glow_enabled(&self) -> bool {
        self.effects.glow_enabled
    }
    pub fn glow_sigma(&self) -> f64 {
        self.effects.glow_sigma
    }
    pub fn glow_intensity(&self) -> f64 {
        self.effects.glow_intensity
    }
    pub fn fluid_mode_enabled(&self) -> bool {
        self.effects.fluid_mode_enabled
    }
    pub fn fluid_strength(&self) -> f64 {
        self.effects.fluid_strength
    }
    /// Gesture policy state; direct Rotation commands remain allowed.
    pub fn rotation_locked(&self) -> bool {
        self.effects.rotation_locked
    }
    pub fn kaleidoscope_enabled(&self) -> bool {
        self.effects.kaleidoscope.enabled
    }
    pub fn kaleidoscope_sectors(&self) -> i64 {
        self.effects.kaleidoscope.sectors
    }
    pub fn kaleidoscope_mirror(&self) -> bool {
        self.effects.kaleidoscope.mirror
    }
    pub fn kaleidoscope_rotation(&self) -> f64 {
        self.effects.kaleidoscope.rotation
    }
    pub fn kaleidoscope_mirror_mode(&self) -> i64 {
        self.effects.kaleidoscope.mirror_mode
    }
}
