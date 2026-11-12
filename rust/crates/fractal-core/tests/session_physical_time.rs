use fractal_core::{
    catalog_baseline::{CatalogBaseline, Dimension, ParameterValue},
    normalization::{ViewInput, normalize_view},
    physical_events::*,
    session::{CameraInput, Command, RawParams, Session},
};
use serde_json::Value;
use std::sync::Arc;

fn pair(v: &Value) -> [f64; 2] {
    std::array::from_fn(|i| v[i].as_f64().unwrap())
}
fn view(v: &Value) -> ViewInput {
    ViewInput {
        zoom: v["zoom"].as_f64().unwrap(),
        pan: pair(&v["pan"]),
        rotation: std::array::from_fn(|i| v["rotation"][i].as_f64().unwrap()),
    }
}
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
fn event(v: &Value, generation: u64) -> PhysicalEvent {
    PhysicalEvent {
        sequence: v["seq"].as_u64().unwrap(),
        source_us: v["sourceUs"].as_i64(),
        consumed: false,
        input: match v["op"].as_str().unwrap() {
            "pump" => PhysicalInput::Pump {
                generation,
                delta_us: v["us"].as_i64().unwrap(),
            },
            "wall" => PhysicalInput::Wall(v["us"].as_i64().unwrap()),
            "dispose" => PhysicalInput::Dispose,
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
                kind: PointerKind::Touch,
                buttons: v["buttons"].as_u64().unwrap(),
                phase: match op {
                    "down" => PointerPhase::Down,
                    "move" => PointerPhase::Move,
                    "up" => PointerPhase::Up,
                    "cancel" => PointerPhase::Cancel,
                    _ => panic!("{op}"),
                },
            },
        },
    }
}
fn close(a: ViewInput, b: ViewInput, label: &str) {
    for (x, y) in [a.zoom]
        .into_iter()
        .chain(a.pan)
        .chain(a.rotation)
        .zip([b.zoom].into_iter().chain(b.pan).chain(b.rotation))
    {
        assert!((x - y).abs() < 1e-8, "{label}: {a:?} != {b:?}");
    }
}

#[test]
fn all_raw_timed_oracle_checkpoints() {
    let oracle: Value = serde_json::from_str(include_str!(
        "../../../../migration/oracles/physical-events.json"
    ))
    .unwrap();
    let catalog = catalog();
    let mut checkpoints = 0;
    assert_eq!(oracle["scenarios"].as_array().unwrap().len(), 67);
    for scenario in oracle["scenarios"].as_array().unwrap() {
        let id = scenario["id"].as_str().unwrap();
        let initial = &scenario["initial"];
        let mut module = initial["module"].as_str().unwrap();
        let three = matches!(module, "mandelbulb" | "quaternion_julia_3d");
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
        let mut keys = Vec::new();
        for raw in scenario["input"].as_array().unwrap() {
            if raw["op"] == "module" {
                module = raw["id"].as_str().unwrap();
                let s = session.as_mut().unwrap();
                s.apply_batch(
                    7,
                    s.snapshot().revision(),
                    &[Command::SelectModule {
                        module_id: module.into(),
                        reset_view: true,
                        initial_params: RawParams::new(),
                    }],
                )
                .unwrap();
                let v = s.snapshot().view();
                camera = ViewInput {
                    zoom: v.zoom(),
                    pan: v.pan(),
                    rotation: v.rotation(),
                };
            } else if raw["op"] != "checkpoint" {
                let generation = session
                    .as_ref()
                    .map_or_else(|| owner.generation(), |s| s.physical_generation());
                let mut e = event(raw, generation);
                if id == "nested-controls" && matches!(e.input, PhysicalInput::Pointer { .. }) {
                    e.consumed = true;
                }
                let output = if let Some(s) = &mut session {
                    let result = s
                        .apply_physical(
                            7,
                            s.snapshot().revision(),
                            Some(pair(&initial["viewport"])),
                            &[e],
                        )
                        .unwrap();
                    let v = result.snapshot.view();
                    camera = ViewInput {
                        zoom: v.zoom(),
                        pan: v.pan(),
                        rotation: v.rotation(),
                    };
                    result.output
                } else {
                    let output = owner
                        .reduce(
                            &PhysicalContext {
                                viewer_keys_enabled: initial["routing"]["viewerMode"] != "walk",
                                dimension: if three {
                                    &Dimension::ThreeD
                                } else {
                                    &Dimension::TwoD
                                },
                                horizontal_orbit_sign: if module == "mandelbulb" {
                                    -1.0
                                } else {
                                    1.0
                                },
                                rotation_locked: initial["effects"]["rotationLocked"]
                                    .as_bool()
                                    .unwrap(),
                                viewport: Some(pair(&initial["viewport"])),
                                view: camera,
                            },
                            &e,
                        )
                        .unwrap();
                    for u in &output.updates {
                        let v = normalize_view(u.view(camera), camera, module);
                        camera = ViewInput {
                            zoom: v.zoom(),
                            pan: v.pan(),
                            rotation: v.rotation(),
                        };
                    }
                    output
                };
                callbacks.extend(output.interactions.iter().map(|i| match i {
                    Interaction::Start => "start",
                    Interaction::End => "end",
                    Interaction::Correction => "correction",
                }));
                keys.extend(output.keys);
            }
            if let Some(expected) = scenario["expected"]
                .as_array()
                .unwrap()
                .iter()
                .find(|e| e["seq"] == raw["seq"])
            {
                let label = format!("{id}/{}", expected["label"]);
                close(camera, view(&expected["state"]["view"]), &label);
                if let Some(expected_callbacks) = expected["callbacks"].as_array() {
                    assert_eq!(
                        callbacks,
                        expected_callbacks
                            .iter()
                            .map(|v| v.as_str().unwrap())
                            .collect::<Vec<_>>(),
                        "{label}"
                    );
                }
                if let Some(s) = &session {
                    let snap = s.snapshot();
                    assert_eq!(
                        snap.module_id(),
                        expected["state"]["module"].as_str().unwrap()
                    );
                    for (k, v) in expected["state"]["params"].as_object().unwrap() {
                        let ParameterValue::Number(n) = snap.params().get(k).unwrap() else {
                            panic!("{k}")
                        };
                        assert_eq!(n.as_f64().unwrap(), v.as_f64().unwrap(), "{label}/{k}");
                    }
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
                }
                if let Some(routed) = expected["routed"].as_str() {
                    assert_eq!(
                        *keys.last().unwrap(),
                        if routed.ends_with("control-handled") {
                            KeyDisposition::ControlHandled
                        } else if routed.ends_with("/handled") {
                            KeyDisposition::Handled
                        } else {
                            KeyDisposition::Ignored
                        },
                        "{label}"
                    );
                }
                checkpoints += 1;
            }
        }
    }
    assert_eq!(checkpoints, 382);
}

