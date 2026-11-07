//! Rendering service boundary. No renderer is implemented yet.

/// Rust engine support, not the capabilities of the existing Flutter renderer.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct EngineCapabilities {
    pub rendering: bool,
}

impl EngineCapabilities {
    /// shortcut: Boolean-only JSON; use a serializer when the descriptor expands.
    pub fn to_json(self) -> String {
        format!(r#"{{"rendering":{}}}"#, self.rendering)
    }
}

/// No CPU, GPU or export implementation is available in this foundation.
pub fn engine_capabilities() -> EngineCapabilities {
    EngineCapabilities { rendering: false }
}
