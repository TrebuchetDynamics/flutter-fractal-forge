//! M1 probe only: no mathematical state or rendering ownership.
use std::sync::atomic::{AtomicBool, Ordering};

use flutter_rust_bridge::frb;

/// An opaque session; closing one handle never closes another.
#[frb(opaque)]
pub struct Engine {
    closed: AtomicBool,
}

pub struct Capabilities {
    pub rendering: bool,
}

#[frb(sync)]
pub fn engine_version() -> String {
    fractal_core::engine_version()
}

impl Engine {
    #[frb(sync)]
    pub fn new() -> Self {
        Self {
            closed: AtomicBool::new(false),
        }
    }

    #[frb(sync)]
    pub fn capabilities(&self) -> Result<Capabilities, String> {
        if self.closed.load(Ordering::SeqCst) {
            return Err("Rust engine session is closed".to_owned());
        }
        Ok(Capabilities {
            rendering: fractal_render::engine_capabilities().rendering,
        })
    }

    #[frb(sync)]
    pub fn shutdown(&self) {
        self.closed.store(true, Ordering::SeqCst);
    }
}

impl Default for Engine {
    #[frb(ignore)]
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn opaque_sessions_close_idempotently_and_independently() {
        assert_eq!(engine_version(), "0.1.0");
        let first = Engine::new();
        let second = Engine::new();
        assert!(!first.capabilities().unwrap().rendering);
        first.shutdown();
        first.shutdown();
        assert_eq!(
            first.capabilities().err().as_deref(),
            Some("Rust engine session is closed")
        );
        assert!(!second.capabilities().unwrap().rendering);
        second.shutdown();
        assert!(second.capabilities().is_err());
    }
}
