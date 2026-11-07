use fractal_core::{
    catalog_baseline::{CatalogBaseline, ParameterValue},
    normalization::ViewInput,
    number_wall_prime::NumberWallPrimeStatus as Status,
    session::{
        Command, RawParams, RequestGuard, RequestProgress, RequestToken, Session, SessionError,
        Snapshot,
    },
};
use serde_json::{Value, json};
use std::sync::{Arc, OnceLock};

fn catalog() -> Arc<CatalogBaseline> {
    static CATALOG: OnceLock<Arc<CatalogBaseline>> = OnceLock::new();
    CATALOG
        .get_or_init(|| {
            Arc::new(
                CatalogBaseline::from_jsons(
                    include_str!("../../../../migration/baseline/modules.json"),
                    include_str!("../../../../migration/baseline/parameters.json"),
                    include_str!("../../../../migration/baseline/presets.json"),
                    include_str!("../../../../migration/baseline/capabilities.json"),
                )
                .unwrap(),
            )
        })
        .clone()
}

fn oracle() -> Value {
    serde_json::from_str(include_str!(
        "../../../../migration/oracles/randomization.json"
    ))
    .unwrap()
}

fn apply(s: &mut Session, commands: &[Command]) -> Snapshot {
    s.apply_batch(1, s.snapshot().revision(), commands).unwrap()
}

fn load(params: &Value, camera: &Value) -> Command {
    Command::Load {
        module_id: None,
        params: serde_json::from_value::<std::collections::BTreeMap<String, ParameterValue>>(
            params.clone(),
        )
        .unwrap()
        .into_iter()
        .map(|(k, v)| (k, v.into()))
        .collect(),
        camera: ViewInput {
            zoom: camera["zoom"].as_f64().unwrap(),
            pan: serde_json::from_value(camera["pan"].clone()).unwrap(),
            rotation: serde_json::from_value(camera["rotation"].clone()).unwrap(),
        }
        .into(),
        transparent: false,
    }
}

fn begin(s: &mut Session, command: &Command, guard: RequestGuard) -> RequestToken {
    s.begin_number_wall(1, s.snapshot().revision(), command, guard, 100_000)
        .unwrap()
        .unwrap()
}

fn randomize(s: &mut Session, seed: i64, guard: RequestGuard) -> Option<RequestToken> {
    s.begin_number_wall_randomization(1, s.snapshot().revision(), seed, guard, 100_000)
        .unwrap()
}

fn finish(s: &mut Session, token: RequestToken) -> Status {
    loop {
        match s
            .advance_number_wall(1, s.snapshot().revision(), token, 4096)
            .unwrap()
        {
            RequestProgress::Pending => {}
            RequestProgress::Finished(status) => return status,
        }
    }
}

fn undo(s: &mut Session) -> bool {
    s.undo_number_wall_randomization(1, s.snapshot().revision())
        .unwrap()
}

fn assert_state(s: &Snapshot, expected: &Value) {
    assert_eq!(s.module_id(), expected["module"]);
    let params: std::collections::BTreeMap<String, ParameterValue> =
        serde_json::from_value(expected["params"].clone()).unwrap();
    assert_eq!(s.params(), &params);
    for (id, value) in &params {
        let kind = match value {
            ParameterValue::Boolean(_) => "bool",
            ParameterValue::Text(_) => "String",
            ParameterValue::Number(n) if n.is_f64() => "double",
            ParameterValue::Number(_) => "int",
        };
        assert_eq!(kind, expected["paramKinds"][id]);
    }
    assert_eq!(s.can_undo_number_wall_randomization(), expected["canUndo"]);
    assert_eq!(s.number_wall_pending().is_some(), expected["pending"]);
    let status = match s.number_wall_status() {
        None => Value::Null,
        Some(Status::VerifiedPrime) => json!("verifiedPrime"),
        Some(Status::Composite) => json!("composite"),
        Some(Status::Cancelled) => json!("cancelled"),
        other => panic!("unexpected status {other:?}"),
    };
    assert_eq!(status, expected["status"]);
    assert_eq!(
        s.transparent_background(),
        expected["transparentBackground"]
    );
    assert_eq!(
        json!({"zoom":s.view().zoom(), "pan":s.view().pan(), "rotation":s.view().rotation()}),
        expected["view"]
    );
    if expected["grid"].is_null() {
        assert!(s.number_wall_frame().is_none());
    } else {
        let grid = s.number_wall_frame().unwrap().grid();
        let (start, end) = grid.support();
        assert_eq!(
            json!({
                "cells":grid.values(), "prime":grid.modulus(), "rows":grid.row_count(),
                "columns":grid.column_count(), "columnStart":grid.column_start(),
                "support":{"start":start,"end":end},
            }),
            {
                let mut grid = expected["grid"].clone();
                grid.as_object_mut().unwrap().remove("sequence");
                grid
            }
        );
        if s.module_id() == "number_wall" {
            assert_eq!(s.number_wall_frame().unwrap().params(), s.params());
        }
    }
}

