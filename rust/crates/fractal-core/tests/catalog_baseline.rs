use fractal_core::catalog_baseline::{
    CatalogBaseline, CatalogError, ParameterKind, ParameterValue,
};
use serde_json::{Value, json};
use std::{fs, path::Path};

fn originals() -> [Value; 4] {
    let root = Path::new(env!("CARGO_MANIFEST_DIR")).join("../../../migration/baseline");
    ["modules", "parameters", "presets", "capabilities"].map(|kind| {
        serde_json::from_str(&fs::read_to_string(root.join(format!("{kind}.json"))).unwrap())
            .unwrap()
    })
}

fn load(values: &[Value; 4]) -> Result<CatalogBaseline, CatalogError> {
    let texts = values.each_ref().map(Value::to_string);
    CatalogBaseline::from_jsons(&texts[0], &texts[1], &texts[2], &texts[3])
}

fn readback(catalog: &CatalogBaseline) -> [Value; 4] {
    [
        serde_json::to_value(catalog.modules()).unwrap(),
        serde_json::to_value(catalog.parameters()).unwrap(),
        serde_json::to_value(catalog.presets()).unwrap(),
        serde_json::to_value(catalog.capabilities()).unwrap(),
    ]
}

#[test]
fn original_envelopes_round_trip_through_typed_records() {
    let original = originals();
    let catalog = load(&original).unwrap();
    // Compare the complete envelopes, not a projection or fixed catalog count.
    assert_eq!(readback(&catalog), original);
    for (module, raw) in catalog
        .modules()
        .payload
        .records
        .iter()
        .zip(original[0]["payload"]["records"].as_array().unwrap())
    {
        assert_eq!(module.id.as_str(), raw["id"].as_str().unwrap());
        for (entry, raw_entry) in module
            .catalog
            .iter()
            .zip(raw["catalog"].as_array().unwrap())
        {
            assert_eq!(entry.id.as_str(), raw_entry["id"].as_str().unwrap());
        }
    }
    for record in &catalog.parameters().payload.records {
        for parameter in &record.parameters {
            match (&parameter.kind, &parameter.default) {
                (ParameterKind::DecimalInteger, ParameterValue::Text(text)) => {
                    assert_eq!(text, "2")
                }
                (ParameterKind::Enumeration, ParameterValue::Text(_))
                | (ParameterKind::Boolean, ParameterValue::Boolean(_))
                | (
                    ParameterKind::Integer | ParameterKind::Float | ParameterKind::Enumeration,
                    ParameterValue::Number(_),
                ) => {}
                other => panic!("unexpected typed parameter: {other:?}"),
            }
        }
    }
}

#[test]
fn invalid_envelopes_fail_atomically_at_the_reader() {
    let original = originals();
    assert!(matches!(
        CatalogBaseline::from_jsons("{", "{}", "{}", "{}"),
        Err(CatalogError::Json { .. })
    ));
    for index in 0..4 {
        for (field, value) in [("schema", json!(2)), ("kind", json!("wrong"))] {
            let mut altered = original.clone();
            altered[index][field] = value;
            assert!(load(&altered).is_err(), "accepted {index}/{field}");
        }
    }
    let cases = [
        (
            0,
            "/payload/records/1/id",
            original[0]["payload"]["records"][0]["id"].clone(),
        ),
        (
            0,
            "/payload/records/1/catalog/0/id",
            original[0]["payload"]["records"][0]["catalog"][0]["id"].clone(),
        ),
        (
            1,
            "/payload/records/0/parameters/1/id",
            original[1]["payload"]["records"][0]["parameters"][0]["id"].clone(),
        ),
        (
            2,
            "/payload/records/0/built_in/1/id",
            original[2]["payload"]["records"][0]["built_in"][0]["id"].clone(),
        ),
        (
            2,
            "/payload/records/1/default/id",
            original[2]["payload"]["records"][0]["default"]["id"].clone(),
        ),
        (0, "/payload/records/0/dimension", json!("fourD")),
        (1, "/payload/records/0/parameters/0/type", json!("unknown")),
        (1, "/payload/records/0/parameters/0/default", json!([])),
        (1, "/payload/records/0/parameters/0/default", json!(true)),
        (
            1,
            "/payload/records/0/parameters/2/default",
            json!("unknown"),
        ),
        (
            2,
            "/payload/records/0/default/moduleId",
            json!("missing-module"),
        ),
        (3, "/payload/records/0/native_cpu", json!("certified")),
    ];
    for (index, pointer, value) in cases {
        let mut altered = original.clone();
        *altered[index].pointer_mut(pointer).unwrap() = value;
        assert!(load(&altered).is_err(), "accepted {index}{pointer}");
    }
    for index in 1..4 {
        for replacement in [
            json!("missing-module"),
            original[index]["payload"]["records"][0]["module_id"].clone(),
        ] {
            let mut altered = original.clone();
            altered[index]["payload"]["records"][1]["module_id"] = replacement;
            assert!(
                load(&altered).is_err(),
                "accepted reference/duplicate in {index}"
            );
        }
        let mut altered = original.clone();
        altered[index]["payload"]["records"]
            .as_array_mut()
            .unwrap()
            .pop();
        assert!(
            load(&altered).is_err(),
            "accepted incomplete envelope {index}"
        );
    }
    let mut altered = original.clone();
    altered[0]["payload"]["records"]
        .as_array_mut()
        .unwrap()
        .remove(0);
    assert!(load(&altered).is_err(), "accepted removed module");
    let alias_record = original[2]["payload"]["records"]
        .as_array()
        .unwrap()
        .iter()
        .position(|record| {
            record["built_in"]
                .as_array()
                .unwrap()
                .iter()
                .any(|preset| preset["id"] == record["default"]["id"])
        })
        .unwrap();
    let mut altered = original.clone();
    altered[2]["payload"]["records"][alias_record]["default"]["name"] =
        json!("Conflicting definition");
    assert!(matches!(
        load(&altered),
        Err(CatalogError::Duplicate { kind: "preset", .. })
    ));

    // Keep these inputs raw: parsing the marker into Value first can hide the corruption.
    let texts = original.each_ref().map(Value::to_string);
    let marker = r#"{"$serde_json::private::Number":"123"}"#;
    let number_field = format!(
        "\"horizontal_orbit_sign\":{}",
        original[0]["payload"]["records"][0]["horizontal_orbit_sign"]
    );
    for (needle, replacement) in [
        (
            number_field.as_str(),
            format!("\"horizontal_orbit_sign\":{marker}"),
        ),
        (
            "\"display_name_en\":",
            format!("\"future_presentation\":{marker},\"display_name_en\":"),
        ),
    ] {
        let malformed = texts[0].replacen(needle, &replacement, 1);
        assert_ne!(malformed, texts[0]);
        assert!(CatalogBaseline::from_jsons(&malformed, &texts[1], &texts[2], &texts[3]).is_err());
    }
    for (index, pointer, field) in [
        (0, "/payload/records/0", "registry_order"),
        (0, "/payload/records/0/catalog/0", "order"),
        (1, "/payload/records/0/parameters/0", "default"),
        (1, "/payload/records/0/parameters/0", "control"),
        (2, "/payload/records/0/default", "thumbnailPath"),
        (3, "/payload/records/0/precision_samples/0", "shader_asset"),
    ] {
        let mut altered = original.clone();
        altered[index]
            .pointer_mut(pointer)
            .unwrap()
            .as_object_mut()
            .unwrap()
            .remove(field);
        assert!(
            load(&altered).is_err(),
            "accepted missing {pointer}/{field}"
        );
    }
}

