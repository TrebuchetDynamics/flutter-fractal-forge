+++
schema = 1
id = "ACAD-009-795c5cbf"
title = "Separate Fractal Music synthesis and platform playback without changing behavior"
short = "Separate music synthesis and playback"
status = "done"
goal = "APP-QUALITY-001"
section = "Next"
rank = 13000
depends_on = []
touches = ["lib/features/viewer/audio/fractal_music_service.dart", "lib/features/viewer/audio/fractal_music_playback.dart", "lib/features/viewer/audio/fractal_music_synthesis.dart", "test/features/viewer/fractal_music_service_test.dart"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "Preserve fractal_music_service.dart as the existing Dart library/public facade. Move the private playback adapter hierarchy/factory into fractal_music_playback.dart and top-level compute/composition/synthesis/PCM/WAV functions into fractal_music_synthesis.dart as parts of that library. Keep public models, feature/identity entry points and service lifecycle orchestration in the facade; retain the existing conditional web-player import. Mechanical extraction only: preserve calculations, defaults, operation ordering, top-level callback names and cancellation/publication guards."
acceptance = ["Given existing facade imports, state/scan WAV determinism, header/loop/silence/stereo/headroom, feature mapping and identity hysteresis remain unchanged; existing public helpers/types still compile (test/features/viewer/fractal_music_service_test.dart and test/features/viewer/fourier_music_render_integration_test.dart).", "Given mocked Web/Android/Linux playback, cancellation, stale preparation, publish/stop failures and temporary-file cleanup retain current behavior; the viewer coordinator and effects consumers still pass without caller changes (test/features/viewer/fractal_music_service_test.dart, test/features/viewer/actions/viewer_music_coordinator_test.dart, test/features/viewer/viewer_effects_controller_test.dart).", "Source review confirms the chosen library-part responsibility boundaries without promoted/duplicated private musical helpers or changed arithmetic/await order; formatter, analyzer and release web compilation pass. No claim of real-device audio acceptance."]
checks = ["flutter pub get --offline --enforce-lockfile", "dart format --output=none --set-exit-if-changed lib/features/viewer/audio/fractal_music_service.dart lib/features/viewer/audio/fractal_music_playback.dart lib/features/viewer/audio/fractal_music_synthesis.dart test/features/viewer/fractal_music_service_test.dart", "flutter analyze --no-pub", "flutter test --no-pub test/features/viewer/fractal_music_service_test.dart test/features/viewer/actions/viewer_music_coordinator_test.dart test/features/viewer/fourier_music_render_integration_test.dart test/features/viewer/viewer_effects_controller_test.dart", "flutter build web --release --no-pub"]
exclusions = ["No DSP/composition redesign, new public adapter API, new dependency, mathematical/rendering change, URL/storage migration or platform-native source change.", "No changes to catalog candidate, active Number Walls contracts, task metadata, devices, real audio services, publication or schedules."]
closure = "coordinator_verified"
closure_evidence = "tasks/evidence/ACAD-009-795c5cbf.toml"
+++
- Sources: docs/planning/refactor-plan.md#bounded-code-refactor-frontier-2026-10-25
- Planner decision: Use parts to preserve one private namespace and every existing facade import; do not introduce a framework or make shared private math public. Sources span the adapter block around 485–832 and compute/WAV routines from 833 onward at baseline 641f3c675b45d77b50f5965843d8cb413c252e33; exact source SHA-256 is in the plan.
- Next action: Run the existing focused service/coordinator/Fourier/effects guards on unchanged source with pinned SDK/cache, then move declarations unchanged. Pure-move behavior guards are expected to pass before and after, not a fabricated RED baseline. Extend the existing service seam only if a concrete guard gap is demonstrated; no tests just for filenames or line counts.
- Verification status: All implementation checks are proposed/unrun by this planning pass. Follow AGENTS.md and docs/tasks/MAIN-CHECK-01.md for pinned environment, lockfile preservation and the full offline integration/main gate; mock playback and keep real-device checks separate.
- Scheduling: Independent of the codec task and unintegrated catalog candidate; disjoint touches, no shared live resource, no product prerequisite. Preserve current queue priorities. Planning does not authorize execution.
- Pending live: Real-device/browser audible playback qualification on Web, Android and Linux remains outside this mechanical extraction; mocked playback and release compilation do not certify physical audio behavior.
