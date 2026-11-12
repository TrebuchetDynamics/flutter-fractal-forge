use fractal_core::{
    catalog_baseline::{CatalogBaseline, Dimension, ParameterValue},
    normalization::{ViewInput, normalize_view},
    physical_events::*,
    session::{CameraInput, Command, RawParams, Session, SessionError},
};
use serde_json::Value;
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
fn input(v: fractal_core::normalization::FiniteView) -> ViewInput {
    ViewInput {
        zoom: v.zoom(),
        pan: v.pan(),
        rotation: v.rotation(),
    }
}
fn pair(v: &Value) -> [f64; 2] {
    [v[0].as_f64().unwrap(), v[1].as_f64().unwrap()]
}
fn view(v: &Value) -> ViewInput {
    ViewInput {
        zoom: v["zoom"].as_f64().unwrap(),
        pan: pair(&v["pan"]),
        rotation: std::array::from_fn(|i| v["rotation"][i].as_f64().unwrap()),
    }
}
fn event(v: &Value) -> PhysicalEvent {
    let op = match v["op"].as_str().unwrap() {
        "wall" => PhysicalInput::Wall(v["us"].as_i64().unwrap()),
        "focus" => PhysicalInput::Focus(if v["target"] == "control" {
            Focus::Control
        } else {
            Focus::Canvas
        }),
        "wheel" => PhysicalInput::Wheel {
            local: pair(&v["local"]),
            dy: v["delta"][1].as_f64().unwrap(),
        },
        "key" => PhysicalInput::Key {
            key: match v["key"].as_str().unwrap() {
                "left" => Key::Left,
                "right" => Key::Right,
                "up" => Key::Up,
                "down" => Key::Down,
                "plus" => Key::Plus,
                "minus" => Key::Minus,
                "reset" => Key::Reset,
                _ => Key::Unknown,
            },
            phase: match v["type"].as_str().unwrap() {
                "down" => KeyPhase::Down,
                "repeat" => KeyPhase::Repeat,
                _ => KeyPhase::Up,
            },
        },
        op => PhysicalInput::Pointer {
            id: v["pointer"].as_u64().unwrap(),
            local: pair(&v["local"]),
            phase: match op {
                "down" => PointerPhase::Down,
                "move" => PointerPhase::Move,
                "up" => PointerPhase::Up,
                "cancel" => PointerPhase::Cancel,
                _ => panic!("{op}"),
            },
            kind: PointerKind::Touch,
            buttons: v["buttons"].as_u64().unwrap(),
        },
    };
    PhysicalEvent {
        sequence: v["seq"].as_u64().unwrap(),
        source_us: v["sourceUs"].as_i64(),
        input: op,
        consumed: false,
    }
}
fn close(actual: ViewInput, expected: ViewInput, label: &str) {
    for (a, b) in [actual.zoom]
        .into_iter()
        .chain(actual.pan)
        .chain(actual.rotation)
        .zip(
            [expected.zoom]
                .into_iter()
                .chain(expected.pan)
                .chain(expected.rotation),
        )
    {
        assert!((a - b).abs() < 1e-8, "{label}: {actual:?} != {expected:?}");
    }
}

