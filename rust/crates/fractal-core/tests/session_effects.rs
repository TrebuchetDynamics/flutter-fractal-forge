use fractal_core::{
    catalog_baseline::{CatalogBaseline, ParameterValue},
    normalization::ViewInput,
    session::{CameraInput, Command, RawParams, Session, SessionError, Snapshot},
};
use std::sync::Arc;

fn catalog() -> Arc<CatalogBaseline> {
    Arc::new(
        CatalogBaseline::from_jsons(
            include_str!("../../../../migration/baseline/modules.json"),
            include_str!("../../../../migration/baseline/parameters.json"),
            include_str!("../../../../migration/baseline/presets.json"),
            include_str!("../../../../migration/baseline/capabilities.json"),
        )
        .unwrap(),
    )
}

fn apply(session: &mut Session, commands: &[Command]) -> Snapshot {
    let before = session.snapshot();
    session
        .apply_batch(before.session_id(), before.revision(), commands)
        .unwrap()
}

fn select(id: &str) -> Command {
    Command::SelectModule {
        module_id: id.into(),
        reset_view: false,
        initial_params: RawParams::new(),
    }
}

fn camera() -> CameraInput {
    ViewInput {
        zoom: 2.0,
        pan: [0.25, -0.5],
        rotation: [0.1, 0.2, 0.3],
    }
    .into()
}

fn load(id: Option<&str>) -> Command {
    Command::Load {
        module_id: id.map(str::to_owned),
        params: RawParams::new(),
        camera: camera(),
        transparent: true,
    }
}

fn kaleidoscope(s: &Snapshot) -> (bool, i64, bool, f64, i64) {
    (
        s.kaleidoscope_enabled(),
        s.kaleidoscope_sectors(),
        s.kaleidoscope_mirror(),
        s.kaleidoscope_rotation(),
        s.kaleidoscope_mirror_mode(),
    )
}

#[test]
fn defaults_and_all_effect_setters_match_dart_bounds() {
    // Oracles: fractal_controller.dart field defaults/setters and
    // test/core/controllers/{fractal_effect_input_bounds_test,
    // fractal_controller_effect_bounds_test}.dart (NaN, clamps, even sectors).
    let mut session = Session::new(catalog(), 1, "mandelbrot").unwrap();
    let initial = session.snapshot();
    assert!(!initial.glow_enabled());
    assert_eq!(
        (initial.glow_sigma(), initial.glow_intensity()),
        (1.0, 0.35)
    );
    assert!(!initial.fluid_mode_enabled());
    assert_eq!(initial.fluid_strength(), 1.0);
    assert!(!initial.rotation_locked());
    assert_eq!(kaleidoscope(&initial), (false, 8, true, 0.0, 0));

    let s = apply(
        &mut session,
        &[
            Command::GlowEnabled(true),
            Command::FluidModeEnabled(true),
            Command::RotationLocked(true),
            Command::Rotation([0.1, 0.2, 0.3]),
            Command::KaleidoscopeEnabled(true),
            Command::KaleidoscopeMirror(false),
        ],
    );
    assert!(s.glow_enabled() && s.fluid_mode_enabled() && s.rotation_locked());
    assert_eq!(s.view().rotation(), [0.1, 0.2, 0.3]); // Lock is gesture-only.
    assert_eq!(kaleidoscope(&s), (true, 8, false, 0.0, 0));
    let s = apply(
        &mut session,
        &[
            Command::GlowEnabled(false),
            Command::FluidModeEnabled(false),
            Command::RotationLocked(false),
            Command::KaleidoscopeEnabled(false),
            Command::KaleidoscopeMirror(true),
        ],
    );
    assert!(!s.glow_enabled() && !s.fluid_mode_enabled() && !s.rotation_locked());
    assert_eq!(kaleidoscope(&s), kaleidoscope(&initial));

    for (value, expected) in [
        (2.5, [2.5, 1.0, 2.0]),
        (0.6, [0.6, 0.6, 0.6]),
        (f64::NAN, [0.6, 0.6, 0.6]),
        (-9.0, [0.1, 0.0, 0.0]),
        (9.0, [5.0, 1.0, 2.0]),
        (f64::NEG_INFINITY, [0.1, 0.0, 0.0]),
        (f64::INFINITY, [5.0, 1.0, 2.0]),
    ] {
        let s = apply(
            &mut session,
            &[
                Command::GlowSigma(value),
                Command::GlowIntensity(value),
                Command::FluidStrength(value),
            ],
        );
        assert_eq!(
            [s.glow_sigma(), s.glow_intensity(), s.fluid_strength()],
            expected
        );
    }
    let s = apply(
        &mut session,
        &[Command::GlowIntensity(-0.0), Command::FluidStrength(-0.0)],
    );
    assert_eq!(s.glow_intensity().to_bits(), 0.0_f64.to_bits());
    assert_eq!(s.fluid_strength().to_bits(), 0.0_f64.to_bits());
    for (value, expected) in [(6, 6), (7, 6), (15, 14), (5, 4), (99, 16), (i64::MIN, 4)] {
        assert_eq!(
            apply(&mut session, &[Command::KaleidoscopeSectors(value)]).kaleidoscope_sectors(),
            expected
        );
    }
    for (value, expected) in [(1, 1), (2, 2), (i64::MIN, 0), (i64::MAX, 3)] {
        assert_eq!(
            apply(&mut session, &[Command::KaleidoscopeMirrorMode(value)])
                .kaleidoscope_mirror_mode(),
            expected
        );
    }
    for (value, expected) in [
        (0.75, 0.75),
        (f64::NAN, 0.75),
        (f64::INFINITY, 0.75),
        (f64::NEG_INFINITY, 0.75),
        (-1e100, -1e100),
    ] {
        assert_eq!(
            apply(&mut session, &[Command::KaleidoscopeRotation(value)]).kaleidoscope_rotation(),
            expected
        );
    }
}

