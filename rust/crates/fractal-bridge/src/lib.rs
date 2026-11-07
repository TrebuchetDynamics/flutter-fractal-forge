//! Flutter-facing probe adapter. Domain/render crates remain platform-independent.

pub mod api;
mod frb_generated;

pub use fractal_core::engine_version;
pub use fractal_render::{EngineCapabilities, engine_capabilities};

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
