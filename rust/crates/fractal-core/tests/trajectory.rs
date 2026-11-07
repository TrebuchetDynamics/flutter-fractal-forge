use std::sync::atomic::{AtomicBool, Ordering};

use fractal_core::trajectory::{
    AttractorSystem, MAX_STEPS_PER_ADVANCE, OrbitPoint, OrbitProjection, OrbitTrajectorySettings,
    TrajectoryError, TrajectoryJob, decode_orbit_trajectory_settings, generate, integrate, project,
};
use serde_json::{Value, json};

const SEED: OrbitPoint = OrbitPoint {
    x: 0.1,
    y: 0.2,
    z: 0.3,
};
const SYSTEMS: [AttractorSystem; 3] = [
    AttractorSystem::Thomas,
    AttractorSystem::FourWing,
    AttractorSystem::Lorenz2d,
];

fn settings(system: AttractorSystem, burn: u32, retained: u32) -> OrbitTrajectorySettings {
    OrbitTrajectorySettings::new(system, SEED, 0.01, burn, retained, OrbitProjection::Xz).unwrap()
}

#[test]
fn defaults_json_and_compatibility_preserve_the_dart_schema() {
    let modules = ["thomas_attractor", "four_wing", "lorenz_2d"];
    for (index, (id, system, name, seed, projection, projection_name)) in [
        (
            modules[0],
            AttractorSystem::Thomas,
            "thomas",
            SEED,
            OrbitProjection::ThomasOblique,
            "thomasOblique",
        ),
        (
            modules[1],
            AttractorSystem::FourWing,
            "fourWing",
            OrbitPoint {
                x: 1.0,
                y: 1.0,
                z: 1.0,
            },
            OrbitProjection::Xz,
            "xz",
        ),
        (
            modules[2],
            AttractorSystem::Lorenz2d,
            "lorenz2d",
            SEED,
            OrbitProjection::Xz,
            "xz",
        ),
    ]
    .into_iter()
    .enumerate()
    {
        let defaults = OrbitTrajectorySettings::defaults_for(id).unwrap();
        let expected = json!({
            "version": 1, "system": name, "seed": [seed.x, seed.y, seed.z],
            "integrator": "rk4", "stepSize": 0.01, "burnInSteps": 5000,
            "retainedSteps": 20000, "projection": projection_name,
        });
        assert_eq!(serde_json::to_value(defaults).unwrap(), expected);
        assert_eq!(
            decode_orbit_trajectory_settings(&expected).unwrap(),
            Some(defaults)
        );
        assert_eq!(
            (defaults.system(), defaults.seed(), defaults.projection()),
            (system, seed, projection)
        );
        assert_eq!(
            (
                defaults.version(),
                defaults.integrator(),
                defaults.step_size(),
                defaults.burn_in_steps(),
                defaults.retained_steps()
            ),
            (1, "rk4", 0.01, 5000, 20000)
        );
        for (other_index, other) in modules.into_iter().enumerate() {
            assert_eq!(defaults.is_compatible_with(other), index == other_index);
        }
        assert!(!defaults.is_compatible_with("f0057_thomas_attractor"));
        let changed = OrbitTrajectorySettings::new(
            system,
            seed,
            0.1,
            0,
            1,
            if projection == OrbitProjection::Xz {
                OrbitProjection::ThomasOblique
            } else {
                OrbitProjection::Xz
            },
        )
        .unwrap();
        assert!(!changed.is_compatible_with(id));
    }
    // Integer-valued seed/step inputs remain numeric, not cache-key strings.
    let integers = json!({"version":1,"system":"fourWing","seed":[1,1,1],"integrator":"rk4","stepSize":0.1,"burnInSteps":0,"retainedSteps":1,"projection":"xz"});
    let decoded = decode_orbit_trajectory_settings(&integers)
        .unwrap()
        .unwrap();
    assert_eq!(
        serde_json::from_str::<OrbitTrajectorySettings>(&serde_json::to_string(&decoded).unwrap())
            .unwrap(),
        decoded
    );
    assert_eq!(
        decode_orbit_trajectory_settings(&Value::Null).unwrap(),
        None
    );
    assert!(OrbitTrajectorySettings::defaults_for("f0057_thomas_attractor").is_none());
}