#[test]
fn instantaneous_oracle_at_public_seams() {
    let oracle: Value = serde_json::from_str(include_str!(
        "../../../../migration/oracles/physical-events.json"
    ))
    .unwrap();
    let mut checkpoints = 0;
    let catalog = catalog();
    for scenario in oracle["scenarios"].as_array().unwrap() {
        let id = scenario["id"].as_str().unwrap();
        if !(id.starts_with("fling/")
            || id.starts_with("bounds/")
            || id.starts_with("pinch-")
            || id.starts_with("twist/")
            || id.starts_with("wheel/")
            || id.starts_with("viewer-keys/")
            || id == "nested-controls")
        {
            continue;
        }
        let initial = &scenario["initial"];
        let module = initial["module"].as_str().unwrap();
        let three = module == "mandelbulb" || module == "quaternion_julia_3d";
        let mut camera = view(&initial["view"]);
        let mut owner = PhysicalState::default();
        let mut session = if three || module == "gaussian_prime_lattice" {
            None
        } else {
            Some(Session::new(catalog.clone(), 7, module).unwrap())
        };
        if let Some(s) = &mut session {
            let params: RawParams = initial["params"]
                .as_object()
                .unwrap()
                .iter()
                .map(|(k, v)| {
                    (
                        k.clone(),
                        fractal_core::normalization::RawScalar::Float(v.as_f64().unwrap()),
                    )
                })
                .collect();
            s.apply_batch(
                7,
                0,
                &[
                    Command::Load {
                        module_id: None,
                        params,
                        camera: CameraInput::from(camera),
                        transparent: false,
                    },
                    Command::RotationLocked(
                        initial["effects"]["rotationLocked"].as_bool().unwrap(),
                    ),
                ],
            )
            .unwrap();
        }
        let mut callbacks = Vec::new();
        for raw in scenario["input"].as_array().unwrap() {
            if raw["op"] == "pump" {
                break;
            }
            let context = PhysicalContext {
                viewer_keys_enabled: initial["routing"]["viewerMode"] != "walk",
                dimension: if three {
                    &Dimension::ThreeD
                } else {
                    &Dimension::TwoD
                },
                horizontal_orbit_sign: if module == "mandelbulb" { -1.0 } else { 1.0 },
                rotation_locked: initial["effects"]["rotationLocked"].as_bool().unwrap(),
                viewport: Some(pair(&initial["viewport"])),
                view: camera,
            };
            let mut output = PhysicalOutput::default();
            if raw["op"] != "checkpoint" {
                let mut e = event(raw);
                // The nested widget owns its arena; routing metadata contains no camera math.
                if id == "nested-controls" && matches!(e.input, PhysicalInput::Pointer { .. }) {
                    e.consumed = true;
                }
                if let Some(s) = &mut session {
                    let result = s
                        .apply_physical(7, s.snapshot().revision(), context.viewport, &[e])
                        .unwrap();
                    camera = input(result.snapshot.view());
                    output = result.output;
                } else {
                    output = owner.reduce(&context, &e).unwrap();
                    for update in &output.updates {
                        camera = input(normalize_view(update.view(camera), camera, module));
                    }
                }
                callbacks.extend(output.interactions.iter().map(|s| match s {
                    Interaction::Start => "start",
                    Interaction::End => "end",
                    Interaction::Correction => "correction",
                }));
            }
            if let Some(expected) = scenario["expected"]
                .as_array()
                .unwrap()
                .iter()
                .find(|e| e["seq"] == raw["seq"])
            {
                // Timed release/tap completion is owned by PHYSICAL-TIME.
                if expected.get("label").is_some_and(|l| {
                    ![
                        "drag",
                        "bounded-drag",
                        "pinched",
                        "handoff",
                        "resumed",
                        "twisted",
                        "control-consumed",
                    ]
                    .contains(&l.as_str().unwrap())
                        && !l.as_str().unwrap().starts_with("wheel-")
                }) {
                    continue;
                }
                close(camera, view(&expected["state"]["view"]), id);
                if let Some(s) = &session {
                    let snap = s.snapshot();
                    assert_eq!(snap.module_id(), module);
                    assert_eq!(
                        snap.rotation_locked(),
                        expected["state"]["effects"]["rotationLocked"]
                            .as_bool()
                            .unwrap()
                    );
                    assert_eq!(
                        snap.fluid_mode_enabled(),
                        expected["state"]["effects"]["fluidMode"].as_bool().unwrap()
                    );
                    assert_eq!(
                        snap.transparent_background(),
                        expected["state"]["effects"]["transparentBackground"]
                            .as_bool()
                            .unwrap()
                    );
                    for (k, v) in expected["state"]["params"].as_object().unwrap() {
                        let number = match snap.params().get(k).unwrap() {
                            ParameterValue::Number(n) => n.as_f64().unwrap(),
                            other => panic!("{other:?}"),
                        };
                        assert_eq!(number, v.as_f64().unwrap(), "{id}/{k}");
                    }
                }
                if let Some(expected_callbacks) = expected["callbacks"].as_array() {
                    assert_eq!(
                        callbacks,
                        expected_callbacks
                            .iter()
                            .map(|v| v.as_str().unwrap())
                            .collect::<Vec<_>>(),
                        "{id}"
                    );
                }
                if let Some(routed) = expected["routed"].as_str() {
                    assert_eq!(
                        output.keys,
                        vec![if routed.ends_with("control-handled") {
                            KeyDisposition::ControlHandled
                        } else if routed.ends_with("/handled") {
                            KeyDisposition::Handled
                        } else {
                            KeyDisposition::Ignored
                        }],
                        "{id}"
                    );
                }
                checkpoints += 1;
            }
        }
    }
    assert_eq!(checkpoints, 191);
}

#[test]
fn absent_layout_keeps_pan_and_uses_only_unlocked_3d_twist() {
    for dimension in [&Dimension::TwoD, &Dimension::ThreeD] {
        for locked in [false, true] {
            let mut owner = PhysicalState::default();
            let mut camera = ViewInput {
                zoom: 1.0,
                pan: [0.2, -0.3],
                rotation: [0.0; 3],
            };
            for (sequence, id, phase, local) in [
                (0, 1, PointerPhase::Down, [200.0, 0.0]),
                (1, 2, PointerPhase::Down, [100.0, 0.0]),
                (2, 2, PointerPhase::Move, [60.0, 0.0]),
                (
                    3,
                    2,
                    PointerPhase::Move,
                    [200.0 - 168.0 * 0.2_f64.cos(), -168.0 * 0.2_f64.sin()],
                ),
            ] {
                let output = owner
                    .reduce(
                        &PhysicalContext {
                            viewer_keys_enabled: true,
                            dimension,
                            horizontal_orbit_sign: -1.0,
                            rotation_locked: locked,
                            viewport: None,
                            view: camera,
                        },
                        &PhysicalEvent {
                            sequence,
                            source_us: None,
                            consumed: false,
                            input: PhysicalInput::Pointer {
                                id,
                                phase,
                                local,
                                kind: PointerKind::Touch,
                                buttons: 1,
                            },
                        },
                    )
                    .unwrap();
                for update in output.updates {
                    camera = update.view(camera);
                }
            }
            let three = matches!(dimension, Dimension::ThreeD);
            close(
                camera,
                ViewInput {
                    zoom: if three { 1.68 } else { 1.2 },
                    pan: [0.2, -0.3],
                    rotation: [0.0, 0.0, if three && !locked { 0.2 } else { 0.0 }],
                },
                "absent layout",
            );
        }
    }
}

