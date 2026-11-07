use fractal_core::{
    catalog_baseline::{CatalogBaseline, ParameterValue},
    normalization::{RawScalar, ViewInput},
    session::{CameraInput, Command, Session, SessionError, Snapshot},
};
use serde_json::{Value, json};
use std::{collections::BTreeMap, fs, path::Path, sync::Arc};

const PREFIX_LEN: usize = 47;
const EPOCH: &str = "2026-01-01T00:00:00.000Z";

fn baseline(name: &str) -> String {
    fs::read_to_string(
        Path::new(env!("CARGO_MANIFEST_DIR"))
            .join("../../../migration/baseline")
            .join(format!("{name}.json")),
    )
    .unwrap()
}

fn catalog() -> Arc<CatalogBaseline> {
    Arc::new(
        CatalogBaseline::from_jsons(
            &baseline("modules"),
            &baseline("parameters"),
            &baseline("presets"),
            &baseline("capabilities"),
        )
        .unwrap(),
    )
}

fn raw(value: &Value) -> RawScalar {
    match value.get("nonfinite").and_then(Value::as_str) {
        Some("nan") => RawScalar::Float(f64::NAN),
        Some("+infinity") => RawScalar::Float(f64::INFINITY),
        Some("-infinity") => RawScalar::Float(f64::NEG_INFINITY),
        Some(other) => panic!("unknown nonfinite operand: {other}"),
        None => RawScalar::from(serde_json::from_value::<ParameterValue>(value.clone()).unwrap()),
    }
}

fn number(value: &Value) -> f64 {
    match raw(value) {
        RawScalar::Number(n) => n.as_f64().unwrap(),
        RawScalar::Float(n) => n,
        other => panic!("not a camera number: {other:?}"),
    }
}

fn params(value: &Value) -> BTreeMap<String, RawScalar> {
    value
        .as_object()
        .map(|map| map.iter().map(|(k, v)| (k.clone(), raw(v))).collect())
        .unwrap_or_default()
}

// Legacy HistoryEntry decoding supplies these scalar defaults before ingress.
fn camera(value: &Value) -> CameraInput {
    let n = |key: &str, default: f64| value.get(key).map(number).unwrap_or(default);
    CameraInput {
        view: ViewInput {
            zoom: n("zoom", 1.0),
            pan: [n("panX", 0.0), n("panY", 0.0)],
            rotation: [n("rotX", 0.0), n("rotY", 0.0), n("rotZ", 0.0)],
        },
        has_trajectory: value.get("trajectory").is_some_and(|v| !v.is_null()),
    }
}

fn view_json(view: ViewInput) -> Value {
    json!({"zoom": view.zoom, "panX": view.pan[0], "panY": view.pan[1],
        "rotX": view.rotation[0], "rotY": view.rotation[1], "rotZ": view.rotation[2]})
}

fn history(snapshot: &Snapshot) -> Value {
    let view = snapshot.view();
    json!({"id": "replay", "moduleId": snapshot.module_id(), "name": null,
        "params": snapshot.params(), "visitedAt": EPOCH,
        "view": view_json(ViewInput {zoom: view.zoom(), pan: view.pan(), rotation: view.rotation()})})
}

fn command(event: &Value, current_module: &str) -> Command {
    let module_id = || event["moduleId"].as_str().map(str::to_owned);
    match event["op"].as_str().unwrap() {
        "zoom" => Command::Zoom(number(&event["value"])),
        "pan" => Command::Pan(std::array::from_fn(|i| number(&event["value"][i]))),
        "rotation" => Command::Rotation(std::array::from_fn(|i| number(&event["value"][i]))),
        "view" => Command::View {
            camera: camera(&event["value"]),
            adaptive: event["adaptive"] == true,
        },
        "param" => Command::Param {
            id: event["id"].as_str().unwrap().into(),
            value: raw(&event["value"]),
        },
        "module" => Command::SelectModule {
            module_id: module_id().unwrap(),
            reset_view: event["resetView"] == true,
            initial_params: BTreeMap::new(),
        },
        "transparent" => Command::Transparent(event["value"].as_bool().unwrap()),
        "preset" => Command::ApplyPreset {
            module_id: module_id().unwrap_or_else(|| current_module.into()),
            params: params(&event["params"]),
            camera: camera(&event["view"]),
        },
        "load" => Command::Load {
            module_id: module_id(),
            params: params(&event["params"]),
            camera: camera(&event["view"]),
            transparent: event["transparentBackground"] == true,
        },
        "resetParams" => Command::ResetParams,
        "resetView" => Command::ResetView,
        "resetSession" => Command::ResetSession,
        other => panic!("unported replay command: {other}"),
    }
}

