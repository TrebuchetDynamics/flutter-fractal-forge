//! Pure camera math ported from renderer/input/gesture_handler.dart and momentum helpers.
//! Results are raw candidates: apply `normalize_view` before storing them. This module
//! owns no recognition, pointer handoff, clock, animation or Session transaction.

use crate::{
    catalog_baseline::Dimension,
    normalization::{DEFAULT_MIN_ZOOM, MAX_PAN, MAX_ZOOM, MIN_PAN, ViewInput, clamp},
};
use std::f64::consts::PI;

fn rubber_band(value: f64, min: f64, max: f64) -> f64 {
    if value < min {
        min + (value - min) * 0.5
    } else if value > max {
        max + (value - max) * 0.5
    } else {
        value
    }
}

fn bounded_pan(pan: [f64; 2]) -> [f64; 2] {
    pan.map(|v| rubber_band(v, MIN_PAN, MAX_PAN))
}

fn scale_px(viewport: [f64; 2]) -> f64 {
    viewport[0].min(viewport[1]).max(1.0)
}

fn normalized_point(point: [f64; 2], viewport: [f64; 2]) -> [f64; 2] {
    let scale = scale_px(viewport);
    std::array::from_fn(|i| (point[i] - viewport[i] / 2.0) / scale)
}

fn rotate_inverse(value: [f64; 2], angle: f64) -> [f64; 2] {
    let (sin, cos) = angle.sin_cos();
    [
        value[0] * cos + value[1] * sin,
        -value[0] * sin + value[1] * cos,
    ]
}

fn screen_rotation(dimension: &Dimension, rotation_z: f64) -> f64 {
    match dimension {
        // Stored rotZ does not rotate the current 2D FlutterFragCoord shaders.
        Dimension::TwoD => 0.0,
        Dimension::ThreeD => rotation_z,
    }
}

/// 2D pixel delta, using the shader's shortest-side scale and safe zoom floor.
/// Stored rotation intentionally has no effect on 2D screen mapping.
pub fn screen_delta_to_world(delta: [f64; 2], viewport: [f64; 2], zoom: f64) -> [f64; 2] {
    let scale = scale_px(viewport);
    delta.map(|v| (v / scale) / zoom.max(1e-9))
}

/// Incremental 2D drag (also usable with elapsed pan displacement).
pub fn drag_2d(current: ViewInput, delta: [f64; 2], viewport: [f64; 2]) -> ViewInput {
    let world = screen_delta_to_world(delta, viewport, current.zoom);
    ViewInput {
        pan: bounded_pan(std::array::from_fn(|i| current.pan[i] - world[i])),
        ..current
    }
}

/// XY target displacement along the raymarch camera-right/up columns.
/// Unlike 2D mapping, camera target motion scales by height, not shortest side.
pub fn camera_target_delta(
    delta: [f64; 2],
    viewport: [f64; 2],
    zoom: f64,
    rotation: [f64; 3],
) -> [f64; 2] {
    let [x, y, z] = rotation;
    let (sx, cx) = x.sin_cos();
    let (sy, cy) = y.sin_cos();
    let (sz, cz) = z.sin_cos();
    let units_per_pixel = 6.0 / (viewport[1].max(1.0) * zoom.max(0.1));
    let right = -delta[0] * units_per_pixel;
    let up = delta[1] * units_per_pixel;
    [
        cy * cz * right + cy * sz * up,
        (sx * sy * cz - cx * sz) * right + (sx * sy * sz + cx * cz) * up,
    ]
}

/// Caller-selected 3D gesture orbit. The lock applies here, not to direct commands.
/// The event/animation owner selects whether to apply this operation to a fling.
pub fn orbit(
    current: ViewInput,
    delta: [f64; 2],
    viewport: [f64; 2],
    horizontal_orbit_sign: f64,
    rotation_locked: bool,
) -> ViewInput {
    if rotation_locked {
        return current;
    }
    let tilt_max = 67.5 * PI / 180.0;
    ViewInput {
        rotation: [
            clamp(
                current.rotation[0] - delta[1] * (PI / viewport[1].max(1.0)),
                -tilt_max,
                tilt_max,
            ),
            current.rotation[1] + horizontal_orbit_sign * delta[0] * (PI / viewport[0].max(1.0)),
            current.rotation[2],
        ],
        ..current
    }
}

/// Unbounded wheel target; focal zoom applies soft bands before hard normalization.
pub fn wheel_zoom_target(current_zoom: f64, scroll_dy: f64) -> f64 {
    current_zoom * (-scroll_dy * 0.001).exp()
}

/// Keep the focal world point fixed using the current view's screen rotation.
/// Missing layout/focal leaves pan unchanged.
pub fn focal_zoom(
    current: ViewInput,
    target_zoom: f64,
    dimension: &Dimension,
    viewport: Option<[f64; 2]>,
    focal: Option<[f64; 2]>,
) -> ViewInput {
    let zoom = rubber_band(target_zoom, DEFAULT_MIN_ZOOM, MAX_ZOOM);
    let pan = if let (Some(viewport), Some(focal)) = (viewport, focal) {
        let rotated = rotate_inverse(
            normalized_point(focal, viewport),
            screen_rotation(dimension, current.rotation[2]),
        );
        bounded_pan(std::array::from_fn(|i| {
            current.pan[i] + rotated[i] / current.zoom - rotated[i] / zoom
        }))
    } else {
        current.pan
    };
    ViewInput {
        zoom,
        pan,
        ..current
    }
}