#[test]
fn stale_generation_and_failed_batch_preserve_time() {
    let mut s = Session::new(catalog(), 7, "mandelbrot").unwrap();
    let mut control = Session::new(catalog(), 7, "mandelbrot").unwrap();
    let raw: Value = serde_json::from_str(include_str!(
        "../../../../migration/oracles/physical-events.json"
    ))
    .unwrap();
    let scenario = raw["scenarios"]
        .as_array()
        .unwrap()
        .iter()
        .find(|s| s["id"] == "double-interruption/new-input")
        .unwrap();
    for e in scenario["input"]
        .as_array()
        .unwrap()
        .iter()
        .filter(|e| e["seq"].as_u64().unwrap() <= 8 && e["op"] != "checkpoint")
    {
        let e = event(e, s.physical_generation());
        control
            .apply_physical(
                7,
                control.snapshot().revision(),
                Some([300.0, 240.0]),
                std::slice::from_ref(&e),
            )
            .unwrap();
        s.apply_physical(7, s.snapshot().revision(), Some([300.0, 240.0]), &[e])
            .unwrap();
    }
    // A partially advanced animation must roll back both its clock and camera.
    let before = s.snapshot();
    let valid = PhysicalEvent {
        sequence: 9,
        source_us: None,
        consumed: false,
        input: PhysicalInput::Pump {
            generation: s.physical_generation(),
            delta_us: 10000,
        },
    };
    assert!(
        s.apply_physical(7, 0, Some([300.0, 240.0]), std::slice::from_ref(&valid))
            .is_err()
    );
    assert!(
        s.apply_physical(
            8,
            before.revision(),
            Some([300.0, 240.0]),
            std::slice::from_ref(&valid)
        )
        .is_err()
    );
    let invalid = PhysicalEvent {
        sequence: 10,
        input: PhysicalInput::Pump {
            generation: s.physical_generation(),
            delta_us: -1,
        },
        ..valid.clone()
    };
    assert!(
        s.apply_physical(
            7,
            before.revision(),
            Some([300.0, 240.0]),
            &[valid.clone(), invalid]
        )
        .is_err()
    );
    assert_eq!(s.snapshot(), before);
    assert_eq!(s.physical_generation(), control.physical_generation());
    // A pump-clock overflow must also leave the animation intact.
    let overflow = PhysicalEvent {
        input: PhysicalInput::Pump {
            generation: s.physical_generation(),
            delta_us: i64::MAX,
        },
        ..valid.clone()
    };
    assert!(
        s.apply_physical(7, before.revision(), Some([300.0, 240.0]), &[overflow])
            .is_err()
    );
    assert_eq!(s.snapshot(), before);
    assert_eq!(
        s.apply_physical(
            7,
            before.revision(),
            Some([300.0, 240.0]),
            std::slice::from_ref(&valid)
        )
        .unwrap(),
        control
            .apply_physical(
                7,
                control.snapshot().revision(),
                Some([300.0, 240.0]),
                &[valid]
            )
            .unwrap()
    );
    let old = s.physical_generation();
    for e in scenario["input"]
        .as_array()
        .unwrap()
        .iter()
        .filter(|e| matches!(e["seq"].as_u64(), Some(10 | 11)))
    {
        let e = event(e, s.physical_generation());
        control
            .apply_physical(
                7,
                control.snapshot().revision(),
                Some([300.0, 240.0]),
                std::slice::from_ref(&e),
            )
            .unwrap();
        s.apply_physical(7, s.snapshot().revision(), Some([300.0, 240.0]), &[e])
            .unwrap();
    }
    assert_ne!(old, s.physical_generation());
    let before = s.snapshot();
    let pump = PhysicalEvent {
        sequence: 20,
        source_us: None,
        consumed: false,
        input: PhysicalInput::Pump {
            generation: old,
            delta_us: 500000,
        },
    };
    control
        .apply_physical(
            7,
            control.snapshot().revision(),
            Some([300.0, 240.0]),
            std::slice::from_ref(&pump),
        )
        .unwrap();
    let output = s
        .apply_physical(7, before.revision(), Some([300.0, 240.0]), &[pump])
        .unwrap();
    assert!(output.output.interactions.is_empty());
    assert_eq!(output.snapshot.view(), before.view());
    assert_eq!(s.snapshot(), control.snapshot());
}
