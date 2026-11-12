use fractal_bridge::api::{StateCommand, StateSession, StateSnapshot};
use fractal_core::{
    catalog_baseline::CatalogBaseline,
    session::{Command, Session},
};
use std::{collections::HashMap, sync::Arc};

fn session() -> StateSession {
    let [m, p, s, c] = envelopes();
    StateSession::new(m, p, s, c, "mandelbrot".into()).unwrap()
}

fn envelopes() -> [String; 4] {
    ["modules", "parameters", "presets", "capabilities"].map(|name| {
        std::fs::read_to_string(format!(
            "{}/../../../migration/baseline/{name}.json",
            env!("CARGO_MANIFEST_DIR")
        ))
        .unwrap()
    })
}

fn select(id: &str) -> StateCommand {
    StateCommand::select_module(id.into(), false, HashMap::new())
}

fn params(s: &StateSnapshot) -> HashMap<String, String> {
    s.params()
        .into_iter()
        .map(|(k, v)| {
            (
                k,
                format!("{:?}/{:?}/{:?}", v.number(), v.boolean(), v.text()),
            )
        })
        .collect()
}

#[test]
fn independent_timelines_match_all_core_callbacks_and_reject_foreign_stale_inputs() {
    let bridge = session();
    let initial = bridge.snapshot().unwrap();
    let id = initial.session_id();
    let [m, p, s, c] = envelopes();
    let mut core = Session::new(
        Arc::new(CatalogBaseline::from_jsons(&m, &p, &s, &c).unwrap()),
        id,
        "mandelbrot",
    )
    .unwrap();
    let snap = bridge
        .apply_batch_with_module_animation(id, 0, vec![select("julia")], true)
        .unwrap();
    core.apply_batch_with_module_animation(
        id,
        0,
        &[Command::SelectModule {
            module_id: "julia".into(),
            reset_view: false,
            initial_params: Default::default(),
        }],
        true,
    )
    .unwrap();
    let morph = snap.morph_timeline_token().unwrap();
    let cmorph = core.snapshot().morph_timeline_token().unwrap();
    let start = bridge
        .start_seeded_param_timeline(id, snap.revision(), i64::MIN)
        .unwrap();
    let cp = core
        .start_seeded_param_timeline(id, snap.revision(), i64::MIN)
        .unwrap();
    assert_eq!(params(&start.snapshot()), params(&snap));
    let old = start.token();
    let replacement = bridge
        .start_seeded_param_timeline(id, start.snapshot().revision(), -42)
        .unwrap();
    let cp2 = core
        .start_seeded_param_timeline(id, core.snapshot().revision(), -42)
        .unwrap();
    let mut snap = replacement.snapshot();
    assert_eq!(
        bridge
            .tick_param_timeline(id, snap.revision(), &old)
            .unwrap()
            .revision(),
        snap.revision()
    );
    core.tick_param_timeline(id, core.snapshot().revision(), cp)
        .unwrap();
    let foreign = session();
    let fid = foreign.snapshot().unwrap().session_id();
    assert!(
        foreign
            .tick_param_timeline(fid, 0, &replacement.token())
            .is_err()
    );
    assert!(foreign.tick_morph_timeline(fid, 0, &morph).is_err());
    assert!(
        bridge
            .tick_param_timeline(id, 0, &replacement.token())
            .is_err()
    );
    for step in 1..=36 {
        snap = bridge
            .tick_param_timeline(id, snap.revision(), &replacement.token())
            .unwrap();
        core.tick_param_timeline(id, core.snapshot().revision(), cp2)
            .unwrap();
        for (key, value) in core.snapshot().params() {
            let actual = &snap.params()[key];
            match value {
                fractal_core::catalog_baseline::ParameterValue::Number(n) => {
                    assert_eq!(actual.number(), Some(n.to_string()))
                }
                fractal_core::catalog_baseline::ParameterValue::Boolean(b) => {
                    assert_eq!(actual.boolean(), Some(*b))
                }
                fractal_core::catalog_baseline::ParameterValue::Text(t) => {
                    assert_eq!(actual.text(), Some(t.clone()))
                }
            }
        }
        snap = bridge
            .tick_morph_timeline(id, snap.revision(), &morph)
            .unwrap();
        core.tick_morph_timeline(id, core.snapshot().revision(), cmorph)
            .unwrap();
        assert_eq!(snap.morph_progress(), core.snapshot().morph_progress());
        assert_eq!(snap.is_morphing(), step != 36);
        assert_eq!(
            snap.previous_module_id().as_deref(),
            core.snapshot().previous_module_id()
        );
        assert_eq!(snap.revision(), core.snapshot().revision());
    }
    let revision = snap.revision();
    assert_eq!(
        bridge
            .cancel_param_timeline(id, revision, &replacement.token())
            .unwrap()
            .revision(),
        revision
    );
    assert_eq!(
        bridge
            .tick_morph_timeline(id, revision, &morph)
            .unwrap()
            .revision(),
        revision
    );
    let immediate = bridge.randomize_params(id, revision, -42).unwrap();
    core.randomize_params(id, revision, -42).unwrap();
    assert_eq!(immediate.revision(), core.snapshot().revision());
    let undo = bridge
        .undo_number_wall_randomization(id, immediate.revision())
        .unwrap();
    assert!(!undo.changed());
    assert!(!undo.snapshot().can_undo_number_wall_randomization());
    assert_eq!(undo.snapshot().revision(), immediate.revision());
    bridge.shutdown().unwrap();
    assert_eq!(snap.morph_progress(), 1.0);
    assert_eq!(initial.module_id(), "mandelbrot");
    assert!(bridge.snapshot().is_err());
}

