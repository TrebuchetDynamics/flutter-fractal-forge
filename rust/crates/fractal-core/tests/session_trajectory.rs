//! Inert metadata ownership through the public Session seam, using original envelopes.
use fractal_core::{
    catalog_baseline::{CatalogBaseline, ParameterValue},
    normalization::{RawScalar, ViewInput},
    number_wall_prime::{DEFAULT_MAX_TRIAL_DIVISIONS, NumberWallPrimeStatus},
    session::{
        CameraInput, Command, RawParams, RequestGuard, RequestProgress, Session, SessionError,
        Snapshot,
    },
    trajectory::OrbitTrajectorySettings,
};
use serde_json::{Value, json};
use std::sync::Arc;

const PRESETS: &str = include_str!("../../../../migration/baseline/presets.json");
const MODULES: [&str; 3] = ["thomas_attractor", "four_wing", "lorenz_2d"];

fn catalog(presets: &str) -> Arc<CatalogBaseline> {
    Arc::new(
        CatalogBaseline::from_jsons(
            include_str!("../../../../migration/baseline/modules.json"),
            include_str!("../../../../migration/baseline/parameters.json"),
            presets,
            include_str!("../../../../migration/baseline/capabilities.json"),
        )
        .unwrap(),
    )
}

fn edited_catalog(id: &str, trajectory: Option<Value>) -> Arc<CatalogBaseline> {
    let mut presets: Value = serde_json::from_str(PRESETS).unwrap();
    let view = &mut presets["payload"]["records"]
        .as_array_mut()
        .unwrap()
        .iter_mut()
        .find(|p| p["module_id"] == id)
        .unwrap()["default"]["view"];
    view.as_object_mut().unwrap().remove("trajectory");
    if let Some(value) = trajectory {
        view["trajectory"] = value;
    }
    catalog(&presets.to_string())
}

fn camera(id: &str) -> CameraInput {
    CameraInput {
        trajectory: OrbitTrajectorySettings::defaults_for(id).map(|defaults| {
            OrbitTrajectorySettings::new(
                defaults.system(),
                [0.4, 0.5, 0.6].into(),
                0.02,
                10,
                20,
                defaults.projection(),
            )
            .unwrap()
        }),
        ..ViewInput {
            zoom: 2.0,
            pan: [0.2, -0.3],
            rotation: [0.1, 0.2, 0.3],
        }
        .into()
    }
}

fn select(id: &str, reset_view: bool) -> Command {
    Command::SelectModule {
        module_id: id.into(),
        reset_view,
        initial_params: RawParams::new(),
    }
}

fn apply(s: &mut Session, commands: &[Command]) -> Snapshot {
    let before = s.snapshot();
    s.apply_batch(before.session_id(), before.revision(), commands)
        .unwrap()
}

#[test]
fn original_defaults_decode_but_missing_null_and_incompatible_defaults_remain_portraits() {
    let original = catalog(PRESETS);
    for id in MODULES {
        let s = Session::new(original.clone(), 1, id).unwrap().snapshot();
        assert_eq!(s.trajectory(), OrbitTrajectorySettings::defaults_for(id));
        assert_eq!(s.view().zoom(), 1.0);
        for representation in [None, Some(Value::Null)] {
            let legacy = Session::new(edited_catalog(id, representation), 1, id)
                .unwrap()
                .snapshot();
            assert_eq!(legacy.trajectory(), None);
        }
        let other = MODULES.into_iter().find(|other| *other != id).unwrap();
        let incompatible = serde_json::to_value(camera(other).trajectory).unwrap();
        assert_eq!(
            Session::new(edited_catalog(id, Some(incompatible)), 1, id)
                .unwrap()
                .snapshot()
                .trajectory(),
            None
        );
    }
    for id in ["f0057_thomas_attractor", "aizawa", "core.thomas_attractor"] {
        assert!(matches!(
            Session::new(original.clone(), 1, id),
            Err(SessionError::UnsupportedModule(_))
        ));
    }
    // Decode errors are not silently treated as legacy absence, including on selection.
    for malformed in [
        json!({}),
        json!(true),
        json!({"version": 2}),
        json!([
            1,
            "thomas",
            [0.1, 0.2, 0.3],
            "rk4",
            0.01,
            5000,
            20000,
            "thomasOblique"
        ]),
    ] {
        let bad = edited_catalog("thomas_attractor", Some(malformed));
        assert!(matches!(
            Session::new(bad.clone(), 1, "thomas_attractor"),
            Err(SessionError::UnsupportedTrajectory)
        ));
        let mut s = Session::new(bad, 1, "mandelbrot").unwrap();
        let before = s.snapshot();
        assert_eq!(
            s.apply_batch(
                1,
                0,
                &[
                    Command::GlowEnabled(true),
                    select("thomas_attractor", false)
                ]
            ),
            Err(SessionError::UnsupportedTrajectory)
        );
        assert_eq!(s.snapshot(), before);
    }
}

