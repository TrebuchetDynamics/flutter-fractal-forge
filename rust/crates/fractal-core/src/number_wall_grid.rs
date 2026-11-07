//! Exact Number Walls arithmetic and bounded, nonpublishing grid preparation.
//!
//! A modulus >= 2 is an arithmetic operand, never a prime certificate. Composite
//! moduli may fail with `NonInvertible`. No session, executor or platform is used.

use num_bigint::BigInt;
use std::sync::atomic::{AtomicBool, Ordering};

pub const MAX_WORK_UNITS: usize = 1024;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum NumberWallError {
    InvalidDecimal,
    InvalidModulus,
    NegativeIndex,
    IndexOverflow,
    InvalidDimensions,
    InvalidColumnStart,
    NonSquare,
    NonInvertible,
    Cancelled,
}

type Result<T> = std::result::Result<T, NumberWallError>;

fn decimal(text: &str) -> Result<BigInt> {
    let digits = text.strip_prefix('-').unwrap_or(text);
    if digits.is_empty() || !digits.bytes().all(|b| b.is_ascii_digit()) {
        return Err(NumberWallError::InvalidDecimal);
    }
    text.parse().map_err(|_| NumberWallError::InvalidDecimal)
}

fn modulus(text: &str) -> Result<BigInt> {
    let value = decimal(text)?;
    if value < BigInt::from(2) {
        return Err(NumberWallError::InvalidModulus);
    }
    Ok(value)
}

fn residue(value: BigInt, modulus: &BigInt) -> BigInt {
    let r = value % modulus;
    if r < BigInt::from(0) { r + modulus } else { r }
}

fn inverse(value: &BigInt, modulus: &BigInt) -> Result<BigInt> {
    let (mut old_r, mut r) = (value.clone(), modulus.clone());
    let (mut old_s, mut s) = (BigInt::from(1), BigInt::from(0));
    while r != BigInt::from(0) {
        let quotient = &old_r / &r;
        (old_r, r) = (r.clone(), old_r - &quotient * r);
        (old_s, s) = (s.clone(), old_s - quotient * s);
    }
    if old_r != BigInt::from(1) {
        return Err(NumberWallError::NonInvertible);
    }
    Ok(residue(old_s, modulus))
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum NumberWallSequence {
    SignedPagoda,
    Rook,
    ThueMorse,
    RudinShapiro,
    Fibonacci,
    Squares,
}

impl NumberWallSequence {
    pub fn value_at(self, n: i64) -> Result<String> {
        Ok(self.value(n, None)?.to_string())
    }

    pub fn residue_at(self, n: i64, prime: &str) -> Result<String> {
        let p = modulus(prime)?;
        Ok(residue(self.value(n, Some(&p))?, &p).to_string())
    }

    fn value(self, n: i64, p: Option<&BigInt>) -> Result<BigInt> {
        use NumberWallSequence::*;
        Ok(match self {
            Rook => BigInt::from(rook(n)),
            SignedPagoda => BigInt::from(
                rook(n.checked_add(1).ok_or(NumberWallError::IndexOverflow)?)
                    - rook(n.checked_sub(1).ok_or(NumberWallError::IndexOverflow)?),
            ),
            Squares => BigInt::from(n) * BigInt::from(n),
            ThueMorse | RudinShapiro | Fibonacci => {
                let n = u64::try_from(n).map_err(|_| NumberWallError::NegativeIndex)?;
                match self {
                    ThueMorse => BigInt::from(n.count_ones() & 1),
                    RudinShapiro => BigInt::from((n & (n >> 1)).count_ones() & 1),
                    Fibonacci => fibonacci(n, p).0,
                    _ => unreachable!(),
                }
            }
        })
    }
}

fn rook(n: i64) -> i32 {
    if n == 0 {
        return 0;
    }
    let odd = n.unsigned_abs() >> n.unsigned_abs().trailing_zeros();
    let value = ((odd / 2) & 1) as i32;
    if n < 0 { 1 - value } else { value }
}

fn fibonacci(n: u64, p: Option<&BigInt>) -> (BigInt, BigInt) {
    if n == 0 {
        return (BigInt::from(0), BigInt::from(1));
    }
    let (a, b) = fibonacci(n >> 1, p);
    let reduce = |v| match p {
        Some(p) => residue(v, p),
        None => v,
    };
    let c = reduce(&a * ((&b << 1) - &a));
    let d = reduce(&a * &a + &b * &b);
    if n & 1 == 0 {
        (c, d)
    } else {
        (d.clone(), reduce(c + d))
    }
}

/// Observable checkpoint/cursor, not a timing estimate.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum GridPhase {
    Support,
    Matrix,
    Pivot,
    Inverse,
    Elimination,
    RowCheckpoint,
    FinalCheckpoint,
    Finished,
}

