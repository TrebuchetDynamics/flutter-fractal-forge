use fractal_core::number_wall_prime::{
    DEFAULT_MAX_TRIAL_DIVISIONS, NumberWallPrimeCheck, NumberWallPrimeJob,
    NumberWallPrimeStatus::{self, *},
};
use serde_json::Value;
use std::{fs, path::Path, sync::atomic::AtomicBool};

fn finish(input: &str, budget: u32, inspect_chunks: bool) -> NumberWallPrimeCheck {
    let mut job = NumberWallPrimeJob::new(input, budget);
    let cancel = AtomicBool::new(false);
    loop {
        let before = job.divisions();
        job.advance(&cancel);
        if inspect_chunks {
            assert!(job.divisions() - before <= 1024);
        }
        if let Some(result) = job.result() {
            let result = result.clone();
            // Completion cannot be revoked by later cancellation or advances.
            assert_eq!(job.advance(&AtomicBool::new(true)), Some(&result));
            return result;
        }
    }
}

fn check(input: &str, budget: u32, status: NumberWallPrimeStatus, prime: Option<&str>, count: u32) {
    let complete = finish(input, budget, false);
    assert_eq!(complete, finish(input, budget, true), "{input}");
    assert_eq!(complete.status(), status, "{input}");
    assert_eq!(complete.prime(), prime, "{input}");
    assert_eq!(complete.divisions(), count, "{input}");
    assert_eq!(complete.prime().is_some(), status == VerifiedPrime);
}

#[test]
fn raw_decimal_ingress_and_exact_certification_match_dart() {
    for input in [
        "", "0", "0001", "1", "-7", "+7", " 7", "7 ", "7\n", "7x", "1e2", "７", "٧",
    ] {
        check(input, DEFAULT_MAX_TRIAL_DIVISIONS, Invalid, None, 0);
    }
    for input in [
        "2", "3", "5", "7", "11", "13", "17", "19", "23", "29", "31", "37", "41", "43", "47", "53",
        "97",
    ] {
        check(input, 0, VerifiedPrime, Some(input), 0);
    }
    check("00097", 0, VerifiedPrime, Some("97"), 0);
    for input in ["4", "561", "1105", "1729", "9007199254740993"] {
        check(input, 0, Composite, None, 0);
    }
    check(&"9".repeat(256), 0, Composite, None, 0);
    check(&format!("1{}3", "0".repeat(254)), 1, Unverified, None, 1);
    check(&"9".repeat(257), 0, Invalid, None, 0);
    check(
        &format!("{}2", "0".repeat(255)),
        0,
        VerifiedPrime,
        Some("2"),
        0,
    );
    check(&format!("{}2", "0".repeat(256)), 0, Invalid, None, 0);
    let huge = "170141183460469231731687303715884105727";
    check(
        &format!("{}{huge}", "0".repeat(256 - huge.len())),
        1,
        Unverified,
        None,
        1,
    );
}

#[test]
fn original_replay_operands_are_certified_not_replayed_flags_or_last_good_text() {
    let replay: Value = serde_json::from_str(
        &fs::read_to_string(
            Path::new(env!("CARGO_MANIFEST_DIR"))
                .join("../../../migration/baseline/state-replay.json"),
        )
        .unwrap(),
    )
    .unwrap();
    // These are validator results, not the replay's retained committed prime/grid.
    for (event, status, prime, count) in [
        (47, VerifiedPrime, Some("97"), 0),
        (48, VerifiedPrime, Some("97"), 0),
        (49, VerifiedPrime, Some("97"), 0),
        (51, Composite, None, 0),
        (52, Unverified, None, 100000),
        (53, Composite, None, 0),
        (54, Invalid, None, 0),
        (55, VerifiedPrime, Some("101"), 0),
        (56, Invalid, None, 0),
        (57, VerifiedPrime, Some("100003"), 132),
        (58, VerifiedPrime, Some("103"), 0),
        (61, VerifiedPrime, Some("100003"), 132),
        (64, VerifiedPrime, Some("100003"), 132),
    ] {
        let input = &replay["inputs"][event];
        let text = input["params"]["prime"]
            .as_str()
            .or_else(|| input["value"].as_str())
            .unwrap();
        check(text, DEFAULT_MAX_TRIAL_DIVISIONS, status, prime, count);
    }
}

#[test]
fn root_budget_and_trial_counts_keep_source_precedence() {
    for (input, budget, status, prime, count) in [
        ("2801", 0, VerifiedPrime, Some("2801"), 0),
        ("2808", 0, Composite, None, 0),
        ("2809", 0, Unverified, None, 0),
        ("2809", 1, Composite, None, 1),
        ("2810", 1, Composite, None, 0),
        ("2819", 0, Unverified, None, 0),
        ("2819", 1, VerifiedPrime, Some("2819"), 1),
        ("3481", 3, Unverified, None, 3),
        ("3481", 4, Composite, None, 4),
        (
            "1000003",
            DEFAULT_MAX_TRIAL_DIVISIONS,
            VerifiedPrime,
            Some("1000003"),
            474,
        ),
        (
            "170141183460469231731687303715884105727",
            0,
            Unverified,
            None,
            0,
        ),
        (
            "170141183460469231731687303715884105727",
            1024,
            Unverified,
            None,
            1024,
        ),
    ] {
        check(input, budget, status, prime, count);
    }
}

#[test]
fn cancellation_before_screening_between_chunks_and_at_completion_is_terminal() {
    let cancelled = AtomicBool::new(true);
    for (input, status) in [
        ("bad", Invalid),
        ("1", Invalid),
        ("2", Cancelled),
        ("4", Cancelled),
    ] {
        let mut job = NumberWallPrimeJob::new(input, u32::MAX);
        let result = job.advance(&cancelled).unwrap();
        assert_eq!(
            (result.status(), result.prime(), result.divisions()),
            (status, None, 0)
        );
    }
    for (input, budget) in [
        ("170141183460469231731687303715884105727", u32::MAX),
        ("170141183460469231731687303715884105727", 1024),
        // Prime with floor(sqrt(n))=2099: exactly 1024 odd trials.
        ("4405829", 1024),
    ] {
        let mut job = NumberWallPrimeJob::new(input, budget);
        assert!(job.advance(&AtomicBool::new(false)).is_none());
        assert_eq!(job.divisions(), 1024);
        let result = job.advance(&cancelled).unwrap().clone();
        assert_eq!(
            (result.status(), result.prime(), result.divisions()),
            (Cancelled, None, 1024)
        );
        assert_eq!(job.advance(&AtomicBool::new(false)), Some(&result));
    }
    check("4405829", 1024, VerifiedPrime, Some("4405829"), 1024);
}
