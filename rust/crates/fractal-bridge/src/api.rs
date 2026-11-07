//! Default-off probe and inert state transport; mathematical policies remain in core.
use std::{
    collections::{BTreeMap, HashMap},
    sync::{
        Arc, Mutex,
        atomic::{AtomicBool, AtomicU64, Ordering},
    },
};

use fractal_core::{
    catalog_baseline::CatalogBaseline,
    normalization::{RawScalar, ViewInput},
    session::{CameraInput, Command, Session, Snapshot},
};

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

// Opaque typed payloads avoid adding Freezed/build_runner dependencies for Dart
// unions. Constructors convert once; no JSON command protocol or Dart math owner.
#[derive(Debug, Clone)]
#[frb(opaque)]
pub struct StateValue {
    inner: RawScalar,
}

impl StateValue {
    #[frb(sync)]
    pub fn from_float(value: f64) -> Self {
        Self {
            inner: RawScalar::Float(value),
        }
    }

    /// Exact JSON number representation, distinct from exact text parameters.
    #[frb(sync)]
    pub fn from_number(value: String) -> Result<Self, String> {
        Ok(Self {
            inner: RawScalar::Number(value.parse().map_err(|e| format!("Invalid number: {e}"))?),
        })
    }

    #[frb(sync)]
    pub fn from_boolean(value: bool) -> Self {
        Self {
            inner: RawScalar::Boolean(value),
        }
    }

    #[frb(sync)]
    pub fn from_text(value: String) -> Self {
        Self {
            inner: RawScalar::Text(value),
        }
    }

    #[frb(sync)]
    pub fn number(&self) -> Option<String> {
        match &self.inner {
            RawScalar::Number(value) => Some(value.to_string()),
            _ => None,
        }
    }

    #[frb(sync)]
    pub fn float(&self) -> Option<f64> {
        match self.inner {
            RawScalar::Float(value) => Some(value),
            _ => None,
        }
    }

    #[frb(sync)]
    pub fn boolean(&self) -> Option<bool> {
        match self.inner {
            RawScalar::Boolean(value) => Some(value),
            _ => None,
        }
    }

    #[frb(sync)]
    pub fn text(&self) -> Option<String> {
        match &self.inner {
            RawScalar::Text(value) => Some(value.clone()),
            _ => None,
        }
    }
}

#[derive(Debug, Clone)]
pub struct StateView {
    pub zoom: f64,
    pub pan_x: f64,
    pub pan_y: f64,
    pub rot_x: f64,
    pub rot_y: f64,
    pub rot_z: f64,
}

#[derive(Debug, Clone)]
pub struct StateCamera {
    pub view: StateView,
    pub has_trajectory: bool,
}

impl StateCamera {
    fn into_core(self) -> CameraInput {
        CameraInput {
            view: ViewInput {
                zoom: self.view.zoom,
                pan: [self.view.pan_x, self.view.pan_y],
                rotation: [self.view.rot_x, self.view.rot_y, self.view.rot_z],
            },
            has_trajectory: self.has_trajectory,
        }
    }
}

fn core_params(params: HashMap<String, StateValue>) -> BTreeMap<String, RawScalar> {
    params
        .into_iter()
        .map(|(id, value)| (id, value.inner))
        .collect()
}

#[derive(Debug, Clone)]
#[frb(opaque)]
pub struct StateCommand {
    inner: Command,
}

impl StateCommand {
    #[frb(sync)]
    pub fn zoom(value: f64) -> Self {
        Self {
            inner: Command::Zoom(value),
        }
    }

    #[frb(sync)]
    pub fn pan(x: f64, y: f64) -> Self {
        Self {
            inner: Command::Pan([x, y]),
        }
    }

    #[frb(sync)]
    pub fn rotation(x: f64, y: f64, z: f64) -> Self {
        Self {
            inner: Command::Rotation([x, y, z]),
        }
    }