#[test]
fn wall_oracle_success_publishes_single_undo_and_retains_current_view() {
    for case in oracle()["numberWalls"].as_array().unwrap() {
        let expected = &case["expected"];
        let mut s = Session::new(catalog(), 1, "number_wall").unwrap();
        let token = begin(
            &mut s,
            &load(&case["input"]["initialParams"], &expected["before"]["view"]),
            RequestGuard::new(true),
        );
        assert_eq!(finish(&mut s, token), Status::VerifiedPrime);
        assert_state(&s.snapshot(), &expected["before"]);
        let previous = s.snapshot();
        let token = randomize(
            &mut s,
            case["input"]["seed"].as_i64().unwrap(),
            RequestGuard::new(true),
        )
        .unwrap();
        let pending = s.snapshot();
        assert_eq!(pending.params(), previous.params());
        assert!(!pending.can_undo_number_wall_randomization());
        assert_eq!(finish(&mut s, token), Status::VerifiedPrime);
        assert_state(&s.snapshot(), &expected["randomized"]);
        let view = &expected["edited"]["view"];
        apply(
            &mut s,
            &[
                Command::View {
                    camera: ViewInput {
                        zoom: view["zoom"].as_f64().unwrap(),
                        pan: serde_json::from_value(view["pan"].clone()).unwrap(),
                        rotation: serde_json::from_value(view["rotation"].clone()).unwrap(),
                    }
                    .into(),
                    adaptive: false,
                },
                Command::Transparent(true),
            ],
        );
        assert_state(&s.snapshot(), &expected["edited"]);
        assert!(undo(&mut s));
        assert_state(&s.snapshot(), &expected["afterUndo"]);
        assert!(Arc::ptr_eq(
            s.snapshot().number_wall_frame().unwrap(),
            previous.number_wall_frame().unwrap()
        ));
        let done = s.snapshot();
        assert!(!undo(&mut s));
        assert_eq!(s.snapshot(), done);
        assert_state(&s.snapshot(), &expected["afterSecondUndo"]);
    }
}