#[test]
fn every_settings_entry_point_validates_shape_and_safety_caps() {
    let valid = serde_json::to_value(settings(AttractorSystem::Thomas, 5000, 20000)).unwrap();
    for (key, bad) in [
        ("version", json!(2)),
        ("version", json!(1.0)),
        ("system", json!("four_wing")),
        ("integrator", json!("euler")),
        ("seed", json!([0, 1])),
        ("seed", json!([0, "1", 2])),
        ("stepSize", json!(0)),
        ("stepSize", json!(-0.01)),
        ("stepSize", json!(0.10001)),
        ("burnInSteps", json!(-1)),
        ("burnInSteps", json!(5001)),
        ("burnInSteps", json!(u32::MAX)),
        ("retainedSteps", json!(0)),
        ("retainedSteps", json!(20001)),
        ("retainedSteps", json!(3.0)),
        ("projection", json!("xy")),
    ] {
        let mut input = valid.clone();
        input[key] = bad;
        assert!(decode_orbit_trajectory_settings(&input).is_err(), "{input}");
    }
    for key in valid.as_object().unwrap().keys() {
        let mut input = valid.clone();
        input.as_object_mut().unwrap().remove(key);
        assert!(
            decode_orbit_trajectory_settings(&input).is_err(),
            "missing {key}"
        );
    }
    for bad in [json!([]), json!(true), json!("rk4")] {
        assert!(decode_orbit_trajectory_settings(&bad).is_err());
    }
    for (seed, dt, burn, retained) in [
        (
            OrbitPoint {
                x: f64::NAN,
                ..SEED
            },
            0.01,
            0,
            1,
        ),
        (
            OrbitPoint {
                y: f64::INFINITY,
                ..SEED
            },
            0.01,
            0,
            1,
        ),
        (SEED, f64::NAN, 0, 1),
        (SEED, f64::INFINITY, 0, 1),
        (SEED, 0.0, 0, 1),
        (SEED, -0.01, 0, 1),
        (SEED, 0.11, 0, 1),
        (SEED, 0.01, 0, 0),
        (SEED, 0.01, 0, 20001),
        (SEED, 0.01, 5001, 20000),
        (SEED, 0.01, u32::MAX, 1),
    ] {
        assert!(
            OrbitTrajectorySettings::new(
                AttractorSystem::Thomas,
                seed,
                dt,
                burn,
                retained,
                OrbitProjection::Xz
            )
            .is_err()
        );
    }
    assert!(
        OrbitTrajectorySettings::new(
            AttractorSystem::Thomas,
            SEED,
            0.1,
            24999,
            1,
            OrbitProjection::Xz
        )
        .is_ok()
    );
}

#[test]
fn rk4_one_step_matches_the_three_unchanged_dart_fixtures() {
    for (system, expected) in SYSTEMS.into_iter().zip([
        OrbitPoint {
            x: 0.101789084902954,
            y: 0.202538000247744,
            z: 0.300382263876495,
        },
        OrbitPoint {
            x: 0.100801946301577,
            y: 0.198909615912361,
            z: 0.302785794133354,
        },
        OrbitPoint {
            x: 0.110802162964979,
            y: 0.227029836615913,
            z: 0.292327630146888,
        },
    ]) {
        let actual = integrate(system, SEED, 0.01, 1).unwrap();
        for (a, b) in [
            (actual.x, expected.x),
            (actual.y, expected.y),
            (actual.z, expected.z),
        ] {
            assert!((a - b).abs() < 1e-12, "{system:?}: {actual:?}");
        }
    }
}

#[test]
fn rk4_converges_over_the_existing_short_horizon() {
    for system in SYSTEMS {
        let a = integrate(system, SEED, 0.01, 100).unwrap();
        let b = integrate(system, SEED, 0.005, 200).unwrap();
        assert!(((a.x - b.x).powi(2) + (a.y - b.y).powi(2) + (a.z - b.z).powi(2)).sqrt() < 1e-4);
    }
}

#[test]
fn projections_retain_the_source_tolerances() {
    let point = OrbitPoint {
        x: 1.0,
        y: 2.0,
        z: 3.0,
    };
    let xz = project(point, OrbitProjection::Xz);
    assert_eq!((xz.x, xz.y), (1.0, 3.0));
    let oblique = project(point, OrbitProjection::ThomasOblique);
    assert!((oblique.x - -1.0 / 2.0_f64.sqrt()).abs() < 1e-15);
    assert!((oblique.y - -3.0 / 6.0_f64.sqrt()).abs() < 1e-15);
}

#[test]
fn generation_retains_after_burn_in_and_accumulates_projected_bounds() {
    for id in ["thomas_attractor", "four_wing", "lorenz_2d"] {
        let settings = OrbitTrajectorySettings::defaults_for(id).unwrap();
        let result = generate(settings).unwrap();
        assert_eq!(result.settings(), &settings);
        assert_eq!(result.points().len(), 20000);
        let first = integrate(
            settings.system(),
            settings.seed(),
            settings.step_size(),
            5001,
        )
        .unwrap();
        assert_eq!(result.points()[0], first);
        let second = integrate(settings.system(), first, settings.step_size(), 1).unwrap();
        assert_eq!(result.points()[1], second);
        let bounds = result.bounds();
        assert!(bounds.is_finite());
        let projected: Vec<_> = result
            .points()
            .iter()
            .map(|p| project(*p, settings.projection()))
            .collect();
        assert!(result.points().iter().all(|p| p.is_finite()));
        assert_eq!(
            bounds.min_x,
            projected.iter().map(|p| p.x).fold(f64::INFINITY, f64::min)
        );
        assert_eq!(
            bounds.max_x,
            projected
                .iter()
                .map(|p| p.x)
                .fold(f64::NEG_INFINITY, f64::max)
        );
        assert_eq!(
            bounds.min_y,
            projected.iter().map(|p| p.y).fold(f64::INFINITY, f64::min)
        );
        assert_eq!(
            bounds.max_y,
            projected
                .iter()
                .map(|p| p.y)
                .fold(f64::NEG_INFINITY, f64::max)
        );
        if id == "four_wing" {
            assert!(bounds.max_x - bounds.min_x > 1.0);
            assert!(bounds.max_y - bounds.min_y > 0.25);
        }
    }
}