fn apply(session: &mut Session, commands: &[Command]) -> Snapshot {
    let before = session.snapshot();
    session
        .apply_batch(before.session_id(), before.revision(), commands)
        .unwrap()
}

fn replay(inputs: &[Value]) -> Vec<Value> {
    let mut session = Session::new(catalog(), 7, "mandelbrot").unwrap();
    let mut saved = BTreeMap::<String, Value>::new();
    inputs.iter().map(|event| {
        let before = session.snapshot();
        let mut result = Value::Null;
        match event["op"].as_str().unwrap() {
            "snapshot" => {},
            "saveHistory" => {
                result = serde_json::from_str(&history(&before).to_string()).unwrap();
                saved.insert(event["key"].as_str().unwrap().into(), result.clone());
            },
            "restoreHistory" => {
                let entry = &saved[event["key"].as_str().unwrap()];
                apply(&mut session, &[Command::Load {
                    module_id: Some(entry["moduleId"].as_str().unwrap().into()),
                    params: params(&entry["params"]), camera: camera(&entry["view"]), transparent: false,
                }]);
                result = json!(true);
            },
            op => {
                let cmd = command(event, before.module_id());
                if op == "preset" && event["roundTrip"] == true {
                    // FractalPreset serializer framing is harness-owned, not core storage.
                    result = json!({"id": "replay", "moduleId": event["moduleId"].as_str().unwrap_or(before.module_id()),
                        "name": "Replay", "params": event["params"], "createdAt": EPOCH,
                        "isBuiltIn": false, "thumbnailPath": null, "view": view_json(camera(&event["view"]).view)});
                    let decoded: Value = serde_json::from_str(&result.to_string()).unwrap();
                    apply(&mut session, &[command(&json!({"op":"preset", "moduleId":decoded["moduleId"], "params":decoded["params"], "view":decoded["view"]}), before.module_id())]);
                } else {
                    apply(&mut session, &[cmd]);
                }
                if op == "load" { result = json!(true); }
            },
        }
        let snapshot = session.snapshot();
        json!({"result": result, "history": history(&snapshot),
            "transparentBackground": snapshot.transparent_background(),
            "numberWall": {"pending": false, "status": null, "prime": null, "firstCell": null}})
    }).collect()
}

#[test]
fn original_ordinary_prefix_replays_twice_and_rejects_expectation_drift() {
    let original = baseline("state-replay");
    let document: Value = serde_json::from_str(&original).unwrap();
    assert_eq!(document["schema"], 1);
    assert_eq!(document["kind"], "state-replay");
    let inputs = document["inputs"].as_array().unwrap();
    let expected = document["expected"].as_array().unwrap();
    assert_eq!((inputs.len(), expected.len()), (68, 68));
    assert_eq!(
        (inputs[46]["op"].as_str(), inputs[46]["id"].as_str()),
        (Some("param"), Some("animate"))
    );
    assert_eq!(
        (inputs[47]["op"].as_str(), inputs[47]["moduleId"].as_str()),
        (Some("load"), Some("number_wall"))
    );
    // Events 47–67 are deliberately unported, not a skipped full-replay pass.
    let actual = replay(&inputs[..PREFIX_LEN]);
    assert_eq!(replay(&inputs[..PREFIX_LEN]), actual);
    for (i, output) in actual.iter().enumerate() {
        assert_eq!(output, &expected[i], "event {i}: {}", inputs[i]["label"]);
    }
    let actual = Value::Array(actual);
    let mut altered = Value::Array(expected[..PREFIX_LEN].to_vec());
    altered[0]["history"]["view"]["zoom"] = json!(-123);
    assert_ne!(actual, altered);
    assert_eq!(baseline("state-replay"), original);
}