#[derive(Debug)]
enum Elimination {
    Normalize(usize),
    Pivot(usize),
    Inverse,
    Factor(usize),
    Update {
        row: usize,
        column: usize,
        factor: BigInt,
    },
    Done,
}

/// The same scalar cursor is used by standalone determinants and grids.
#[derive(Debug)]
struct Determinant {
    matrix: Vec<Vec<BigInt>>,
    column: usize,
    product: BigInt,
    inverse: BigInt,
    cursor: Elimination,
    result: Option<Result<BigInt>>,
}

impl Determinant {
    fn new(matrix: Vec<Vec<BigInt>>) -> Self {
        Self {
            matrix,
            column: 0,
            product: BigInt::from(1),
            inverse: BigInt::from(0),
            cursor: Elimination::Normalize(0),
            result: None,
        }
    }

    fn phase(&self) -> GridPhase {
        match self.cursor {
            Elimination::Normalize(_) => GridPhase::Matrix,
            Elimination::Pivot(_) => GridPhase::Pivot,
            Elimination::Inverse => GridPhase::Inverse,
            Elimination::Factor(_) | Elimination::Update { .. } => GridPhase::Elimination,
            Elimination::Done => GridPhase::Finished,
        }
    }

    fn finish(&mut self, value: Result<BigInt>) {
        self.result = Some(value);
        self.cursor = Elimination::Done;
    }

    // One normalization, pivot probe, inverse, row probe or scalar matrix update.
    // An inverse/bigint operation is indivisible: this is not an 8 ms guarantee.
    fn step(&mut self, p: &BigInt) {
        let n = self.matrix.len();
        match &self.cursor {
            Elimination::Normalize(index) => {
                let index = *index;
                if index < n * n {
                    let value = &mut self.matrix[index / n][index % n];
                    if *value < BigInt::from(0) || &*value >= p {
                        *value = residue(std::mem::take(value), p);
                    }
                    self.cursor = if index + 1 == n * n {
                        Elimination::Pivot(0)
                    } else {
                        Elimination::Normalize(index + 1)
                    };
                } else {
                    self.finish(Ok(BigInt::from(1)));
                }
            }
            Elimination::Pivot(row) => {
                let row = *row;
                if row == n {
                    self.finish(Ok(BigInt::from(0)));
                } else if self.matrix[row][self.column] == BigInt::from(0) {
                    self.cursor = Elimination::Pivot(row + 1);
                } else {
                    if row != self.column {
                        self.matrix.swap(row, self.column);
                        self.product = -std::mem::take(&mut self.product);
                    }
                    self.product =
                        residue(&self.product * &self.matrix[self.column][self.column], p);
                    self.cursor = Elimination::Inverse;
                }
            }
            Elimination::Inverse => match inverse(&self.matrix[self.column][self.column], p) {
                Ok(value) => {
                    self.inverse = value;
                    self.cursor = Elimination::Factor(self.column + 1);
                }
                Err(error) => self.finish(Err(error)),
            },
            Elimination::Factor(row) => {
                let row = *row;
                if row == n {
                    self.column += 1;
                    if self.column == n {
                        self.finish(Ok(residue(self.product.clone(), p)));
                    } else {
                        self.cursor = Elimination::Pivot(self.column);
                    }
                } else if self.matrix[row][self.column] == BigInt::from(0) {
                    self.cursor = Elimination::Factor(row + 1);
                } else {
                    let factor = residue(&self.matrix[row][self.column] * &self.inverse, p);
                    self.cursor = Elimination::Update {
                        row,
                        column: self.column,
                        factor,
                    };
                }
            }
            Elimination::Update {
                row,
                column,
                factor,
            } => {
                let (row, column) = (*row, *column);
                self.matrix[row][column] = residue(
                    &self.matrix[row][column] - factor * &self.matrix[self.column][column],
                    p,
                );
                if column + 1 == n {
                    self.cursor = Elimination::Factor(row + 1);
                } else if let Elimination::Update { column, .. } = &mut self.cursor {
                    *column += 1;
                }
            }
            Elimination::Done => unreachable!("terminal cursor is not advanced"),
        }
    }
}

