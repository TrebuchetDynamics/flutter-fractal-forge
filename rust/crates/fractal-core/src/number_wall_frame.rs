//! Certified immutable Number Walls transactions, independent of Session/FFI.

use crate::{
    catalog_baseline::ParameterValue,
    number_wall_grid::{
        MAX_WORK_UNITS, NumberWallError, NumberWallGrid, NumberWallGridJob, NumberWallSequence,
    },
    number_wall_prime::{NumberWallPrimeJob, NumberWallPrimeStatus},
};
use std::{
    collections::BTreeMap,
    sync::{
        Arc,
        atomic::{AtomicBool, Ordering},
    },
};

/// Only a successful preparation job can construct a frame. There is no
/// deserialization or certificate/status input; arithmetic grids are not proofs.
///
/// ```compile_fail
/// use fractal_core::{number_wall_frame::NumberWallFrame, number_wall_grid::*};
/// let grid = NumberWallGrid::generate(NumberWallSequence::Rook, "4", 1, 0, 1).unwrap();
/// let forged = NumberWallFrame { params: Default::default(), grid: std::sync::Arc::new(grid) };
/// ```
#[derive(Debug, Clone, PartialEq)]
pub struct NumberWallFrame {
    params: BTreeMap<String, ParameterValue>,
    grid: Arc<NumberWallGrid>,
}

impl NumberWallFrame {
    pub fn params(&self) -> &BTreeMap<String, ParameterValue> {
        &self.params
    }

    pub fn grid(&self) -> &Arc<NumberWallGrid> {
        &self.grid
    }

    /// Session style edits cannot alter any certified mathematical input.
    pub(crate) fn restyle(&self, id: &str, value: ParameterValue) -> Option<Self> {
        if !matches!(
            id,
            "colorMode"
                | "colorScheme"
                | "foregroundColor"
                | "zeroColor"
                | "backgroundColor"
                | "showGrid"
                | "randomizeModulus"
                | "randomSeed"
        ) {
            return None;
        }
        let mut frame = self.clone();
        frame.params.insert(id.into(), value);
        Some(frame)
    }

    /// Synchronous convenience driver of the identical resumable job.
    pub fn prepare(
        raw_prime: &str,
        params: BTreeMap<String, ParameterValue>,
        previous: Option<&Self>,
        max_trial_divisions: u32,
        cancelled: &AtomicBool,
    ) -> NumberWallFrameResult {
        let mut job = NumberWallFrameJob::new(raw_prime, params, previous, max_trial_divisions);
        while job.advance(cancelled, MAX_WORK_UNITS).is_none() {}
        job.result.expect("completed")
    }
}

/// Terminal status; only VerifiedPrime carries a completed settings/grid pair.
#[derive(Debug, Clone, PartialEq)]
pub struct NumberWallFrameResult {
    status: NumberWallPrimeStatus,
    frame: Option<NumberWallFrame>,
}

impl NumberWallFrameResult {
    pub fn status(&self) -> NumberWallPrimeStatus {
        self.status
    }