#[test]
fn ordered_batches_publish_once_without_coalescing_and_keep_snapshots_isolated() {
    let catalog = catalog();
    let mut batch = Session::new(catalog.clone(), 1, "mandelbrot").unwrap();
    let mut singles = Session::new(catalog.clone(), 2, "mandelbrot").unwrap();
    let other = Session::new(catalog, 3, "julia").unwrap();
    let retained = batch.snapshot();
    let other_before = other.snapshot();
    let commands = [
        Command::ResetSession,
        Command::Zoom(2.0),
        Command::Zoom(32.0),
        Command::Zoom(1.0),
    ];
    let published = apply(&mut batch, &commands);
    for cmd in &commands {
        apply(&mut singles, std::slice::from_ref(cmd));
    }
    assert_eq!(published.revision(), 1);
    assert_eq!(singles.snapshot().revision(), 4);
    assert_eq!(
        published.params()["iterations"],
        serde_json::from_value::<ParameterValue>(json!(398)).unwrap()
    );
    assert_eq!(history(&published), history(&singles.snapshot()));
    assert_eq!(
        published.last_adaptive_zoom(),
        singles.snapshot().last_adaptive_zoom()
    );
    assert_eq!(apply(&mut batch, &[]), published);
    let noop = apply(
        &mut batch,
        &[Command::Param {
            id: "unknown".into(),
            value: RawScalar::Boolean(true),
        }],
    );
    assert_eq!(noop.revision(), 2);
    assert_eq!(history(&noop), history(&published));
    assert_eq!(retained.revision(), 0);
    assert_ne!(retained.view(), published.view());
    assert_eq!(other.snapshot(), other_before);

    // Schema defaults < module default preset < explicit selection overrides.
    let selected = apply(
        &mut batch,
        &[Command::SelectModule {
            module_id: "julia".into(),
            reset_view: false,
            initial_params: params(&json!({"iterations":777,"unknown":1})),
        }],
    );
    assert_eq!(
        selected.params()["iterations"],
        serde_json::from_value::<ParameterValue>(json!(777)).unwrap()
    );
    let preset = apply(
        &mut batch,
        &[Command::ApplyPreset {
            module_id: "julia".into(),
            params: params(&json!({"colorScheme":1})),
            camera: camera(&json!({"zoom":2})),
        }],
    );
    assert_eq!(
        preset.params()["iterations"],
        serde_json::from_value::<ParameterValue>(json!(160)).unwrap()
    );
    let no_switch = apply(
        &mut batch,
        &[Command::SelectModule {
            module_id: "julia".into(),
            reset_view: false,
            initial_params: BTreeMap::new(),
        }],
    );
    assert_eq!(history(&no_switch), history(&preset));
    let reset = apply(
        &mut batch,
        &[Command::Transparent(true), Command::ResetSession],
    );
    assert_eq!(reset.revision(), no_switch.revision() + 1);
    assert!(!reset.transparent_background());
    assert_eq!(reset.view().zoom(), 1.0);

    // Synchronize history after preset/load/nonadaptive view; identical zooms
    // must not adapt, while an explicitly adaptive view must do so.
    for (events, iterations) in [
        (
            json!([
                {"op":"module", "moduleId":"julia", "resetView":true},
                {"op":"preset", "moduleId":"julia", "params":{"colorScheme":1}, "view":{"zoom":32}},
                {"op":"zoom", "value":32}
            ]),
            160,
        ),
        (
            json!([
                {"op":"load", "moduleId":"julia", "params":{"iterations":200}, "view":{"zoom":64}, "transparentBackground":true},
                {"op":"zoom", "value":64}, {"op":"pan", "value":[0.5,-0.5]}
            ]),
            200,
        ),
        (
            json!([
                {"op":"view", "value":{"zoom":128}},
                {"op":"zoom", "value":128}, {"op":"rotation", "value":[0.1,0.2,0.3]}
            ]),
            200,
        ),
        (
            json!([
                {"op":"view", "value":{"zoom":256}, "adaptive":true},
                {"op":"zoom", "value":256}
            ]),
            264,
        ),
        (
            json!([
                {"op":"resetParams"}, {"op":"resetView"}, {"op":"zoom", "value":32}
            ]),
            192,
        ),
        (
            json!([
                {"op":"resetSession"}, {"op":"zoom", "value":2}
            ]),
            176,
        ),
    ] {
        let before = batch.snapshot();
        let commands: Vec<_> = events
            .as_array()
            .unwrap()
            .iter()
            .map(|e| command(e, before.module_id()))
            .collect();
        let published = apply(&mut batch, &commands);
        for cmd in &commands {
            apply(&mut singles, std::slice::from_ref(cmd));
        }
        assert_eq!(published.revision(), before.revision() + 1);
        assert_eq!(history(&published), history(&singles.snapshot()));
        assert_eq!(
            published.transparent_background(),
            singles.snapshot().transparent_background()
        );
        assert_eq!(
            published.last_adaptive_zoom(),
            singles.snapshot().last_adaptive_zoom()
        );
        assert_eq!(
            published.params()["iterations"],
            serde_json::from_value::<ParameterValue>(json!(iterations)).unwrap()
        );
    }
    assert_eq!(retained.revision(), 0);
    assert_eq!(other.snapshot(), other_before);
}

