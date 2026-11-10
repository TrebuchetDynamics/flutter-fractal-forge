//! Flutter-facing probe adapter. The core remains platform-independent.

pub mod api;
mod frb_generated;

pub use fractal_core::engine_version;
/// Rust support only, not the active Flutter renderer's capabilities.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct EngineCapabilities {
    pub rendering: bool,
}

impl EngineCapabilities {
    pub fn to_json(self) -> String {
        format!(r#"{{"rendering":{}}}"#, self.rendering)
    }
}

pub fn engine_capabilities() -> EngineCapabilities {
    EngineCapabilities { rendering: false }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn engine_version_is_exposed_at_the_bridge() {
        assert_eq!(engine_version(), "0.1.0");
    }

    #[test]
    fn capabilities_serialize_without_advertising_rendering() {
        let capabilities = engine_capabilities();
        assert!(!capabilities.rendering);
        assert_eq!(capabilities.to_json(), r#"{"rendering":false}"#);
    }
}
