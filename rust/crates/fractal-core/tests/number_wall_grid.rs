use fractal_core::number_wall_grid::{
    GridPhase, MAX_WORK_UNITS, NumberWallDeterminantJob, NumberWallError, NumberWallGrid,
    NumberWallGridJob, NumberWallSequence as Sequence, cross_or_determinant, determinant,
    determinant_matrix_mod,
};
use num_bigint::BigInt;
use std::sync::atomic::{AtomicBool, Ordering};

fn strings(matrix: &[&[&str]]) -> Vec<Vec<String>> {
    matrix
        .iter()
        .map(|row| row.iter().map(|v| v.to_string()).collect())
        .collect()
}

// Independent integer Bareiss oracle, ported without modular elimination from
// test/modules/number_wall_parity_fixtures.dart. Keep identities and order pinned.
fn bareiss(mut a: Vec<Vec<BigInt>>) -> BigInt {
    let mut sign = BigInt::from(1);
    let mut previous = BigInt::from(1);
    for k in 0..a.len() - 1 {
        if a[k][k] == BigInt::from(0) {
            let Some(swap) = (k + 1..a.len()).find(|&r| a[r][k] != BigInt::from(0)) else {
                return BigInt::from(0);
            };
            a.swap(k, swap);
            sign = -sign;
        }
        let pivot = a[k][k].clone();
        for r in k + 1..a.len() {
            for c in k + 1..a.len() {
                a[r][c] = (&a[r][c] * &pivot - &a[r][k] * &a[k][c]) / &previous;
            }
        }
        for row in a.iter_mut().skip(k + 1) {
            row[k] = BigInt::from(0);
        }
        previous = pivot;
    }
    sign * a.last().unwrap().last().unwrap()
}

#[test]
fn independent_971_case_corpus_has_original_fingerprint() {
    let mut count = 0;
    let mut fingerprint = 2166136261_u64;
    let mut record = |identity: String, actual: String, expected: String| {
        assert_eq!(actual, expected, "{identity}");
        for byte in format!("{identity}|{actual}|{expected};").bytes() {
            fingerprint = (fingerprint * 31 + u64::from(byte)) % 1000000007;
        }
        count += 1;
    };
    for (sequence, name, prefix) in [
        (
            Sequence::Rook,
            "rook",
            vec![0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 1, 1],
        ),
        (
            Sequence::SignedPagoda,
            "signedPagoda",
            vec![-1, 0, 1, 0, -1, 1, 1, -1, -1, 0, 1, 1, -1, 0, 1, -1],
        ),
        (
            Sequence::ThueMorse,
            "thueMorse",
            vec![0, 1, 1, 0, 1, 0, 0, 1],
        ),
        (
            Sequence::RudinShapiro,
            "rudinShapiro",
            vec![0, 0, 0, 1, 0, 0, 1, 0],
        ),
        (
            Sequence::Fibonacci,
            "fibonacci",
            vec![0, 1, 1, 2, 3, 5, 8, 13],
        ),
        (
            Sequence::Squares,
            "squares",
            vec![0, 1, 4, 9, 16, 25, 36, 49],
        ),
    ] {
        for (n, expected) in prefix.iter().enumerate() {
            record(
                format!("prefix:{name}:{n}"),
                sequence.value_at(n as i64).unwrap(),
                expected.to_string(),
            );
        }
    }
    for (sequence, name) in [
        (Sequence::SignedPagoda, "signedPagoda"),
        (Sequence::Rook, "rook"),
        (Sequence::ThueMorse, "thueMorse"),
        (Sequence::RudinShapiro, "rudinShapiro"),
        (Sequence::Fibonacci, "fibonacci"),
        (Sequence::Squares, "squares"),
    ] {
        for p in [2, 3, 5, 7, 11, 13] {
            for row in 0..=4 {
                for column in row..row + 5 {
                    let matrix = (0..=row)
                        .map(|i| {
                            (0..=row)
                                .map(|j| {
                                    sequence
                                        .value_at(column + j - i)
                                        .unwrap()
                                        .parse::<BigInt>()
                                        .unwrap()
                                })
                                .collect()
                        })
                        .collect();
                    let modulus = BigInt::from(p);
                    let expected = ((bareiss(matrix) % &modulus + &modulus) % &modulus).to_string();
                    record(
                        format!("det:{name}:{p}:{row}:{column}"),
                        determinant(sequence, row as usize, column, &p.to_string()).unwrap(),
                        expected,
                    );
                }
            }
        }
    }
    record(
        "matrix:row-swap".into(),
        determinant_matrix_mod(&strings(&[&["0", "1"], &["1", "0"]]), "5").unwrap(),
        "4".into(),
    );
    record(
        "matrix:singular".into(),
        determinant_matrix_mod(&strings(&[&["1", "2"], &["2", "4"]]), "5").unwrap(),
        "0".into(),
    );
    record(
        "window:zero".into(),
        determinant(Sequence::Fibonacci, 2, 2, "2").unwrap(),
        "0".into(),
    );
    let expected = determinant(Sequence::Squares, 2, 4, "5").unwrap();
    record(
        "cross:zero-denominator-fallback".into(),
        cross_or_determinant(Sequence::Squares, 2, 4, "5", ["1", "1", "1", "0"]).unwrap(),
        expected.clone(),
    );
    let hankel = strings(&[&["0", "-1", "1"], &["1", "0", "-1"], &["0", "1", "0"]]);
    record(
        "hankel:published-sign".into(),
        determinant_matrix_mod(&hankel, "5").unwrap(),
        "1".into(),
    );
    let reversed = hankel.into_iter().rev().collect::<Vec<_>>();
    record(
        "hankel:reversed-sign".into(),
        determinant_matrix_mod(&reversed, "5").unwrap(),
        "4".into(),
    );
    record(
        "cross:nonzero-denominator".into(),
        cross_or_determinant(Sequence::Squares, 2, 4, "5", ["1", "2", "4", "1"]).unwrap(),
        expected,
    );
    assert_eq!(count, 971);
    assert_eq!(format!("{fingerprint:08x}"), "196b53dc");
}

