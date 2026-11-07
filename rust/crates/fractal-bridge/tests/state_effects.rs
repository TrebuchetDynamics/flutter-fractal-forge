use fractal_bridge::api::{StateCamera, StateCommand, StateSession, StateSnapshot, StateView};
use std::collections::HashMap;

fn session(module: &str) -> StateSession {
    StateSession::new(
        include_str!("../../../../migration/baseline/modules.json").into(),
        include_str!("../../../../migration/baseline/parameters.json").into(),
        include_str!("../../../../migration/baseline/presets.json").into(),
        include_str!("../../../../migration/baseline/capabilities.json").into(),
        module.into(),
    )
    .unwrap()
}

fn apply(session: &StateSession, commands: Vec<StateCommand>) -> StateSnapshot {
    let before = session.snapshot().unwrap();
    let result = session
        .apply_batch(before.session_id(), before.revision(), commands)
        .unwrap();
    assert_eq!(result.revision(), before.revision() + 1);
    result
}

fn select(module: &str) -> StateCommand {
    StateCommand::select_module(module.into(), false, HashMap::new())
}

fn camera() -> StateCamera {
    StateCamera {
        view: StateView {
            zoom: 2.0,
            pan_x: 0.25,
            pan_y: -0.5,
            rot_x: 0.1,
            rot_y: 0.2,
            rot_z: 0.3,
        },
        has_trajectory: false,
    }
}

fn kaleidoscope(s: &StateSnapshot) -> (bool, i64, bool, f64, i64) {
    (
        s.kaleidoscope_enabled(),
        s.kaleidoscope_sectors(),
        s.kaleidoscope_mirror(),
        s.kaleidoscope_rotation(),
        s.kaleidoscope_mirror_mode(),
    )
}

fn ambient(s: &StateSnapshot) -> (bool, f64, f64, bool, f64, bool) {
    (
        s.glow_enabled(),
        s.glow_sigma(),
        s.glow_intensity(),
        s.fluid_mode_enabled(),
        s.fluid_strength(),
        s.rotation_locked(),
    )
}

#[test]
fn typed_effect_defaults_and_bounds_match_core_policy() {
    // Same original six-module catalog and source-derived oracles as core's
    // session_effects tests, exercised only through the public bridge here.
    for module in [
        "mandelbrot",
        "julia",
        "cantor_set",
        "recursive_sine_sphere",
        "kaleidoscope_basic",
        "kaleidoscope_fractal",
    ] {
        let initial = session(module).snapshot().unwrap();
        assert_eq!(ambient(&initial), (false, 1.0, 0.35, false, 1.0, false));
        assert_eq!(
            kaleidoscope(&initial),
            if module.starts_with("kaleidoscope_") {
                (true, 16, true, 0.0, 3)
            } else {
                (false, 8, true, 0.0, 0)
            }
        );
    }
    let session = session("mandelbrot");
    let on = apply(
        &session,
        vec![
            StateCommand::glow_enabled(true),
            StateCommand::fluid_mode_enabled(true),
            StateCommand::rotation_locked(true),
            StateCommand::rotation(0.1, 0.2, 0.3),
            StateCommand::kaleidoscope_enabled(true),
            StateCommand::kaleidoscope_mirror(false),
        ],
    );
    assert_eq!(ambient(&on), (true, 1.0, 0.35, true, 1.0, true));
    assert_eq!(kaleidoscope(&on), (true, 8, false, 0.0, 0));
    assert_eq!(
        [on.view().rot_x, on.view().rot_y, on.view().rot_z],
        [0.1, 0.2, 0.3]
    );
    let off = apply(
        &session,
        vec![
            StateCommand::glow_enabled(false),
            StateCommand::fluid_mode_enabled(false),
            StateCommand::rotation_locked(false),
            StateCommand::kaleidoscope_enabled(false),
            StateCommand::kaleidoscope_mirror(true),
        ],
    );
    assert_eq!(ambient(&off), (false, 1.0, 0.35, false, 1.0, false));
    assert_eq!(kaleidoscope(&off), (false, 8, true, 0.0, 0));
    for (value, expected) in [
        (0.6, [0.6, 0.6, 0.6]),
        (f64::NAN, [0.6, 0.6, 0.6]),
        (-9.0, [0.1, 0.0, 0.0]),
        (9.0, [5.0, 1.0, 2.0]),
        (f64::NEG_INFINITY, [0.1, 0.0, 0.0]),
        (f64::INFINITY, [5.0, 1.0, 2.0]),
    ] {
        let s = apply(
            &session,
            vec![
                StateCommand::glow_sigma(value),
                StateCommand::glow_intensity(value),
                StateCommand::fluid_strength(value),
            ],
        );
        assert_eq!(
            [s.glow_sigma(), s.glow_intensity(), s.fluid_strength()],
            expected
        );
    }
    for (value, expected) in [(6, 6), (7, 6), (i64::MIN, 4), (i64::MAX, 16)] {
        assert_eq!(
            apply(&session, vec![StateCommand::kaleidoscope_sectors(value)]).kaleidoscope_sectors(),
            expected
        );
    }
    for (value, expected) in [(1, 1), (2, 2), (i64::MIN, 0), (i64::MAX, 3)] {
        assert_eq!(
            apply(
                &session,
                vec![StateCommand::kaleidoscope_mirror_mode(value)]
            )
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
            apply(&session, vec![StateCommand::kaleidoscope_rotation(value)])
                .kaleidoscope_rotation(),
            expected
        );
    }
}

