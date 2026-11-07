//! Seeded Dart VM 3.13.7 Random, not browser, secure or cross-version randomness.
//! Port of dart-sdk/lib/_internal/vm/lib/math_patch.dart, bound by the oracle.

use std::fmt;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct InvalidBound(pub i64);

impl fmt::Display for InvalidBound {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "next_int bound must be in 1..=2^32, got {}", self.0)
    }
}

impl std::error::Error for InvalidBound {}

#[derive(Debug, Clone)]
pub struct SeededRandom {
    state: u64,
}

impl SeededRandom {
    /// Signed VM seeds are mixed as wrapping 64-bit words with logical shifts.
    pub fn new(seed: i64) -> Self {
        let mut n = seed as u64;
        n = (!n).wrapping_add(n.wrapping_shl(21));
        n ^= n >> 24;
        n = n.wrapping_mul(265);
        n ^= n >> 14;
        n = n.wrapping_mul(21);
        n ^= n >> 28;
        n = n.wrapping_add(n.wrapping_shl(31));
        let mut random = Self {
            state: if n == 0 { 0x5a17 } else { n },
        };
        for _ in 0..4 {
            random.next_state();
        }
        random
    }

    fn next_state(&mut self) -> u64 {
        self.state = 0xffffda61_u64
            .wrapping_mul(self.state & 0xffffffff)
            .wrapping_add(self.state >> 32);
        self.state & 0xffffffff
    }

    /// Invalid bounds return before consuming state. Even bound 1 draws once.
    pub fn next_int(&mut self, max: i64) -> Result<i64, InvalidBound> {
        if !(1..=1_i64 << 32).contains(&max) {
            return Err(InvalidBound(max));
        }
        let max = max as u64;
        if max.is_power_of_two() {
            return Ok((self.next_state() & (max - 1)) as i64);
        }
        loop {
            let rnd32 = self.next_state();
            let result = rnd32 % max;
            // Deliberately >, not >=: this is the pinned VM rejection rule.
            if rnd32 - result + max <= 1_u64 << 32 {
                return Ok(result as i64);
            }
        }
    }

    pub fn next_double(&mut self) -> f64 {
        let high = self.next_int(1 << 26).expect("constant bound");
        let low = self.next_int(1 << 27).expect("constant bound");
        ((high as f64 * (1_u64 << 27) as f64) + low as f64) / (1_u64 << 53) as f64
    }

    pub fn next_bool(&mut self) -> bool {
        self.next_int(2).expect("constant bound") == 0
    }
}