#[test]
fn integration_is_finite_only_but_generation_enforces_the_coordinate_guard() {
    for (point, dt) in [
        (
            OrbitPoint {
                z: f64::NAN,
                ..SEED
            },
            0.01,
        ),
        (SEED, f64::INFINITY),
        (SEED, 0.0),
        (SEED, -1.0),
    ] {
        assert_eq!(
            integrate(AttractorSystem::Thomas, point, dt, 0),
            Err(TrajectoryError::InvalidIntegrationInputs)
        );
    }
    let huge = OrbitPoint {
        x: 2e12,
        y: 0.0,
        z: 0.0,
    };
    assert_eq!(
        integrate(AttractorSystem::Thomas, huge, 0.2, 0).unwrap(),
        huge
    );
    assert!(
        integrate(AttractorSystem::Thomas, huge, 0.2, 1)
            .unwrap()
            .is_finite()
    );
    let settings = OrbitTrajectorySettings::new(
        AttractorSystem::Thomas,
        huge,
        0.01,
        0,
        1,
        OrbitProjection::Xz,
    )
    .unwrap();
    assert_eq!(generate(settings), Err(TrajectoryError::SafetyBounds));
    let overflowing = OrbitPoint {
        x: f64::MAX,
        y: f64::MAX,
        z: f64::MAX,
    };
    assert_eq!(
        integrate(AttractorSystem::Lorenz2d, overflowing, 0.01, 1),
        Err(TrajectoryError::NonFiniteIntegration)
    );
    let settings = OrbitTrajectorySettings::new(
        AttractorSystem::Lorenz2d,
        overflowing,
        0.01,
        0,
        1,
        OrbitProjection::Xz,
    )
    .unwrap();
    assert_eq!(generate(settings), Err(TrajectoryError::SafetyBounds));
    assert_eq!(
        TrajectoryError::NonFiniteIntegration.to_string(),
        "Attractor integration diverged to a non-finite state."
    );
    assert_eq!(
        TrajectoryError::SafetyBounds.to_string(),
        "Attractor trajectory left the finite safety bounds."
    );
}

#[test]
fn stepped_jobs_bound_all_work_and_keep_completed_owned_results() {
    assert_eq!(MAX_STEPS_PER_ADVANCE, 256);
    for system in SYSTEMS {
        let settings = settings(system, 5000, 20000);
        let synchronous = generate(settings).unwrap();
        let cancellation = AtomicBool::new(false);
        let mut job = TrajectoryJob::new(settings);
        let mut previous = 0;
        while job.result().is_none() {
            job.advance(&cancellation);
            let steps = job.steps_completed();
            assert!(steps - previous <= 256);
            previous = steps;
        }
        assert_eq!(previous, 25000);
        assert_eq!(job.result().unwrap().as_ref().unwrap(), &synchronous);
        let retained = job.result().unwrap().clone().unwrap();
        let mut detached_points = retained.points().to_vec();
        detached_points[0].x = 42.0;
        cancellation.store(true, Ordering::Relaxed);
        assert_eq!(
            job.advance(&cancellation).unwrap().as_ref().unwrap(),
            &retained
        );
        assert_eq!(retained, synchronous);
    }
}

#[test]
fn cancellation_at_start_burn_retained_and_final_boundaries_is_terminal() {
    for (burn, retained, advances, steps) in [
        (300, 300, 0, 0),
        (300, 300, 1, 256),
        (300, 300, 2, 512),
        (0, 256, 1, 256),
        (256, 256, 2, 512),
    ] {
        let flag = AtomicBool::new(false);
        let mut job = TrajectoryJob::new(settings(AttractorSystem::Thomas, burn, retained));
        for _ in 0..advances {
            assert!(job.advance(&flag).is_none());
        }
        assert_eq!(job.steps_completed(), steps);
        flag.store(true, Ordering::Relaxed);
        assert_eq!(job.advance(&flag), Some(&Err(TrajectoryError::Cancelled)));
        assert_eq!(job.steps_completed(), steps);
        flag.store(false, Ordering::Relaxed);
        assert_eq!(job.advance(&flag), Some(&Err(TrajectoryError::Cancelled)));
    }
}
