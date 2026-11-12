//! Inert instantaneous raw-input owner. Flutter still owns arena/focus routing.
//! No elapsed advancement or tap/momentum completion is performed here.
use crate::{catalog_baseline::Dimension, normalization::ViewInput, physical_view};

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum PointerPhase {
    Down,
    Move,
    Up,
    Cancel,
}
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum PointerKind {
    Touch,
    Mouse,
    Stylus,
}
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum Focus {
    #[default]
    Canvas,
    Control,
    None,
}
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Key {
    Left,
    Right,
    Up,
    Down,
    Plus,
    Minus,
    Reset,
    Unknown,
}
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum KeyPhase {
    Down,
    Repeat,
    Up,
}
#[derive(Debug, Clone, PartialEq)]
pub enum PhysicalInput {
    Pointer {
        id: u64,
        local: [f64; 2],
        phase: PointerPhase,
        kind: PointerKind,
        buttons: u64,
    },
    Wheel {
        local: [f64; 2],
        dy: f64,
    },
    Key {
        key: Key,
        phase: KeyPhase,
    },
    Focus(Focus),
    Wall(i64),
}
#[derive(Debug, Clone, PartialEq)]
pub struct PhysicalEvent {
    pub sequence: u64,
    pub source_us: Option<i64>,
    /// Shell routing decision only, never resolved camera geometry.
    pub consumed: bool,
    pub input: PhysicalInput,
}
#[derive(Debug, Clone)]
pub struct PhysicalContext<'a> {
    /// Shell routing: walk mode excludes ordinary viewer key handling.
    pub viewer_keys_enabled: bool,
    pub dimension: &'a Dimension,
    pub horizontal_orbit_sign: f64,
    pub rotation_locked: bool,
    pub viewport: Option<[f64; 2]>,
    pub view: ViewInput,
}
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Interaction {
    Start,
    End,
    Correction,
}
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum KeyDisposition {
    Handled,
    ControlHandled,
    Ignored,
}
#[derive(Debug, Clone, PartialEq)]
pub enum PhysicalUpdate {
    View { camera: ViewInput, adaptive: bool },
    Pan([f64; 2]),
    Zoom(f64),
    Reset,
}
impl PhysicalUpdate {
    /// Raw candidate, for pure consumers which own normalization/reset policy.
    pub fn view(&self, current: ViewInput) -> ViewInput {
        match self {
            Self::View { camera, .. } => *camera,
            Self::Pan(pan) => ViewInput {
                pan: *pan,
                ..current
            },
            Self::Zoom(zoom) => ViewInput {
                zoom: *zoom,
                ..current
            },
            Self::Reset => ViewInput {
                zoom: 1.0,
                pan: [0.0; 2],
                rotation: [0.0; 3],
            },
        }
    }
}
#[derive(Debug, Clone, PartialEq, Default)]
pub struct PhysicalOutput {
    pub updates: Vec<PhysicalUpdate>,
    pub interactions: Vec<Interaction>,
    pub keys: Vec<KeyDisposition>,
}
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum PhysicalError {
    Sequence,
    InvalidInput,
    UnknownPointer,
    DuplicatePointer,
}
#[derive(Debug, Clone, PartialEq)]
struct Pointer {
    id: u64,
    local: [f64; 2],
}
#[derive(Debug, Clone, PartialEq, Default)]
pub struct PhysicalState {
    sequence: Option<u64>,
    viewport: Option<[f64; 2]>,
    wall_us: i64,
    source_us: Option<i64>,
    focus: Focus,
    pointers: Vec<Pointer>,
    primary_down: Option<[f64; 2]>,
    initial_focal: [f64; 2],
    initial_span: f64,
    initial_angle: f64,
    accepted: bool,
    started: bool,
    start_view: Option<ViewInput>,
    start_focal: [f64; 2],
    two_start: Option<(ViewInput, [f64; 2], f64)>,
    rotation_active: bool,
    last_rotation: f64,
    history: Vec<([f64; 2], i64)>,
}
fn sub(a: [f64; 2], b: [f64; 2]) -> [f64; 2] {
    [a[0] - b[0], a[1] - b[1]]
}
fn length(a: [f64; 2]) -> f64 {
    a[0].hypot(a[1])
}
impl PhysicalState {
    /// Atomic even at the pure seam; rejected events do not consume sequence or anchors.
    pub fn reduce(
        &mut self,
        context: &PhysicalContext<'_>,
        event: &PhysicalEvent,
    ) -> Result<PhysicalOutput, PhysicalError> {
        let mut candidate = self.clone();
        let output = candidate.reduce_inner(context, event)?;
        *self = candidate;
        Ok(output)
    }
    fn geometry(&self) -> ([f64; 2], f64, f64) {
        let n = self.pointers.len().max(1) as f64;
        let focal =
            std::array::from_fn(|i| self.pointers.iter().map(|p| p.local[i]).sum::<f64>() / n);
        let span = self
            .pointers
            .iter()
            .map(|p| length(sub(p.local, focal)))
            .sum::<f64>()
            / n;
        let angle = if self.pointers.len() >= 2 {
            let d = sub(self.pointers[0].local, self.pointers[1].local);
            d[1].atan2(d[0])
        } else {
            0.0
        };
        (focal, span, angle)
    }
    fn reduce_inner(
        &mut self,
        c: &PhysicalContext<'_>,
        e: &PhysicalEvent,
    ) -> Result<PhysicalOutput, PhysicalError> {
        if self.sequence.is_some_and(|s| e.sequence <= s) {
            return Err(PhysicalError::Sequence);
        }
        if c.viewport
            .is_some_and(|v| v.iter().any(|x| !x.is_finite() || *x < 0.0))
            || !c.horizontal_orbit_sign.is_finite()
        {
            return Err(PhysicalError::InvalidInput);
        }
        self.sequence = Some(e.sequence);
        self.viewport = c.viewport;
        self.source_us = e.source_us;
        let mut out = PhysicalOutput::default();
        if e.consumed {
            return Ok(out);
        }
        match e.input {
            PhysicalInput::Wall(us) => self.wall_us = us,
            PhysicalInput::Focus(focus) => self.focus = focus,
            PhysicalInput::Wheel { local, dy } => {
                if !dy.is_finite() || local.iter().any(|x| !x.is_finite()) {
                    return Err(PhysicalError::InvalidInput);
                }
                out.interactions.push(Interaction::Correction);
                out.updates.push(PhysicalUpdate::View {
                    camera: physical_view::focal_zoom(
                        c.view,
                        physical_view::wheel_zoom_target(c.view.zoom, dy),
                        c.dimension,
                        c.viewport,
                        Some(local),
                    ),
                    adaptive: true,
                });
            }
            PhysicalInput::Key { key, phase } => {
                let disposition = if self.focus == Focus::Control {
                    KeyDisposition::ControlHandled
                } else if self.focus != Focus::Canvas
                    || !c.viewer_keys_enabled
                    || phase != KeyPhase::Down
                    || key == Key::Unknown
                {
                    KeyDisposition::Ignored
                } else {
                    KeyDisposition::Handled
                };
                out.keys.push(disposition);
                if disposition != KeyDisposition::Handled {
                    return Ok(out);
                }
                let delta = match key {
                    Key::Left => [-0.08, 0.0],
                    Key::Right => [0.08, 0.0],
                    Key::Up => [0.0, -0.08],
                    Key::Down => [0.0, 0.08],
                    _ => [0.0; 2],
                };
                match key {
                    Key::Plus => out.updates.push(PhysicalUpdate::Zoom(c.view.zoom * 1.2)),
                    Key::Minus => out.updates.push(PhysicalUpdate::Zoom(c.view.zoom / 1.2)),
                    Key::Reset => out.updates.push(PhysicalUpdate::Reset),
                    _ => {
                        let (s, co) = c.view.rotation[2].sin_cos();
                        out.updates.push(PhysicalUpdate::Pan([
                            c.view.pan[0] + delta[0] * co + delta[1] * s,
                            c.view.pan[1] - delta[0] * s + delta[1] * co,
                        ]));
                    }
                }
            }
            PhysicalInput::Pointer {
                id,
                local,
                phase,
                kind,
                ..
            } => {
                if local.iter().any(|x| !x.is_finite()) {
                    return Err(PhysicalError::InvalidInput);
                }
                let previous_focal = self.geometry().0;
                let index = self.pointers.iter().position(|p| p.id == id);
                match phase {
                    PointerPhase::Down => {
                        if index.is_some() {
                            return Err(PhysicalError::DuplicatePointer);
                        }
                        if self.pointers.is_empty() {
                            self.primary_down = Some(local);
                            self.accepted = false;
                        }
                        self.pointers.push(Pointer { id, local });
                    }
                    PointerPhase::Move => {
                        self.pointers
                            .get_mut(index.ok_or(PhysicalError::UnknownPointer)?)
                            .unwrap()
                            .local = local
                    }
                    PointerPhase::Up | PointerPhase::Cancel => {
                        self.pointers
                            .remove(index.ok_or(PhysicalError::UnknownPointer)?);
                    }
                }
                let (focal, span, angle) = self.geometry();
                if phase != PointerPhase::Move {
                    self.initial_focal = focal;
                    self.initial_span = span;
                    self.initial_angle = angle;
                    if self.started {
                        self.started = false;
                    }
                    if self.pointers.len() == 2 && phase == PointerPhase::Down {
                        self.two_start = Some((c.view, focal, span));
                    }
                    if self.pointers.len() == 1 && phase != PointerPhase::Down {
                        self.primary_down = Some(self.pointers[0].local);
                    }
                    if self.pointers.is_empty() {
                        self.primary_down = None;
                        self.two_start = None;
                        self.accepted = false;
                    }
                    return Ok(out);
                }
                let was_accepted = self.accepted;
                let slop = if kind == PointerKind::Mouse {
                    1.0
                } else {
                    18.0
                };
                if !self.accepted
                    && ((span - self.initial_span).abs() > slop
                        || length(sub(focal, self.initial_focal)) > slop * 2.0)
                {
                    self.accepted = true;
                }
                if !self.accepted {
                    return Ok(out);
                }
                let restarting = !self.started;
                if restarting {
                    self.started = true;
                    self.start_view = Some(c.view);
                    self.start_focal = focal;
                    self.rotation_active = false;
                    self.last_rotation = 0.0;
                    self.history.clear();
                    out.interactions.push(Interaction::Start);
                    if !was_accepted {
                        self.initial_focal = focal;
                        self.initial_span = span;
                        self.initial_angle = angle;
                    }
                }
                let (camera, adaptive) = if self.pointers.len() == 1 {
                    let delta = sub(
                        focal,
                        if restarting {
                            self.primary_down.unwrap_or(focal)
                        } else {
                            previous_focal
                        },
                    );
                    self.history
                        .push((focal, e.source_us.unwrap_or(self.wall_us) / 1000));
                    if self.history.len() > 5 {
                        self.history.remove(0);
                    }
                    (
                        if matches!(c.dimension, Dimension::ThreeD) {
                            physical_view::orbit(
                                c.view,
                                delta,
                                c.viewport.unwrap_or([1.0; 2]),
                                c.horizontal_orbit_sign,
                                c.rotation_locked,
                            )
                        } else {
                            physical_view::drag_2d(c.view, delta, c.viewport.unwrap_or([1.0; 2]))
                        },
                        false,
                    )
                } else {
                    let mut start = self.start_view.unwrap();
                    let mut start_focal = self.start_focal;
                    let mut scale = if self.initial_span > 0.0 {
                        span / self.initial_span
                    } else {
                        1.0
                    };
                    if matches!(c.dimension, Dimension::ThreeD)
                        && self.pointers.len() == 2
                        && let Some((view, focal, span0)) = self.two_start
                        && span0 > 0.0
                    {
                        start = view;
                        start_focal = focal;
                        scale = span / span0;
                    }
                    let rotation = angle - self.initial_angle;
                    if !c.rotation_locked && rotation.abs() > 0.12 {
                        self.rotation_active = true;
                    }
                    let twist = if self.rotation_active { rotation } else { 0.0 };
                    let camera = if let Some(viewport) = c.viewport {
                        physical_view::pinch(
                            start,
                            c.view,
                            c.dimension,
                            &physical_view::Pinch {
                                viewport,
                                start_focal,
                                focal,
                                scale,
                                rotation_delta: twist,
                                rotation_locked: c.rotation_locked,
                            },
                        )
                    } else {
                        let mut camera = physical_view::focal_zoom(
                            c.view,
                            start.zoom * scale,
                            c.dimension,
                            None,
                            None,
                        );
                        if matches!(c.dimension, Dimension::ThreeD)
                            && !c.rotation_locked
                            && rotation != 0.0
                        {
                            camera.rotation[2] += rotation - self.last_rotation;
                            self.last_rotation = rotation;
                        }
                        camera
                    };
                    (camera, true)
                };
                out.updates.push(PhysicalUpdate::View { camera, adaptive });
            }
        }
        Ok(out)
    }
}