#[test]
fn exact_large_signed_arithmetic_and_validation() {
    let p = "18446744073709551629";
    assert_eq!(
        Sequence::Fibonacci.value_at(100).unwrap(),
        "354224848179261915075"
    );
    assert_eq!(
        Sequence::Fibonacci.residue_at(100, p).unwrap(),
        "3736710778780434124"
    );
    assert_eq!(
        Sequence::SignedPagoda.residue_at(0, p).unwrap(),
        "18446744073709551628"
    );
    let a = strings(&[
        &["-18446744073709551630", "36893488147419103259"],
        &["18446744073709551631", "-36893488147419103259"],
    ]);
    assert_eq!(
        determinant_matrix_mod(&a, p).unwrap(),
        "18446744073709551628"
    );
    assert_eq!(determinant_matrix_mod(&[], p).unwrap(), "1");
    assert_eq!(
        determinant_matrix_mod(&strings(&[&["2"]]), "4"),
        Err(NumberWallError::NonInvertible)
    );
    assert_eq!(
        determinant_matrix_mod(&strings(&[&["1", "2"]]), "5"),
        Err(NumberWallError::NonSquare)
    );
    for text in ["", " 5", "5x", "+5"] {
        assert_eq!(
            Sequence::Squares.residue_at(1, text),
            Err(NumberWallError::InvalidDecimal)
        );
    }
    assert_eq!(
        Sequence::Squares.residue_at(1, "1"),
        Err(NumberWallError::InvalidModulus)
    );
    for sequence in [
        Sequence::ThueMorse,
        Sequence::RudinShapiro,
        Sequence::Fibonacci,
    ] {
        assert_eq!(sequence.value_at(-1), Err(NumberWallError::NegativeIndex));
    }
    assert_eq!(Sequence::Rook.value_at(-3).unwrap(), "0");
    assert_eq!(
        Sequence::Squares.value_at(i64::MIN).unwrap(),
        "85070591730234615865843651857942052864"
    );
}