    #[frb(sync)]
    pub fn view(camera: StateCamera, adaptive: bool) -> Self {
        Self {
            inner: Command::View {
                camera: camera.into_core(),
                adaptive,
            },
        }
    }

    #[frb(sync)]
    pub fn param(id: String, value: StateValue) -> Self {
        Self {
            inner: Command::Param {
                id,
                value: value.inner,
            },
        }
    }

    #[frb(sync)]
    pub fn select_module(
        module_id: String,
        reset_view: bool,
        initial_params: HashMap<String, StateValue>,
    ) -> Self {
        Self {
            inner: Command::SelectModule {
                module_id,
                reset_view,
                initial_params: core_params(initial_params),
            },
        }
    }

    #[frb(sync)]
    pub fn transparent(value: bool) -> Self {
        Self {
            inner: Command::Transparent(value),
        }
    }

    #[frb(sync)]
    pub fn glow_enabled(value: bool) -> Self {
        Self {
            inner: Command::GlowEnabled(value),
        }
    }

    #[frb(sync)]
    pub fn glow_sigma(value: f64) -> Self {
        Self {
            inner: Command::GlowSigma(value),
        }
    }

    #[frb(sync)]
    pub fn glow_intensity(value: f64) -> Self {
        Self {
            inner: Command::GlowIntensity(value),
        }
    }

    #[frb(sync)]
    pub fn fluid_mode_enabled(value: bool) -> Self {
        Self {
            inner: Command::FluidModeEnabled(value),
        }
    }

    #[frb(sync)]
    pub fn fluid_strength(value: f64) -> Self {
        Self {
            inner: Command::FluidStrength(value),
        }
    }

    #[frb(sync)]
    pub fn rotation_locked(value: bool) -> Self {
        Self {
            inner: Command::RotationLocked(value),
        }
    }

    #[frb(sync)]
    pub fn kaleidoscope_enabled(value: bool) -> Self {
        Self {
            inner: Command::KaleidoscopeEnabled(value),
        }
    }

    #[frb(sync)]
    pub fn kaleidoscope_sectors(value: i64) -> Self {
        Self {
            inner: Command::KaleidoscopeSectors(value),
        }
    }

    #[frb(sync)]
    pub fn kaleidoscope_mirror(value: bool) -> Self {
        Self {
            inner: Command::KaleidoscopeMirror(value),
        }
    }

    #[frb(sync)]
    pub fn kaleidoscope_rotation(value: f64) -> Self {
        Self {
            inner: Command::KaleidoscopeRotation(value),
        }
    }

    #[frb(sync)]
    pub fn kaleidoscope_mirror_mode(value: i64) -> Self {
        Self {
            inner: Command::KaleidoscopeMirrorMode(value),
        }
    }

    #[frb(sync)]
    pub fn apply_preset(
        module_id: String,
        params: HashMap<String, StateValue>,
        camera: StateCamera,
    ) -> Self {
        Self {
            inner: Command::ApplyPreset {
                module_id,
                params: core_params(params),
                camera: camera.into_core(),
            },
        }
    }

    #[frb(sync)]
    pub fn load(
        module_id: Option<String>,
        params: HashMap<String, StateValue>,
        camera: StateCamera,
        transparent: bool,
    ) -> Self {
        Self {
            inner: Command::Load {
                module_id,
                params: core_params(params),
                camera: camera.into_core(),
                transparent,
            },
        }
    }

    #[frb(sync)]
    pub fn reset_params() -> Self {
        Self {
            inner: Command::ResetParams,
        }
    }

    #[frb(sync)]
    pub fn reset_view() -> Self {
        Self {
            inner: Command::ResetView,
        }
    }

    #[frb(sync)]
    pub fn reset_session() -> Self {
        Self {
            inner: Command::ResetSession,
        }
    }

    #[frb(sync)]
    pub fn unsupported(operation: String) -> Self {
        Self {
            inner: Command::Unsupported { operation },
        }
    }
}

/// Detached immutable core copy; collection getters return further detached copies.
#[derive(Debug)]
#[frb(opaque)]
pub struct StateSnapshot {
    inner: Snapshot,
}