#[test]
fn ordered_unsuccessful_oracle_never_replaces_prior_undo() {
    let oracle = oracle();
    let mut s = Session::new(catalog(), 1, "number_wall").unwrap();
    let mut pending = None;
    let mut guard = RequestGuard::new(true);
    for action in oracle["unsuccessful"]["expected"].as_array().unwrap() {
        let input = &action["input"];
        let result = match action["op"].as_str().unwrap() {
            "setup" => {
                let token = begin(
                    &mut s,
                    &load(&action["state"]["params"], &action["state"]["view"]),
                    RequestGuard::new(true),
                );
                json!(finish(&mut s, token) == Status::VerifiedPrime)
            }
            "undoNumberWallRandomization" => json!(undo(&mut s)),
            "randomizeNumberWall" | "startRandomizeNumberWall" => {
                let token = randomize(
                    &mut s,
                    input["seed"].as_i64().unwrap(),
                    RequestGuard::new(true),
                );
                if action["op"] == "startRandomizeNumberWall" {
                    pending = token;
                    Value::Null
                } else {
                    json!(token.is_some_and(|token| finish(&mut s, token) == Status::VerifiedPrime))
                }
            }
            "cancelNumberWallRequest" => {
                s.cancel_number_wall(1, s.snapshot().revision(), pending.unwrap())
                    .unwrap();
                Value::Null
            }
            "awaitRandomizeNumberWall" | "awaitGuardedLoadState" => {
                json!(finish(&mut s, pending.take().unwrap()) == Status::VerifiedPrime)
            }
            "loadState" | "startGuardedLoadState" => {
                let mut params = serde_json::to_value(s.snapshot().params()).unwrap();
                params.as_object_mut().unwrap().extend(
                    input
                        .as_object()
                        .unwrap()
                        .iter()
                        .filter(|(k, _)| *k != "owned")
                        .map(|(k, v)| (k.clone(), v.clone())),
                );
                guard = RequestGuard::new(true);
                let token = begin(
                    &mut s,
                    &load(&params, &action["state"]["view"]),
                    guard.clone(),
                );
                if action["op"] == "startGuardedLoadState" {
                    pending = Some(token);
                    Value::Null
                } else {
                    json!(finish(&mut s, token) == Status::VerifiedPrime)
                }
            }
            "revokeOwnership" => {
                guard.revoke();
                Value::Null
            }
            "selectModule" => {
                apply(
                    &mut s,
                    &[Command::SelectModule {
                        module_id: input["module"].as_str().unwrap().into(),
                        reset_view: false,
                        initial_params: RawParams::new(),
                    }],
                );
                Value::Null
            }
            op => panic!("unknown action {op}"),
        };
        assert_eq!(result, action["result"], "{}", action["op"]);
        assert_state(&s.snapshot(), &action["state"]);
    }

    // Randomization provenance must not escape revoked or superseded
    // requests, even when the successor load has exactly a randomizer's params.
    for termination in [
        "complete",
        "revoke",
        "supersede",
        "replacement-success",
        "undo-pending",
    ] {
        let mut s = Session::new(catalog(), 1, "number_wall").unwrap();
        let expected = &oracle["numberWalls"][0]["expected"];
        let params = &expected["before"]["params"];
        let token = begin(
            &mut s,
            &load(params, &expected["before"]["view"]),
            RequestGuard::new(true),
        );
        assert_eq!(finish(&mut s, token), Status::VerifiedPrime);
        let original = s.snapshot();
        let token = randomize(&mut s, 42, RequestGuard::new(true)).unwrap();
        assert_eq!(finish(&mut s, token), Status::VerifiedPrime);
        let committed = s.snapshot();
        let guard = RequestGuard::new(true);
        let token = randomize(&mut s, 1, guard.clone()).unwrap();
        let before = s.snapshot();
        for (id, revision, error) in [
            (2, before.revision(), SessionError::WrongSession),
            (1, 0, SessionError::StaleRevision),
        ] {
            assert_eq!(
                s.begin_number_wall_randomization(
                    id,
                    revision,
                    0,
                    RequestGuard::new(true),
                    100_000
                ),
                Err(error.clone())
            );
            assert_eq!(s.undo_number_wall_randomization(id, revision), Err(error));
        }
        assert_eq!(
            s.apply_batch(
                1,
                before.revision(),
                &[
                    Command::SelectModule {
                        module_id: "mandelbrot".into(),
                        reset_view: false,
                        initial_params: RawParams::new()
                    },
                    Command::Unsupported {
                        operation: "failed batch".into()
                    },
                ]
            ),
            Err(SessionError::UnsupportedOperation("failed batch".into()))
        );
        let deferred = load(
            &serde_json::to_value(committed.params()).unwrap(),
            &expected["before"]["view"],
        );
        assert_eq!(
            s.apply_batch(
                1,
                before.revision(),
                &[Command::Transparent(true), deferred]
            ),
            Err(SessionError::DeferredOperation)
        );
        assert_eq!(s.snapshot(), before);
        assert_eq!(randomize(&mut s, 0, RequestGuard::new(false)), None);
        assert_eq!(s.snapshot(), before);
        match termination {
            "complete" => {
                assert_eq!(finish(&mut s, token), Status::VerifiedPrime);
            }
            "revoke" => {
                guard.revoke();
                assert_eq!(finish(&mut s, token), Status::Cancelled);
            }
            "supersede" => {
                let newer = begin(
                    &mut s,
                    &load(
                        &serde_json::to_value(committed.params()).unwrap(),
                        &expected["before"]["view"],
                    ),
                    RequestGuard::new(true),
                );
                assert_eq!(finish(&mut s, token), Status::Cancelled);
                assert_eq!(finish(&mut s, newer), Status::VerifiedPrime);
            }
            "replacement-success" => {
                let newer = randomize(&mut s, 0, RequestGuard::new(true)).unwrap();
                assert_eq!(finish(&mut s, token), Status::Cancelled);
                assert_eq!(finish(&mut s, newer), Status::VerifiedPrime);
            }
            "undo-pending" => {}
            _ => unreachable!(),
        }
        assert!(undo(&mut s));
        let original = if matches!(termination, "complete" | "replacement-success") {
            committed
        } else {
            original
        };
        assert_eq!(s.snapshot().params(), original.params(), "{termination}");
        assert!(Arc::ptr_eq(
            s.snapshot().number_wall_frame().unwrap(),
            original.number_wall_frame().unwrap()
        ));
        assert_eq!(finish(&mut s, token), Status::Cancelled);
        assert!(!undo(&mut s));
    }
}

