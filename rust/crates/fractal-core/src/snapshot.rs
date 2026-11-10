//! Persistent probe state, independent of application state and rendering.
use crate::view::ViewState;

#[derive(Debug, Clone, Copy, PartialEq)]
pub struct EngineSnapshot {
    pub session_id: u64,
    pub revision: u64,
    pub view: ViewState,
}

pub struct EngineState {
    snapshot: EngineSnapshot,
}

impl EngineState {
    pub fn new(session_id: u64) -> Self {
        Self {
            snapshot: EngineSnapshot {
                session_id,
                revision: 0,
                view: ViewState::default(),
            },
        }
    }

    pub fn snapshot(&self) -> EngineSnapshot {
        self.snapshot
    }

    // No mutation command crosses the bootstrap FFI.
    #[cfg_attr(
        not(test),
        expect(
            dead_code,
            reason = "internal commit seam reserved for later state ownership"
        )
    )]
    fn commit_view(&mut self, view: ViewState) -> Result<(), &'static str> {
        if !view.is_finite() {
            return Err("Nonfinite probe view");
        }
        let revision = self
            .snapshot
            .revision
            .checked_add(1)
            .ok_or("Probe revision exhausted")?;
        self.snapshot = EngineSnapshot {
            revision,
            view,
            ..self.snapshot
        };
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn snapshots_are_neutral_stable_and_commit_atomically_without_wrap() {
        let mut first = EngineState::new(1);
        let second = EngineState::new(2);
        let initial = first.snapshot();
        assert_eq!(initial.view, ViewState::default());
        assert!(initial.view.is_finite());
        assert_eq!(initial.revision, 0);
        assert_eq!(initial, first.snapshot());
        assert_ne!(initial.session_id, second.snapshot().session_id);
        first
            .commit_view(ViewState {
                center_x: 2.0,
                ..initial.view
            })
            .unwrap();
        assert_eq!(first.snapshot().revision, 1);
        assert_eq!(second.snapshot().revision, 0);
        let committed = first.snapshot();
        assert!(
            first
                .commit_view(ViewState {
                    zoom: f64::NAN,
                    ..initial.view
                })
                .is_err()
        );
        assert_eq!(first.snapshot(), committed);
        first.snapshot.revision = u64::MAX;
        let last = first.snapshot();
        assert_eq!(
            first.commit_view(initial.view),
            Err("Probe revision exhausted")
        );
        assert_eq!(first.snapshot(), last);
    }
}