impl StateSnapshot {
    #[frb(sync)]
    pub fn session_id(&self) -> u64 {
        self.inner.session_id()
    }

    #[frb(sync)]
    pub fn revision(&self) -> u64 {
        self.inner.revision()
    }

    #[frb(sync)]
    pub fn module_id(&self) -> String {
        self.inner.module_id().into()
    }

    #[frb(sync)]
    pub fn params(&self) -> HashMap<String, StateValue> {
        self.inner
            .params()
            .iter()
            .map(|(id, value)| {
                (
                    id.clone(),
                    StateValue {
                        inner: value.clone().into(),
                    },
                )
            })
            .collect()
    }

    #[frb(sync)]
    pub fn view(&self) -> StateView {
        let view = self.inner.view();
        StateView {
            zoom: view.zoom(),
            pan_x: view.pan()[0],
            pan_y: view.pan()[1],
            rot_x: view.rotation()[0],
            rot_y: view.rotation()[1],
            rot_z: view.rotation()[2],
        }
    }

    #[frb(sync)]
    pub fn transparent_background(&self) -> bool {
        self.inner.transparent_background()
    }

    #[frb(sync)]
    pub fn glow_enabled(&self) -> bool {
        self.inner.glow_enabled()
    }

    #[frb(sync)]
    pub fn glow_sigma(&self) -> f64 {
        self.inner.glow_sigma()
    }

    #[frb(sync)]
    pub fn glow_intensity(&self) -> f64 {
        self.inner.glow_intensity()
    }

    #[frb(sync)]
    pub fn fluid_mode_enabled(&self) -> bool {
        self.inner.fluid_mode_enabled()
    }

    #[frb(sync)]
    pub fn fluid_strength(&self) -> f64 {
        self.inner.fluid_strength()
    }

    #[frb(sync)]
    pub fn rotation_locked(&self) -> bool {
        self.inner.rotation_locked()
    }

    #[frb(sync)]
    pub fn kaleidoscope_enabled(&self) -> bool {
        self.inner.kaleidoscope_enabled()
    }

    #[frb(sync)]
    pub fn kaleidoscope_sectors(&self) -> i64 {
        self.inner.kaleidoscope_sectors()
    }

    #[frb(sync)]
    pub fn kaleidoscope_mirror(&self) -> bool {
        self.inner.kaleidoscope_mirror()
    }

    #[frb(sync)]
    pub fn kaleidoscope_rotation(&self) -> f64 {
        self.inner.kaleidoscope_rotation()
    }

    #[frb(sync)]
    pub fn kaleidoscope_mirror_mode(&self) -> i64 {
        self.inner.kaleidoscope_mirror_mode()
    }

    #[frb(sync)]
    pub fn last_adaptive_zoom(&self) -> f64 {
        self.inner.last_adaptive_zoom()
    }
}

static LAST_SESSION_ID: AtomicU64 = AtomicU64::new(0);

fn allocate_session_id(last: &AtomicU64) -> Result<u64, String> {
    last.fetch_update(Ordering::SeqCst, Ordering::SeqCst, |value| {
        value.checked_add(1)
    })
    .map(|previous| previous + 1)
    .map_err(|_| "Rust state session identity exhausted".into())
}

#[derive(Debug)]
#[frb(opaque)]
pub struct StateSession {
    // A single lock linearizes transactions, snapshots and shutdown. Dropping the
    // option releases the catalog/state; a poisoned lock never exposes last-good state.
    inner: Mutex<Option<Session>>,
}

impl StateSession {
    /// Consume and validate all four original envelopes once, not per command/frame.
    #[frb(sync)]
    pub fn new(
        modules: String,
        parameters: String,
        presets: String,
        capabilities: String,
        module_id: String,
    ) -> Result<Self, String> {
        let catalog = CatalogBaseline::from_jsons(&modules, &parameters, &presets, &capabilities)
            .map_err(|e| e.to_string())?;
        let session = Session::new(
            Arc::new(catalog),
            allocate_session_id(&LAST_SESSION_ID)?,
            &module_id,
        )
        .map_err(|e| e.to_string())?;
        Ok(Self {
            inner: Mutex::new(Some(session)),
        })
    }

