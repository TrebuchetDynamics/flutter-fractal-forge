use fractal_core::{
    catalog_baseline::{CatalogBaseline, ParameterKind, ParameterValue},
    normalization::{RawScalar, ViewInput},
    number_wall_prime::NumberWallPrimeStatus,
    session::{
        Command, ParamTimelineToken, RawParams, RequestGuard, RequestProgress, Session,
        SessionError, Snapshot,
    },
};
use serde_json::{Value, json};
use std::{
    collections::BTreeMap,
    sync::{Arc, OnceLock},
};

type Params = BTreeMap<String, ParameterValue>;

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
        "../../../../migration/oracles/param-interpolation.json"
    ))
    .unwrap()
}

fn params(value: &Value) -> Params {
    serde_json::from_value(value.clone()).unwrap()
}

fn apply(session: &mut Session, commands: &[Command]) -> Snapshot {
    let s = session.snapshot();
    session
        .apply_batch(s.session_id(), s.revision(), commands)
        .unwrap()
}

fn start(session: &mut Session, target: Params) -> ParamTimelineToken {
    let s = session.snapshot();
    session
        .start_param_timeline(s.session_id(), s.revision(), target)
        .unwrap()
}

fn tick(session: &mut Session, token: ParamTimelineToken) -> Snapshot {
    let s = session.snapshot();
    session
        .tick_param_timeline(s.session_id(), s.revision(), token)
        .unwrap()
}

fn load(value: &Value) -> Command {
    Command::Load {
        module_id: None,
        params: params(value)
            .into_iter()
            .map(|(k, v)| (k, v.into()))
            .collect(),
        camera: ViewInput {
            zoom: 1.0,
            pan: [0.0; 2],
            rotation: [0.0; 3],
        }
        .into(),
        transparent: false,
    }
}

fn assert_params(actual: &Snapshot, expected: &Value) {
    let expected = params(expected);
    assert_eq!(
        actual.params().keys().collect::<Vec<_>>(),
        expected.keys().collect::<Vec<_>>()
    );
    let catalog = catalog();
    let schema = &catalog
        .parameters()
        .payload
        .records
        .iter()
        .find(|p| p.module_id.as_str() == actual.module_id())
        .unwrap()
        .parameters;
    for (id, expected) in expected {
        if schema
            .iter()
            .any(|p| p.id == id && p.kind == ParameterKind::Float)
        {
            let number = |v: &ParameterValue| match v {
                ParameterValue::Number(n) => n.as_f64().unwrap(),
                _ => panic!("non-numeric float {id}"),
            };
            assert!(
                (number(&actual.params()[&id]) - number(&expected)).abs() <= 1e-12,
                "{id}"
            );
        } else {
            assert_eq!(actual.params()[&id], expected, "{id}");
        }
    }
}

#[test]
fn actual_module_oracle_ticks_and_replacement_start_from_live_partial_params() {
    let oracle = oracle();
    let case = &oracle["cases"][0];
    assert_eq!(case["id"], "mandelbrot");
    let mut session = Session::new(catalog(), 7, "mandelbrot").unwrap();
    apply(&mut session, &[load(&case["from"])]);
    let retained = session.snapshot();
    let token = start(&mut session, params(&case["target"]));
    assert_eq!(session.snapshot().params(), retained.params());
    for output in case["expected"].as_array().unwrap() {
        let before = session.snapshot();
        let actual = if output["step"] == 0 {
            before.clone()
        } else {
            tick(&mut session, token)
        };
        assert_eq!(
            actual.revision(),
            before.revision() + u64::from(output["step"] != 0)
        );
        assert_params(&actual, &output["params"]);
    }
    assert_eq!(session.snapshot().params(), &params(&case["target"]));
    let finished = session.snapshot();
    assert_eq!(tick(&mut session, token), finished);
    assert_eq!(retained.params(), &params(&case["from"]));

    // The cancellation oracle starts with palette zero, then replaces after five callbacks.
    apply(&mut session, &[Command::ResetSession]);
    let mut target = params(&case["target"]);
    target.insert("colorScheme".into(), ParameterValue::Number(0.into()));
    let old = start(&mut session, target);
    let replacement = &oracle["cancellations"][0];
    for _ in 0..replacement["afterStep"].as_u64().unwrap() {
        tick(&mut session, old);
    }
    assert_params(&session.snapshot(), &replacement["from"]);
    let partial = session.snapshot();
    let new = start(&mut session, params(&replacement["target"]));
    assert_ne!(old, new);
    let started = session.snapshot();
    assert_eq!(tick(&mut session, old), started);
    let mut previous_step = 0;
    for output in replacement["expected"].as_array().unwrap() {
        let step = output["step"].as_u64().unwrap();
        for _ in previous_step..step {
            tick(&mut session, new);
        }
        assert_eq!(session.snapshot().revision(), started.revision() + step);
        assert_params(&session.snapshot(), &output["params"]);
        previous_step = step;
    }
    assert_eq!(session.snapshot().params(), &params(&replacement["target"]));
    assert_eq!(partial.params(), &params(&replacement["from"]));
}

