use fractal_core::{
    catalog_baseline::{Parameter, ParameterValue},
    param_randomization::{general_targets, number_wall_targets},
    seeded_random::SeededRandom,
};
use serde_json::{Value, json};
use std::collections::BTreeMap;

type Params = BTreeMap<String, ParameterValue>;

fn oracle() -> Value {
    serde_json::from_str(include_str!(
        "../../../../migration/oracles/randomization.json"
    ))
    .unwrap()
}

// Oracle schemas deliberately omit presentation metadata. Do not register them.
fn schema(oracle: &Value, module: &str) -> Vec<Parameter> {
    oracle["schemas"][module]
        .as_array()
        .unwrap()
        .iter()
        .enumerate()
        .map(|(order, input)| {
            let mut input = input.clone();
            input["order"] = json!(order);
            input["control"] = Value::Null;
            input["resolved_control"] = json!("slider");
            input["label_en"] = json!("");
            for option in input["options"].as_array_mut().unwrap() {
                option["label_en"] = json!("");
            }
            serde_json::from_value(input).unwrap()
        })
        .collect()
}

fn params(value: &Value) -> Params {
    serde_json::from_value(value.clone()).unwrap()
}

fn assert_params(actual: Params, snapshot: &Value, id: &Value) {
    assert_eq!(actual, params(&snapshot["params"]), "{id}");
    for (key, value) in actual {
        let kind = match value {
            ParameterValue::Boolean(_) => "bool",
            ParameterValue::Text(_) => "String",
            ParameterValue::Number(n) if n.is_f64() => "double",
            ParameterValue::Number(_) => "int",
        };
        assert_eq!(kind, snapshot["paramKinds"][&key], "{id}/{key}");
    }
}

fn replay_draws(random: &mut SeededRandom, draws: &Value) {
    for (order, draw) in draws.as_array().unwrap().iter().enumerate() {
        assert_eq!(draw["order"], order);
        let actual = match draw["method"].as_str().unwrap() {
            "nextInt" => json!(random.next_int(draw["bound"].as_i64().unwrap()).unwrap()),
            "nextDouble" => json!(random.next_double()),
            "nextBool" => json!(random.next_bool()),
            method => panic!("unknown draw: {method}"),
        };
        assert_eq!(actual, draw["value"], "{draw}");
    }
}

#[test]
fn pinned_vm_draws_match_every_oracle_transcript() {
    let oracle = oracle();
    for case in oracle["general"].as_array().unwrap() {
        let mut random = SeededRandom::new(case["input"]["seed"].as_i64().unwrap());
        replay_draws(&mut random, &case["expected"]["draws"]);
    }
    for case in oracle["numberWalls"].as_array().unwrap() {
        let seed = case["input"]["seed"].as_i64().unwrap() & 0x7fffffff;
        replay_draws(
            &mut SeededRandom::new(seed),
            &case["expected"]["explanatoryTranscript"]["draws"],
        );
    }
}

#[test]
fn next_int_validates_bounds_without_drawing() {
    let mut random = SeededRandom::new(42);
    let mut unchanged = random.clone();
    for bound in [i64::MIN, -1, 0, (1_i64 << 32) + 1, i64::MAX] {
        assert!(random.next_int(bound).is_err());
    }
    assert_eq!(random.next_double(), unchanged.next_double());
    assert_eq!(random.next_int(1).unwrap(), 0);
    assert!(random.next_int(1_i64 << 32).unwrap() < 1_i64 << 32);

    // Additional direct Dart VM 3.13.7 draws: signed seed extremes, maximum
    // bounds, and repeated >2^31 bounds that exercise rejection (not modulo).
    for (seed, expected, double, boolean) in [
        (
            i64::MIN,
            [
                0, 508709504, 1579164249, 2132682595, 495945979, 1745035409, 266950036,
            ],
            0.18020005130222494,
            false,
        ),
        (
            i64::MAX,
            [
                0, 582864159, 1436238347, 2130634896, 900376831, 2140341382, 3115545570,
            ],
            0.34209598376486383,
            true,
        ),
        (
            42,
            [
                0, 523363758, 376088004, 1319473077, 40243304, 283265935, 3505223485,
            ],
            0.7904403321523352,
            false,
        ),
    ] {
        let mut random = SeededRandom::new(seed);
        for (bound, expected) in [
            1, 4294967296, 2147483649, 2147483649, 2147483649, 2147483649, 4294967295,
        ]
        .into_iter()
        .zip(expected)
        {
            assert_eq!(random.next_int(bound).unwrap(), expected, "{seed}/{bound}");
        }
        assert_eq!(random.next_double(), double);
        assert_eq!(random.next_bool(), boolean);
    }
}