    #[frb(sync)]
    pub fn snapshot(&self) -> Result<StateSnapshot, String> {
        let guard = self
            .inner
            .lock()
            .map_err(|_| "Rust state session lock poisoned")?;
        let session = guard.as_ref().ok_or("Rust state session is closed")?;
        Ok(StateSnapshot {
            inner: session.snapshot(),
        })
    }

    #[frb(sync)]
    pub fn apply_batch(
        &self,
        session_id: u64,
        expected_revision: u64,
        commands: Vec<StateCommand>,
    ) -> Result<StateSnapshot, String> {
        let mut guard = self
            .inner
            .lock()
            .map_err(|_| "Rust state session lock poisoned")?;
        let session = guard.as_mut().ok_or("Rust state session is closed")?;
        let commands: Vec<_> = commands.into_iter().map(|command| command.inner).collect();
        session
            .apply_batch(session_id, expected_revision, &commands)
            .map(|inner| StateSnapshot { inner })
            .map_err(|e| e.to_string())
    }

    #[frb(sync)]
    pub fn shutdown(&self) -> Result<(), String> {
        self.inner
            .lock()
            .map_err(|_| "Rust state session lock poisoned")?
            .take();
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn checked_identity_exhaustion_is_unique_even_under_contention() {
        let last = Arc::new(AtomicU64::new(u64::MAX - 2));
        let workers: Vec<_> = (0..4)
            .map(|_| {
                let last = last.clone();
                std::thread::spawn(move || allocate_session_id(&last))
            })
            .collect();
        let mut ids: Vec<_> = workers
            .into_iter()
            .filter_map(|w| w.join().unwrap().ok())
            .collect();
        ids.sort_unstable();
        assert_eq!(ids, vec![u64::MAX - 1, u64::MAX]);
        assert!(allocate_session_id(&last).is_err());
        assert_eq!(last.load(Ordering::SeqCst), u64::MAX);
    }

    #[test]
    fn generated_rust_u64_codec_preserves_large_identity_and_revision_operands() {
        use crate::frb_generated::SseEncode;
        use flutter_rust_bridge::for_generated::SseSerializer;
        let id = (1_u64 << 53) + 1;
        let catalog = CatalogBaseline::from_jsons(
            include_str!("../../../../migration/baseline/modules.json"),
            include_str!("../../../../migration/baseline/parameters.json"),
            include_str!("../../../../migration/baseline/presets.json"),
            include_str!("../../../../migration/baseline/capabilities.json"),
        )
        .unwrap();
        // Private setup only: no public identity/revision setter is exposed.
        let session = StateSession {
            inner: Mutex::new(Some(
                Session::new(Arc::new(catalog), id, "mandelbrot").unwrap(),
            )),
        };
        assert_eq!(session.snapshot().unwrap().session_id(), id);
        assert_eq!(
            session.apply_batch(id - 1, 0, vec![]).unwrap_err(),
            "WrongSession"
        );
        assert_eq!(
            session.apply_batch(id, id, vec![]).unwrap_err(),
            "StaleRevision"
        );
        assert_eq!(session.apply_batch(id, 0, vec![]).unwrap().session_id(), id);
        // The same generated u64 codec serves snapshot identity/revision and
        // apply_batch operands. This is Rust-side evidence, not executed Dart/native proof.
        // Core's existing private revision-exhaustion test covers large actual revisions.
        for value in [
            session.snapshot().unwrap().session_id(),
            u64::MAX - 1,
            u64::MAX,
        ] {
            let mut serializer = SseSerializer::new();
            value.sse_encode(&mut serializer);
            assert_eq!(serializer.cursor.into_inner(), value.to_ne_bytes());
        }
    }

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
