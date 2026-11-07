use fractal_core::{
    catalog_baseline::Dimension,
    normalization::{DEFAULT_MIN_ZOOM, MAX_ZOOM, ViewInput, normalize_view},
    physical_view::{
        Pinch, advance_pan, advance_zoom, camera_target_delta, double_tap_target, drag_2d,
        focal_zoom, orbit, pinch, screen_delta_to_world, wheel_zoom_target,
    },
};
use std::f64::consts::PI;

const VIEWPORT: [f64; 2] = [300.0, 600.0];
const VIEW: ViewInput = ViewInput {
    zoom: 2.0,
    pan: [0.2, -0.3],
    rotation: [0.1, 0.2, 1.4],
};

fn close(actual: f64, expected: f64, tolerance: f64) {
    assert!(
        (actual - expected).abs() <= tolerance,
        "actual={actual:?}, expected={expected:?}, tolerance={tolerance}"
    );
}

fn close_pair(actual: [f64; 2], expected: [f64; 2], tolerance: f64) {
    for i in 0..2 {
        close(actual[i], expected[i], tolerance);
    }
}

#[test]
fn drag_uses_min_dimension_and_zero_2d_screen_rotation() {
    let delta = [30.0, -60.0];
    close_pair(
        screen_delta_to_world(delta, VIEWPORT, 2.0),
        [0.05, -0.1],
        1e-12,
    );
    let result = drag_2d(VIEW, delta, VIEWPORT);
    close_pair(result.pan, [0.15, -0.2], 1e-12);
    assert_eq!(result.rotation, VIEW.rotation);
    close_pair(
        screen_delta_to_world([1.0, -1.0], [0.0, 0.0], 0.0),
        [1e9, -1e9],
        1e-6,
    );
    close_pair(
        drag_2d(ViewInput { zoom: 1e12, ..VIEW }, delta, VIEWPORT).pan,
        [VIEW.pan[0] - 0.1 / 1e12, VIEW.pan[1] + 0.2 / 1e12],
        1e-12,
    );
}

#[test]
fn camera_target_preserves_right_up_signs_height_scaling_and_zoom_floor() {
    for rotation in [[0.0; 3], [0.0, 0.0, PI / 2.0], [0.3, -0.7, 0.4]] {
        let [x, y, z] = rotation;
        let expected = [
            y.cos() * z.cos() * -0.3 + y.cos() * z.sin() * 0.6,
            (x.sin() * y.sin() * z.cos() - x.cos() * z.sin()) * -0.3
                + (x.sin() * y.sin() * z.sin() + x.cos() * z.cos()) * 0.6,
        ];
        for zoom in [0.0, 0.05, 0.1] {
            close_pair(
                camera_target_delta([3.0, 6.0], VIEWPORT, zoom, rotation),
                expected,
                1e-12,
            );
        }
        close_pair(
            camera_target_delta([30.0, 60.0], VIEWPORT, 2.0, rotation),
            expected.map(|v| v / 2.0),
            1e-12,
        );
    }
}

#[test]
fn orbit_uses_each_axis_module_sign_tilt_cap_and_gesture_lock() {
    for sign in [-1.0, 1.0] {
        let result = orbit(VIEW, [30.0, 20.0], VIEWPORT, sign, false);
        close(result.rotation[0], 0.1 - 20.0 * PI / 600.0, 1e-12);
        close(result.rotation[1], 0.2 + sign * 30.0 * PI / 300.0, 1e-12);
        assert_eq!(result.pan, VIEW.pan);
        assert_eq!(result.zoom, VIEW.zoom);
        assert_eq!(result.rotation[2], VIEW.rotation[2]);
    }
    for dy in [-2000.0_f64, 2000.0] {
        close(
            orbit(VIEW, [0.0, dy], VIEWPORT, -1.0, false).rotation[0],
            -dy.signum() * 67.5 * PI / 180.0,
            1e-12,
        );
    }
    assert_eq!(orbit(VIEW, [30.0, 2000.0], VIEWPORT, -1.0, true), VIEW);
    // The gesture lock is not a normalizer/direct-command restriction.
    let direct = ViewInput {
        rotation: [4.0, -5.0, 6.0],
        ..VIEW
    };
    assert_eq!(
        normalize_view(direct, VIEW, "mandelbrot").rotation(),
        direct.rotation
    );
}

