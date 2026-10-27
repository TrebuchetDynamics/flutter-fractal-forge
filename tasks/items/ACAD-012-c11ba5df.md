+++
schema = 1
id = "ACAD-012-c11ba5df"
title = "Remove unreachable Amazing Box shader helpers"
short = "Remove only shader-local boxDE and sphereDE after proving no path from main and comparing compiler output."
status = "open"
goal = "APP-QUALITY-001"
section = "Now"
rank = 2000
depends_on = []
touches = ["shaders/3d_and_hypercomplex/raymarched_volumes/amazing_box_gpu.frag"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "shaders/3d_and_hypercomplex/raymarched_volumes/amazing_box_gpu.frag"
acceptance = ["Only unused helper definitions removed; main, uniforms, registration, and live distance estimator preserved."]
checks = ["Baseline/post-delete shader compiler stages, existing shader compilation and pan target tests, preset image health, independent review."]
exclusions = ["No other shaders, generated evidence, dependencies, commits, pushes, or live/device suites."]
+++
- Notes: Applied smallest proven batch: removed amazing_box_gpu.frag boxDE and sphereDE (10 lines); no other shader or uniform/registration changes. Ownership boundary: standalone Flutter fragment asset, sole runtime_effect.glsl include, entrypoint main -> rayMarch/getNormal/ambientOcclusion -> sceneDE -> fractalDE; no helper caller or macro/source-inclusion/generator found. Same-name helpers in other shaders retained, including live tglad_formula uses; other scan leads not qualified for deletion. No Understand graph present or generated. Baseline compiler command initially lacked required --spirv and failed before deletion; corrected command succeeded. Corrected baseline/post-delete impellerc SKSL/GLES/GLES3/Vulkan compile checks pass, compiled SL and reflection JSON byte-identical for all four stages. Pinned Flutter 3.44.6 existing tests before/after: 21 shader/pan + 1 Amazing Box 128x128 image-health; after broader catalog/uniform/builder contracts: 12 pass. Independent read-only review found no blockers and independently verified compiler artifacts; unknown external source-copy consumers not provably absent, not an exposed shader API. git diff --check passed; pubspec.lock unchanged. Logs and recoverable baseline: /tmp/fractal-unused-code-bmSKeq/. No new framework, behavior change, graph, commit or push. Root index/HEAD left to coordinated delivery worker. Full offline gate not rerun after earlier unrelated task timeout; hardware-GPU/device qualification not run. Local deletion validated; remains open pending integration verification.
