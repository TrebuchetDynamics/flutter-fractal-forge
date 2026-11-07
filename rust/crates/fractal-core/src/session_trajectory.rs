//! Typed camera metadata only; no integration, cache or job execution.
use super::{SessionError, Snapshot};
use crate::{
    catalog_baseline::{Preset, View},
    normalization::ViewInput,
    trajectory::{OrbitTrajectorySettings, decode_orbit_trajectory_settings},
};

#[derive(Debug, Clone, Copy, PartialEq)]
pub struct CameraInput {
    pub view: ViewInput,
    pub trajectory: Option<OrbitTrajectorySettings>,
    /// Ingress without typed settings must mark every non-null trajectory so it
    /// rejects rather than silently downgrading to a legacy portrait.
    pub has_trajectory: bool,
}

impl From<ViewInput> for CameraInput {
    fn from(view: ViewInput) -> Self {
        Self {
            view,
            trajectory: None,
            has_trajectory: false,
        }
    }
}

impl CameraInput {
    pub(super) fn trajectory_for(
        self,
        module_id: &str,
    ) -> Result<Option<OrbitTrajectorySettings>, SessionError> {
        if self.has_trajectory && self.trajectory.is_none() {
            return Err(SessionError::UnsupportedTrajectory);
        }
        Ok(self
            .trajectory
            .filter(|settings| settings.is_compatible_with(module_id)))
    }
}

impl Snapshot {
    /// Detached validated settings; scalar camera edits preserve this copy.
    pub fn trajectory(&self) -> Option<OrbitTrajectorySettings> {
        self.trajectory
    }
}

pub(super) fn default_camera(preset: &Preset) -> Result<CameraInput, SessionError> {
    let View {
        zoom,
        pan_x,
        pan_y,
        rot_x,
        rot_y,
        rot_z,
        metadata,
    } = &preset.view;
    let n = |value: &serde_json::Number| {
        value
            .as_f64()
            .filter(|n| n.is_finite())
            .ok_or_else(|| SessionError::InvalidCatalog(preset.id.clone()))
    };
    let raw = metadata
        .get("trajectory")
        .unwrap_or(&serde_json::Value::Null);
    // serde structs also accept positional arrays; saved Dart metadata requires a map.
    if !raw.is_null() && !raw.is_object() {
        return Err(SessionError::UnsupportedTrajectory);
    }
    let trajectory =
        decode_orbit_trajectory_settings(raw).map_err(|_| SessionError::UnsupportedTrajectory)?;
    Ok(CameraInput {
        view: ViewInput {
            zoom: n(zoom)?,
            pan: [n(pan_x)?, n(pan_y)?],
            rotation: [n(rot_x)?, n(rot_y)?, n(rot_z)?],
        },
        trajectory,
        has_trajectory: !raw.is_null(),
    })
}
