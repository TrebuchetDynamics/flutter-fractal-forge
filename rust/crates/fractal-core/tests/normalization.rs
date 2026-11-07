use fractal_core::{
    catalog_baseline::{CatalogBaseline, Parameter, ParameterValue},
    normalization::{RawScalar, ViewInput, normalize_parameter, normalize_view},
};
use serde_json::{Value, json};
use std::{fs, path::Path};

fn baseline(name: &str) -> String {
    fs::read_to_string(
        Path::new(env!("CARGO_MANIFEST_DIR"))
            .join("../../../migration/baseline")
            .join(format!("{name}.json")),
    )
    .unwrap()
}

fn catalog() -> CatalogBaseline {
    CatalogBaseline::from_jsons(
        &baseline("modules"),
        &baseline("parameters"),
        &baseline("presets"),
        &baseline("capabilities"),
    )
    .unwrap()
}

fn parameter<'a>(catalog: &'a CatalogBaseline, module: &str, id: &str) -> &'a Parameter {
    catalog
        .parameters()
        .payload
        .records
        .iter()
        .find(|r| r.module_id.as_str() == module)
        .unwrap()
        .parameters
        .iter()
        .find(|p| p.id == id)
        .unwrap()
}

fn value(value: Value) -> ParameterValue {
    serde_json::from_value(value).unwrap()
}

fn raw(input: &Value) -> RawScalar {
    match input.get("nonfinite").and_then(Value::as_str) {
        Some("nan") => RawScalar::Float(f64::NAN),
        Some("+infinity") => RawScalar::Float(f64::INFINITY),
        Some("-infinity") => RawScalar::Float(f64::NEG_INFINITY),
        Some(other) => panic!("unknown nonfinite: {other}"),
        None => value(input.clone()).into(),
    }
}

#[test]
fn numeric_parameters_clamp_round_and_default_like_dart() {
    let catalog = catalog();
    let integer = parameter(&catalog, "mandelbrot", "iterations");
    let float = parameter(&catalog, "mandelbrot", "bailout");
    for (schema, input, expected) in [
        (integer, 19.0, json!(20)),
        (integer, 350.49, json!(350)),
        (integer, 350.5, json!(351)),
        (integer, 501.0, json!(500)),
        (float, 1.0, json!(2.0)),
        (float, 4.55, json!(4.55)),
    ] {
        assert_eq!(
            normalize_parameter(schema, &RawScalar::Float(input)),
            value(expected)
        );
    }
    let zero_bounded = parameter(&catalog, "recursive_sine_sphere", "strength");
    assert_eq!(
        normalize_parameter(zero_bounded, &RawScalar::Float(-0.0)),
        value(json!(0.0))
    );
    for schema in [integer, float] {
        for input in [json!(true), json!("351")] {
            assert_eq!(normalize_parameter(schema, &raw(&input)), schema.default);
        }
    }
    // Original replay values, not the misleading infinity max/min labels.
    let replay: Value = serde_json::from_str(&baseline("state-replay")).unwrap();
    for i in 7..=13 {
        let input = &replay["inputs"][i];
        let id = input["id"].as_str().unwrap();
        assert_eq!(
            normalize_parameter(parameter(&catalog, "mandelbrot", id), &raw(&input["value"])),
            value(replay["expected"][i]["history"]["params"][id].clone())
        );
    }
    // Exercise the same scalar policy with negative/fractional and invalid bounds.
    let mut schema: Parameter =
        serde_json::from_value(serde_json::to_value(integer).unwrap()).unwrap();
    schema.min = serde_json::from_value(json!(-3.8)).unwrap();
    schema.max = serde_json::from_value(json!(3.8)).unwrap();
    assert_eq!(
        normalize_parameter(&schema, &RawScalar::Float(-2.5)),
        value(json!(-3))
    );
    assert_eq!(
        normalize_parameter(&schema, &RawScalar::Float(-4.0)),
        value(json!(-3))
    );
    for (min, max) in [(2.1, 2.9), (5.0, 2.0)] {
        schema.min = serde_json::from_value(json!(min)).unwrap();
        schema.max = serde_json::from_value(json!(max)).unwrap();
        assert_eq!(
            normalize_parameter(&schema, &RawScalar::Float(2.5)),
            schema.default
        );
    }
}

#[test]
fn enums_accept_equal_numbers_but_keep_text_distinct() {
    let catalog = catalog();
    let numeric = parameter(&catalog, "mandelbrot", "colorScheme");
    for input in [json!(1), json!(1.0)] {
        assert_eq!(normalize_parameter(numeric, &raw(&input)), value(input));
    }
    assert_eq!(
        normalize_parameter(numeric, &RawScalar::Float(1.0)),
        value(json!(1.0))
    );
    for input in [json!("1"), json!(true), json!(999), json!(1.5)] {
        assert_eq!(normalize_parameter(numeric, &raw(&input)), numeric.default);
    }
    for input in [f64::NAN, f64::INFINITY, f64::NEG_INFINITY] {
        assert_eq!(
            normalize_parameter(numeric, &RawScalar::Float(input)),
            numeric.default
        );
    }
    let textual = parameter(&catalog, "number_wall", "source");
    assert_eq!(
        normalize_parameter(textual, &raw(&json!("rook"))),
        value(json!("rook"))
    );
    assert_eq!(
        normalize_parameter(textual, &raw(&json!(1))),
        textual.default
    );

    // Mixed numeric equality must not merge adjacent integers above binary64 precision.
    let mut schema: Parameter =
        serde_json::from_value(serde_json::to_value(numeric).unwrap()).unwrap();
    schema.options[0].value = value(json!(9007199254740993_u64));
    assert_eq!(
        normalize_parameter(&schema, &raw(&json!(9007199254740993_u64))),
        value(json!(9007199254740993_u64))
    );
    assert_eq!(
        normalize_parameter(&schema, &RawScalar::Float(9007199254740992.0)),
        schema.default
    );
    schema.options[0].value = value(json!(1.0));
    assert_eq!(
        normalize_parameter(&schema, &raw(&json!(1))),
        value(json!(1))
    );
}

