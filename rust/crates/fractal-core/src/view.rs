//! Neutral probe coordinates; center components retain Dart pan semantics.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct ViewState {
    pub center_x: f64,
    pub center_y: f64,
    pub zoom: f64,
    pub rotation_x: f64,
    pub rotation_y: f64,
    pub rotation_z: f64,
}

impl Default for ViewState {
    fn default() -> Self {
        Self {
            center_x: 0.0,
            center_y: 0.0,
            zoom: 1.0,
            rotation_x: 0.0,
            rotation_y: 0.0,
            rotation_z: 0.0,
        }
    }
}

impl ViewState {
    pub fn is_finite(self) -> bool {
        [
            self.center_x,
            self.center_y,
            self.zoom,
            self.rotation_x,
            self.rotation_y,
            self.rotation_z,
        ]
        .into_iter()
        .all(f64::is_finite)
    }
}