/// Double-tap computes a clamped endpoint, not an animation or tap decision.
pub fn double_tap_target(
    current: ViewInput,
    dimension: &Dimension,
    viewport: Option<[f64; 2]>,
    focal: Option<[f64; 2]>,
) -> ViewInput {
    focal_zoom(
        current,
        clamp(current.zoom * 2.0, DEFAULT_MIN_ZOOM, MAX_ZOOM),
        dimension,
        viewport,
        focal,
    )
}

/// Resolved pinch geometry with a known viewport. The caller selects anchors,
/// scale and intentional rotation delta; this record does not recognize gestures.
#[derive(Debug, Clone, Copy)]
pub struct Pinch {
    pub viewport: [f64; 2],
    pub start_focal: [f64; 2],
    pub focal: [f64; 2],
    pub scale: f64,
    /// Accumulated intentional twist from the start, already selected by the owner.
    pub rotation_delta: f64,
    pub rotation_locked: bool,
}

/// Anchored pinch math. 3D uses start zoom and current camera axes for target pan;
/// with layout present it does not twist the camera. 2D stores twist but maps at zero.
pub fn pinch(
    start: ViewInput,
    current: ViewInput,
    dimension: &Dimension,
    gesture: &Pinch,
) -> ViewInput {
    let zoom = rubber_band(start.zoom * gesture.scale, DEFAULT_MIN_ZOOM, MAX_ZOOM);
    let mut rotation = current.rotation;
    let pan = match dimension {
        Dimension::ThreeD => {
            let delta = camera_target_delta(
                std::array::from_fn(|i| gesture.focal[i] - gesture.start_focal[i]),
                gesture.viewport,
                start.zoom,
                current.rotation,
            );
            std::array::from_fn(|i| start.pan[i] + delta[i])
        }
        Dimension::TwoD => {
            let start_n = normalized_point(gesture.start_focal, gesture.viewport);
            let current_n = normalized_point(gesture.focal, gesture.viewport);
            rotation[2] = start.rotation[2]
                + if gesture.rotation_locked {
                    0.0
                } else {
                    gesture.rotation_delta
                };
            std::array::from_fn(|i| start_n[i] / start.zoom + start.pan[i] - current_n[i] / zoom)
        }
    };
    ViewInput {
        zoom,
        pan: bounded_pan(pan),
        rotation,
    }
}

#[derive(Debug, Clone, Copy, PartialEq)]
pub struct PanStep {
    pub displacement: [f64; 2],
    /// Pixels per 16000-us reference frame, as in the Dart helper.
    pub velocity: [f64; 2],
}

/// Elapsed-time pan inertia. No additional nonfinite velocity policy is imposed.
pub fn advance_pan(velocity: [f64; 2], elapsed_us: i64) -> PanStep {
    let speed = (velocity[0] * velocity[0] + velocity[1] * velocity[1]).sqrt();
    if speed <= 0.1 {
        return PanStep {
            displacement: [0.0; 2],
            velocity: [0.0; 2],
        };
    }
    if elapsed_us <= 0 {
        return PanStep {
            displacement: [0.0; 2],
            velocity,
        };
    }
    let retention = 0.95_f64;
    let frames = elapsed_us as f64 / 16000.0;
    let stop_frames = (0.1 / speed).ln() / retention.ln();
    let decay = retention.powf(frames.min(stop_frames));
    let travel = retention * (1.0 - decay) / (1.0 - retention);
    PanStep {
        displacement: velocity.map(|v| v * travel),
        velocity: if frames >= stop_frames {
            [0.0; 2]
        } else {
            velocity.map(|v| v * decay)
        },
    }
}

#[derive(Debug, Clone, Copy, PartialEq)]
pub struct ZoomStep {
    pub log_zoom_delta: f64,
    pub velocity: f64,
}

/// Elapsed-time log2 zoom inertia, retaining the source 0.016 travel factor.
pub fn advance_zoom(velocity: f64, elapsed_us: i64) -> ZoomStep {
    let speed = velocity.abs();
    if !velocity.is_finite() || speed <= 0.0001 {
        return ZoomStep {
            log_zoom_delta: 0.0,
            velocity: 0.0,
        };
    }
    if elapsed_us <= 0 {
        return ZoomStep {
            log_zoom_delta: 0.0,
            velocity,
        };
    }
    let retention = 0.92_f64;
    let frames = elapsed_us as f64 / 16000.0;
    let stop_frames = (0.0001 / speed).ln() / retention.ln();
    let decay = retention.powf(frames.min(stop_frames));
    let travel = retention * (1.0 - decay) / (1.0 - retention);
    ZoomStep {
        log_zoom_delta: velocity * 0.016 * travel,
        velocity: if frames >= stop_frames {
            0.0
        } else {
            velocity * decay
        },
    }
}