#[test]
fn scalar_copies_preserve_detached_metadata_while_initial_and_reset_views_clear_it() {
    let mut s = Session::new(catalog(PRESETS), 1, "thomas_attractor").unwrap();
    let retained = apply(
        &mut s,
        &[Command::View {
            camera: camera("thomas_attractor"),
            adaptive: false,
        }],
    );
    for command in [
        Command::Zoom(2.0),
        Command::Pan([0.5, -0.5]),
        Command::Rotation([0.3, 0.4, 0.5]),
        Command::Param {
            id: "iterations".into(),
            value: RawScalar::Float(300.0),
        },
        Command::ResetParams,
    ] {
        assert_eq!(
            apply(&mut s, &[command]).trajectory(),
            retained.trajectory()
        );
    }
    for command in [Command::ResetView, Command::ResetSession] {
        apply(
            &mut s,
            &[Command::View {
                camera: camera("thomas_attractor"),
                adaptive: false,
            }],
        );
        let reset = apply(&mut s, &[command]);
        assert_eq!(reset.trajectory(), None);
        assert_eq!(reset.view().zoom(), 1.0);
        assert_eq!(reset.view().pan(), [0.0; 2]);
        assert_eq!(reset.view().rotation(), [0.0; 3]);
    }
    assert_eq!(retained.revision(), 1);
    assert_eq!(retained.trajectory(), camera("thomas_attractor").trajectory);
}

#[test]
fn select_load_preset_and_full_view_replace_metadata_using_the_current_module() {
    let mut s = Session::new(catalog(PRESETS), 1, "mandelbrot").unwrap();
    for id in MODULES {
        let selected = apply(&mut s, &[select(id, false)]);
        assert_eq!(
            selected.trajectory(),
            OrbitTrajectorySettings::defaults_for(id)
        );
        let portrait = apply(
            &mut s,
            &[Command::View {
                camera: camera("mandelbrot"),
                adaptive: true,
            }],
        );
        assert_eq!(portrait.trajectory(), None);
        assert_eq!(apply(&mut s, &[select(id, false)]).trajectory(), None); // same module is a no-op
        for source in [
            id,
            "mandelbrot",
            MODULES.into_iter().find(|other| *other != id).unwrap(),
        ] {
            let input = camera(source);
            let expected = input.trajectory.filter(|t| t.is_compatible_with(id));
            for command in [
                Command::View {
                    camera: input,
                    adaptive: false,
                },
                // Ordinary presets do not switch to the preset's module.
                Command::ApplyPreset {
                    module_id: source.into(),
                    params: RawParams::new(),
                    camera: input,
                },
                Command::Load {
                    module_id: None,
                    params: RawParams::new(),
                    camera: input,
                    transparent: true,
                },
            ] {
                let result = apply(&mut s, &[command]);
                assert_eq!(result.module_id(), id);
                assert_eq!(result.trajectory(), expected);
                assert_eq!(result.view().pan(), input.view.pan);
            }
        }
        apply(&mut s, &[select("mandelbrot", false)]);
        let loaded = apply(
            &mut s,
            &[Command::Load {
                module_id: Some(id.into()),
                params: RawParams::new(),
                camera: camera(id),
                transparent: true,
            }],
        );
        assert_eq!(loaded.trajectory(), camera(id).trajectory);
        assert_eq!(apply(&mut s, &[select(id, true)]).trajectory(), None);
        apply(&mut s, &[select("mandelbrot", false)]);
        // Loading an explicit module uses supplied metadata, not its default.
        let loaded = apply(
            &mut s,
            &[Command::Load {
                module_id: Some(id.into()),
                params: RawParams::new(),
                camera: camera("mandelbrot"),
                transparent: false,
            }],
        );
        assert_eq!(loaded.trajectory(), None);
        apply(&mut s, &[select("mandelbrot", false)]);
    }
    assert_eq!(
        apply(
            &mut s,
            &[Command::View {
                camera: camera("four_wing"),
                adaptive: false
            }]
        )
        .trajectory(),
        None
    );
}

