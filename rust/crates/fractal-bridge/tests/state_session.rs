use fractal_bridge::api::{
    Engine, StateCamera, StateCommand, StateSession, StateSnapshot, StateValue, StateView,
};
use fractal_core::{
    catalog_baseline::{CatalogBaseline, ParameterValue},
    normalization::{RawScalar, ViewInput},
    session::{CameraInput, Command, Session, Snapshot},
};
use std::{
    collections::{BTreeMap, HashMap},
    fs,
    path::Path,
    sync::Arc,
};

fn envelopes() -> [String; 4] {
    ["modules", "parameters", "presets", "capabilities"].map(|name| {
        fs::read_to_string(
            Path::new(env!("CARGO_MANIFEST_DIR"))
                .join("../../../migration/baseline")
                .join(format!("{name}.json")),
        )
        .unwrap()
    })
}

fn session() -> StateSession {
    let [modules, parameters, presets, capabilities] = envelopes();
    StateSession::new(
        modules,
        parameters,
        presets,
        capabilities,
        "mandelbrot".into(),
    )
    .unwrap()
}

fn assert_same(actual: &StateSnapshot, expected: &Snapshot) {
    assert_eq!(actual.session_id(), expected.session_id());
    assert_eq!(actual.revision(), expected.revision());
    assert_eq!(actual.module_id(), expected.module_id());
    assert_eq!(
        actual.transparent_background(),
        expected.transparent_background()
    );
    assert_eq!(actual.last_adaptive_zoom(), expected.last_adaptive_zoom());
    let view = actual.view();
    assert_eq!(
        (
            view.zoom,
            [view.pan_x, view.pan_y],
            [view.rot_x, view.rot_y, view.rot_z]
        ),
        (
            expected.view().zoom(),
            expected.view().pan(),
            expected.view().rotation()
        )
    );
    let params = actual.params();
    assert_eq!(params.len(), expected.params().len());
    for (id, value) in expected.params() {
        let actual = &params[id];
        match value {
            ParameterValue::Number(n) => assert_eq!(actual.number(), Some(n.to_string())),
            ParameterValue::Boolean(b) => assert_eq!(actual.boolean(), Some(*b)),
            ParameterValue::Text(s) => assert_eq!(actual.text(), Some(s.clone())),
        }
    }
}

#[test]
fn typed_batches_match_direct_core_with_original_envelopes() {
    let [modules, parameters, presets, capabilities] = envelopes();
    let bridge = session();
    let initial = bridge.snapshot().unwrap();
    let id = initial.session_id();
    let mut core = Session::new(
        Arc::new(
            CatalogBaseline::from_jsons(&modules, &parameters, &presets, &capabilities).unwrap(),
        ),
        id,
        "mandelbrot",
    )
    .unwrap();
    assert_same(&initial, &core.snapshot());
    let mut detached_params = initial.params();
    detached_params.clear();
    let mut detached_view = initial.view();
    detached_view.pan_x = 123.0;
    assert_ne!(initial.view().pan_x, detached_view.pan_x);
    assert!(!initial.params().is_empty());
    let view = StateView {
        zoom: 32.0,
        pan_x: f64::NAN,
        pan_y: f64::INFINITY,
        rot_x: 0.1,
        rot_y: 0.2,
        rot_z: 0.3,
    };
    let camera = StateCamera {
        view: view.clone(),
        has_trajectory: false,
    };
    let core_camera = CameraInput::from(ViewInput {
        zoom: view.zoom,
        pan: [view.pan_x, view.pan_y],
        rotation: [view.rot_x, view.rot_y, view.rot_z],
    });
    let cases = vec![
        (
            vec![
                StateCommand::zoom(64.0),
                StateCommand::pan(1.0, -1.0),
                StateCommand::rotation(0.0, 0.0, 0.5),
            ],
            vec![
                Command::Zoom(64.0),
                Command::Pan([1.0, -1.0]),
                Command::Rotation([0.0, 0.0, 0.5]),
            ],
        ),
        (
            vec![
                StateCommand::view(camera.clone(), true),
                StateCommand::param("iterations".into(), StateValue::from_float(f64::NAN)),
            ],
            vec![
                Command::View {
                    camera: core_camera,
                    adaptive: true,
                },
                Command::Param {
                    id: "iterations".into(),
                    value: RawScalar::Float(f64::NAN),
                },
            ],
        ),
        (
            vec![
                StateCommand::select_module("julia".into(), false, HashMap::new()),
                StateCommand::transparent(true),
            ],
            vec![
                Command::SelectModule {
                    module_id: "julia".into(),
                    reset_view: false,
                    initial_params: BTreeMap::new(),
                },
                Command::Transparent(true),
            ],
        ),
        (
            vec![StateCommand::apply_preset(
                "mandelbrot".into(),
                HashMap::from([(
                    "iterations".into(),
                    StateValue::from_number("9007199254740993".into()).unwrap(),
                )]),
                camera.clone(),
            )],
            vec![Command::ApplyPreset {
                module_id: "mandelbrot".into(),
                params: BTreeMap::from([(
                    "iterations".into(),
                    RawScalar::Number("9007199254740993".parse().unwrap()),
                )]),
                camera: core_camera,
            }],
        ),
        (
            vec![StateCommand::load(
                Some("cantor_set".into()),
                HashMap::from([(
                    "iterations".into(),
                    StateValue::from_text("9007199254740993".into()),
                )]),
                camera,
                false,
            )],
            vec![Command::Load {
                module_id: Some("cantor_set".into()),
                params: BTreeMap::from([(
                    "iterations".into(),
                    RawScalar::Text("9007199254740993".into()),
                )]),
                camera: core_camera,
                transparent: false,
            }],
        ),
        (
            vec![
                StateCommand::reset_params(),
                StateCommand::reset_view(),
                StateCommand::reset_session(),
            ],
            vec![
                Command::ResetParams,
                Command::ResetView,
                Command::ResetSession,
            ],
        ),
    ];
    for (commands, direct) in cases {
        let revision = core.snapshot().revision();
        let expected = core.apply_batch(id, revision, &direct).unwrap();
        assert_same(
            &bridge.apply_batch(id, revision, commands).unwrap(),
            &expected,
        );
    }
    // A retained snapshot remains the initial value even after all later batches.
    assert_eq!(initial.revision(), 0);
    assert_eq!(initial.module_id(), "mandelbrot");
    assert!(!Engine::new().capabilities().unwrap().rendering);
}