    pub fn frame(&self) -> Option<&NumberWallFrame> {
        self.frame.as_ref()
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum FramePhase {
    Prime,
    Grid,
    FinalCheckpoint,
    Finished,
}

/// Consumes raw prime text separately from normalized non-prime parameters.
/// The map's prime/verification/status fields cannot supply proof. Prior proof
/// reuse requires an actual completed frame and exact canonical raw-text equality.
#[derive(Debug)]
pub struct NumberWallFrameJob {
    params: BTreeMap<String, ParameterValue>,
    prime_job: Option<NumberWallPrimeJob>,
    certified_prime: Option<String>,
    previous_grid: Option<Arc<NumberWallGrid>>,
    grid_job: Option<NumberWallGridJob>,
    grid: Option<Arc<NumberWallGrid>>,
    phase: FramePhase,
    result: Option<NumberWallFrameResult>,
    last_grid_work_units: usize,
}

impl NumberWallFrameJob {
    pub fn new(
        raw_prime: &str,
        params: BTreeMap<String, ParameterValue>,
        previous: Option<&NumberWallFrame>,
        max_trial_divisions: u32,
    ) -> Self {
        let certified_prime = previous
            .filter(|frame| raw_prime == frame.grid.modulus())
            .map(|frame| frame.grid.modulus().to_owned());
        Self {
            params,
            prime_job: certified_prime
                .is_none()
                .then(|| NumberWallPrimeJob::new(raw_prime, max_trial_divisions)),
            certified_prime,
            previous_grid: previous.map(|frame| Arc::clone(&frame.grid)),
            grid_job: None,
            grid: None,
            phase: FramePhase::Prime,
            result: None,
            last_grid_work_units: 0,
        }
    }

    pub fn phase(&self) -> FramePhase {
        self.phase
    }

    pub fn result(&self) -> Option<&NumberWallFrameResult> {
        self.result.as_ref()
    }

    pub fn last_grid_work_units(&self) -> usize {
        self.last_grid_work_units
    }

    /// One prime advance (at most 1024 odd trials), OR at most
    /// min(grid_work_limit, 1024) scalar grid units. Always yields between stages
    /// and after completed grid storage, before frame publication. Zero only
    /// checks cancellation. Bigint operations are indivisible, not a time bound.
    /// Cancellation is independent of request ownership and is rechecked even
    /// for reused proofs/grids and immediately before publishing the frame.
    /// Once terminal, status and frame remain stable under later cancellation.
    pub fn advance(
        &mut self,
        cancelled: &AtomicBool,
        grid_work_limit: usize,
    ) -> Option<&NumberWallFrameResult> {
        use NumberWallPrimeStatus::*;
        self.last_grid_work_units = 0;
        if self.result.is_some() {
            return self.result();
        }
        if cancelled.load(Ordering::Relaxed) {
            self.finish(Cancelled, None);
            return self.result();
        }
        if grid_work_limit == 0 {
            return None;
        }
        match self.phase {
            FramePhase::Prime => {
                if let Some(job) = &mut self.prime_job {
                    let check = job.advance(cancelled)?;
                    let status = check.status();
                    if status != VerifiedPrime {
                        self.finish(
                            if cancelled.load(Ordering::Relaxed) {
                                Cancelled
                            } else {
                                status
                            },
                            None,
                        );
                        return self.result();
                    }
                    self.certified_prime = check.prime().map(str::to_owned);
                }
                self.prime_job = None;
                self.phase = FramePhase::Grid;
            }
            FramePhase::Grid => {
                if self.grid_job.is_none() {
                    let Some((sequence, rows, start, columns)) = mathematical_params(&self.params)
                    else {
                        self.finish(Invalid, None);
                        return self.result();
                    };
                    let prime = self
                        .certified_prime
                        .as_deref()
                        .expect("prime stage completed");
                    if let Some(grid) = self.previous_grid.take().filter(|grid| {
                        grid.sequence() == sequence
                            && grid.modulus() == prime
                            && grid.row_count() == rows
                            && grid.column_count() == columns
                            && grid.column_start() == start
                    }) {
                        self.grid = Some(grid);
                        self.phase = FramePhase::FinalCheckpoint;
                    } else {
                        match NumberWallGridJob::new(sequence, prime, rows, start, columns) {
                            Ok(job) => self.grid_job = Some(job),
                            Err(_) => {
                                self.finish(Invalid, None);
                                return self.result();
                            }
                        }
                    }
                }
                if let Some(job) = &mut self.grid_job {
                    job.advance(cancelled, grid_work_limit);
                    self.last_grid_work_units = job.last_work_units();
                    if job.result().is_some() {
                        match self
                            .grid_job
                            .take()
                            .expect("grid job")
                            .into_result()
                            .expect("completed")
                        {
                            Ok(grid) => {
                                self.grid = Some(Arc::new(grid));
                                self.phase = FramePhase::FinalCheckpoint;
                            }
                            Err(error) => self.finish(
                                if error == NumberWallError::Cancelled {
                                    Cancelled
                                } else {
                                    Invalid
                                },
                                None,
                            ),
                        }
                    }
                }
            }
            FramePhase::FinalCheckpoint => {
                self.params.insert(
                    "prime".into(),
                    ParameterValue::Text(self.certified_prime.take().expect("certified prime")),
                );
                let frame = NumberWallFrame {
                    params: std::mem::take(&mut self.params),
                    grid: self.grid.take().expect("completed grid"),
                };
                if cancelled.load(Ordering::Relaxed) {
                    self.finish(Cancelled, None);
                } else {
                    self.finish(VerifiedPrime, Some(frame));
                }
            }
            FramePhase::Finished => unreachable!("terminal result already returned"),
        }
        if self.result.is_none() && cancelled.load(Ordering::Relaxed) {
            self.finish(Cancelled, None);
        }
        self.result()
    }

    fn finish(&mut self, status: NumberWallPrimeStatus, frame: Option<NumberWallFrame>) {
        self.result = Some(NumberWallFrameResult { status, frame });
        self.phase = FramePhase::Finished;
    }
}

// Inputs are already schema-normalized; reject malformed/missing math fields
// rather than publishing settings that disagree with the generated field.
fn mathematical_params(
    params: &BTreeMap<String, ParameterValue>,
) -> Option<(NumberWallSequence, usize, i64, usize)> {
    let sequence = match params.get("source")? {
        ParameterValue::Text(source) => match source.as_str() {
            "signedPagoda" => NumberWallSequence::SignedPagoda,
            "rook" => NumberWallSequence::Rook,
            "thueMorse" => NumberWallSequence::ThueMorse,
            "rudinShapiro" => NumberWallSequence::RudinShapiro,
            "fibonacci" => NumberWallSequence::Fibonacci,
            "squares" => NumberWallSequence::Squares,
            _ => return None,
        },
        _ => return None,
    };
    let integer = |key: &str, max: u32| match params.get(key)? {
        ParameterValue::Number(number) => number
            .as_f64()
            .filter(|n| n.fract() == 0.0 && (0.0..=f64::from(max)).contains(n))
            .map(|n| n as u32),
        _ => None,
    };
    Some((
        sequence,
        integer("rows", 64)? as usize,
        i64::from(integer("columnStart", 1_000_000)?),
        integer("columns", 256)? as usize,
    ))
}
