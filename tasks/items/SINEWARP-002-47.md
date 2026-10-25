+++
schema = 1
id = "SINEWARP-002-47"
title = "Qualify sine-sphere defaults, saved views and real PNG export.**"
short = "Qualify sine-sphere defaults, saved views and real PNG export.**"
status = "done"
goal = "SINE-WARP-001"
section = "Next"
rank = 12000
depends_on = ["SINEWARP-001-aa"]
touches = ["integration_test/rendering/recursive_sine_sphere_test.dart", "test/modules/recursive_sine_sphere_test.dart", "lib/core/modules/fractals/recursive_sine_sphere_module.dart", "docs/engineering/test-plan.md", "docs/planning/", "shaders/3d_and_hypercomplex/raymarched_volumes/recursive_sine_sphere_kernel.glsl", "test/shaders/"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "Add the scoped actual renderer journey for the implemented identity. Qualify baseline/default/higher-detail settings, camera pan/rotation, controls, saved restoration and same-state PNG/transparency on available supported targets. Tune default framing/presets within the decided math and bounds from actual captures; do not redesign the surface, replace source math, silently reduce detail or use the source video as app artwork."
acceptance = ["Named-backend real captures show the ordinary sphere control, nonblank framed warped default and visibly finer detail without unexplained holes/non-convergent pixels. Report default/max timings and convergence limitations rather than inventing FPS thresholds. Changing/restoring phase, depth, strength, radius, camera and palette yields the same requested geometry and corresponding decoded PNG; animation-off/reduced-motion freezes time and export matches its frozen state. Existing catalog, saved-state and export guards pass. Record Linux/browser/device outcomes independently; unavailable physical/human checks remain pending, never certified by numerical tests or screenshots alone. Compare selected actual production-renderer hit/silhouette/depth samples with the independent sphere/warped-ray oracle at declared precision/tolerances. Viewer/export agreement alone cannot satisfy this requirement."]
checks = ["Implement planned `integration_test/rendering/recursive_sine_sphere_test.dart`, then run `flutter test integration_test/rendering/recursive_sine_sphere_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded`; `flutter test test/modules/recursive_sine_sphere_test.dart test/modules/raymarched_3d_pan_target_test.dart test/catalog/catalog_id_integrity_test.dart --reporter expanded`; `flutter analyze`; inspect actual baseline/default/detail PNG dimensions, hashes, transparency/content and source/backend/state binding; `git diff --check`. Reuse existing browser/edited-PNG journey tooling for this identity when supported, retaining exact skips. All these app/GPU/export checks are planned. Exercise the independent ray oracle and actual production hit/depth samples in the existing planned integration target; report non-convergence separately, never as a certified hit."]
exclusions = []
closure = "coordinator_verified"
closure_evidence = "tasks/evidence/SINEWARP-002-47.toml"
+++

- Section: Next.
- Sources: [Accepted implementation](docs/engineering/spec.md#recursive-sine-warped-sphere), [source study and finite design](research/recursive-sine-sphere.md), [owner outcome](PRD.md#recursive-sine-warped-sphere), [verification](docs/engineering/test-plan.md#recursive-sine-warped-sphere-verification).
- Ownership: Repository backlog, unassigned; inspect writers before execution. Study/planning does not dispatch or publish.
- Next action: After SINEWARP-001-aa is complete, use its same-production-kernel diagnostic and independently derived ray brackets to implement the already planned integration target. Draw/read actual production hit/silhouette/depth values on a named authorized backend and compare them at declared camera, coordinate basis and precision/tolerances; report miss, tangent/stagnation and budget exhaustion separately. The retained candidate shader test only compiles/sets uniforms and does not supply this evidence. Then capture sphere-control/default/detail states, saved/restored/animated-frozen states and corresponding decoded PNGs; correct only demonstrated framing/preset defects. Preserve independent Linux/browser/device verdicts and pending physical/human review; no invented pixels or second test marcher.
- Pending live: Physical Android/device execution of the sine-sphere renderer, controls, saved restoration and real transparent PNG journey remains unrun.
- Pending live: Human composition/source-faithfulness review of retained actual captures and source study remains pending; numerical/pixel checks do not certify it.
- Pending live: Other hardware/browser/aspect/performance qualification cells remain unrun, including browser independent hit/depth diagnostics. Chromium evidence is SwiftShader only; native integration bindings suppress live animation ticker. Convergence/budget and maximum-framing limitations remain disclosed, not a universal all-rays/FPS guarantee.