#[test]
fn cancellation_matches_edit_call_sites_not_camera_changes_and_is_idempotent() {
    let oracle = oracle();
    let target = params(&oracle["cases"][0]["target"]);
    let camera = ViewInput {
        zoom: 2.0,
        pan: [0.1; 2],
        rotation: [0.2; 3],
    }
    .into();
    for (command, cancels) in [
        (
            Command::Param {
                id: "iterations".into(),
                value: RawScalar::Float(200.0),
            },
            true,
        ),
        (
            Command::Param {
                id: "unknown".into(),
                value: RawScalar::Boolean(true),
            },
            false,
        ),
        (
            Command::ApplyPreset {
                module_id: "mandelbrot".into(),
                params: RawParams::new(),
                camera,
            },
            true,
        ),
        (load(&oracle["cases"][0]["from"]), true),
        (
            Command::SelectModule {
                module_id: "julia".into(),
                reset_view: false,
                initial_params: RawParams::new(),
            },
            true,
        ),
        (
            Command::SelectModule {
                module_id: "mandelbrot".into(),
                reset_view: false,
                initial_params: RawParams::new(),
            },
            true,
        ),
        (Command::ResetParams, true),
        (Command::ResetSession, true),
        (Command::Zoom(2.0), false),
        (Command::Pan([0.1; 2]), false),
        (Command::Rotation([0.2; 3]), false),
        (
            Command::View {
                camera,
                adaptive: true,
            },
            false,
        ),
        (Command::ResetView, false),
        (Command::Transparent(true), false),
    ] {
        let mut session = Session::new(catalog(), 7, "mandelbrot").unwrap();
        let token = start(&mut session, target.clone());
        tick(&mut session, token);
        let edited = apply(&mut session, std::slice::from_ref(&command));
        let next = tick(&mut session, token);
        assert_eq!(
            next.revision(),
            edited.revision() + u64::from(!cancels),
            "{command:?}"
        );
        if cancels {
            assert_eq!(next, edited, "{command:?}");
        }
    }
    let mut session = Session::new(catalog(), 7, "mandelbrot").unwrap();
    let old = start(&mut session, target.clone());
    let s = session.snapshot();
    let cancelled = session.cancel_param_timeline(7, s.revision(), old).unwrap();
    assert_eq!(cancelled.revision(), s.revision() + 1);
    assert_eq!(cancelled.params(), s.params());
    assert_eq!(
        session
            .cancel_param_timeline(7, cancelled.revision(), old)
            .unwrap(),
        cancelled
    );
    let replacement = start(&mut session, target);
    let s = session.snapshot();
    assert_eq!(
        session.cancel_param_timeline(7, s.revision(), old).unwrap(),
        s
    );
    assert_eq!(tick(&mut session, old), s);
    assert_eq!(tick(&mut session, replacement).revision(), s.revision() + 1);

    // Deferred load admission, not just immediate apply_batch, must cancel too.
    let before = session.snapshot();
    let mut command = load(&json!({"prime":"97"}));
    if let Command::Load { module_id, .. } = &mut command {
        *module_id = Some("number_wall".into());
    }
    session
        .begin_number_wall(
            7,
            before.revision(),
            &command,
            RequestGuard::new(true),
            100_000,
        )
        .unwrap()
        .unwrap();
    let pending = session.snapshot();
    assert_eq!(tick(&mut session, replacement), pending);
    let wall = pending.number_wall_pending().unwrap();
    let new = start(&mut session, params(&oracle["cases"][0]["target"]));
    let restarted = session.snapshot();
    assert_eq!(restarted.number_wall_pending(), None);
    assert_eq!(
        session
            .advance_number_wall(7, restarted.revision(), wall, 1024)
            .unwrap(),
        RequestProgress::Finished(NumberWallPrimeStatus::Cancelled)
    );
    assert_eq!(session.snapshot(), restarted);
    assert_eq!(tick(&mut session, new).revision(), restarted.revision() + 1);
}