#[test]
fn booleans_require_real_booleans() {
    let catalog = catalog();
    let schema = parameter(&catalog, "recursive_sine_sphere", "animate");
    for input in [json!(true), json!(false)] {
        assert_eq!(normalize_parameter(schema, &raw(&input)), value(input));
    }
    for input in [json!(1), json!(0), json!("true")] {
        assert_eq!(normalize_parameter(schema, &raw(&input)), schema.default);
    }
    let mut schema: Parameter =
        serde_json::from_value(serde_json::to_value(schema).unwrap()).unwrap();
    schema.default = value(json!(true));
    assert_eq!(
        normalize_parameter(&schema, &raw(&json!(1))),
        value(json!(true))
    );
}

#[test]
fn canonical_decimal_text_is_preserved_without_prime_certification() {
    let catalog = catalog();
    let schema = parameter(&catalog, "number_wall", "prime");
    for text in ["0", "1", "4", "900719925474099312345678901234567890"] {
        assert_eq!(
            normalize_parameter(schema, &raw(&json!(text))),
            value(json!(text))
        );
    }
    for input in [
        json!(""),
        json!("01"),
        json!("+2"),
        json!("-2"),
        json!("2.0"),
        json!("2e0"),
        json!(" 2"),
        json!("2\n"),
        json!("２"),
        json!(2),
        json!(false),
    ] {
        assert_eq!(normalize_parameter(schema, &raw(&input)), schema.default);
    }
}

fn number(value: &Value) -> f64 {
    match raw(value) {
        RawScalar::Number(n) => n.as_f64().unwrap(),
        RawScalar::Float(n) => n,
        _ => panic!("not a number"),
    }
}

fn view(value: &Value) -> ViewInput {
    ViewInput {
        zoom: number(&value["zoom"]),
        pan: [number(&value["panX"]), number(&value["panY"])],
        rotation: [
            number(&value["rotX"]),
            number(&value["rotY"]),
            number(&value["rotZ"]),
        ],
    }
}

#[test]
fn scalar_views_match_original_events_and_sanitize_bad_prior_values() {
    let replay: Value = serde_json::from_str(&baseline("state-replay")).unwrap();
    for i in [
        1, 2, 17, 18, 19, 20, 21, 22, 23, 24, 34, 35, 36, 37, 38, 39, 40, 41,
    ] {
        let input = &replay["inputs"][i];
        let previous = &replay["expected"][i - 1]["history"];
        let current = view(&previous["view"]);
        let mut candidate = current;
        match input["op"].as_str().unwrap() {
            "zoom" => candidate.zoom = number(&input["value"]),
            "pan" => candidate.pan = [number(&input["value"][0]), number(&input["value"][1])],
            "rotation" => candidate.rotation = std::array::from_fn(|j| number(&input["value"][j])),
            "view" => candidate = view(&input["value"]),
            "preset" | "load" => candidate = view(&input["view"]),
            other => panic!("unselected scalar operation: {other}"),
        }
        let actual = normalize_view(candidate, current, previous["moduleId"].as_str().unwrap());
        let expected = view(&replay["expected"][i]["history"]["view"]);
        assert_eq!(actual.zoom(), expected.zoom, "event {i}");
        assert_eq!(actual.pan(), expected.pan, "event {i}");
        assert_eq!(actual.rotation(), expected.rotation, "event {i}");
    }
    for (module, minimum) in [("mandelbrot", 1e-9), ("cantor_set", 0.2)] {
        let bad = ViewInput {
            zoom: f64::NAN,
            pan: [f64::NAN, f64::NAN],
            rotation: [f64::NAN; 3],
        };
        let actual = normalize_view(bad, bad, module);
        assert_eq!(actual.zoom(), minimum);
        assert_eq!(actual.pan(), [0.0; 2]);
        assert_eq!(actual.rotation(), [0.0; 3]);
        let prior = ViewInput {
            zoom: f64::INFINITY,
            pan: [f64::NEG_INFINITY, f64::INFINITY],
            rotation: [f64::NEG_INFINITY, 0.7, f64::INFINITY],
        };
        let actual = normalize_view(bad, prior, module);
        assert_eq!(actual.zoom(), 1e12);
        assert_eq!(actual.pan(), [-3.0, 3.0]);
        assert_eq!(actual.rotation(), [0.0, 0.7, 0.0]);
    }
}