#[test]
fn forced_restoration_survives_failed_stale_and_closed_operations() {
    let session = session("mandelbrot");
    let other = self::session("mandelbrot");
    let retained = apply(
        &session,
        vec![
            StateCommand::kaleidoscope_sectors(6),
            StateCommand::kaleidoscope_mirror(false),
            StateCommand::kaleidoscope_rotation(0.25),
            StateCommand::kaleidoscope_mirror_mode(1),
        ],
    );
    let edited = apply(
        &session,
        vec![
            select("kaleidoscope_basic"),
            StateCommand::kaleidoscope_enabled(false),
            StateCommand::kaleidoscope_sectors(10),
            StateCommand::kaleidoscope_mirror_mode(2),
        ],
    );
    assert_eq!(kaleidoscope(&edited), (true, 10, false, 0.25, 2));
    let forced = apply(&session, vec![select("kaleidoscope_fractal")]);
    assert_eq!(kaleidoscope(&forced), (true, 16, false, 0.25, 3));
    let id = forced.session_id();
    let revision = forced.revision();
    // These candidate transitions would replace the hidden restore state if
    // rollback leaked. Observe it later by exiting, never through a mutable DTO.
    assert_eq!(
        session
            .apply_batch(
                id,
                revision,
                vec![
                    StateCommand::glow_enabled(true),
                    select("julia"),
                    StateCommand::kaleidoscope_sectors(14),
                    select("kaleidoscope_basic"),
                    StateCommand::unsupported("effect rollback".into()),
                ]
            )
            .unwrap_err(),
        "UnsupportedOperation(\"effect rollback\")"
    );
    assert_eq!(
        session
            .apply_batch(id, revision - 1, vec![select("julia")])
            .unwrap_err(),
        "StaleRevision"
    );
    assert_eq!(
        session
            .apply_batch(
                other.snapshot().unwrap().session_id(),
                revision,
                vec![StateCommand::glow_enabled(true)]
            )
            .unwrap_err(),
        "WrongSession"
    );
    let unchanged = session.snapshot().unwrap();
    assert_eq!(unchanged.revision(), revision);
    assert_eq!(ambient(&unchanged), ambient(&forced));
    assert_eq!(kaleidoscope(&unchanged), kaleidoscope(&forced));
    let restored = apply(&session, vec![select("julia")]);
    assert_eq!(kaleidoscope(&restored), kaleidoscope(&retained));
    assert_eq!(kaleidoscope(&forced), (true, 16, false, 0.25, 3));
    assert_eq!(retained.revision(), 1);
    session.shutdown().unwrap();
    session.shutdown().unwrap();
    assert_eq!(
        session.snapshot().unwrap_err(),
        "Rust state session is closed"
    );
    assert_eq!(
        session
            .apply_batch(
                id,
                restored.revision(),
                vec![StateCommand::glow_enabled(true)]
            )
            .unwrap_err(),
        "Rust state session is closed"
    );
    assert_eq!(kaleidoscope(&restored), (false, 6, false, 0.25, 1));
    let untouched = other.snapshot().unwrap();
    assert_eq!(untouched.revision(), 0);
    assert_eq!(ambient(&untouched), (false, 1.0, 0.35, false, 1.0, false));
    assert_eq!(kaleidoscope(&untouched), (false, 8, true, 0.0, 0));
}

#[test]
fn reset_load_and_preset_retain_effects_and_reapply_only_source_module_policy() {
    let session = session("mandelbrot");
    let user = apply(
        &session,
        vec![
            StateCommand::glow_enabled(true),
            StateCommand::glow_sigma(2.5),
            StateCommand::glow_intensity(0.6),
            StateCommand::fluid_mode_enabled(true),
            StateCommand::fluid_strength(1.6),
            StateCommand::rotation_locked(true),
            StateCommand::kaleidoscope_enabled(true),
            StateCommand::kaleidoscope_sectors(6),
            StateCommand::kaleidoscope_mirror(false),
            StateCommand::kaleidoscope_rotation(0.75),
            StateCommand::kaleidoscope_mirror_mode(1),
        ],
    );
    let forced = apply(
        &session,
        vec![
            StateCommand::load(
                Some("kaleidoscope_basic".into()),
                HashMap::new(),
                camera(),
                true,
            ),
            StateCommand::kaleidoscope_sectors(10),
            StateCommand::kaleidoscope_mirror_mode(2),
        ],
    );
    assert_eq!(ambient(&forced), ambient(&user));
    assert_eq!(kaleidoscope(&forced), (true, 10, false, 0.75, 2));
    for command in [
        select("kaleidoscope_basic"),
        StateCommand::reset_params(),
        StateCommand::reset_view(),
        StateCommand::apply_preset("julia".into(), HashMap::new(), camera()),
    ] {
        let s = apply(&session, vec![command]);
        assert_eq!(s.module_id(), "kaleidoscope_basic");
        assert_eq!(ambient(&s), ambient(&user));
        assert_eq!(kaleidoscope(&s), kaleidoscope(&forced));
    }
    let reset = apply(&session, vec![StateCommand::reset_session()]);
    assert_eq!(ambient(&reset), (true, 2.5, 0.6, true, 1.6, false));
    assert_eq!(kaleidoscope(&reset), kaleidoscope(&forced));
    assert_eq!(reset.view().zoom, 1.0);
    assert!(!reset.transparent_background());
    for module in [None, Some("kaleidoscope_fractal"), Some("cantor_set")] {
        let s = apply(
            &session,
            vec![StateCommand::load(
                module.map(str::to_owned),
                HashMap::new(),
                camera(),
                true,
            )],
        );
        assert_eq!(ambient(&s), ambient(&reset));
        assert_eq!(
            kaleidoscope(&s),
            if module == Some("cantor_set") {
                kaleidoscope(&user)
            } else {
                (true, 16, false, 0.75, 3)
            }
        );
    }
}
