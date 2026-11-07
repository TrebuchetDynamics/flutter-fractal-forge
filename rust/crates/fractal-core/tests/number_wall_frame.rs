use fractal_core::{
    catalog_baseline::ParameterValue as Value,
    number_wall_frame::{FramePhase, NumberWallFrame, NumberWallFrameJob, NumberWallFrameResult},
    number_wall_grid::{MAX_WORK_UNITS, NumberWallGrid, NumberWallSequence as Sequence},
    number_wall_prime::{DEFAULT_MAX_TRIAL_DIVISIONS, NumberWallPrimeStatus as Status},
};
use std::{collections::BTreeMap, sync::atomic::AtomicBool};

fn params() -> BTreeMap<String, Value> {
    BTreeMap::from([
        ("source".into(), Value::Text("signedPagoda".into())),
        ("rows".into(), Value::Number(4.into())),
        ("columns".into(), Value::Number(16.into())),
        ("columnStart".into(), Value::Number(3.into())),
        ("colorMode".into(), Value::Number(0.into())),
    ])
}

fn finish(mut job: NumberWallFrameJob, units: usize) -> NumberWallFrameResult {
    let flag = AtomicBool::new(false);
    for _ in 0..100_000 {
        job.advance(&flag, units);
        assert!(job.last_grid_work_units() <= units.min(MAX_WORK_UNITS));
        if let Some(result) = job.result() {
            let retained = result.clone();
            assert_eq!(job.advance(&AtomicBool::new(true), units), Some(&retained));
            return retained;
        }
    }
    panic!("frame job must terminate");
}

#[test]
fn untrusted_flags_and_decimal_syntax_never_publish_uncertified_frames() {
    let mut proposed = params();
    proposed.insert("primeVerified".into(), Value::Boolean(true));
    proposed.insert("status".into(), Value::Text("verifiedPrime".into()));
    // Even a pre-normalized/defaulted prime is not the raw candidate or a proof.
    proposed.insert("prime".into(), Value::Text("2".into()));
    for (raw, budget, status) in [
        ("bad", 0, Status::Invalid),
        ("+97", 0, Status::Invalid),
        ("561", 0, Status::Composite),
        (
            "170141183460469231731687303715884105727",
            1,
            Status::Unverified,
        ),
        ("00097", 0, Status::VerifiedPrime),
    ] {
        let result = finish(
            NumberWallFrameJob::new(raw, proposed.clone(), None, budget),
            7,
        );
        assert_eq!(
            result,
            NumberWallFrame::prepare(raw, proposed.clone(), None, budget, &AtomicBool::new(false))
        );
        assert_eq!(result.status(), status, "{raw}");
        assert_eq!(result.frame().is_some(), status == Status::VerifiedPrime);
        if let Some(frame) = result.frame() {
            assert_eq!(frame.params()["prime"], Value::Text("97".into()));
            assert_eq!(
                frame.grid().as_ref(),
                &NumberWallGrid::generate(Sequence::SignedPagoda, "97", 4, 3, 16).unwrap()
            );
        }
    }
}

