//! Exact bounded Number Walls prime certification, independent of session ingress.

use std::sync::atomic::{AtomicBool, Ordering};

pub const MAX_DECIMAL_DIGITS: usize = 256;
pub const DEFAULT_MAX_TRIAL_DIVISIONS: u32 = 100_000;
const TRIALS_PER_ADVANCE: u32 = 1024;
const SMALL_PRIMES: [u64; 15] = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47];

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum NumberWallPrimeStatus {
    VerifiedPrime,
    Composite,
    Invalid,
    Unverified,
    Cancelled,
}

/// Immutable terminal result. Only completed exact proofs carry prime text.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct NumberWallPrimeCheck {
    status: NumberWallPrimeStatus,
    prime: Option<String>,
    divisions: u32,
}

impl NumberWallPrimeCheck {
    pub fn status(&self) -> NumberWallPrimeStatus {
        self.status
    }

    pub fn prime(&self) -> Option<&str> {
        self.prime.as_deref()
    }

    /// Odd trials only; the small-prime screen is not counted.
    pub fn divisions(&self) -> u32 {
        self.divisions
    }
}

/// Resumable equivalent of Dart's NumberWallPrimeValidator.
///
/// A budget is total, not per advance. An unverified result is terminal; a caller
/// can start a new job with a larger budget, but cannot treat syntax as proof.
#[derive(Debug)]
pub struct NumberWallPrimeJob {
    decimal: String,
    budget: u32,
    candidate: u64,
    divisions: u32,
    screened: bool,
    result: Option<NumberWallPrimeCheck>,
}

impl NumberWallPrimeJob {
    /// Check raw ASCII digits and length before canonicalizing leading zeros.
    /// Invalid syntax and values below two finish before cancellation is checked.
    pub fn new(input: &str, max_trial_divisions: u32) -> Self {
        let valid = !input.is_empty()
            && input.len() <= MAX_DECIMAL_DIGITS
            && input.bytes().all(|digit| digit.is_ascii_digit());
        let decimal = if valid {
            input.trim_start_matches('0')
        } else {
            ""
        };
        let mut job = Self {
            decimal: decimal.to_owned(),
            budget: max_trial_divisions,
            candidate: 53,
            divisions: 0,
            screened: false,
            result: None,
        };
        if decimal.is_empty() || decimal == "1" {
            job.finish(NumberWallPrimeStatus::Invalid);
        }
        job
    }

    pub fn result(&self) -> Option<&NumberWallPrimeCheck> {
        self.result.as_ref()
    }

    pub fn divisions(&self) -> u32 {
        self.divisions
    }

    /// Perform the small-prime screen once, then at most 1024 odd trials.
    ///
    /// `None` means pending, including the source's yield after trial 1024 even
    /// if the next advance will finish. A Rust caller can share the atomic flag
    /// with another thread. Cancellation is checked before each small prime,
    /// before each in-root trial (before budget), and at final completion.
    /// Terminal results never change, even if cancellation is later requested.
    pub fn advance(&mut self, is_cancelled: &AtomicBool) -> Option<&NumberWallPrimeCheck> {
        use NumberWallPrimeStatus::*;
        if self.result.is_some() {
            return self.result();
        }
        if !self.screened {
            for prime in SMALL_PRIMES {
                if is_cancelled.load(Ordering::Relaxed) {
                    return self.finish(Cancelled);
                }
                if self.decimal == prime.to_string() {
                    return self.finish(VerifiedPrime);
                }
                if remainder(&self.decimal, prime) == 0 {
                    return self.finish(Composite);
                }
            }
            self.screened = true;
        }
        for _ in 0..TRIALS_PER_ADVANCE {
            // candidate <= floor(sqrt(value)) iff candidate^2 <= value.
            let square = u128::from(self.candidate)
                .checked_mul(u128::from(self.candidate))
                .expect("u64 candidate square fits u128")
                .to_string();
            if (square.len(), square.as_str()) > (self.decimal.len(), self.decimal.as_str()) {
                return self.finish(if is_cancelled.load(Ordering::Relaxed) {
                    Cancelled
                } else {
                    VerifiedPrime
                });
            }
            if is_cancelled.load(Ordering::Relaxed) {
                return self.finish(Cancelled);
            }
            if self.divisions >= self.budget {
                return self.finish(Unverified);
            }
            self.divisions = self
                .divisions
                .checked_add(1)
                .expect("trial is within u32 budget");
            if remainder(&self.decimal, self.candidate) == 0 {
                return self.finish(Composite);
            }
            // A u32 total budget bounds candidate by 53 + 2*u32::MAX.
            self.candidate = self
                .candidate
                .checked_add(2)
                .expect("candidate is within u64 bound");
        }
        None
    }

    fn finish(&mut self, status: NumberWallPrimeStatus) -> Option<&NumberWallPrimeCheck> {
        self.result = Some(NumberWallPrimeCheck {
            status,
            prime: (status == NumberWallPrimeStatus::VerifiedPrime).then(|| self.decimal.clone()),
            divisions: self.divisions,
        });
        self.result()
    }
}

fn remainder(decimal: &str, divisor: u64) -> u64 {
    // u128 keeps remainder*10+digit exact even for a u64 divisor.
    decimal.bytes().fold(0_u128, |remainder, digit| {
        (remainder * 10 + u128::from(digit - b'0')) % u128::from(divisor)
    }) as u64
}