#[test]
fn identities_revisions_and_rejected_batches_preserve_last_good_state() {
    let first = session();
    let other = session();
    let before = first.snapshot().unwrap();
    let id = before.session_id();
    assert_ne!(id, other.snapshot().unwrap().session_id());
    assert_eq!(
        first
            .apply_batch(other.snapshot().unwrap().session_id(), 0, vec![])
            .unwrap_err(),
        "WrongSession"
    );
    assert_eq!(
        first.apply_batch(id, 1, vec![]).unwrap_err(),
        "StaleRevision"
    );
    let bad_camera = StateCamera {
        view: before.view(),
        has_trajectory: true,
    };
    for command in [
        StateCommand::select_module("number_walls".into(), false, HashMap::new()),
        StateCommand::view(bad_camera, false),
        StateCommand::unsupported("randomize".into()),
    ] {
        assert!(
            first
                .apply_batch(id, 0, vec![StateCommand::transparent(true), command])
                .is_err()
        );
        assert_eq!(first.snapshot().unwrap().revision(), 0);
        assert!(!first.snapshot().unwrap().transparent_background());
    }
    assert_eq!(first.apply_batch(id, 0, vec![]).unwrap().revision(), 0);
    assert_eq!(
        first
            .apply_batch(id, 0, vec![StateCommand::transparent(false)])
            .unwrap()
            .revision(),
        1
    );
    assert_eq!(
        first.apply_batch(id, 0, vec![]).unwrap_err(),
        "StaleRevision"
    );
    first.shutdown().unwrap();
    first.shutdown().unwrap();
    assert_eq!(
        first.snapshot().unwrap_err(),
        "Rust state session is closed"
    );
    assert_eq!(
        first.apply_batch(id, 1, vec![]).unwrap_err(),
        "Rust state session is closed"
    );
    assert_eq!(other.snapshot().unwrap().revision(), 0);
    let [modules, parameters, presets, capabilities] = envelopes();
    assert!(
        StateSession::new(
            "{}".into(),
            parameters.clone(),
            presets.clone(),
            capabilities.clone(),
            "mandelbrot".into()
        )
        .is_err()
    );
    assert!(
        StateSession::new(
            modules,
            parameters,
            presets,
            capabilities,
            "number_walls".into()
        )
        .is_err()
    );
}

#[test]
fn scalar_boundary_preserves_nonfinite_and_exact_text_without_numeric_coercion() {
    let exact = "9007199254740993";
    assert_eq!(
        StateValue::from_number(exact.into())
            .unwrap()
            .number()
            .as_deref(),
        Some(exact)
    );
    assert_eq!(
        StateValue::from_text(exact.into()).text().as_deref(),
        Some(exact)
    );
    assert!(StateValue::from_number("not a number".into()).is_err());
    assert!(StateValue::from_float(f64::NAN).float().unwrap().is_nan());
    assert_eq!(
        StateValue::from_float(f64::INFINITY).float(),
        Some(f64::INFINITY)
    );
    assert_eq!(StateValue::from_boolean(true).boolean(), Some(true));
    assert_eq!(StateValue::from_text(exact.into()).number(), None);
}

#[test]
fn concurrent_batches_and_shutdown_have_one_serial_order() {
    let session = Arc::new(session());
    let id = session.snapshot().unwrap().session_id();
    let barrier = Arc::new(std::sync::Barrier::new(3));
    let workers: Vec<_> = (0..2)
        .map(|_| {
            let session = session.clone();
            let barrier = barrier.clone();
            std::thread::spawn(move || {
                barrier.wait();
                session.apply_batch(id, 0, vec![StateCommand::transparent(true)])
            })
        })
        .collect();
    barrier.wait();
    let results: Vec<_> = workers.into_iter().map(|w| w.join().unwrap()).collect();
    assert_eq!(results.iter().filter(|r| r.is_ok()).count(), 1);
    assert_eq!(
        results
            .iter()
            .filter(|r| r.as_ref().err().is_some_and(|e| e == "StaleRevision"))
            .count(),
        1
    );
    let retained = session.snapshot().unwrap();
    let barrier = Arc::new(std::sync::Barrier::new(2));
    let worker = {
        let session = session.clone();
        let barrier = barrier.clone();
        std::thread::spawn(move || {
            barrier.wait();
            session.apply_batch(id, 1, vec![StateCommand::transparent(false)])
        })
    };
    barrier.wait();
    session.shutdown().unwrap();
    match worker.join().unwrap() {
        Ok(snapshot) => {
            assert_eq!(snapshot.revision(), 2);
            assert!(!snapshot.transparent_background());
        }
        Err(error) => assert_eq!(error, "Rust state session is closed"),
    }
    assert!(retained.transparent_background());
    assert_eq!(retained.revision(), 1);
    assert!(session.snapshot().is_err());
}