/// Owned arbitrary-matrix job. Construction parses decimal input; field
/// normalization, pivot probes and elimination are performed only by advance.
#[derive(Debug)]
pub struct NumberWallDeterminantJob {
    modulus: BigInt,
    determinant: Determinant,
    result: Option<Result<String>>,
    last_work_units: usize,
}

impl NumberWallDeterminantJob {
    pub fn new(matrix: &[Vec<String>], prime: &str) -> Result<Self> {
        let modulus = modulus(prime)?;
        if matrix.iter().any(|row| row.len() != matrix.len()) {
            return Err(NumberWallError::NonSquare);
        }
        let matrix = matrix
            .iter()
            .map(|row| row.iter().map(|v| decimal(v)).collect())
            .collect::<Result<_>>()?;
        Ok(Self {
            modulus,
            determinant: Determinant::new(matrix),
            result: None,
            last_work_units: 0,
        })
    }

    pub fn phase(&self) -> GridPhase {
        if self.result.is_some() {
            GridPhase::Finished
        } else {
            self.determinant.phase()
        }
    }

    pub fn result(&self) -> Option<&Result<String>> {
        self.result.as_ref()
    }
    pub fn last_work_units(&self) -> usize {
        self.last_work_units
    }

    /// Clamp the requested scalar work to 1024. Zero only checks cancellation.
    /// Terminal results are stable. No partial determinant is exposed.
    pub fn advance(
        &mut self,
        cancelled: &AtomicBool,
        work_limit: usize,
    ) -> Option<&Result<String>> {
        self.last_work_units = 0;
        if self.result.is_some() {
            return self.result();
        }
        for _ in 0..work_limit.min(MAX_WORK_UNITS) {
            if cancelled.load(Ordering::Relaxed) {
                self.result = Some(Err(NumberWallError::Cancelled));
                return self.result();
            }
            self.determinant.step(&self.modulus);
            self.last_work_units += 1;
            if let Some(result) = self.determinant.result.take() {
                let result = result.map(|v| v.to_string());
                self.result = Some(if cancelled.load(Ordering::Relaxed) {
                    Err(NumberWallError::Cancelled)
                } else {
                    result
                });
                return self.result();
            }
        }
        if cancelled.load(Ordering::Relaxed) {
            self.result = Some(Err(NumberWallError::Cancelled));
        }
        self.result()
    }
}

pub fn determinant_matrix_mod(matrix: &[Vec<String>], prime: &str) -> Result<String> {
    let mut job = NumberWallDeterminantJob::new(matrix, prime)?;
    let flag = AtomicBool::new(false);
    while job.advance(&flag, MAX_WORK_UNITS).is_none() {}
    job.result.take().expect("completed")
}

pub fn determinant(
    sequence: NumberWallSequence,
    row: usize,
    column: i64,
    prime: &str,
) -> Result<String> {
    let row = i64::try_from(row).map_err(|_| NumberWallError::IndexOverflow)?;
    let matrix = (0..=row)
        .map(|i| {
            (0..=row)
                .map(|j| {
                    let n = column
                        .checked_add(j)
                        .and_then(|n| n.checked_sub(i))
                        .ok_or(NumberWallError::IndexOverflow)?;
                    sequence.residue_at(n, prime)
                })
                .collect()
        })
        .collect::<Result<Vec<_>>>()?;
    determinant_matrix_mod(&matrix, prime)
}