#[test]
fn ordinary_immediate_randomization_matches_every_actual_module_oracle() {
    for case in oracle()["general"]
        .as_array()
        .unwrap()
        .iter()
        .filter(|c| c["input"]["module"] != "randomization_oracle_schema")
    {
        let mut s = Session::new(catalog(), 1, case["input"]["module"].as_str().unwrap()).unwrap();
        apply(
            &mut s,
            &[load(
                &case["input"]["params"],
                &case["expected"]["before"]["view"],
            )],
        );
        assert_state(&s.snapshot(), &case["expected"]["before"]);
        let before = s.snapshot();
        s.randomize_params(
            1,
            before.revision(),
            case["input"]["seed"].as_i64().unwrap(),
        )
        .unwrap();
        assert_eq!(s.snapshot().revision(), before.revision() + 1);
        assert_state(&s.snapshot(), &case["expected"]["after"]);
    }
    let mut s = Session::new(catalog(), 1, "mandelbrot").unwrap();
    let timeline = s
        .start_param_timeline(1, 0, s.snapshot().params().clone())
        .unwrap();
    s.randomize_params(1, 1, 42).unwrap();
    let done = s.snapshot();
    assert_eq!(
        s.tick_param_timeline(1, done.revision(), timeline).unwrap(),
        done
    );
    let expected = &oracle()["numberWalls"][0]["expected"]["before"];
    let mut command = load(&expected["params"], &expected["view"]);
    if let Command::Load { module_id, .. } = &mut command {
        *module_id = Some("number_wall".into());
    }
    let token = begin(&mut s, &command, RequestGuard::new(true));
    let before = s.snapshot();
    assert_eq!(
        s.randomize_params(2, before.revision(), 0),
        Err(SessionError::WrongSession)
    );
    assert_eq!(
        s.randomize_params(1, 0, 0),
        Err(SessionError::StaleRevision)
    );
    assert_eq!(s.snapshot(), before);
    s.randomize_params(1, before.revision(), 0).unwrap();
    let done = s.snapshot();
    assert_eq!(finish(&mut s, token), Status::Cancelled);
    assert_eq!(s.snapshot(), done);
    assert!(matches!(
        Session::new(catalog(), 1, "randomization_oracle_schema"),
        Err(SessionError::UnsupportedModule(_))
    ));
}

#[test]
fn wall_load_reset_edit_and_same_module_selection_retain_undo_but_navigation_clears_it() {
    let oracle = oracle();
    let before = &oracle["numberWalls"][0]["expected"]["before"];
    let load = load(&before["params"], &before["view"]);
    let camera = ViewInput {
        zoom: 1.0,
        pan: [0.0; 2],
        rotation: [0.0; 3],
    }
    .into();
    let select = |id: &str| Command::SelectModule {
        module_id: id.into(),
        reset_view: false,
        initial_params: RawParams::new(),
    };
    for command in [
        load.clone(),
        Command::ResetParams,
        Command::ResetSession,
        Command::Param {
            id: "source".into(),
            value: ParameterValue::Text("squares".into()).into(),
        },
        Command::Param {
            id: "showGrid".into(),
            value: ParameterValue::Boolean(true).into(),
        },
        Command::ApplyPreset {
            module_id: "number_wall".into(),
            params: match &load {
                Command::Load { params, .. } => params.clone(),
                _ => unreachable!(),
            },
            camera,
        },
        select("number_wall"),
        select("mandelbrot"),
        Command::Load {
            module_id: Some("mandelbrot".into()),
            params: RawParams::new(),
            camera,
            transparent: false,
        },
    ] {
        let mut s = Session::new(catalog(), 1, "number_wall").unwrap();
        assert_eq!(randomize(&mut s, 42, RequestGuard::new(true)), None);
        assert_eq!(
            s.randomize_params(1, 0, 42),
            Err(SessionError::DeferredOperation)
        );
        let token = begin(&mut s, &load, RequestGuard::new(true));
        assert_eq!(finish(&mut s, token), Status::VerifiedPrime);
        let original = s.snapshot();
        let token = randomize(&mut s, 42, RequestGuard::new(true)).unwrap();
        assert_eq!(finish(&mut s, token), Status::VerifiedPrime);
        if let Some(token) = s
            .begin_number_wall(
                1,
                s.snapshot().revision(),
                &command,
                RequestGuard::new(true),
                100_000,
            )
            .unwrap()
        {
            assert_eq!(finish(&mut s, token), Status::VerifiedPrime, "{command:?}");
        }
        let wall = s.snapshot().module_id() == "number_wall";
        assert_eq!(s.snapshot().can_undo_number_wall_randomization(), wall);
        if !wall {
            let token = begin(&mut s, &select("number_wall"), RequestGuard::new(true));
            assert_eq!(finish(&mut s, token), Status::VerifiedPrime);
        }
        assert_eq!(undo(&mut s), wall, "{command:?}");
        if wall {
            assert_eq!(s.snapshot().params(), original.params());
        }
        assert!(!undo(&mut s));
    }
}