#[test]
fn wheel_targets_keep_source_exponential_in_both_directions() {
    for dy in [-120.0_f64, 0.0, 120.0] {
        close(wheel_zoom_target(2.0, dy), 2.0 * (-dy * 0.001).exp(), 1e-12);
    }
}

#[test]
fn focal_zoom_keeps_world_point_with_dimension_specific_rotation() {
    for dimension in [Dimension::TwoD, Dimension::ThreeD] {
        let angle = match dimension {
            Dimension::TwoD => 0.0,
            Dimension::ThreeD => VIEW.rotation[2],
        };
        let rotated = [
            0.3 * angle.cos() - 0.2 * angle.sin(),
            -0.3 * angle.sin() - 0.2 * angle.cos(),
        ];
        let result = focal_zoom(VIEW, 4.0, &dimension, Some(VIEWPORT), Some([240.0, 240.0]));
        assert_eq!(result.zoom, 4.0);
        close_pair(
            result.pan,
            std::array::from_fn(|i| VIEW.pan[i] + rotated[i] / 2.0 - rotated[i] / 4.0),
            1e-12,
        );
        assert_eq!(result.rotation, VIEW.rotation);
    }
    assert_eq!(
        focal_zoom(VIEW, 4.0, &Dimension::TwoD, None, Some([240.0, 240.0])).pan,
        VIEW.pan
    );
}

#[test]
fn double_tap_clamps_target_before_focal_math() {
    let result = double_tap_target(VIEW, &Dimension::TwoD, Some(VIEWPORT), Some([240.0, 240.0]));
    close_pair(result.pan, [0.275, -0.35], 1e-12);
    assert_eq!(result.zoom, 4.0);
    for (zoom, expected) in [(0.0, DEFAULT_MIN_ZOOM), (MAX_ZOOM * 0.75, MAX_ZOOM)] {
        let result = double_tap_target(
            ViewInput { zoom, ..VIEW },
            &Dimension::TwoD,
            Some(VIEWPORT),
            None,
        );
        assert_eq!(result.zoom, expected);
        assert_eq!(result.pan, VIEW.pan);
    }
}

#[test]
fn pinch_anchors_start_values_without_locking_pan_or_zoom() {
    for locked in [false, true] {
        let gesture = Pinch {
            viewport: VIEWPORT,
            start_focal: [240.0, 240.0],
            focal: [270.0, 300.0],
            scale: 2.0,
            rotation_delta: 0.6,
            rotation_locked: locked,
        };
        let current = ViewInput {
            pan: [1.0, 1.0],
            rotation: [0.0, 0.0, 1.4],
            ..VIEW
        };
        let result = pinch(VIEW, current, &Dimension::TwoD, &gesture);
        close_pair(result.pan, [0.25, -0.4], 1e-12);
        close(result.rotation[2], if locked { 1.4 } else { 2.0 }, 1e-12);
        assert_eq!(result.zoom, 4.0);
        let result = pinch(VIEW, current, &Dimension::ThreeD, &gesture);
        let delta = camera_target_delta([30.0, 60.0], VIEWPORT, VIEW.zoom, current.rotation);
        close_pair(
            result.pan,
            [VIEW.pan[0] + delta[0], VIEW.pan[1] + delta[1]],
            1e-12,
        );
        assert_eq!(result.zoom, 4.0);
        assert_eq!(result.rotation, current.rotation);
    }
}

#[test]
fn soft_half_strength_bands_precede_unchanged_hard_module_bounds() {
    let raw = drag_2d(VIEW, [-2400.0, 2400.0], VIEWPORT);
    close_pair(raw.pan, [3.6, -3.65], 1e-12);
    assert_eq!(normalize_view(raw, VIEW, "mandelbrot").pan(), [3.0, -3.0]);
    for (target, soft, hard) in [
        (0.0, DEFAULT_MIN_ZOOM * 0.5, DEFAULT_MIN_ZOOM),
        (MAX_ZOOM * 3.0, MAX_ZOOM * 2.0, MAX_ZOOM),
    ] {
        let raw = focal_zoom(VIEW, target, &Dimension::TwoD, None, None);
        assert_eq!(raw.zoom, soft);
        assert_eq!(normalize_view(raw, VIEW, "mandelbrot").zoom(), hard);
    }
    let raw = focal_zoom(VIEW, 0.1, &Dimension::TwoD, None, None);
    assert_eq!(raw.zoom, 0.1);
    assert_eq!(normalize_view(raw, VIEW, "cantor_set").zoom(), 0.2);
}