#[test]
fn forced_modules_keep_first_restore_state_and_original_descriptors() {
    // Oracles: fractal_kaleidoscope_state.dart transitionForModule and the
    // "does not leak forced kaleidoscope defaults" controller test. Consecutive
    // forced modules retain the first restore state, not the latest forced edits.
    let catalog = catalog();
    let mut session = Session::new(catalog.clone(), 1, "mandelbrot").unwrap();
    let user = apply(
        &mut session,
        &[
            Command::KaleidoscopeSectors(6),
            Command::KaleidoscopeMirror(false),
            Command::KaleidoscopeRotation(0.25),
            Command::KaleidoscopeMirrorMode(1),
        ],
    );
    for id in ["kaleidoscope_basic", "kaleidoscope_fractal"] {
        let s = apply(&mut session, &[select(id)]);
        assert_eq!(kaleidoscope(&s), (true, 16, false, 0.25, 3));
        let mut fresh = Session::new(catalog.clone(), 2, id).unwrap();
        assert_eq!(s.params(), fresh.snapshot().params());
        assert_eq!(s.view(), fresh.snapshot().view());
        assert_eq!(kaleidoscope(&fresh.snapshot()), (true, 16, true, 0.0, 3));
        assert_eq!(
            kaleidoscope(&apply(&mut fresh, &[select("mandelbrot")])),
            (false, 8, true, 0.0, 0)
        );
        let descriptor = &catalog
            .presets()
            .payload
            .records
            .iter()
            .find(|r| r.module_id.as_str() == id)
            .unwrap()
            .default;
        assert_eq!(s.view().zoom(), descriptor.view.zoom.as_f64().unwrap());
        assert_eq!(
            s.view().pan(),
            [
                descriptor.view.pan_x.as_f64().unwrap(),
                descriptor.view.pan_y.as_f64().unwrap()
            ]
        );
        for (key, value) in &descriptor.params {
            // Dart numeric equality does not distinguish 20 from 20.0.
            match (s.params().get(key), value) {
                (Some(ParameterValue::Number(actual)), ParameterValue::Number(expected)) => {
                    assert_eq!(actual.as_f64(), expected.as_f64());
                }
                (actual, expected) => assert_eq!(actual, Some(expected)),
            }
        }
        let edited = apply(
            &mut session,
            &[
                Command::KaleidoscopeEnabled(false),
                Command::KaleidoscopeSectors(10),
                Command::KaleidoscopeMirrorMode(2),
            ],
        );
        assert_eq!(kaleidoscope(&edited), (true, 10, false, 0.25, 2));
        // Same-module select does not reapply policy.
        assert_eq!(
            kaleidoscope(&apply(&mut session, &[select(id)])),
            kaleidoscope(&edited)
        );
    }
    assert_eq!(
        kaleidoscope(&apply(&mut session, &[select("julia")])),
        kaleidoscope(&user)
    );
    for id in [
        "kaleidoscope_unknown",
        "core.kaleidoscope_basic",
        "flame-horseshoe-kaleidoscope",
        "f0148_kaleidoscope_julia",
    ] {
        assert!(matches!(
            Session::new(catalog.clone(), 3, id),
            Err(SessionError::UnsupportedModule(_))
        ));
    }
}