#[test]
fn rejected_batches_preserve_metadata_effects_pending_work_and_exact_retained_frame() {
    let mut s = Session::new(catalog(PRESETS), 1, "mandelbrot").unwrap();
    let load = Command::Load {
        module_id: Some("number_wall".into()),
        params: [
            ("prime", json!("97")),
            ("rows", json!(4)),
            ("columns", json!(16)),
            ("columnStart", json!(3)),
        ]
        .into_iter()
        .map(|(k, v)| {
            (
                k.into(),
                RawScalar::from(serde_json::from_value::<ParameterValue>(v).unwrap()),
            )
        })
        .collect(),
        camera: camera("four_wing"),
        transparent: false,
    };
    let token = s
        .begin_number_wall(
            1,
            0,
            &load,
            RequestGuard::new(true),
            DEFAULT_MAX_TRIAL_DIVISIONS,
        )
        .unwrap()
        .unwrap();
    loop {
        let before = s.snapshot();
        if let RequestProgress::Finished(status) = s
            .advance_number_wall(1, before.revision(), token, 1024)
            .unwrap()
        {
            assert_eq!(status, NumberWallPrimeStatus::VerifiedPrime);
            break;
        }
    }
    assert_eq!(s.snapshot().trajectory(), None); // valid incompatible settings also clear on staged load
    let retained_frame = s.snapshot().number_wall_frame().unwrap().clone();
    let retained = apply(
        &mut s,
        &[
            select("thomas_attractor", false),
            Command::GlowEnabled(true),
        ],
    );
    let token = s
        .begin_number_wall(
            1,
            retained.revision(),
            &load,
            RequestGuard::new(true),
            DEFAULT_MAX_TRIAL_DIVISIONS,
        )
        .unwrap()
        .unwrap();
    let before = s.snapshot();
    assert_eq!(before.revision(), retained.revision() + 1);
    assert_eq!(before.trajectory(), retained.trajectory());
    assert_eq!(before.number_wall_pending(), Some(token));
    for rejected in [
        Command::View {
            camera: CameraInput {
                has_trajectory: true,
                ..camera("mandelbrot")
            },
            adaptive: false,
        },
        Command::Unsupported {
            operation: "trajectory job".into(),
        },
    ] {
        assert!(
            s.apply_batch(
                1,
                before.revision(),
                &[
                    Command::GlowEnabled(false),
                    select("four_wing", false),
                    rejected
                ]
            )
            .is_err()
        );
        assert_eq!(s.snapshot(), before);
        assert!(Arc::ptr_eq(
            s.snapshot().number_wall_frame().unwrap(),
            &retained_frame
        ));
    }
    let selected = apply(&mut s, &[select("lorenz_2d", false)]);
    assert_eq!(selected.revision(), before.revision() + 1);
    assert_eq!(
        selected.trajectory(),
        OrbitTrajectorySettings::defaults_for("lorenz_2d")
    );
    assert_eq!(selected.number_wall_pending(), None);
    assert_eq!(
        s.advance_number_wall(1, selected.revision(), token, 1024)
            .unwrap(),
        RequestProgress::Finished(NumberWallPrimeStatus::Cancelled)
    );
    assert_eq!(s.snapshot(), selected);
    assert_eq!(
        retained.trajectory(),
        OrbitTrajectorySettings::defaults_for("thomas_attractor")
    );
    assert!(Arc::ptr_eq(
        selected.number_wall_frame().unwrap(),
        &retained_frame
    ));
}