#[test]
fn explicit_animation_replacement_and_typed_start_preserve_detached_metadata() {
    let s = session();
    let id = s.snapshot().unwrap().session_id();
    let before = s
        .apply_batch_with_module_animation(id, 0, vec![select("julia")], false)
        .unwrap();
    assert!(!before.is_morphing());
    let before = s
        .apply_batch_with_module_animation(id, before.revision(), vec![select("mandelbrot")], true)
        .unwrap();
    let old = before.morph_timeline_token().unwrap();
    let next = s
        .apply_batch_with_module_animation(id, before.revision(), vec![select("julia")], true)
        .unwrap();
    let token = next.morph_timeline_token().unwrap();
    assert_eq!(
        s.cancel_morph_timeline(id, next.revision(), &old)
            .unwrap()
            .revision(),
        next.revision()
    );
    let mut target = next.params();
    let float_id = target
        .iter()
        .find(|(_, value)| value.number().is_some_and(|n| n.contains('.')))
        .map(|(id, _)| id.clone())
        .unwrap();
    let number = target[&float_id].number().unwrap();
    target.insert(
        float_id.clone(),
        fractal_bridge::api::StateValue::from_float(number.parse().unwrap()),
    );
    let start = s.start_param_timeline(id, next.revision(), target).unwrap();
    let mut invalid = next.params();
    invalid.insert(
        float_id.clone(),
        fractal_bridge::api::StateValue::from_float(f64::NAN),
    );
    assert!(
        s.start_param_timeline(id, start.snapshot().revision(), invalid)
            .is_err()
    );
    assert!(
        s.start_param_timeline(id, start.snapshot().revision(), HashMap::new())
            .is_err()
    );
    let tick = s
        .tick_param_timeline(id, start.snapshot().revision(), &start.token())
        .unwrap();
    assert_eq!(tick.revision(), start.snapshot().revision() + 1);
    assert_eq!(tick.params()[&float_id].number(), Some(number));
    let same = s
        .apply_batch_with_module_animation(id, tick.revision(), vec![select("julia")], false)
        .unwrap();
    assert!(same.is_morphing());
    let done = s
        .cancel_morph_timeline(id, same.revision(), &token)
        .unwrap();
    assert!(!done.is_morphing());
    assert_eq!(
        s.cancel_morph_timeline(id, done.revision(), &token)
            .unwrap()
            .revision(),
        done.revision()
    );
    assert!(before.is_morphing());
    assert_eq!(before.previous_module_id().as_deref(), Some("julia"));
}