#[test]
fn rejected_transactions_preserve_hidden_anchors_and_detached_snapshots() {
    let mut s = Session::new(catalog(), 1, "mandelbrot").unwrap();
    let token = s
        .start_param_timeline(1, 0, s.snapshot().params().clone())
        .unwrap();
    let make = |sequence, phase, local| PhysicalEvent {
        sequence,
        source_us: Some(16000),
        consumed: false,
        input: PhysicalInput::Pointer {
            id: 1,
            local,
            phase,
            kind: PointerKind::Touch,
            buttons: 1,
        },
    };
    let down = make(0, PointerPhase::Down, [80.0, 80.0]);
    s.apply_physical(1, s.snapshot().revision(), Some([300.0, 240.0]), &[down])
        .unwrap();
    let before = s.snapshot();
    let movement = make(1, PointerPhase::Move, [120.0, 100.0]);
    assert_eq!(
        s.apply_physical(
            2,
            before.revision(),
            Some([300.0, 240.0]),
            std::slice::from_ref(&movement)
        )
        .unwrap_err(),
        SessionError::WrongSession
    );
    assert_eq!(
        s.apply_physical(1, 0, Some([300.0, 240.0]), std::slice::from_ref(&movement))
            .unwrap_err(),
        SessionError::StaleRevision
    );
    let invalid = make(3, PointerPhase::Move, [f64::NAN, 0.0]);
    let wheel = PhysicalEvent {
        sequence: 2,
        source_us: None,
        consumed: false,
        input: PhysicalInput::Wheel {
            local: [200.0, 90.0],
            dy: -200.0,
        },
    };
    assert!(
        s.apply_physical(
            1,
            before.revision(),
            Some([300.0, 240.0]),
            &[movement.clone(), wheel, invalid]
        )
        .is_err()
    );
    assert_eq!(s.snapshot(), before);
    let after = s
        .apply_physical(
            1,
            before.revision(),
            Some([300.0, 240.0]),
            std::slice::from_ref(&movement),
        )
        .unwrap();
    assert_eq!(after.snapshot.revision(), before.revision() + 1);
    close(
        input(after.snapshot.view()),
        ViewInput {
            pan: [
                before.view().pan()[0] - 40.0 / 240.0 / before.view().zoom(),
                before.view().pan()[1] - 20.0 / 240.0 / before.view().zoom(),
            ],
            ..input(before.view())
        },
        "rejected mixed batch did not consume first delta",
    );
    assert_ne!(after.snapshot.view(), before.view());
    assert!(
        s.apply_physical(1, after.snapshot.revision(), None, &[movement])
            .is_err()
    );
    assert_eq!(s.snapshot(), after.snapshot);
    let ticked = s
        .tick_param_timeline(1, s.snapshot().revision(), token)
        .unwrap();
    assert_eq!(
        ticked.revision(),
        after.snapshot.revision() + 1,
        "physical camera transactions retain the parameter callback owner"
    );
    let batch: Vec<_> = [
        PhysicalInput::Wheel {
            local: [200.0, 90.0],
            dy: -200.0,
        },
        PhysicalInput::Wheel {
            local: [200.0, 90.0],
            dy: 200.0,
        },
        PhysicalInput::Key {
            key: Key::Right,
            phase: KeyPhase::Down,
        },
        PhysicalInput::Key {
            key: Key::Right,
            phase: KeyPhase::Repeat,
        },
        PhysicalInput::Key {
            key: Key::Right,
            phase: KeyPhase::Up,
        },
    ]
    .into_iter()
    .enumerate()
    .map(|(i, input)| PhysicalEvent {
        sequence: i as u64 + 2,
        source_us: None,
        consumed: false,
        input,
    })
    .collect();
    let result = s
        .apply_physical(1, ticked.revision(), Some([300.0, 240.0]), &batch)
        .unwrap();
    assert_eq!(result.snapshot.revision(), ticked.revision() + 1);
    close(
        input(result.snapshot.view()),
        ViewInput {
            pan: [ticked.view().pan()[0] + 0.08, ticked.view().pan()[1]],
            ..input(ticked.view())
        },
        "ordered batch",
    );
    assert_eq!(
        result.output.interactions,
        vec![Interaction::Correction, Interaction::Correction]
    );
    assert_eq!(
        result.output.keys,
        vec![
            KeyDisposition::Handled,
            KeyDisposition::Ignored,
            KeyDisposition::Ignored
        ]
    );
    assert_eq!(result.output.updates.len(), 3);
}