/// `cross` is [northWest, west, east, denominator], matching the Dart owner.
/// A zero denominator uses a direct determinant, not a division by zero.
pub fn cross_or_determinant(
    sequence: NumberWallSequence,
    row: usize,
    column: i64,
    prime: &str,
    cross: [&str; 4],
) -> Result<String> {
    let p = modulus(prime)?;
    let [nw, west, east, denominator] = cross.map(decimal);
    let d = residue(denominator?, &p);
    if d == BigInt::from(0) {
        return determinant(sequence, row, column, prime);
    }
    let nw = nw?;
    Ok(residue((&nw * &nw - west? * east?) * inverse(&d, &p)?, &p).to_string())
}

/// Completed immutable value; no caller can mutate a retained grid's cells.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct NumberWallGrid {
    sequence: NumberWallSequence,
    modulus: String,
    column_start: i64,
    column_count: usize,
    support: (i64, i64),
    values: Vec<Vec<String>>,
}

impl NumberWallGrid {
    pub fn sequence(&self) -> NumberWallSequence {
        self.sequence
    }
    pub fn modulus(&self) -> &str {
        &self.modulus
    }
    pub fn row_count(&self) -> usize {
        self.values.len()
    }
    pub fn column_start(&self) -> i64 {
        self.column_start
    }
    pub fn column_count(&self) -> usize {
        self.column_count
    }
    pub fn support(&self) -> (i64, i64) {
        self.support
    }
    pub fn values(&self) -> &[Vec<String>] {
        &self.values
    }

    pub fn required_support(
        sequence: NumberWallSequence,
        rows: usize,
        column_start: i64,
        columns: usize,
    ) -> Result<(i64, i64)> {
        if !(1..=64).contains(&rows) || !(1..=256).contains(&columns) {
            return Err(NumberWallError::InvalidDimensions);
        }
        if !(rows as i64 - 1..=1_000_000).contains(&column_start) {
            return Err(NumberWallError::InvalidColumnStart);
        }
        let halo = rows as i64 - 1 + i64::from(sequence == NumberWallSequence::SignedPagoda);
        Ok((
            column_start - halo,
            column_start + columns as i64 - 1 + halo,
        ))
    }

    /// Synchronous convenience helper driving the identical resumable cursor.
    pub fn generate(
        sequence: NumberWallSequence,
        prime: &str,
        rows: usize,
        column_start: i64,
        columns: usize,
    ) -> Result<Self> {
        let mut job = NumberWallGridJob::new(sequence, prime, rows, column_start, columns)?;
        let flag = AtomicBool::new(false);
        while job.advance(&flag, MAX_WORK_UNITS).is_none() {}
        job.result.take().expect("completed")
    }
}

#[derive(Debug)]
pub struct NumberWallGridJob {
    sequence: NumberWallSequence,
    modulus: BigInt,
    row_count: usize,
    column_start: i64,
    column_count: usize,
    support: (i64, i64),
    sequence_values: Vec<BigInt>,
    values: Vec<Vec<String>>,
    cells: Vec<String>,
    matrix: Vec<Vec<BigInt>>,
    determinant: Option<Determinant>,
    phase: GridPhase,
    result: Option<Result<NumberWallGrid>>,
    last_work_units: usize,
}

impl NumberWallGridJob {
    pub fn new(
        sequence: NumberWallSequence,
        prime: &str,
        rows: usize,
        column_start: i64,
        columns: usize,
    ) -> Result<Self> {
        let modulus = modulus(prime)?;
        let support = NumberWallGrid::required_support(sequence, rows, column_start, columns)?;
        Ok(Self {
            sequence,
            modulus,
            row_count: rows,
            column_start,
            column_count: columns,
            support,
            sequence_values: Vec::new(),
            values: Vec::new(),
            cells: Vec::new(),
            matrix: Vec::new(),
            determinant: None,
            phase: GridPhase::Support,
            result: None,
            last_work_units: 0,
        })
    }

    pub fn phase(&self) -> GridPhase {
        self.phase
    }
    pub fn result(&self) -> Option<&Result<NumberWallGrid>> {
        self.result.as_ref()
    }
    pub fn last_work_units(&self) -> usize {
        self.last_work_units
    }