#[test]
fn reset_preset_and_load_preserve_source_effect_policy() {
    // Oracles: fractal_controller.dart resetSession/_applyPreset/_commitLoadedState
    // and test/fractal/fractal_controller_reset_session_test.dart. Effects persist;
    // only resetSession clears the rotation lock. Load always reapplies policy.
    let mut session = Session::new(catalog(), 1, "mandelbrot").unwrap();
    apply(
        &mut session,
        &[
            Command::GlowEnabled(true),
            Command::GlowSigma(2.5),
            Command::GlowIntensity(0.6),
            Command::FluidModeEnabled(true),
            Command::FluidStrength(1.6),
            Command::RotationLocked(true),
            Command::KaleidoscopeEnabled(true),
            Command::KaleidoscopeSectors(6),
            Command::KaleidoscopeMirror(false),
            Command::KaleidoscopeRotation(0.75),
            Command::KaleidoscopeMirrorMode(1),
        ],
    );
    let user = session.snapshot();
    for command in [
        select("julia"),
        load(Some("kaleidoscope_basic")),
        Command::KaleidoscopeSectors(10),
        Command::KaleidoscopeMirrorMode(2),
        Command::ResetParams,
        Command::ResetView,
        Command::ApplyPreset {
            module_id: "julia".into(),
            params: RawParams::new(),
            camera: camera(),
        },
        Command::ResetSession,
        load(None),
        load(Some("kaleidoscope_fractal")),
        load(Some("julia")),
    ] {
        let before = session.snapshot();
        let s = apply(&mut session, std::slice::from_ref(&command));
        assert!(s.glow_enabled() && s.fluid_mode_enabled());
        assert_eq!(
            (s.glow_sigma(), s.glow_intensity(), s.fluid_strength()),
            (2.5, 0.6, 1.6)
        );
        if command == Command::ResetSession {
            assert!(!s.rotation_locked());
            assert!(!s.transparent_background());
            assert_eq!(s.view().zoom(), 1.0);
        } else {
            assert_eq!(s.rotation_locked(), before.rotation_locked());
        }
        match command {
            Command::SelectModule { .. } => assert_eq!(kaleidoscope(&s), kaleidoscope(&user)),
            Command::ResetParams
            | Command::ResetView
            | Command::ResetSession
            | Command::ApplyPreset { .. } => {
                assert_eq!(s.module_id(), "kaleidoscope_basic");
                assert_eq!(kaleidoscope(&s), (true, 10, false, 0.75, 2));
            }
            Command::Load { .. } => {
                assert_eq!(
                    kaleidoscope(&s),
                    if s.module_id() == "julia" {
                        kaleidoscope(&user)
                    } else {
                        (true, 16, false, 0.75, 3)
                    }
                );
            }
            _ => {}
        }
    }
}

#[test]
fn effect_batches_are_ordered_atomic_and_snapshot_isolated() {
    let catalog = catalog();
    let mut batch = Session::new(catalog.clone(), 1, "mandelbrot").unwrap();
    let mut single = Session::new(catalog.clone(), 1, "mandelbrot").unwrap();
    let other = Session::new(catalog, 2, "mandelbrot").unwrap();
    let retained = batch.snapshot();
    let other_before = other.snapshot();
    let commands = [
        Command::GlowEnabled(true),
        Command::GlowSigma(2.5),
        Command::GlowSigma(f64::NAN),
        Command::GlowIntensity(0.6),
        Command::FluidModeEnabled(true),
        Command::FluidStrength(1.6),
        Command::RotationLocked(true),
        Command::KaleidoscopeEnabled(false),
        Command::KaleidoscopeSectors(6),
        Command::KaleidoscopeRotation(0.75),
        Command::KaleidoscopeMirrorMode(1),
        select("kaleidoscope_basic"),
        Command::KaleidoscopeMirror(false),
        select("kaleidoscope_fractal"),
        Command::ResetSession,
    ];
    let published = apply(&mut batch, &commands);
    assert_eq!(published.revision(), 1);
    for command in commands {
        apply(&mut single, &[command]);
    }
    // Align revisions with valid no-ops, then compare even the hidden state.
    while batch.snapshot().revision() < single.snapshot().revision() {
        apply(&mut batch, &[Command::GlowSigma(2.5)]);
    }
    assert_eq!(batch.snapshot(), single.snapshot());
    let before = batch.snapshot();
    let failed = [
        Command::GlowSigma(4.0),
        Command::FluidStrength(1.7),
        select("julia"),
        Command::KaleidoscopeSectors(14),
        select("kaleidoscope_basic"),
        load(Some("cantor_set")),
        Command::View {
            camera: CameraInput {
                has_trajectory: true,
                ..camera()
            },
            adaptive: false,
        },
    ];
    assert_eq!(
        batch.apply_batch(1, before.revision(), &failed),
        Err(SessionError::UnsupportedTrajectory)
    );
    assert_eq!(batch.snapshot(), before);
    assert_eq!(
        batch.apply_batch(1, before.revision() - 1, &[select("julia")]),
        Err(SessionError::StaleRevision)
    );
    assert_eq!(batch.snapshot(), before);
    // A later exit exposes whether either failed candidate corrupted restoration.
    let exit = apply(&mut batch, &[select("julia")]);
    assert_eq!(exit, apply(&mut single, &[select("julia")]));
    assert_eq!(kaleidoscope(&exit), (false, 6, true, 0.75, 1));
    assert_eq!(kaleidoscope(&retained), (false, 8, true, 0.0, 0));
    assert_eq!(retained.revision(), 0);
    assert_eq!(kaleidoscope(&published), (true, 16, false, 0.75, 3));
    assert_eq!(other.snapshot(), other_before);
}
