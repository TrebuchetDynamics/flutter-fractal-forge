# Validation engineering docs

Owns GPU/emulator validation evidence, troubleshooting writeups, and thumbnail integrity reports.

Exposes reproducible findings and success criteria. It must not own renderer architecture decisions, performance tuning guidance, or development setup.

## Historical incidents versus current policy

[GPU emulator validation](gpu_emulator_validation.md) records the 2026-02-12 SwiftShader failure; [GPU_EMULATOR_FIX.md](GPU_EMULATOR_FIX.md) retains its diagnostic proposals, not a currently required emulator guard or physical-phone prerequisite. The [current backend policy](../../../lib/features/renderer/policy/backend_policy.dart) permits emulator GPU selection in auto mode and uses runtime health signals. Android tests use the [designated Waydroid target](../testing/waydroid-headless.md); container evidence is still not physical hardware qualification. Do not rerun the old install/debug recipes as release instructions.
