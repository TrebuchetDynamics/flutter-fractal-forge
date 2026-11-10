//! Fixed debug instrumentation, not a production identity source or security boundary.
use super::Snapshot;

impl Snapshot {
    /// Clone validated state; never mutate a Session or accept caller counters.
    pub fn debug_u64_fixtures(&self) -> [Self; 2] {
        [
            (9_007_199_254_740_993, u64::MAX - 1),
            (u64::MAX - 1, u64::MAX),
        ]
        .map(|(session_id, revision)| Self {
            session_id,
            revision,
            ..self.clone()
        })
    }
}