#[test]
fn grids_are_bounded_stepped_exact_and_immutable() {
    let flag = AtomicBool::new(false);
    for sequence in [
        Sequence::SignedPagoda,
        Sequence::Rook,
        Sequence::ThueMorse,
        Sequence::RudinShapiro,
        Sequence::Fibonacci,
        Sequence::Squares,
    ] {
        let complete = NumberWallGrid::generate(sequence, "7", 5, 4, 8).unwrap();
        let mut job = NumberWallGridJob::new(sequence, "007", 5, 4, 8).unwrap();
        while job.advance(&flag, 17).is_none() {
            assert!(job.last_work_units() <= 17);
            assert!(job.result().is_none());
        }
        assert_eq!(job.result().unwrap().as_ref().unwrap(), &complete);
        assert_eq!(complete.modulus(), "7");
        for (r, row) in complete.values().iter().enumerate() {
            for (offset, value) in row.iter().enumerate() {
                assert_eq!(
                    value,
                    &determinant(sequence, r, 4 + offset as i64, "7").unwrap()
                );
            }
        }
        let retained = job.result().unwrap().clone();
        flag.store(true, Ordering::Relaxed);
        assert_eq!(job.advance(&flag, 1), Some(&retained));
        flag.store(false, Ordering::Relaxed);
    }
    assert_eq!(
        NumberWallGrid::required_support(Sequence::SignedPagoda, 1, 0, 1).unwrap(),
        (-1, 1)
    );
    assert_eq!(
        NumberWallGrid::required_support(Sequence::Rook, 64, 63, 256).unwrap(),
        (0, 381)
    );
    assert_eq!(
        NumberWallGrid::required_support(Sequence::SignedPagoda, 64, 1000000, 256).unwrap(),
        (999936, 1000319)
    );
    for (rows, start, cols) in [
        (0, 0, 1),
        (65, 64, 1),
        (1, 0, 0),
        (1, 0, 257),
        (2, 0, 1),
        (1, 1000001, 1),
    ] {
        assert!(NumberWallGridJob::new(Sequence::Rook, "5", rows, start, cols).is_err());
    }
    let mut tall_job = NumberWallGridJob::new(Sequence::Squares, "5", 64, 63, 1).unwrap();
    while tall_job.advance(&flag, usize::MAX).is_none() {
        assert!(tall_job.last_work_units() <= MAX_WORK_UNITS);
    }
    let tall = tall_job.result().unwrap().as_ref().unwrap();
    assert_eq!(
        &tall.values()[..3],
        &[
            vec!["4".to_owned()],
            vec!["2".to_owned()],
            vec!["3".to_owned()]
        ]
    );
    assert!(tall.values()[3..].iter().all(|row| row == &["0"]));
    let edge =
        NumberWallGrid::generate(Sequence::Fibonacci, "18446744073709551629", 1, 1000000, 256)
            .unwrap();
    assert_eq!(
        edge.values()[0][255],
        Sequence::Fibonacci
            .residue_at(1000255, edge.modulus())
            .unwrap()
    );
}

#[test]
fn cancellation_at_support_elimination_row_and_final_publishes_nothing() {
    for target in [
        GridPhase::Support,
        GridPhase::Elimination,
        GridPhase::RowCheckpoint,
        GridPhase::FinalCheckpoint,
    ] {
        let flag = AtomicBool::new(false);
        let mut job = NumberWallGridJob::new(Sequence::SignedPagoda, "7", 8, 7, 5).unwrap();
        // One-unit steps expose actual in-progress support/elimination cursors.
        job.advance(&flag, 1);
        while job.phase() != target {
            assert!(job.advance(&flag, 1).is_none(), "missing {target:?}");
        }
        assert!(job.result().is_none());
        flag.store(true, Ordering::Relaxed);
        assert_eq!(
            job.advance(&flag, MAX_WORK_UNITS),
            Some(&Err(NumberWallError::Cancelled))
        );
        flag.store(false, Ordering::Relaxed);
        assert_eq!(
            job.advance(&flag, 1),
            Some(&Err(NumberWallError::Cancelled))
        );
    }
}

#[test]
fn matrix_initialization_pivot_and_elimination_cursors_obey_work_cap() {
    let flag = AtomicBool::new(false);
    let n = 64;
    // Dense lower triangular input needs every elimination update; final column
    // requires a long unsuccessful pivot search. Its determinant is zero.
    let matrix = (0..n)
        .map(|r| {
            (0..n)
                .map(|c| if c <= r && c != n - 1 { "1" } else { "0" }.to_owned())
                .collect()
        })
        .collect::<Vec<_>>();
    let mut job = NumberWallDeterminantJob::new(&matrix, "7").unwrap();
    let mut phases = std::collections::HashSet::new();
    while job.result().is_none() {
        phases.insert(job.phase());
        job.advance(&flag, usize::MAX);
        assert!(job.last_work_units() <= MAX_WORK_UNITS);
    }
    assert!(phases.contains(&GridPhase::Matrix));
    assert!(phases.contains(&GridPhase::Elimination));
    assert_eq!(job.result(), Some(&Ok("0".into())));
    // A one-unit budget proves pivot probes themselves advance incrementally.
    let zeros = vec![vec!["0".to_owned(); 4]; 4];
    let mut singular = NumberWallDeterminantJob::new(&zeros, "7").unwrap();
    while singular.phase() != GridPhase::Pivot {
        singular.advance(&flag, 1);
    }
    for _ in 0..3 {
        assert!(singular.advance(&flag, 1).is_none());
        assert_eq!(singular.phase(), GridPhase::Pivot);
    }
    flag.store(true, Ordering::Relaxed);
    assert_eq!(
        singular.advance(&flag, 1),
        Some(&Err(NumberWallError::Cancelled))
    );
}