#[test]
fn mutations_cannot_hide_behind_parity_or_binary64_conversion() {
    let original = originals();
    let decimal_record = original[1]["payload"]["records"]
        .as_array()
        .unwrap()
        .iter()
        .position(|r| {
            r["parameters"]
                .as_array()
                .unwrap()
                .iter()
                .any(|p| p["type"] == "decimalInteger")
        })
        .unwrap();
    let decimal_parameter = original[1]["payload"]["records"][decimal_record]["parameters"]
        .as_array()
        .unwrap()
        .iter()
        .position(|p| p["type"] == "decimalInteger")
        .unwrap();
    let decimal_path =
        format!("/payload/records/{decimal_record}/parameters/{decimal_parameter}/default");
    let huge = "900719925474099312345678901234567890";
    for (index, pointer, value) in [
        (
            0,
            "/payload/records/0/display_name_en",
            json!("Changed presentation"),
        ),
        (1, "/payload/records/0/parameters/2/default", json!(0)),
        (1, decimal_path.as_str(), json!(huge)),
        (
            1,
            "/payload/records/0/parameters/0/default",
            serde_json::from_str::<Value>(huge).unwrap(),
        ),
    ] {
        let mut altered = original.clone();
        *altered[index].pointer_mut(pointer).unwrap() = value;
        let catalog = load(&altered).unwrap();
        let result = readback(&catalog);
        if pointer == decimal_path {
            assert_eq!(
                catalog.parameters().payload.records[decimal_record].parameters[decimal_parameter]
                    .default,
                ParameterValue::Text(huge.to_owned())
            );
        }
        assert_eq!(result, altered);
        assert_ne!(result[index]["payload"], original[index]["payload"]);
    }
    for value in [json!("1e20"), json!(2)] {
        let mut altered = original.clone();
        *altered[1].pointer_mut(&decimal_path).unwrap() = value;
        assert!(load(&altered).is_err(), "accepted non-decimal string/type");
    }
    let mut extended = original;
    extended[0]["payload"]["records"][0]["registry_order"] = Value::Null;
    extended[0]["payload"]["records"][0]["catalog"][0]["order"] = Value::Null;
    extended[2]["payload"]["records"][0]["default"]["order"] = Value::Null;
    extended[0]["payload"]["records"][0]["future_presentation"] = json!({"literal": "Do not localize IDs", "integer": serde_json::from_str::<Value>(huge).unwrap()});
    let catalog = load(&extended).unwrap();
    assert!(
        catalog.modules().payload.records[0]
            .registry_order
            .is_none()
    );
    assert!(
        catalog.modules().payload.records[0].catalog[0]
            .order
            .is_none()
    );
    assert_eq!(readback(&catalog), extended);
}