#[test]
fn ordered_general_targets_match_all_18_cases_without_extra_draws() {
    let oracle = oracle();
    let cases = oracle["general"].as_array().unwrap();
    assert_eq!(cases.len(), 18);
    for case in cases {
        let schema = schema(&oracle, case["input"]["module"].as_str().unwrap());
        let seed = case["input"]["seed"].as_i64().unwrap();
        let mut random = SeededRandom::new(seed);
        let actual = general_targets(
            &schema,
            &params(&case["expected"]["before"]["params"]),
            &mut random,
        )
        .unwrap();
        assert_params(actual, &case["expected"]["after"], &case["id"]);
        let mut transcript = SeededRandom::new(seed);
        replay_draws(&mut transcript, &case["expected"]["draws"]);
        assert_eq!(
            random.next_double(),
            transcript.next_double(),
            "{}",
            case["id"]
        );
    }
}

#[test]
fn stepped_float_targets_use_dart_six_decimal_ties_and_normalization() {
    let oracle = oracle();
    let mut schema = schema(&oracle, "randomization_oracle_schema");
    let param = schema.iter_mut().find(|p| p.id == "fraction").unwrap();
    // Exact binary half ties use away-from-zero decimal rounding, not Rust's
    // formatter's ties-to-even. No added synthetic production module.
    for (min, max, step, expected) in [
        (0.006, 0.010, 0.0078125, 0.007813),
        (-0.010, -0.006, 0.0078125, -0.007813),
        (
            5000000000.007,
            5000000000.009,
            0.0078125,
            5_000_000_000.007_813,
        ),
        (
            -5000000000.009,
            -5000000000.007,
            0.0078125,
            -5_000_000_000.007_813,
        ),
        (0.0000004, 0.0000006, 0.0000005, 0.0000004),
        (-0.0000006, -0.0000004, 0.0000005, -0.0000004),
        (1.2, 1.3, 1.0, 1.2),
    ] {
        param.min = serde_json::from_value(json!(min)).unwrap();
        param.max = serde_json::from_value(json!(max)).unwrap();
        param.step = serde_json::from_value(json!(step)).unwrap();
        let actual = general_targets(
            std::slice::from_ref(param),
            &Params::new(),
            &mut SeededRandom::new(42),
        )
        .unwrap();
        assert_eq!(
            actual["fraction"],
            serde_json::from_value(json!(expected)).unwrap()
        );
    }
}

#[test]
fn integer_target_bounds_reject_unsupported_spans_before_a_draw() {
    let oracle = oracle();
    let mut schema = schema(&oracle, "mandelbrot");
    let param = &mut schema[0];
    let mut random = SeededRandom::new(42);
    let mut unchanged = random.clone();
    for (min, max) in [(0.0, 4294967296.0), (-1e20, 0.0), (0.0, 1e20)] {
        param.min = serde_json::from_value(json!(min)).unwrap();
        param.max = serde_json::from_value(json!(max)).unwrap();
        assert!(general_targets(std::slice::from_ref(param), &Params::new(), &mut random).is_err());
    }
    assert_eq!(random.next_double(), unchanged.next_double());
}

#[test]
fn wall_targets_match_all_15_masked_seed_and_prime_opt_in_cases() {
    let oracle = oracle();
    let schema = schema(&oracle, "number_wall");
    let cases = oracle["numberWalls"].as_array().unwrap();
    assert_eq!(cases.len(), 15);
    for case in cases {
        let actual = number_wall_targets(
            &schema,
            &params(&case["expected"]["before"]["params"]),
            case["input"]["seed"].as_i64().unwrap(),
        )
        .unwrap();
        assert_params(actual, &case["expected"]["randomized"], &case["id"]);
    }
}