#[test]
fn pan_momentum_retains_reference_step_cutoff_and_nonpositive_elapsed() {
    let step = advance_pan([20.0, -10.0], 16000);
    close_pair(step.velocity, [19.0, -9.5], 1e-10);
    close_pair(step.displacement, [19.0, -9.5], 1e-10);
    let stopped = advance_pan([20.0, -10.0], 2000000);
    assert_eq!(stopped.velocity, [0.0; 2]);
    let travel = 0.95 * (1.0 - 0.1 / 500.0_f64.sqrt()) / (1.0 - 0.95);
    close_pair(stopped.displacement, [20.0 * travel, -10.0 * travel], 1e-10);
    for elapsed in [0, -16000] {
        let step = advance_pan([10.0, 0.0], elapsed);
        assert_eq!(step.velocity, [10.0, 0.0]);
        assert_eq!(step.displacement, [0.0; 2]);
    }
    for velocity in [[0.0; 2], [0.06, -0.06], [0.1, 0.0]] {
        let step = advance_pan(velocity, 1000000);
        assert_eq!(step.velocity, [0.0; 2]);
        assert_eq!(step.displacement, [0.0; 2]);
    }
}

#[test]
fn zoom_momentum_retains_reference_step_cutoff_and_nonfinite_policy() {
    for velocity in [0.08, -0.08] {
        let step = advance_zoom(velocity, 16000);
        close(step.velocity, velocity * 0.92, 1e-12);
        close(step.log_zoom_delta, velocity * 0.92 * 0.016, 1e-12);
        let stopped = advance_zoom(velocity, 2000000);
        assert_eq!(stopped.velocity, 0.0);
        close(
            stopped.log_zoom_delta,
            velocity * 0.016 * 0.92 * (1.0 - 0.0001 / velocity.abs()) / (1.0 - 0.92),
            1e-12,
        );
    }
    for elapsed in [0, -16000] {
        let step = advance_zoom(0.1, elapsed);
        assert_eq!(step.velocity, 0.1);
        assert_eq!(step.log_zoom_delta, 0.0);
    }
    for velocity in [
        0.0,
        0.00001,
        -0.00001,
        0.0001,
        f64::NAN,
        f64::INFINITY,
        f64::NEG_INFINITY,
    ] {
        let step = advance_zoom(velocity, 2000000);
        assert_eq!(step.velocity, 0.0);
        assert_eq!(step.log_zoom_delta, 0.0);
    }
}

#[test]
fn elapsed_momentum_is_invariant_across_original_frame_schedules() {
    for total in [320000, 1280000, 2000000] {
        let expected_pan = advance_pan([20.0, -10.0], total);
        for initial_zoom in [0.02, -0.02, 0.1, -0.1] {
            let expected_zoom = advance_zoom(initial_zoom, total);
            for cadence in [8333, 16667, 33333, 100000] {
                let (mut pan_velocity, mut displacement) = ([20.0, -10.0], [0.0; 2]);
                let (mut zoom_velocity, mut travel) = (initial_zoom, 0.0);
                let mut elapsed = 0;
                while elapsed < total {
                    let dt = (total - elapsed).min(cadence);
                    let pan_step = advance_pan(pan_velocity, dt);
                    let zoom_step = advance_zoom(zoom_velocity, dt);
                    for (value, delta) in displacement.iter_mut().zip(pan_step.displacement) {
                        *value += delta;
                    }
                    pan_velocity = pan_step.velocity;
                    travel += zoom_step.log_zoom_delta;
                    zoom_velocity = zoom_step.velocity;
                    elapsed += dt;
                }
                close_pair(displacement, expected_pan.displacement, 1e-8);
                close_pair(pan_velocity, expected_pan.velocity, 1e-8);
                close(travel, expected_zoom.log_zoom_delta, 1e-12);
                close(zoom_velocity, expected_zoom.velocity, 1e-12);
            }
        }
    }
}