    /// One unit is a support residue, matrix entry, pivot/row probe, inverse,
    /// elimination update or completed cell. Bigint operations are indivisible.
    /// Each call does at most min(work_limit, 1024) units, returning pending at
    /// every row boundary and before final publication even if budget remains.
    /// Cancellation is checked per unit, at each boundary and before publication.
    /// No wall-clock responsiveness follows from this scalar bound.
    pub fn advance(
        &mut self,
        cancelled: &AtomicBool,
        work_limit: usize,
    ) -> Option<&Result<NumberWallGrid>> {
        self.last_work_units = 0;
        if self.result.is_some() {
            return self.result();
        }
        if cancelled.load(Ordering::Relaxed) {
            self.finish(Err(NumberWallError::Cancelled));
            return self.result();
        }
        if self.phase == GridPhase::FinalCheckpoint {
            let grid = NumberWallGrid {
                sequence: self.sequence,
                modulus: self.modulus.to_string(),
                column_start: self.column_start,
                column_count: self.column_count,
                support: self.support,
                values: std::mem::take(&mut self.values),
            };
            self.finish(if cancelled.load(Ordering::Relaxed) {
                Err(NumberWallError::Cancelled)
            } else {
                Ok(grid)
            });
            return self.result();
        }
        if self.phase == GridPhase::RowCheckpoint {
            if self.values.len() == self.row_count {
                self.phase = GridPhase::FinalCheckpoint;
                return None;
            }
            self.phase = GridPhase::Matrix;
        }
        for _ in 0..work_limit.min(MAX_WORK_UNITS) {
            if cancelled.load(Ordering::Relaxed) {
                self.finish(Err(NumberWallError::Cancelled));
                break;
            }
            self.last_work_units += 1;
            if let Err(error) = self.step() {
                self.finish(Err(error));
                break;
            }
            if self.phase == GridPhase::RowCheckpoint {
                break;
            }
        }
        if self.result.is_none() && cancelled.load(Ordering::Relaxed) {
            self.finish(Err(NumberWallError::Cancelled));
        }
        self.result()
    }

    /// Move completed storage into the composing frame without cloning cells.
    pub(crate) fn into_result(self) -> Option<Result<NumberWallGrid>> {
        self.result
    }

    fn finish(&mut self, result: Result<NumberWallGrid>) {
        self.result = Some(result);
        self.phase = GridPhase::Finished;
    }

    fn step(&mut self) -> Result<()> {
        if self.phase == GridPhase::Support {
            let n = self.support.0 + self.sequence_values.len() as i64;
            self.sequence_values.push(residue(
                self.sequence.value(n, Some(&self.modulus))?,
                &self.modulus,
            ));
            if n == self.support.1 {
                self.phase = GridPhase::Matrix;
            }
        } else if let Some(determinant) = &mut self.determinant {
            if let Some(result) = determinant.result.take() {
                self.cells.push(result?.to_string());
                self.determinant = None;
                self.phase = GridPhase::Matrix;
                if self.cells.len() == self.column_count {
                    self.values.push(std::mem::take(&mut self.cells));
                    self.phase = GridPhase::RowCheckpoint;
                }
            } else {
                determinant.step(&self.modulus);
                self.phase = match determinant.phase() {
                    GridPhase::Finished => GridPhase::Matrix,
                    phase => phase,
                };
            }
        } else {
            let size = self.values.len() + 1;
            if self.matrix.last().is_none_or(|row| row.len() == size) {
                self.matrix.push(Vec::with_capacity(size));
            }
            let i = self.matrix.len() - 1;
            let j = self.matrix[i].len();
            let n = self.column_start + self.cells.len() as i64 + j as i64 - i as i64;
            self.matrix[i].push(self.sequence_values[(n - self.support.0) as usize].clone());
            if self.matrix.len() == size && self.matrix[i].len() == size {
                self.determinant = Some(Determinant::new(std::mem::take(&mut self.matrix)));
            }
        }
        Ok(())
    }
}
