use fractal_core::{
    catalog_baseline::{Parameter, ParameterKind, ParameterValue},
    param_interpolation::interpolate_parameters,
};
use serde_json::{Value, json};
use std::{collections::BTreeMap, fs, path::Path};

type Params = BTreeMap<String, ParameterValue>;

fn oracle() -> Value {
    serde_json::from_str(
        &fs::read_to_string(
            Path::new(env!("CARGO_MANIFEST_DIR"))
                .join("../../../migration/oracles/param-interpolation.json"),
        )
        .unwrap(),
    )
    .unwrap()
}

fn params(value: &Value) -> Params {
    serde_json::from_value(value.clone()).unwrap()
}

fn compare_steps(schema: &[Parameter], from: &Params, target: &Params, outputs: &Value) {
    for output in outputs.as_array().unwrap() {
        let step = output["step"].as_u64().unwrap() as u32;
        let actual = interpolate_parameters(schema, from, target, step);
        let expected = params(&output["params"]);
        assert_eq!(
            actual.keys().collect::<Vec<_>>(),
            expected.keys().collect::<Vec<_>>()
        );
        for (id, expected) in &expected {
            let actual = &actual[id];
            let float = schema
                .iter()
                .any(|p| p.id == *id && p.kind == ParameterKind::Float);
            if float && (1..36).contains(&step) {
                let (ParameterValue::Number(a), ParameterValue::Number(b)) = (actual, expected)
                else {
                    panic!("non-numeric float {id}");
                };
                assert!(
                    (a.as_f64().unwrap() - b.as_f64().unwrap()).abs() <= 1e-12,
                    "step {step}/{id}: {a} != {b}"
                );
            } else {
                assert_eq!(actual, expected, "step {step}/{id}");
            }
        }
    }
    for step in [36, 37, u32::MAX] {
        assert_eq!(interpolate_parameters(schema, from, target, step), *target);
    }
}

#[test]
fn full_fake_time_dart_oracle_matches_at_the_public_kernel_seam() {
    let oracle = oracle();
    assert_eq!(oracle["steps"], 36);
    assert_eq!(oracle["scheduledTickMilliseconds"], 16);
    for case in oracle["cases"].as_array().unwrap() {
        let schema: Vec<Parameter> = serde_json::from_value(case["schema"].clone()).unwrap();
        assert_eq!(case["expected"].as_array().unwrap().len(), 37);
        compare_steps(
            &schema,
            &params(&case["from"]),
            &params(&case["target"]),
            &case["expected"],
        );
    }
    // A replacement begins from the partially interpolated live state, not the
    // original starting map. Timer cancellation itself remains a Dart concern.
    let replacement = oracle["cancellations"]
        .as_array()
        .unwrap()
        .iter()
        .find(|c| c["action"] == "replace")
        .unwrap();
    let schema: Vec<Parameter> = serde_json::from_value(replacement["schema"].clone()).unwrap();
    compare_steps(
        &schema,
        &params(&replacement["from"]),
        &params(&replacement["target"]),
        &replacement["expected"],
    );
}

#[test]
fn non_randomizable_boundary_inputs_keep_source_policies() {
    let oracle = oracle();
    let schema: Vec<Parameter> =
        serde_json::from_value(oracle["cases"][1]["schema"].clone()).unwrap();
    let from = params(&json!({
        "positive": 1, "negative": -1, "fraction": 4.0,
        "colorScheme": 17, "colorCycleSpeed": 0.625,
        "decimal": "900719925474099312345678901234567891",
        "enumNumber": 2.5, "boolean": true, "extraFrom": "retained only at zero"
    }));
    let target = params(&json!({
        "positive": 5, "negative": -5,
        "colorScheme": 18, "colorCycleSpeed": 1.25,
        "decimal": "900719925474099312345678901234567892",
        "enumNumber": 1, "boolean": false, "extraTarget": "assigned only at end"
    }));
    assert_eq!(interpolate_parameters(&schema, &from, &target, 0), from);
    let mid = interpolate_parameters(&schema, &from, &target, 18);
    for (id, expected) in [
        ("positive", json!(5)),
        ("negative", json!(-5)),
        ("fraction", json!(-0.484375)), // Missing target uses default -1.125.
        ("colorScheme", json!(17)),
        ("colorCycleSpeed", json!(0.625)),
        ("decimal", json!("900719925474099312345678901234567891")),
        ("enumNumber", json!(2.5)),
        ("boolean", json!(true)),
    ] {
        assert_eq!(
            mid[id],
            serde_json::from_value::<ParameterValue>(expected).unwrap(),
            "{id}"
        );
    }
    assert!(!mid.contains_key("extraFrom"));
    for step in [36, 100] {
        assert_eq!(
            interpolate_parameters(&schema, &from, &target, step),
            target
        );
    }
    let invalid = params(&json!({"fraction": "not a number", "positive": 100}));
    let mid = interpolate_parameters(&schema, &invalid, &invalid, 1);
    assert_eq!(mid["fraction"], invalid["fraction"]);
    assert_eq!(
        mid["positive"],
        serde_json::from_value::<ParameterValue>(json!(5)).unwrap()
    );
}
