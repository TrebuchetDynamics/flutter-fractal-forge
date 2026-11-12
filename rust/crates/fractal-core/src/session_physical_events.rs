//! One publication for ordered raw input, including hidden recognizer state.
use super::*;
use crate::physical_events::{PhysicalContext, PhysicalEvent, PhysicalOutput, PhysicalUpdate};

#[derive(Debug, Clone, PartialEq)]
pub struct PhysicalTransaction {
    pub snapshot: Snapshot,
    pub output: PhysicalOutput,
}
impl Session {
    pub fn physical_generation(&self) -> u64 {
        self.physical.generation()
    }

    pub fn apply_physical(
        &mut self,
        session_id: u64,
        expected_revision: u64,
        viewport: Option<[f64; 2]>,
        events: &[PhysicalEvent],
    ) -> Result<PhysicalTransaction, SessionError> {
        self.check_owner(session_id, expected_revision)?;
        if events.is_empty() {
            return Ok(PhysicalTransaction {
                snapshot: self.snapshot(),
                output: PhysicalOutput::default(),
            });
        }
        let revision = expected_revision
            .checked_add(1)
            .ok_or(SessionError::RevisionOverflow)?;
        let mut candidate = self.state.clone();
        let mut physical = self.physical.clone();
        let mut output = PhysicalOutput::default();
        for event in events {
            let data = module_data(&self.catalog, &candidate.module_id)?;
            let context = PhysicalContext {
                viewer_keys_enabled: true,
                dimension: &data.module.dimension,
                // The only source override (+1) is the unsupported quaternion module.
                horizontal_orbit_sign: -1.0,
                rotation_locked: candidate.effects.rotation_locked,
                viewport,
                view: ViewInput {
                    zoom: candidate.view.zoom(),
                    pan: candidate.view.pan(),
                    rotation: candidate.view.rotation(),
                },
            };
            let next = physical
                .reduce(&context, event)
                .map_err(SessionError::Physical)?;
            for update in &next.updates {
                let command = match update {
                    PhysicalUpdate::View { camera, adaptive } => Command::View {
                        camera: CameraInput {
                            trajectory: candidate.trajectory,
                            ..(*camera).into()
                        },
                        adaptive: *adaptive,
                    },
                    PhysicalUpdate::Pan(pan) => Command::Pan(*pan),
                    PhysicalUpdate::Zoom(zoom) => Command::Zoom(*zoom),
                    PhysicalUpdate::Reset => Command::ResetView,
                };
                let before = candidate.clone();
                apply_command(&self.catalog, &mut candidate, &command)?;
                trajectory_jobs::invalidate_changed(&before, &mut candidate, revision);
            }
            output.updates.extend(next.updates);
            output.interactions.extend(next.interactions);
            output.keys.extend(next.keys);
        }
        candidate.reserve_terminals(revision)?;
        candidate.revision = revision;
        self.physical = physical;
        self.publish_candidate(candidate);
        Ok(PhysicalTransaction {
            snapshot: self.snapshot(),
            output,
        })
    }
}