#[test]
fn rejected_transactions_and_invalid_targets_preserve_the_hidden_next_step() {
    let oracle = oracle();
    let case = &oracle["cases"][0];
    let mut session = Session::new(catalog(), 7, "mandelbrot").unwrap();
    apply(&mut session, &[load(&case["from"])]);
    let token = start(&mut session, params(&case["target"]));
    tick(&mut session, token);
    let before = session.snapshot();
    let mut deferred = load(&json!({"prime":"97"}));
    if let Command::Load { module_id, .. } = &mut deferred {
        *module_id = Some("number_wall".into());
    }
    for rejected in [
        Command::Unsupported {
            operation: "reject mixed batch".into(),
        },
        deferred,
    ] {
        assert!(
            session
                .apply_batch(
                    7,
                    before.revision(),
                    &[
                        Command::ResetParams,
                        Command::SelectModule {
                            module_id: "julia".into(),
                            reset_view: true,
                            initial_params: RawParams::new(),
                        },
                        rejected,
                    ]
                )
                .is_err()
        );
    }
    for (id, revision, error) in [
        (8, before.revision(), SessionError::WrongSession),
        (7, before.revision() - 1, SessionError::StaleRevision),
    ] {
        assert_eq!(
            session.start_param_timeline(id, revision, params(&case["target"])),
            Err(error.clone())
        );
        assert_eq!(
            session.tick_param_timeline(id, revision, token),
            Err(error.clone())
        );
        assert_eq!(
            session.cancel_param_timeline(id, revision, token),
            Err(error.clone())
        );
        assert_eq!(
            session.apply_batch(id, revision, &[Command::ResetSession]),
            Err(error)
        );
    }
    for invalid in [
        json!({}),
        json!({"iterations":100,"bailout":4.0,"colorScheme":0,"extra":1}),
        json!({"iterations":true,"bailout":4.0,"colorScheme":0}),
        json!({"iterations":501,"bailout":4.0,"colorScheme":0}),
    ] {
        assert!(matches!(
            session.start_param_timeline(7, before.revision(), params(&invalid)),
            Err(SessionError::InvalidParameterTarget(_))
        ));
    }
    let mut foreign = Session::new(catalog(), 8, "mandelbrot").unwrap();
    let foreign = start(&mut foreign, params(&case["target"]));
    assert_eq!(
        session.tick_param_timeline(7, before.revision(), foreign),
        Err(SessionError::WrongSession)
    );
    assert_eq!(
        session.cancel_param_timeline(7, before.revision(), foreign),
        Err(SessionError::WrongSession)
    );
    assert_eq!(session.snapshot(), before);
    assert_params(&tick(&mut session, token), &case["expected"][2]["params"]);
    assert_params(&before, &case["expected"][1]["params"]);

    let mut wall = Session::new(catalog(), 9, "number_wall").unwrap();
    let before = wall.snapshot();
    assert!(matches!(
        wall.start_param_timeline(9, 0, before.params().clone()),
        Err(SessionError::UnsupportedOperation(_))
    ));
    assert_eq!(wall.snapshot(), before);
}