#[test]
fn only_completed_canonical_proofs_and_matching_mathematics_reuse_owned_storage() {
    // Independent trial division: sqrt floor 200057, requiring 100003 odd trials.
    let prime = "40022803297";
    assert_eq!(
        finish(
            NumberWallFrameJob::new(prime, params(), None, DEFAULT_MAX_TRIAL_DIVISIONS),
            1024
        )
        .status(),
        Status::Unverified
    );
    let previous = finish(
        NumberWallFrameJob::new(prime, params(), None, 100_003),
        1024,
    );
    assert_eq!(
        previous,
        NumberWallFrame::prepare(prime, params(), None, 100_003, &AtomicBool::new(false))
    );
    let previous = previous.frame().unwrap();
    let retained = previous.clone();
    let mut style = params();
    style.insert("colorMode".into(), Value::Number(1.into()));
    let result = finish(
        NumberWallFrameJob::new(prime, style.clone(), Some(previous), 0),
        1,
    );
    let styled = result.frame().unwrap();
    assert!(std::sync::Arc::ptr_eq(previous.grid(), styled.grid()));
    assert_eq!(styled.params()["colorMode"], Value::Number(1.into()));
    assert_eq!(
        finish(
            NumberWallFrameJob::new(&format!("0{prime}"), style, Some(previous), 0),
            1
        )
        .status(),
        Status::Unverified
    );
    let revalidated = finish(
        NumberWallFrameJob::new(&format!("0{prime}"), params(), Some(previous), 100_003),
        1024,
    );
    assert!(std::sync::Arc::ptr_eq(
        previous.grid(),
        revalidated.frame().unwrap().grid()
    ));
    for (key, value) in [
        ("source", Value::Text("rook".into())),
        ("rows", Value::Number(3.into())),
        ("columns", Value::Number(17.into())),
        ("columnStart", Value::Number(5.into())),
        ("prime", Value::Text("101".into())),
    ] {
        let mut changed = params();
        changed.insert(key.into(), value);
        let raw = if key == "prime" { "101" } else { prime };
        let result = finish(
            NumberWallFrameJob::new(raw, changed.clone(), Some(previous), 0),
            17,
        );
        assert_eq!(
            result,
            NumberWallFrame::prepare(raw, changed, Some(previous), 0, &AtomicBool::new(false))
        );
        let frame = result.frame().unwrap();
        let expected = NumberWallGrid::generate(
            if key == "source" {
                Sequence::Rook
            } else {
                Sequence::SignedPagoda
            },
            raw,
            if key == "rows" { 3 } else { 4 },
            if key == "columnStart" { 5 } else { 3 },
            if key == "columns" { 17 } else { 16 },
        )
        .unwrap();
        assert_eq!(frame.grid().as_ref(), &expected, "{key}");
        assert!(
            !std::sync::Arc::ptr_eq(previous.grid(), frame.grid()),
            "{key}"
        );
    }
    assert_eq!(previous, &retained);
}

#[test]
fn complete_and_stepped_jobs_are_atomic_and_cancel_at_every_owned_boundary() {
    let complete = NumberWallFrame::prepare("00097", params(), None, 0, &AtomicBool::new(false));
    assert_eq!(
        complete,
        finish(NumberWallFrameJob::new("00097", params(), None, 0), 1)
    );
    let previous = complete.frame().unwrap();
    let retained = previous.clone();
    for (key, value) in [
        ("rows", 0),
        ("rows", 65),
        ("columns", 0),
        ("columns", 257),
        ("columnStart", 2),
        ("columnStart", 1_000_001),
    ] {
        let mut invalid = params();
        invalid.insert(key.into(), Value::Number(value.into()));
        let result = finish(NumberWallFrameJob::new("97", invalid, Some(previous), 0), 1);
        assert_eq!(result.status(), Status::Invalid);
        assert!(result.frame().is_none());
    }
    // A trace gives deterministic checkpoints without sleeps or racing threads.
    // Cancel before each advance: before prime, between stages, within grid,
    // and after completed grid/before frame publication. Repeat with full reuse.
    for reuse in [false, true] {
        let mut trace = NumberWallFrameJob::new("97", params(), reuse.then_some(previous), 0);
        let mut steps = 0;
        let mut phases = Vec::new();
        while trace.result().is_none() {
            phases.push(trace.phase());
            trace.advance(&AtomicBool::new(false), 17);
            steps += 1;
        }
        assert!(phases.contains(&FramePhase::Prime));
        assert!(phases.contains(&FramePhase::Grid));
        assert!(phases.contains(&FramePhase::FinalCheckpoint));
        for cancel_at in 0..steps {
            let mut job = NumberWallFrameJob::new("97", params(), reuse.then_some(previous), 0);
            for _ in 0..cancel_at {
                assert!(job.advance(&AtomicBool::new(false), 17).is_none());
            }
            let result = job.advance(&AtomicBool::new(true), 0).unwrap();
            assert_eq!(result.status(), Status::Cancelled);
            assert!(result.frame().is_none());
        }
    }
    // Prime's own yield must also be an interruptible composition boundary.
    let mut prime_job = NumberWallFrameJob::new("4405829", params(), None, 1024);
    assert!(prime_job.advance(&AtomicBool::new(false), 17).is_none());
    assert_eq!(prime_job.phase(), FramePhase::Prime);
    assert_eq!(
        prime_job
            .advance(&AtomicBool::new(true), 17)
            .unwrap()
            .status(),
        Status::Cancelled
    );
    // Frame cancellation has final precedence even over immediately invalid text.
    assert_eq!(
        NumberWallFrame::prepare("bad", params(), Some(previous), 0, &AtomicBool::new(true))
            .status(),
        Status::Cancelled
    );
    assert_eq!(previous, &retained);
}