#[test]
fn wrong_identity_stale_revision_and_unsupported_inputs_reject_atomically() {
    let catalog = catalog();
    for module in ["number_wall", "unknown", "core.mandelbrot"] {
        assert!(matches!(
            Session::new(catalog.clone(), 1, module),
            Err(SessionError::UnsupportedModule(_))
        ));
    }
    let mut session = Session::new(catalog.clone(), u64::MAX, "mandelbrot").unwrap();
    let before = session.snapshot();
    for (id, revision, error) in [
        (0, 0, SessionError::WrongSession),
        (u64::MAX, 1, SessionError::StaleRevision),
    ] {
        assert_eq!(
            session.apply_batch(id, revision, &[Command::ResetSession]),
            Err(error)
        );
        assert_eq!(session.snapshot(), before);
        assert!(session.apply_batch(id, revision, &[]).is_err());
    }
    let mut trajectory = camera(&json!({}));
    trajectory.has_trajectory = true;
    for rejected in [
        Command::SelectModule {
            module_id: "number_wall".into(),
            reset_view: true,
            initial_params: BTreeMap::new(),
        },
        Command::ApplyPreset {
            module_id: "unknown".into(),
            params: BTreeMap::new(),
            camera: camera(&json!({})),
        },
        Command::Load {
            module_id: Some("number_wall".into()),
            params: BTreeMap::new(),
            camera: camera(&json!({})),
            transparent: false,
        },
        Command::View {
            camera: trajectory,
            adaptive: true,
        },
        Command::ApplyPreset {
            module_id: "mandelbrot".into(),
            params: BTreeMap::new(),
            camera: trajectory,
        },
        Command::Load {
            module_id: None,
            params: BTreeMap::new(),
            camera: trajectory,
            transparent: false,
        },
        Command::Unsupported {
            operation: "randomize".into(),
        },
    ] {
        let error = session
            .apply_batch(
                u64::MAX,
                0,
                &[Command::Zoom(32.0), Command::Transparent(true), rejected],
            )
            .unwrap_err();
        assert!(matches!(
            error,
            SessionError::UnsupportedModule(_)
                | SessionError::UnsupportedTrajectory
                | SessionError::UnsupportedOperation(_)
        ));
        assert_eq!(session.snapshot(), before);
    }
    // A rejected candidate must not leak adaptive history into the next commit.
    let after = apply(&mut session, &[Command::Zoom(2.0)]);
    let mut fresh = Session::new(catalog, 4, "mandelbrot").unwrap();
    assert_eq!(
        history(&after),
        history(&apply(&mut fresh, &[Command::Zoom(2.0)]))
    );
}
