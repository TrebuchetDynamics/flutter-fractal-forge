//! Hidden clock/animation state shared by the raw pointer owner, never a camera owner.
use super::*;
use crate::normalization;

#[derive(Debug, Clone, PartialEq)]
struct TapAnimation {
    start: ViewInput,
    target: ViewInput,
    focal: [f64; 2],
    double: bool,
}
#[derive(Debug, Clone, PartialEq, Default)]
pub(super) struct PhysicalTime {
    generation: u64,
    pump_us: i64,
    elapsed_us: i64,
    anchored: bool,
    pending: bool,
    pan: Option<[f64; 2]>,
    zoom: Option<f64>,
    tap: Option<TapAnimation>,
    pub zoom_velocity: f64,
    pub last_scale: f64,
    pub zoom_focal: [f64; 2],
    two_down: Vec<(u64, [f64; 2])>,
    two_at: i64,
    two_candidate: bool,
    last_raw: Option<(i64, [f64; 2])>,
    last_double: Option<i64>,
    pub disposed: bool,
}
impl PhysicalState {
    pub fn generation(&self) -> u64 {
        self.time.generation
    }

    /// Module replacement invalidates callbacks and recognizer anchors atomically.
    pub fn invalidate(&mut self) -> Result<(), PhysicalError> {
        let generation = self
            .time
            .generation
            .checked_add(1)
            .ok_or(PhysicalError::TimeOverflow)?;
        let sequence = self.sequence;
        let wall_us = self.wall_us;
        let focus = self.focus;
        let pump_us = self.time.pump_us;
        *self = Self::default();
        self.sequence = sequence;
        self.wall_us = wall_us;
        self.focus = focus;
        self.time.generation = generation;
        self.time.pump_us = pump_us;
        Ok(())
    }
    fn stop_time(&mut self) -> Result<(), PhysicalError> {
        self.time.generation = self
            .time
            .generation
            .checked_add(1)
            .ok_or(PhysicalError::TimeOverflow)?;
        self.time.pan = None;
        self.time.zoom = None;
        self.time.tap = None;
        self.time.pending = false;
        self.time.anchored = false;
        self.time.elapsed_us = 0;
        Ok(())
    }
    pub(super) fn begin(&mut self, out: &mut PhysicalOutput) -> Result<(), PhysicalError> {
        self.stop_time()?;
        self.time.zoom_velocity = 0.0;
        self.time.last_scale = 1.0;
        out.interactions.push(Interaction::Start);
        Ok(())
    }
    pub(super) fn release(&mut self, out: &mut PhysicalOutput) -> Result<(), PhysicalError> {
        if self.history.len() >= 2 {
            let (first, a) = self.history[0];
            let (last, b) = *self.history.last().unwrap();
            let dt = b.checked_sub(a).ok_or(PhysicalError::TimeOverflow)?;
            if dt > 0 {
                let velocity = sub(last, first).map(|v| v / dt as f64 * 16.0);
                if length(velocity) > 5.0 {
                    self.time.pan = Some(velocity);
                }
            }
        }
        self.history.clear();
        if self.time.zoom_velocity.abs() > 0.01 {
            self.time.zoom = Some(self.time.zoom_velocity);
        }
        if self.time.tap.is_none() {
            if self.time.pan.is_some() || self.time.zoom.is_some() {
                self.time.pending = true;
                self.time.anchored = false;
                self.time.elapsed_us = 0;
            } else {
                out.interactions.push(Interaction::End);
            }
        }
        Ok(())
    }
    fn tap(
        &mut self,
        c: &PhysicalContext<'_>,
        focal: [f64; 2],
        double: bool,
        out: &mut PhysicalOutput,
    ) -> Result<(), PhysicalError> {
        self.stop_time()?;
        let zoom = (c.view.zoom * if double { 2.0 } else { 0.5 })
            .clamp(normalization::DEFAULT_MIN_ZOOM, normalization::MAX_ZOOM);
        let target = physical_view::focal_zoom(c.view, zoom, c.dimension, c.viewport, Some(focal));
        self.time.tap = Some(TapAnimation {
            start: c.view,
            target,
            focal,
            double,
        });
        out.interactions.push(Interaction::Start);
        Ok(())
    }
    pub(super) fn raw_time(
        &mut self,
        c: &PhysicalContext<'_>,
        id: u64,
        local: [f64; 2],
        phase: PointerPhase,
        out: &mut PhysicalOutput,
    ) -> Result<(), PhysicalError> {
        match phase {
            PointerPhase::Down => {
                if !self.pointers.is_empty() {
                    self.time.last_raw = None;
                }
                if self.pointers.len() == 1 {
                    self.time.two_candidate = true;
                    self.time.two_at = self.wall_us;
                    self.time.two_down = self
                        .pointers
                        .iter()
                        .map(|p| (p.id, p.local))
                        .chain([(id, local)])
                        .collect();
                } else if self.pointers.len() > 1 {
                    self.time.two_candidate = false;
                }
            }
            PointerPhase::Move => {
                if self
                    .time
                    .two_down
                    .iter()
                    .any(|(i, p)| *i == id && length(sub(local, *p)) > 18.0)
                {
                    self.time.two_candidate = false;
                }
            }
            PointerPhase::Up | PointerPhase::Cancel => {
                if phase == PointerPhase::Up {
                    let ms = self
                        .wall_us
                        .checked_sub(self.time.two_at)
                        .ok_or(PhysicalError::TimeOverflow)?
                        / 1000;
                    if self.time.two_candidate && self.pointers.len() == 2 && ms <= 220 {
                        self.tap(c, self.geometry().0, false, out)?;
                    }
                    if self.pointers.len() == 1 {
                        if let Some((at, pos)) = self.time.last_raw {
                            let gap = self
                                .wall_us
                                .checked_sub(at)
                                .ok_or(PhysicalError::TimeOverflow)?
                                / 1000;
                            if gap <= 280 && length(sub(local, pos)) <= 28.0 {
                                let duplicate = self
                                    .time
                                    .last_double
                                    .map(|at| {
                                        self.wall_us
                                            .checked_sub(at)
                                            .map(|d| d / 1000 < 120)
                                            .ok_or(PhysicalError::TimeOverflow)
                                    })
                                    .transpose()?
                                    .unwrap_or(false);
                                if !duplicate {
                                    self.time.last_double = Some(self.wall_us);
                                    self.tap(c, local, true, out)?;
                                }
                                self.time.last_raw = None;
                            } else {
                                self.time.last_raw = Some((self.wall_us, local));
                            }
                        } else {
                            self.time.last_raw = Some((self.wall_us, local));
                        }
                    }
                }
                self.time.two_candidate = false;
                self.time.two_down.clear();
            }
        }
        Ok(())
    }
    pub(super) fn pump(
        &mut self,
        c: &PhysicalContext<'_>,
        generation: u64,
        delta_us: i64,
        out: &mut PhysicalOutput,
    ) -> Result<(), PhysicalError> {
        if delta_us < 0 {
            return Err(PhysicalError::InvalidInput);
        }
        if generation != self.time.generation || self.time.disposed {
            return Ok(());
        }
        self.time.pump_us = self
            .time
            .pump_us
            .checked_add(delta_us)
            .ok_or(PhysicalError::TimeOverflow)?;
        if self.time.pan.is_none() && self.time.zoom.is_none() && self.time.tap.is_none() {
            return Ok(());
        }
        if !self.time.anchored {
            self.time.anchored = true;
            return Ok(());
        }
        let limit = if self.time.tap.is_some() {
            200000
        } else {
            2000000
        };
        let elapsed = self
            .time
            .elapsed_us
            .checked_add(delta_us)
            .ok_or(PhysicalError::TimeOverflow)?
            .min(limit);
        let dt = elapsed - self.time.elapsed_us;
        self.time.elapsed_us = elapsed;
        let mut camera = c.view;
        // Flutter registers the zoom ticker before the pan ticker.
        if let Some(v) = self.time.zoom {
            let step = physical_view::advance_zoom(v, dt);
            let zoom = (camera.zoom * 2.0_f64.powf(step.log_zoom_delta))
                .clamp(normalization::DEFAULT_MIN_ZOOM, normalization::MAX_ZOOM);
            if step.log_zoom_delta != 0.0 {
                camera = if matches!(c.dimension, Dimension::ThreeD) {
                    ViewInput { zoom, ..camera }
                } else {
                    physical_view::focal_zoom(
                        camera,
                        zoom,
                        c.dimension,
                        c.viewport,
                        Some(self.time.zoom_focal),
                    )
                };
                out.updates.push(PhysicalUpdate::View {
                    camera,
                    adaptive: true,
                });
            }
            self.time.zoom = if step.velocity == 0.0
                || elapsed == limit
                || zoom == normalization::DEFAULT_MIN_ZOOM
                || zoom == normalization::MAX_ZOOM
            {
                None
            } else {
                Some(step.velocity)
            };
        }
        if let Some(v) = self.time.pan {
            let step = physical_view::advance_pan(v, dt);
            let mut velocity = step.velocity;
            if step.displacement != [0.0; 2] {
                if matches!(c.dimension, Dimension::ThreeD) {
                    camera = physical_view::orbit(
                        camera,
                        step.displacement,
                        c.viewport.unwrap_or([1.0; 2]),
                        c.horizontal_orbit_sign,
                        false,
                    );
                } else {
                    let viewport = c.viewport.unwrap_or([1.0; 2]);
                    let scale = viewport[0].min(viewport[1]).max(1.0);
                    let pan = std::array::from_fn(|i| {
                        camera.pan[i] - step.displacement[i] / scale / camera.zoom
                    });
                    let bounded = physical_view::drag_2d(camera, step.displacement, viewport).pan;
                    if bounded != pan {
                        velocity = velocity.map(|v| v * 0.5);
                    }
                    camera.pan = bounded;
                }
                out.updates.push(PhysicalUpdate::View {
                    camera,
                    adaptive: false,
                });
            }
            self.time.pan = if velocity == [0.0; 2] || elapsed == limit {
                None
            } else {
                Some(velocity)
            };
        }
        if let Some(tap) = &self.time.tap {
            let t = ease_out_cubic(elapsed as f64 / 200000.0);
            let zoom = tap.start.zoom + (tap.target.zoom - tap.start.zoom) * t;
            if tap.double {
                camera.zoom = zoom;
                let pan_t = t * tap.target.zoom / zoom;
                camera.pan = std::array::from_fn(|i| {
                    tap.start.pan[i] + (tap.target.pan[i] - tap.start.pan[i]) * pan_t
                });
            } else {
                camera = physical_view::focal_zoom(
                    camera,
                    zoom,
                    c.dimension,
                    c.viewport,
                    Some(tap.focal),
                );
            }
            out.updates.push(PhysicalUpdate::View {
                camera,
                adaptive: true,
            });
            if elapsed == limit {
                self.time.tap = None;
                out.interactions.push(Interaction::End);
            }
        }
        if self.time.pending && self.time.pan.is_none() && self.time.zoom.is_none() {
            self.time.pending = false;
            out.interactions.push(Interaction::End);
        }
        Ok(())
    }
}
// Match Flutter Cubic.transformInternal, including its 0.001 search tolerance.
fn ease_out_cubic(t: f64) -> f64 {
    if t == 0.0 || t == 1.0 {
        return t;
    }
    let cubic = |a: f64, b: f64, m: f64| {
        3.0 * a * (1.0 - m) * (1.0 - m) * m + 3.0 * b * (1.0 - m) * m * m + m * m * m
    };
    let (mut start, mut end) = (0.0, 1.0);
    loop {
        let midpoint = (start + end) / 2.0;
        let estimate = cubic(0.215, 0.355, midpoint);
        if (t - estimate).abs() < 0.001 {
            return cubic(0.61, 1.0, midpoint);
        }
        if estimate < t {
            start = midpoint;
        } else {
            end = midpoint;
        }
    }
}
