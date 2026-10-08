# Flutter Fractal Forge — Execution TODO

> **Last comprehensive update:** 2026-08-25 recursive-object 3D expansion. Catalog counts below are reconciled to the current integrity test.
>
> **Source anchors for this refresh:** `test/catalog/catalog_id_integrity_test.dart` (545 escape-time entries, 1019 production fractals, 1 scientific visualization, and 1027 debug/test registry modules including 7 diagnostics), `lib/features/viewer/fractal_viewer_screen.dart` (controls HUD), `lib/core/services/rendering/palette_service.dart` + `palette_shader_adapter.dart` (palette textures).

## Goal coverage — visual-fidelity scope

<!-- goals:coverage:begin -->

Generated from `goals.json` by `goals.py render`. `met` requires an executed, passing check.

| Goal | Status | Evidence | Task |
| --- | --- | --- | --- |
| VIS-004: Verify the Featured Launch Set default and viewer-start flow | met | executed `dart format --output=none --set-exit-if-changed integration_test/flows/vis004_newton_z3_first_view_test.dart && flutter analyze integration_test/flows/vis004_newton_z3_first_view_test.dart && git diff --check` → pass; executed `dart format --output=none --set-exit-if-changed integration_test/flows/vis004_nova_first_view_test.dart` → pass; executed `flutter analyze integration_test/flows/vis004_nova_first_view_test.dart` → pass; executed `flutter test integration_test/flows/user_flows_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded` → pass; executed `flutter test integration_test/flows/vis004_newton_z3_first_view_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded` → pass; executed `flutter test integration_test/flows/vis004_newton_z3_first_view_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (pass; observed gpu_first_frame module=newton_z3 backend=gpu at 207ms, assertions synchronized to that frame)` → pass; executed `flutter test integration_test/flows/vis004_nova_first_view_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (pass; observed gpu_first_frame module=nova backend=gpu; default pan=(0,0), zoom=1.5, iterations=200, relaxation=1.0, colorScheme=2)` → pass; executed `git diff --check` → pass; inspection `TODO.md#VIS-004: all nine Featured Launch Set IDs have executed GPU first-view evidence` → pass | — |
| VIS-005: Reconcile the visual audit across Explore and the research library | met | executed `flutter test test/catalog/catalog_id_integrity_test.dart --reporter expanded (15 tests passed; includes live Explore inventory reconciliation)` → pass; executed `python research/fractals-library/scripts/validate_manifest.py` → pass; executed `python research/fractals-library/scripts/validate_visual_inventory.py` → pass; inspection `docs/planning/visual-audit-inventory.json: 1,027 Explore IDs and 200 manifest IDs have explicit renderer status and references` → pass | — |
| VIS-006: Audit mapped fractals in reconciled batches | partial | executed `Artifact reconciliation: 20/20 batch-11 PNGs exist; 10 default images are 256x256 and 10 runtime images are 384x346; all targets have captured inventory metrics and no failures/skips` → pass; executed `CATALOG_THUMB_ONLY=<ten VIS-006-BATCH-12 IDs> CATALOG_THUMB_USE_MODULE_DEFAULTS=true STRICT_CATALOG_THUMBS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch12-defaults flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=10/10/0/0; all default image-health pass)` → pass; executed `CATALOG_THUMB_ONLY=<ten VIS-006-BATCH-15 IDs> CATALOG_THUMB_USE_MODULE_DEFAULTS=true STRICT_CATALOG_THUMBS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch15-defaults flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded` → pass; executed `CATALOG_THUMB_ONLY=core.arneodo,core.dadras,core.chen,core.lu_chen,core.halvorsen,core.scroll_waves,core.rikitake,core.aizawa,core.rabinovich_fabrikant,core.nose_hoover CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch11-defaults STRICT_CATALOG_THUMBS=true FORCE_GPU_RENDER=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=10/10/0/0; all default images 256x256; strict image-health pass)` → pass; executed `CATALOG_THUMB_ONLY=core.buddhabrot_approx,core.anti_buddhabrot,core.nebulabrot,core.wolfram_rule30,core.rule90_linear_ca,core.rule150_linear_ca,core.cyclic_cellular_automaton,core.greenberg_hastings_ca,core.klausmeier_vegetation,core.gerhardt_schuster_tyson_ca CATALOG_THUMB_USE_MODULE_DEFAULTS=true STRICT_CATALOG_THUMBS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch19-defaults flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=10/10/0/0; all default image verdicts pass)` → pass; executed `CATALOG_THUMB_ONLY=core.burning_ship CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-burning-ship-defaults STRICT_CATALOG_THUMBS=true FORCE_GPU_RENDER=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=1/1/0/0; 256x256; 1209 colors; blackPixelRatio=0.2008; math oracle pass)` → pass; executed `CATALOG_THUMB_ONLY=core.druid,core.inverse_mandelbrot,core.glynn,core.simonbrot,core.shark_fin,core.manowar,core.spider,core.collatz,core.popcorn,core.talis CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch03-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=10/10/0/0; all ten GPU image metrics pass; no CPU oracles registered)` → pass; executed `CATALOG_THUMB_ONLY=core.four_wing CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-four-wing-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=1/1/0/0; 256x256, 785 colors, blackPixelRatio=0.0, nonBlack=1.0, verdict pass; shader receives bailout=8; oracle skipped)` → pass; executed `CATALOG_THUMB_ONLY=core.fractal_canopy,core.benesi,core.schottky_limit_set,core.henon,core.tinkerbell,core.gingerbreadman,core.lozi,core.duffing,core.ikeda,core.clifford CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch09-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=10/10/0/0; all 256x256 and strict image verdict pass; all math oracles skipped)` → pass; executed `CATALOG_THUMB_ONLY=core.greek_cross_fractal,core.sierpinski_pentagon,core.hexaflake,core.pentaflake,core.cantor_dust,core.apollonian_gasket,core.ford_circles,core.steiner_chain,core.cesaro_fractal,core.cantor_set CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch08-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=10/10/0/0; strict render health pass)` → pass; executed `CATALOG_THUMB_ONLY=core.greek_cross_fractal,core.sierpinski_pentagon,core.hexaflake,core.pentaflake,core.cantor_dust,core.apollonian_gasket,core.ford_circles,core.steiner_chain,core.cesaro_fractal,core.cantor_set CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch08-defaults-review STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded` → pass; executed `CATALOG_THUMB_ONLY=core.householder,core.zeta_newton,core.magnet_newton,core.hypercomplex_newton,core.quaternion_julia_2d,core.tessarine_julia,core.split_complex,core.dual_complex,core.bicomplex,core.sine_julia CATALOG_THUMB_USE_MODULE_DEFAULTS=true STRICT_CATALOG_THUMBS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch14-defaults flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded` → pass; executed `CATALOG_THUMB_ONLY=core.julia CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-julia-defaults STRICT_CATALOG_THUMBS=true FORCE_GPU_RENDER=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=1/1/0/0; 256x256; 2298 colors; verdict pass; Julia C=(-0.8,0.156), iterations=160, bailout=4.0; math oracle pass; render warmup 2092.344ms; capture 278.926ms)` → pass; executed `CATALOG_THUMB_ONLY=core.julia_dual,core.phoenix,core.tricorn,core.celtic,core.buffalo,core.multibrot3,core.nova,core.nova_julia,core.fatou,core.gamma_fractal CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch01-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded` → pass; executed `CATALOG_THUMB_ONLY=core.koch_snowflake CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-koch-followup STRICT_CATALOG_THUMBS=true FORCE_GPU_RENDER=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded` → pass; executed `CATALOG_THUMB_ONLY=core.levy_c_curve,core.levy_tapestry,core.golden_dragon,core.twin_dragon,core.terdragon,core.chair_tiling,core.koch_anti_snowflake,core.quadratic_koch_island,core.cyclosorus_fern,core.menger_sponge_2d CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch06-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=10/10/0/0; each 256x256; all render verdicts pass; no reference math oracles)` → pass; executed `CATALOG_THUMB_ONLY=core.log_spiral,core.lyapunov,core.logistic_lyapunov,core.circle_map_lyapunov,core.sine_map_lyapunov,core.tent_map,core.hopalong,core.pickover_biomorph,core.feigenbaum,core.gauss_map CATALOG_THUMB_USE_MODULE_DEFAULTS=true STRICT_CATALOG_THUMBS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch18-defaults flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded` → pass; executed `CATALOG_THUMB_ONLY=core.lorenz_2d CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-lorenz-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed=1/1/0; image 256x256, 641 colors, nonBlack=1.0)` → pass; executed `CATALOG_THUMB_ONLY=core.mandelbrot CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-mandelbrot-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=1/1/0/0; 256x256; 941 colors; blackPixelRatio=0.1749; nonBlack=0.8251; verdict pass; math oracle pass)` → pass; executed `CATALOG_THUMB_ONLY=core.perpendicular_julia,core.tricorn_julia,core.burning_ship_julia,core.multibrot_neg2,core.heart,core.cosine_mandelbrot,core.tangent_mandelbrot,core.sinh_mandelbrot,core.cosh_mandelbrot,core.tanh_mandelbrot CATALOG_THUMB_USE_MODULE_DEFAULTS=true STRICT_CATALOG_THUMBS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch17-defaults flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (10/10/0/0; all metrics pass; math oracle skipped 10)` → pass; executed `CATALOG_THUMB_ONLY=core.perpendicular_julia,core.tricorn_julia,core.burning_ship_julia,core.multibrot_neg2,core.heart,core.cosine_mandelbrot,core.tangent_mandelbrot,core.sinh_mandelbrot,core.cosh_mandelbrot,core.tanh_mandelbrot CATALOG_THUMB_USE_MODULE_DEFAULTS=true STRICT_CATALOG_THUMBS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch17-defaults flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=10/10/0/0; all image health pass)` → pass; executed `CATALOG_THUMB_ONLY=core.perpendicular_mandelbrot,core.lambda,core.magnet_type_1,core.magnet_type_2,core.magnet_type_3,core.power_sum,core.cactus,core.astroid,core.deltoid,core.eisenstein CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch02-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=10/10/0/0; 10/10 math oracle skipped for lack of stable known-point checks)` → pass; executed `CATALOG_THUMB_ONLY=core.peter_de_jong,core.svensson,core.gumowski_mira,core.arnold_cat,core.standard_map,core.zaslavsky,core.kicked_rotator,core.chua_circuit,core.sprott_a,core.burke_shaw CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch10-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=10/10/0/0; all defaults 256x256; all strict metrics pass; reference oracles skipped)` → pass; executed `CATALOG_THUMB_ONLY=core.rossler_2d CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-rossler-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=1/1/0/0; image 256x256, 1245 colors, blackPixelRatio=0.0, nonBlack=1.0, verdict pass; math oracle skipped: no reference oracle)` → pass; executed `CATALOG_THUMB_ONLY=core.secant_cosecant,core.taylor,core.rational_map,core.lattes_map_julia,core.complex_henon_julia_slice,core.matrix_logistic_spectrum,core.barnsley_j2,core.barnsley_j3,core.celtic_julia,core.buffalo_julia CATALOG_THUMB_USE_MODULE_DEFAULTS=true STRICT_CATALOG_THUMBS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch16-defaults flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=10/10/0/0; all ten default image-health pass; reference math oracle skipped 10)` → pass; executed `CATALOG_THUMB_ONLY=core.tetration,core.sierpinski_triangle,core.sierpinski_carpet,core.koch_snowflake,core.dragon_curve,core.barnsley_fern,core.pythagorean_tree,core.hilbert_curve,core.peano_curve,core.gosper_curve CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch04-defaults STRICT_CATALOG_THUMBS=false flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=10/10/0/0; all image-health verdicts pass)` → pass; executed `CATALOG_THUMB_ONLY=core.tetration,core.sierpinski_triangle,core.sierpinski_carpet,core.koch_snowflake,core.dragon_curve,core.barnsley_fern,core.pythagorean_tree,core.hilbert_curve,core.peano_curve,core.gosper_curve CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch04-strict STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=10/9/1/0; Koch strict black-ratio threshold failure)` → fail; executed `CATALOG_THUMB_ONLY=core.thomas_attractor CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-thomas-attractor-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=1/1/0/0; 256x256, 979 colors, blackPixelRatio=0.0, nonBlack=1.0; verdict pass; no math oracle)` → pass; executed `CATALOG_THUMB_ONLY=core.vicsek_fractal,core.penrose_tiling,core.fibonacci_word,core.rauzy_fractal,core.arnoux_rauzy_fractal,core.dual_substitution_tiling,core.bedford_mcmullen_carpet,core.self_affine_finite_type,core.pinwheel_tiling,core.z_order_curve CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch07-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (10/10/0/0; all defaults image verdict pass; math oracles skipped 10)` → pass; executed `CATALOG_THUMB_ONLY=core.vicsek_fractal,core.penrose_tiling,core.fibonacci_word,core.rauzy_fractal,core.arnoux_rauzy_fractal,core.dual_substitution_tiling,core.bedford_mcmullen_carpet,core.self_affine_finite_type,core.pinwheel_tiling,core.z_order_curve CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch07-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded; FORCE_GPU_RENDER=true flutter test integration_test/catalog/vis006_batch07_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded` → pass; executed `CATALOG_THUMB_ONLY=core.yu_wang,core.zhou_chen,core.tsucs,core.rayleigh_benard,core.robinson,core.globo_toroid,core.tamari,core.wang_sun_cang,core.newton_z3,core.halley CATALOG_THUMB_USE_MODULE_DEFAULTS=true STRICT_CATALOG_THUMBS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch13-defaults flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=10/10/0/0)` → pass; executed `CATALOG_THUMB_ONLY=core.yu_wang,core.zhou_chen,core.tsucs,core.rayleigh_benard,core.robinson,core.globo_toroid,core.tamari,core.wang_sun_cang,core.newton_z3,core.halley CATALOG_THUMB_USE_MODULE_DEFAULTS=true STRICT_CATALOG_THUMBS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch13-defaults flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=10/10/0/0)` → pass; executed `FORCE_GPU_RENDER=true FORCE_RUNTIME_CATALOG_THUMBNAILS=true flutter test integration_test/catalog/vis006_batch18_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded` → pass; executed `FORCE_GPU_RENDER=true flutter test integration_test/catalog/vis006_batch07_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (10/10 runtime previews pass; 384x346 metrics)` → pass; executed `FORCE_GPU_RENDER=true flutter test integration_test/catalog/vis006_batch08_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded` → pass; executed `FORCE_GPU_RENDER=true flutter test integration_test/catalog/vis006_batch11_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (10/10 actual runtime GPU previews; 384x346; all image-health verdicts pass)` → pass; executed `FORCE_GPU_RENDER=true flutter test integration_test/catalog/vis006_batch13_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (10/10 actual GPU previews pass; dimensions 384x346)` → pass; executed `FORCE_GPU_RENDER=true flutter test integration_test/catalog/vis006_batch14_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded` → pass; executed `FORCE_GPU_RENDER=true flutter test integration_test/catalog/vis006_julia_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (384x346; 1314 colors; blackPixelRatio=0.0; nonBlack=1.0; verdict pass; first_thumbnail_displayed=1909ms)` → pass; executed `FRESH 2026-10-06: CATALOG_THUMB_ONLY=core.four_wing CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-four-wing-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=1/1/0/0; 256x256, 785 colors, verdict pass)` → pass; executed `FRESH 2026-10-06: dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_four_wing_runtime_preview_test.dart (0 changed) && flutter analyze integration_test/catalog/vis006_four_wing_runtime_preview_test.dart (no issues) && python research/fractals-library/scripts/validate_visual_inventory.py (1027 Explore, 200 manifest; pass) && git diff --check (pass)` → pass; executed `FRESH 2026-10-06: flutter test integration_test/catalog/vis006_four_wing_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (384x346; 481 colors; verdict pass)` → pass; executed `RenderMathOracle.evaluate in strict GPU report: all ten targets explicitly skipped because no reference oracle exists; cpu_formulas.dart registry inspection confirmed native _cpu_ implementations for all ten (not CPU correctness tests)` → pass; executed `STRICT batch04 GPU defaults capture selected=10 generated=9 failed=1 skipped=0; Koch blackPixelRatio=0.301254 exceeds threshold <0.2; failure recorded and follow-up t_b2bbfadc created` → fail; executed `VIS-006 remaining-scope reconciliation after Thomas Attractor batch: mapped core Explore rows remain uncaptured; batch completes this module only` → fail; executed `VIS-006 scope closure check: requested all mapped Explore definitions and first-view behavior are not covered by this Four Wing-only batch` → fail; executed `dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch04_runtime_preview_test.dart && flutter analyze integration_test/catalog/vis006_batch04_runtime_preview_test.dart && python research/fractals-library/scripts/validate_visual_inventory.py && python -m json.tool docs/planning/visual-audit-inventory.json > /dev/null && git diff --check` → pass; executed `dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch04_runtime_preview_test.dart && flutter analyze integration_test/catalog/vis006_batch04_runtime_preview_test.dart && python research/fractals-library/scripts/validate_visual_inventory.py && python -m json.tool docs/planning/visual-audit-inventory.json > /dev/null && git diff --check (all pass)` → pass; executed `dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch06_runtime_preview_test.dart && flutter analyze integration_test/catalog/vis006_batch06_runtime_preview_test.dart && flutter test integration_test/catalog/vis006_batch06_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (10/10 actual runtime GPU previews pass; each 384x346; per-image metrics emitted)` → pass; executed `dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch07_runtime_preview_test.dart && flutter analyze integration_test/catalog/vis006_batch07_runtime_preview_test.dart` → pass; executed `dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch09_runtime_preview_test.dart && flutter analyze integration_test/catalog/vis006_batch09_runtime_preview_test.dart && python research/fractals-library/scripts/validate_visual_inventory.py && python -m json.tool docs/planning/visual-audit-inventory.json > /dev/null && git diff --check` → pass; executed `dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch13_runtime_preview_test.dart && flutter analyze integration_test/catalog/vis006_batch13_runtime_preview_test.dart && python research/fractals-library/scripts/validate_visual_inventory.py && python -m json.tool docs/planning/visual-audit-inventory.json > /dev/null && git diff --check` → pass; executed `dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch13_runtime_preview_test.dart && flutter analyze integration_test/catalog/vis006_batch13_runtime_preview_test.dart && python research/fractals-library/scripts/validate_visual_inventory.py && python -m json.tool docs/planning/visual-audit-inventory.json > /dev/null && git diff --check HEAD` → pass; executed `dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch16_runtime_preview_test.dart && flutter analyze integration_test/catalog/vis006_batch16_runtime_preview_test.dart` → pass; executed `dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch17_runtime_preview_test.dart && flutter analyze integration_test/catalog/vis006_batch17_runtime_preview_test.dart && flutter test integration_test/catalog/vis006_batch17_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (10 actual GPU runtime previews, 384x346, all metrics pass)` → pass; executed `dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch18_runtime_preview_test.dart && flutter analyze integration_test/catalog/vis006_batch18_runtime_preview_test.dart && python research/fractals-library/scripts/validate_visual_inventory.py && python ~/.hermes/shared-skills/repo-docs/scripts/goals.py validate . && git diff --check` → pass; executed `dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch19_runtime_preview_test.dart && flutter analyze integration_test/catalog/vis006_batch19_runtime_preview_test.dart && python research/fractals-library/scripts/validate_visual_inventory.py && git diff --check` → pass; executed `dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_mandelbrot_runtime_preview_test.dart && flutter analyze integration_test/catalog/vis006_mandelbrot_runtime_preview_test.dart && python research/fractals-library/scripts/validate_visual_inventory.py && python -m json.tool docs/planning/visual-audit-inventory.json && git diff --check (all passed)` → pass; executed `dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_thomas_attractor_runtime_preview_test.dart && flutter analyze integration_test/catalog/vis006_thomas_attractor_runtime_preview_test.dart (formatted; no issues)` → pass; executed `dart format --output=none --set-exit-if-changed integration_test/flows/vis006_first_view_test.dart` → pass; executed `dart format --output=none --set-exit-if-changed integration_test/flows/vis006_first_view_test.dart && flutter analyze integration_test/flows/vis006_first_view_test.dart && flutter test integration_test/flows/vis006_first_view_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded` → pass; executed `dart format --output=none --set-exit-if-changed integration_test/flows/vis006_first_view_test.dart && flutter analyze integration_test/flows/vis006_first_view_test.dart && python research/fractals-library/scripts/validate_visual_inventory.py && python -m json.tool docs/planning/visual-audit-inventory.json > /dev/null && git diff --check` → pass; executed `dart format --output=none --set-exit-if-changed lib/core/modules/builders/escape_time_catalog/ifs_geometric_fractals.dart && flutter analyze lib/core/modules/builders/escape_time_catalog/ifs_geometric_fractals.dart` → pass; executed `dart format --output=none --set-exit-if-changed lib/core/modules/common_params.dart test/modules/module_registry_widget_test.dart` → pass; executed `dart format integration_test/catalog/vis006_batch03_runtime_preview_test.dart --set-exit-if-changed && flutter analyze integration_test/catalog/vis006_batch03_runtime_preview_test.dart && git diff --check` → pass; executed `dart format integration_test/catalog/vis006_batch17_runtime_preview_test.dart && flutter analyze integration_test/catalog/vis006_batch17_runtime_preview_test.dart && flutter test integration_test/catalog/vis006_batch17_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (10/10 actual runtime GPU previews, all 384x346 and metric verdict pass)` → pass; executed `dart format integration_test/catalog/vis006_four_wing_runtime_preview_test.dart (Formatted 1 file; 0 changed)` → pass; executed `dart format integration_test/catalog/vis006_julia_runtime_preview_test.dart && flutter analyze integration_test/catalog/vis006_julia_runtime_preview_test.dart && python research/fractals-library/scripts/validate_visual_inventory.py && python -m json.tool docs/planning/visual-audit-inventory.json && git diff --check (all passed)` → pass; executed `flutter analyze integration_test/catalog/vis006_four_wing_runtime_preview_test.dart (No issues found)` → pass; executed `flutter analyze integration_test/flows/vis006_first_view_test.dart` → pass; executed `flutter analyze lib/core/modules/common_params.dart test/modules/module_registry_widget_test.dart` → pass; executed `flutter test integration_test/catalog/vis006_batch01_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded` → pass; executed `flutter test integration_test/catalog/vis006_batch02_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (10/10 runtime GPU previews; 384x346; metrics captured; all verdicts pass)` → pass; executed `flutter test integration_test/catalog/vis006_batch03_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (ten runtime catalog previews; each image metric verdict pass)` → pass; executed `flutter test integration_test/catalog/vis006_batch04_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded` → pass; executed `flutter test integration_test/catalog/vis006_batch04_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (10/10 GPU runtime previews pass; 384x346)` → pass; executed `flutter test integration_test/catalog/vis006_batch04_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (10/10 runtime previews pass; 384x346 metrics)` → pass; executed `flutter test integration_test/catalog/vis006_batch08_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (10/10 GPU catalog previews; 384x346; all image verdicts pass)` → pass; executed `flutter test integration_test/catalog/vis006_batch09_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (10/10 actual GPU runtime previews pass; all 384x346)` → pass; executed `flutter test integration_test/catalog/vis006_batch10_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (10/10 actual runtime GPU previews; 384x346; all image-health verdicts pass)` → pass; executed `flutter test integration_test/catalog/vis006_batch12_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (10/10 actual runtime previews; all pass)` → pass; executed `flutter test integration_test/catalog/vis006_batch13_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded` → pass; executed `flutter test integration_test/catalog/vis006_batch15_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded` → pass; executed `flutter test integration_test/catalog/vis006_batch16_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (10/10 actual runtime GPU previews pass; each 384x346; per-image metrics emitted)` → pass; executed `flutter test integration_test/catalog/vis006_batch19_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded` → pass; executed `flutter test integration_test/catalog/vis006_batch19_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (10/10 actual runtime GPU previews, 384x346; all image verdicts pass)` → pass; executed `flutter test integration_test/catalog/vis006_burning_ship_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (384x346; 1063 colors; blackPixelRatio=0.2151; verdict pass)` → pass; executed `flutter test integration_test/catalog/vis006_four_wing_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (core.four_wing runtime preview 384x346; 481 colors, blackPixelRatio=0.0, nonBlack=1.0, verdict pass)` → pass; executed `flutter test integration_test/catalog/vis006_julia_dual_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded` → pass; executed `flutter test integration_test/catalog/vis006_lorenz_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (runtime catalog preview 384x346; 3008 colors; nonBlack=1.0)` → pass; executed `flutter test integration_test/catalog/vis006_mandelbrot_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (384x346; 603 colors; blackPixelRatio=0.1772; nonBlack=0.8228; verdict pass)` → pass; executed `flutter test integration_test/catalog/vis006_rossler_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (runtime catalog preview 384x346; 421 colors; blackPixelRatio=0.0; nonBlack=1.0; verdict pass)` → pass; executed `flutter test integration_test/catalog/vis006_thomas_attractor_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (384x346; 876 colors; blackPixelRatio=0.0; nonBlack=1.0; verdict pass)` → pass; executed `flutter test integration_test/flows/vis006_first_view_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded` → pass; executed `flutter test integration_test/flows/vis006_first_view_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (15/15 pass; five target modules logged gpu_first_frame backend=gpu and matched module default preset)` → pass; executed `flutter test integration_test/flows/vis006_first_view_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (5/5 GPU first frames; each controller module, params, pan and zoom matched module default preset)` → pass; executed `flutter test integration_test/flows/vis006_first_view_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (observed gpu_first_frame modules=fatou,gamma_fractal,lambda,nova_julia,perpendicular_mandelbrot; backend=gpu; default params/view matched; 10/10 total passed)` → pass; executed `flutter test test/cpu/cpu_formula_coverage_test.dart --reporter expanded (4 tests passed; CPU formula registry coverage; no independent correctness claim)` → pass; executed `flutter test test/cpu/cpu_formula_coverage_test.dart --reporter expanded (4 tests passed; confirms data-driven CPU approximation coverage, not native Thomas ODE correctness)` → pass; executed `flutter test test/cpu/cpu_formula_coverage_test.dart --reporter expanded (4 tests passed; registry/finite-color coverage, not independent mathematical correctness)` → pass; executed `flutter test test/cpu/cpu_formula_coverage_test.dart --reporter expanded (4 tests passed; resolves each escape-time catalog module and verifies finite CPU color output, including native formulas in this batch)` → pass; executed `flutter test test/modules/module_registry_widget_test.dart --plain-name 'Rossler bailout schema preserves configured default'` → pass; executed `git diff --check` → pass; executed `inventory reconciliation: prior VIS-006 captures occupy Explore rows 0–72; this task scope occupies the next ten source-ordered rows 73–82; all ten referenced shader assets exist` → pass; executed `python - batch17 report/artifact/inventory reconciliation (10 target rows captured; selected/generated/failed/skipped=10/10/0/0; ten 384x346 runtime PNGs; next uncaptured order advances to core.log_spiral, core.lyapunov, core.logistic_lyapunov) && python research/fractals-library/scripts/validate_visual_inventory.py && python -m json.tool docs/planning/visual-audit-inventory.json >/dev/null && python ~/.hermes/shared-skills/repo-docs/scripts/goals.py validate . && git diff --check` → pass; executed `python -c "import json; d=json.load(open('docs/planning/visual-audit-inventory.json')); r=d['rows']; x=[i for i in r if i.get('source')=='Explore' and i.get('group')=='core']; captured=[i for i in x if i.get('runtime_preview','').startswith('captured in VIS-006:') or i.get('runtime_preview','').startswith('captured in VIS-006 ')]; print(f'Explore core rows={len(x)}; captured entries={len(captured)}; remaining={len(x)-len(captured)}'); assert len(captured)==len(x), 'VIS-006 has remaining mapped entries'" (exit 1: 1027 Explore core rows; 3 captured; 1024 remaining)` → fail; executed `python -m json.tool docs/planning/visual-audit-inventory.json > /dev/null` → pass; executed `python -m json.tool docs/planning/visual-audit-inventory.json >/dev/null` → pass; executed `python /home/xel/.hermes/shared-skills/repo-docs/scripts/goals.py fmt . && python /home/xel/.hermes/shared-skills/repo-docs/scripts/goals.py validate . && python /home/xel/.hermes/shared-skills/repo-docs/scripts/goals.py render . && python research/fractals-library/scripts/validate_visual_inventory.py && python -m json.tool docs/planning/visual-audit-inventory.json >/dev/null && git diff --check HEAD` → pass; executed `python VIS-006-BATCH-08 reconciliation assertion: exact ten IDs and order, shader assets, per-ID inventory records, default report 10/10/0/0, ten runtime PNGs` → pass; executed `python batch17 reconciliation: source-order exact target IDs, 10 shader paths exist, defaults report and runtime PNG count 10 each, inventory rows captured` → pass; executed `python research/fractals-library/scripts/validate_visual_inventory.py` → pass; executed `python research/fractals-library/scripts/validate_visual_inventory.py && dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch10_runtime_preview_test.dart && flutter analyze integration_test/catalog/vis006_batch10_runtime_preview_test.dart && python -m json.tool docs/planning/visual-audit-inventory.json > /dev/null && git diff --check` → pass; executed `python research/fractals-library/scripts/validate_visual_inventory.py && flutter test test/catalog/catalog_id_integrity_test.dart --reporter expanded` → pass; executed `python research/fractals-library/scripts/validate_visual_inventory.py && python -c "verify ten VIS-006-BATCH-01 cpu_formula fields against cpu_formulas.dart registry and assert 9 native formulas plus julia_dual absent"` → pass; executed `python research/fractals-library/scripts/validate_visual_inventory.py && python -m json.tool docs/planning/visual-audit-inventory.json > /dev/null && dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_burning_ship_runtime_preview_test.dart && flutter analyze integration_test/catalog/vis006_burning_ship_runtime_preview_test.dart && git diff --check` → pass; executed `python research/fractals-library/scripts/validate_visual_inventory.py && python -m json.tool docs/planning/visual-audit-inventory.json > /dev/null && git diff --check` → pass; executed `python research/fractals-library/scripts/validate_visual_inventory.py && python -m json.tool docs/planning/visual-audit-inventory.json > /dev/null && git diff --check && python inventory-count assertion` → pass; executed `python research/fractals-library/scripts/validate_visual_inventory.py && python -m json.tool docs/planning/visual-audit-inventory.json > /dev/null && git diff --check (1227 rows; pass)` → pass; executed `python research/fractals-library/scripts/validate_visual_inventory.py && python -m json.tool docs/planning/visual-audit-inventory.json >/dev/null && batch16 artifact/inventory reconciliation assertion && git diff --check` → pass; executed `python research/fractals-library/scripts/validate_visual_inventory.py && python -m json.tool docs/planning/visual-audit-inventory.json >/dev/null && dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch08_runtime_preview_test.dart && flutter analyze integration_test/catalog/vis006_batch08_runtime_preview_test.dart && git diff --check` → pass; executed `python research/fractals-library/scripts/validate_visual_inventory.py && python -m json.tool docs/planning/visual-audit-inventory.json >/dev/null && dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch11_runtime_preview_test.dart && flutter analyze integration_test/catalog/vis006_batch11_runtime_preview_test.dart && git diff --check` → pass; executed `python research/fractals-library/scripts/validate_visual_inventory.py && python -m json.tool docs/planning/visual-audit-inventory.json >/dev/null && dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch14_runtime_preview_test.dart && flutter analyze integration_test/catalog/vis006_batch14_runtime_preview_test.dart && git diff --check` → pass; executed `python research/fractals-library/scripts/validate_visual_inventory.py && python -m json.tool docs/planning/visual-audit-inventory.json >/dev/null && dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch19_runtime_preview_test.dart && flutter analyze integration_test/catalog/vis006_batch19_runtime_preview_test.dart && git diff --check` → pass; executed `python research/fractals-library/scripts/validate_visual_inventory.py && python -m json.tool docs/planning/visual-audit-inventory.json >/dev/null && git diff --check` → pass; executed `python research/fractals-library/scripts/validate_visual_inventory.py (OK: 1027 Explore IDs + 200 manifest IDs; 1227 unique rows)` → pass; executed `python ~/.hermes/shared-skills/repo-docs/scripts/goals.py validate .` → pass; executed `python3 VIS-006-BATCH-01 report/inventory/path reconciliation assertion` → pass; executed `visual inventory JSON candidate integrity and source-order assertion for the five first-view rows` → pass; inspection `Inspected default and actual runtime-preview PNGs for core.four_wing: both are smooth broad color gradients with sharp sector/wedge boundaries, not a recognizable four-wing orbit; preserve formula pending follow-up` → fail; inspection `Lorenz captures show a narrow diagonal band over a smooth gradient rather than a recognizable two-lobed silhouette; visual follow-up warranted, formula preserved` → fail; inspection `Rossler defaults/runtime captures are mostly smooth gradients with a sharp triangular boundary rather than a recognizable orbit; additionally configured bailout=12 is normalized to 8 by shared parameter max=8 before shader uniform mapping; visual/default follow-up warranted, formula preserved` → fail; inspection `TODO.md#VIS-006: broad batch audit remains to be completed; Lorenz batch only captured` → fail; inspection `docs/planning/visual-audit-inventory.json: only 7 of 1,027 Explore rows have capture records; 200 manifest rows are missing_app_renderer; no first_viewer field exists; cpu_formula is not audited in 1,224 rows and three rows have limited caveats` → fail; inspection `shaders/ifs_and_geometric/koch_snowflake_gpu.frag:102-105: edge below 0.02 returns opaque black; observed strict default blackPixelRatio=0.301254 above harness threshold <0.2. No shader/default alteration authorized.` → fail | VIS-006, VIS-006-BATCH-20 |
| SMOOTH-001: Prove smooth-coloring coverage for supported escape-time shaders | met | executed `dart format --output=none --set-exit-if-changed test/shaders/smooth_coloring_family_coverage_test.dart` → pass; executed `dart format --output=none --set-exit-if-changed test/shaders/smooth_coloring_family_coverage_test.dart && flutter analyze test/shaders/smooth_coloring_family_coverage_test.dart && flutter test test/shaders/smooth_coloring_family_coverage_test.dart test/shaders/smooth_coloring_regression_test.dart test/shaders/escape_time_perturb_smooth_coloring_test.dart test/shaders/mcmullen_map_smooth_coloring_test.dart && git diff --check` → pass; executed `dart format test/shaders/smooth_coloring_family_coverage_test.dart && dart format --output=none --set-exit-if-changed test/shaders/smooth_coloring_family_coverage_test.dart && flutter analyze test/shaders/smooth_coloring_family_coverage_test.dart && flutter test test/shaders/smooth_coloring_family_coverage_test.dart test/shaders/smooth_coloring_regression_test.dart test/shaders/escape_time_perturb_smooth_coloring_test.dart test/shaders/mcmullen_map_smooth_coloring_test.dart && git diff --check` → pass; executed `flutter analyze test/shaders/smooth_coloring_family_coverage_test.dart` → pass; executed `flutter test test/shaders/smooth_coloring_family_coverage_test.dart` → pass; executed `flutter test test/shaders/smooth_coloring_family_coverage_test.dart test/shaders/smooth_coloring_regression_test.dart --reporter expanded` → pass; executed `flutter test test/shaders/smooth_coloring_family_coverage_test.dart test/shaders/smooth_coloring_regression_test.dart test/shaders/escape_time_perturb_smooth_coloring_test.dart test/shaders/mcmullen_map_smooth_coloring_test.dart` → pass; executed `git diff --check` → pass; inspection `TODO.md#P1-3: four families (7 shaders) covered; complete applicable polynomial escape-time inventory remains open` → fail; inspection `docs/engineering/performance/SHADER_OPTIMIZATIONS.md` → pass | — |
| MEDIA-002: Select launch hero stills from qualified captures | unmet | inspection `TODO.md#MEDIA-002: owner selection remains open` → fail | MEDIA-002 |
| VIS-003: Obtain app icon visual sign-off | unmet | inspection `TODO.md#VIS-003: owner sign-off remains open` → fail | VIS-003 |
| DOC-PRD-001: Resolve which documents own active product scope | unverified | inspection `BLOCKERS.md#BLK-20261005-004: conflicting scope statements require owner decision` → fail | DOC-PRD-001 |

<!-- goals:coverage:end -->

---

## Architecture Direction (decided 2026-02-15, reaffirmed 2026-04-05)

**GPU-primary, CPU safety net.**
- GPU is the default renderer; many catalog modules share reviewed shader families rather than one shader per fractal
- Live registry lock: 545 escape-time catalog entries, 37 raymarched-3D entries, 9 custom hand-built modules, 1019 production fractals plus 1 scientific visualization (1027 debug/test `ModuleRegistry` modules including 7 diagnostics)
- CPU fallback auto-activates via renderer health/precision policy when GPU output or precision is invalid
- CPU path is maintenance-only (no further performance investment)
- GPU investment: coloring quality, smooth iteration, deep zoom, new formulas

---

## Perturbation Theory — Realistic Capability Assessment

**IMPORTANT:** Perturbation theory CANNOT be applied to all fractals. This section clarifies what's achievable.

### ✅ Perturbation Theory WORKS For (Polynomial Escape-Time)

These fractals use differentiable formulas where `dz_next = f(z+dz, c+dc) - f(z,c)` can be computed:

| Category | Fractals | Count | Status |
|----------|----------|-------|--------|
| Core Mandelbrot family | mandelbrot, multibrot variants | ~20 | 🔶 Mandelbrot uses DF2 path; multibrot3/4/5 perturbation implemented |
| Julia variants | julia, celtic_julia, buffalo_julia, etc. | ~30 | 🔶 Core `julia` perturbation implemented; variants remain open |
| Burning Ship variants | burning_ship, burning_ship_cubic, etc. | ~10 | 🔶 `burning_ship` implemented; variants remain open |
| Phoenix variants | phoenix, phoenix_julia | ~4 | 🔶 `phoenix` implemented; variants remain open |
| Buffalo/Tricorn/Celtic | buffalo, tricorn, celtic | ~6 | ✅ Implemented for core IDs |

**Current shipped GPU perturbation path:** `julia`, `burning_ship`, `buffalo`, `tricorn`, `celtic`, `phoenix`, `multibrot3`, `multibrot4`, `multibrot5`.
**Total achievable with perturbation: ~70-80 fractals**

### ❌ Perturbation Theory DOES NOT Work For

| Category | Reason | Examples |
|----------|--------|----------|
| IFS/Geometric | Uses iterated function systems, not escape-time | Sierpinski, Koch, Barnsley Fern |
| Strange Attractors | Continuous dynamics, not complex iteration | Lorenz, Rossler, Clifford |
| Cellular Automata | Discrete grid-based, not complex plane | Rule 30, Brian's Brain |
| Root-Finding fractals | Newton/Halley method, different algorithm | Newton z³-1, Halley |
| Stochastic | Random sampling, not deterministic | Buddhabrot, DLA |
| Tilings | Substitution rules, not iteration | Penrose, Ammann-Beenker |

**Most of the 1019-production-fractal catalog is still NOT suitable for perturbation; exact category counts need a fresh catalog audit.**

### 📊 Module Registry Breakdown (1019 production fractals; 1027 debug/test modules)

```
Live locks from test/catalog/catalog_id_integrity_test.dart:
├── Escape-time catalog raw unique IDs: 545
├── Raymarched-3D catalog IDs: 37
├── Custom hand-built modules: 9
├── Production fractals: 1019
├── Scientific visualizations: 1
└── Debug/test ModuleRegistry modules including diagnostics: 1027

Perturbation-capable target remains ~70-80 polynomial escape-time fractals.
Currently routed to GPU perturbation: 9 IDs (julia + 8 generic escape-time IDs).
Older 370-count planning rows are retired.
```

---

## P0 — MUST SHIP NEXT

**All open (unchecked) items in this section remain P0 until resolved.**

### P0-1: Critical Render Regressions

- [x] **GPU artifact at z≈5.10e+6** — Color blocks/grid artifacts appear despite perturbation shader ✅ FIXED 2026-04-05
  - **Root cause:** Delta overflow check in `escape_time_perturb_gpu.frag:165` used threshold `1e6` which was too aggressive
  - **Fix:** Changed threshold from `1e6` to `1e12` to avoid false triggers at deep zoom
  - **Verified:** All 350 fractals render correctly (fractal_render_audit_test.dart passed)

- [x] **FractalViewControls parameter mismatch** ✅ FIXED 2026-04-05
  - **Issue:** `fractal_viewer_screen.dart` called `FractalViewControls` with old parameter names
  - **Fix:** Updated to match current widget signature (`onOpenMoreActions` → removed, `onEnterFullscreen` → `onToggleFullscreen`)

- [x] **KIFS Menger Sponge stuck on "Loading shaders..."** — 3D fractal not loading ✅ FIXED 2026-04-05
  - **Root cause:** SkSL compiler doesn't support `%` operator on integers or `clamp(int, int, int)`
  - **Fix:** Replaced with integer-division modulo trick and `float(clamp(float(...)))` pattern
  - **Files fixed:** `shaders/quaternion_julia_2d_gpu.frag`, `shaders/menger_sponge_gpu.frag`, `shaders/menger_3d_slice_gpu.frag`
  - **Verified:** All 14 3D shaders compile successfully (shader_3d_diagnostic_test.dart passed)

- [x] **All 3D fractals broken** — Raymarching not working ✅ FIXED 2026-04-05
  - **Root cause:** Same SkSL incompatibility issues in 3D fractal shaders
  - **Fix:** Applied SkSL-compatible replacements to all affected 3D shaders
  - **Verified:** Build succeeds, all tests pass (864+ passed)

### P0-2: User-Reported Blockers (2026-02-25)

- [x] GPU→CPU fallback too slow when zooming deep; reduce hysteresis/threshold so CPU engages faster
- [x] **Controls too big/too intrusive** — Redesign for smaller, less cluttered UI ✅ 2026-06-06
  - Replaced modal bottom sheet (38% screen height) with semi-transparent HUD overlay
  - Game-like glass-morphism HUD with compact sliders, palette chips, and action buttons
  - Tap-outside-to-dismiss behavior (like game HUD)
  - Fractal visible and updating behind controls
  - New: `fractal_controls_hud.dart` overlay widget
  - Changed: viewer FAB toggles overlay instead of opening modal
  - Tests: 5 new HUD tests + all 18 existing controls tests pass
- [x] **3D fractals not working** — Investigate 3D pipeline/shaders and fix ✅ FIXED 2026-04-05
  - **Root cause:** SkSL `%` and `clamp(int, int, int)` not supported
  - **Fix:** See P0-1 items above
- **App icon visual sign-off** — adaptive launcher and store-art inputs exist; visual presentation acceptance remains open (details in Launch Visual Audit Handoff below).
- [x] **Improve catalog thumbnails** — Larger view size, higher-quality renders ✅ 2026-08-29
  - Raised bounded capture/decode width to 384 px with high-quality filtering
  - Increased thumbnail detail caps to 24 web / 40 native iterations and 24 colors
  - Added layout-aware cache keys so portrait grids never reuse square captures
- [ ] **Visual playtest audit** — cover both Explore groups and all 200 research-library definitions. Check true module defaults, runtime previews, and first viewer renders. Run CPU checks where a native CPU formula exists. Preserve formulas and log failures. The broad audit remains partial: the inventory now records captures for 177 of 1,027 Explore IDs (850 remain uncaptured), and all 200 research definitions have no app renderer. First-view evidence is recorded for 14 Explore rows; CPU formula coverage remains partial. See `VIS-005` and `VIS-006` below.

### Visual Fidelity Audit — current queue

#### Now

- [ ] **VIS-006 — Capture and inspect the next ten uncaptured Explore modules.** Goal: complete the accepted visual playtest audit.
  - Payoff: extend evidence-backed GPU default and runtime-preview coverage while preserving formulas.
  - Scope: select the next ten uncaptured Explore IDs from `docs/planning/visual-audit-inventory.json`; capture true module defaults and runtime previews. Run CPU checks only when a native CPU formula exists. Do not alter formulas, static catalog images, or research-library module support.
  - Sources: [`docs/planning/visual-fidelity-audit-next.md`](docs/planning/visual-fidelity-audit-next.md), [`docs/planning/visual-audit-inventory.json`](docs/planning/visual-audit-inventory.json), and `goals.json`.
  - Acceptance: reconcile selected/generated/failed/skipped counts, record per-ID defaults and image metrics, and validate inventory references. Dependencies: VIS-005 and VIS-006-BATCH-01. Ownership: repository backlog; check active work before dispatch.
  - [x] **VIS-006-BATCH-18 — Capture defaults and runtime previews for the next ten uncaptured Explore modules.** Strict forced-GPU module-default captures reconciled selected/generated/failed/skipped as 10/10/0/0; all ten default images passed image health. In-app runtime GPU previews passed 10/10 at 384x346. Per-ID paths, defaults, and actual image metrics are recorded in `docs/planning/visual-audit-inventory.json`; mathematical oracles are skipped because no reference oracle is registered. Defaults: `build/test_output/vis006-batch18-defaults/`; runtime previews: `build/test_output/vis006-batch18/`; test: `integration_test/catalog/vis006_batch18_runtime_preview_test.dart`. No formulas or defaults changed.
  - [x] **VIS-006-BATCH-14 — Capture defaults and runtime previews for the next ten uncaptured Explore modules.** Strict forced-GPU module-default captures reconciled selected/generated/failed/skipped as 10/10/0/0; all ten default images are 256x256 with strict image-health pass. Actual runtime catalog GPU previews passed 10/10 at 384x346. Per-ID artifacts, image metrics, shader references, and native CPU formula registration (correctness NOT_CHECKED; no formula for Zeta Newton) are recorded in `docs/planning/visual-audit-inventory.json`. The ten math oracles are NOT_CHECKED because no stable reference oracle is registered. Default artifacts: `build/test_output/vis006-batch14-defaults/`; runtime previews: `build/test_output/vis006-batch14/`; test: `integration_test/catalog/vis006_batch14_runtime_preview_test.dart`. No formulas or defaults changed.

- [x] **SMOOTH-001-COVERAGE-01 — Extend regression coverage to the next supported shader family.** Added source-level smooth-coloring assertions for both Feather map shaders (`feather_gpu.frag` and `feather_julia_gpu.frag`), preserving their degree-3 correction and smooth palette inputs. Coverage is now eight bounded families (12 shaders); shader formulas were unchanged. Formatter, analyzer, and four focused smooth-coloring tests passed; see `goals.json` for exact commands.
- [x] **SMOOTH-001-COVERAGE-02 — Extend regression coverage to the next supported shader family.** Added source-level assertions for the supported Shark Fin shader's quadratic smooth correction, palette coordinate, and inside-set output. Coverage is now nine bounded families (13 shaders); shader formulas were unchanged. Formatter, analyzer, and four focused smooth-coloring tests passed; see `goals.json` for exact commands.

- [x] **VIS-006-BATCH-01 — Reconcile Featured Launch Set first-view evidence and capture the next ten uncaptured Explore IDs.** Goal: complete the accepted visual playtest audit.
  - Payoff: make the nine executed Featured Launch Set first-view checks discoverable in the inventory, then extend measured GPU coverage.
  - Scope: record first-view test references for `core.mandelbrot`, `core.burning_ship`, `core.phoenix`, `core.barnsley_fern`, `core.lorenz_2d`, `core.julia`, `core.koch_snowflake`, `core.newton_z3`, and `core.nova`. Capture true module defaults and runtime previews for `core.julia_dual`, `core.phoenix`, `core.tricorn`, `core.celtic`, `core.buffalo`, `core.multibrot3`, `core.nova`, `core.nova_julia`, `core.fatou`, and `core.gamma_fractal`. Reuse the existing Phoenix, Nova, and Newton first-view test evidence where applicable. Run a CPU check only when a native CPU formula exists. Preserve formulas. Do not add static catalog images or implement research-library modules in this batch.
  - Sources: [`docs/planning/visual-fidelity-audit-next.md`](docs/planning/visual-fidelity-audit-next.md), [`docs/planning/visual-audit-inventory.json`](docs/planning/visual-audit-inventory.json), and `goals.json`.
  - Acceptance: the nine inventory rows link to executed first-view checks; the ten capture IDs have reconciled selected, generated, failed, and skipped counts; each output links to its row and artifact; record CPU support or no native formula. Use `CATALOG_THUMB_USE_MODULE_DEFAULTS=true` and `--dart-define=FORCE_GPU_RENDER=true` for GPU captures.
  - Dependencies: VIS-005 ID reconciliation is complete. Ownership: repository backlog; check active work before dispatch.

- [x] **VIS-006-FIRST-VIEW-01 — Add first-view checks for the next five captured Explore modules.** Added `integration_test/flows/vis006_first_view_test.dart`; executed forced-GPU Explore launches for Julia Dual, Tricorn, Celtic, Buffalo, and Multibrot d=3. All five logged `gpu_first_frame` with backend `gpu`; controller module, default parameters, pan, and zoom matched the module default preset. The five inventory rows link to the test and observed evidence. Formatter, targeted analyzer, inventory validation, JSON parsing, and `git diff --check` passed; exact commands and results are in `goals.json`.

- [x] **VIS-006-FIRST-VIEW-02 — Add first-view checks for the next five captured Explore modules.** Extended `integration_test/flows/vis006_first_view_test.dart` with real forced-GPU Explore launches for Fatou, Gamma Fractal, Lambda, Nova Julia, and Perpendicular Mandelbrot. All five emitted `gpu_first_frame` with `backend=gpu`; the shared assertions confirmed module identity and that controller params/view matched each module default preset. Added exact test/evidence references to the five inventory rows. Formatter, analyzer, forced-GPU integration test (5 new targets passed; full suite 10/10), inventory validation, JSON parsing, and `git diff --check` passed; exact command evidence is recorded in `goals.json`.

- [x] **VIS-006-FIRST-VIEW-03 — Add first-view checks for the next five captured Explore modules.** Extended `integration_test/flows/vis006_first_view_test.dart` with forced-GPU Explore launches for Magnet Fractal Types I–III, Power Sum, and Cactus. All five emitted `gpu_first_frame` with `backend=gpu`; shared assertions verified exact module identity and controller params/view against each module default preset. Added first-view evidence to their inventory rows. Formatter, analyzer, forced-GPU integration test, inventory validation, goals validation/render, and `git diff --check` results are recorded in `goals.json`.

- [x] **VIS-006-BATCH-02 — Capture defaults and runtime previews for the next ten uncaptured Explore modules.** Executed real-GPU default captures and catalog previews for `core.perpendicular_mandelbrot`, `core.lambda`, `core.magnet_type_1`, `core.magnet_type_2`, `core.magnet_type_3`, `core.power_sum`, `core.cactus`, `core.astroid`, `core.deltoid`, and `core.eisenstein`; counts reconciled 10/10/0/0. Per-module defaults, image metrics, runtime preview paths, CPU formula registrations, and oracle skips are recorded in `docs/planning/visual-audit-inventory.json`. Captures: `build/test_output/vis006-batch02-defaults/`; runtime previews: `build/test_output/vis006-batch02/`; test: `integration_test/catalog/vis006_batch02_runtime_preview_test.dart`. No formula, shader, or catalog-default changes.

- [x] **VIS-006-BATCH-03 — Capture defaults and runtime previews for the next ten uncaptured Explore modules.** Executed strict real-GPU module-default captures and runtime catalog previews for `core.druid`, `core.inverse_mandelbrot`, `core.glynn`, `core.simonbrot`, `core.shark_fin`, `core.manowar`, `core.spider`, `core.collatz`, `core.popcorn`, and `core.talis`; both runs covered all ten, and default capture counts reconciled 10/10/0/0. Defaults, shader paths, image metrics, runtime metrics, native CPU formula registration, and unsupported CPU oracle skips are recorded in `docs/planning/visual-audit-inventory.json`. Captures: `build/test_output/vis006-batch03-defaults/`; runtime previews: `build/test_output/vis006-batch03/`; test: `integration_test/catalog/vis006_batch03_runtime_preview_test.dart`. No formula, shader, catalog-default, or static-thumbnail changes.

- [x] **VIS-006-BATCH-04 — Capture defaults and runtime previews for the next ten uncaptured Explore modules.** Captured defaults and in-app runtime previews for `core.tetration`, `core.sierpinski_triangle`, `core.sierpinski_carpet`, `core.koch_snowflake`, `core.dragon_curve`, `core.barnsley_fern`, `core.pythagorean_tree`, `core.hilbert_curve`, `core.peano_curve`, and `core.gosper_curve`. Runtime previews pass 10/10. Strict defaults captured 9/10; Koch's strict capture failed its existing black-pixel-ratio threshold (0.3013 vs <0.2). Source inspection found the Koch shader emits opaque black for `edge < 0.02` (`shaders/ifs_and_geometric/koch_snowflake_gpu.frag:102-105`); changing the formula/shading rule is outside this batch, so the failure is recorded without altering defaults or shader. Non-strict GPU audit captured all 10, render verdict pass; all ten CPU mathematical oracles skipped (no reference oracle); only tetration has a native CPU formula registered. Evidence/artifacts: non-strict defaults `build/test_output/vis006-batch04-defaults/`, strict report `build/test_output/vis006-batch04-strict/`, runtime previews `build/test_output/vis006-batch04/`; runtime test: `integration_test/catalog/vis006_batch04_runtime_preview_test.dart`. Per-ID defaults, metrics, CPU support, and shader references are recorded in the visual inventory.

#### Next

- [ ] **VIS-006-BATCH-20 — Capture defaults and runtime previews for the next ten uncaptured Explore modules.** Goal: complete the accepted visual playtest audit.
  - Payoff: extend measured GPU and first-view audit coverage while preserving fractal formulas.
  - Scope: select the next ten uncaptured Explore IDs from `docs/planning/visual-audit-inventory.json`; capture module defaults and actual runtime previews. Run CPU checks only where a native CPU formula exists. Do not alter formulas, static catalog images, or research-library module support.
  - Sources: [`docs/planning/visual-fidelity-audit-next.md`](docs/planning/visual-fidelity-audit-next.md), [`docs/planning/visual-audit-inventory.json`](docs/planning/visual-audit-inventory.json), and `goals.json`.
  - Acceptance: reconcile selected/generated/failed/skipped counts; record defaults, metrics, and artifacts for each ID; validate inventory references; run formatter, analyzer, and targeted GPU integration tests. Dependency: VIS-006. Ownership: repository backlog; check active work before dispatch.

- [x] **VIS-006-BATCH-15 — Capture defaults and runtime previews for the following ten uncaptured Explore modules.** Executed forced-GPU default captures and actual runtime catalog previews for `core.cosine_julia`, `core.tangent`, `core.sinh_cosh`, `core.exponential`, `core.zircon_zity`, `core.barnsley_j1`, `core.fish`, `core.ducky`, `core.schroeder`, and `core.secant_fractal`. Default capture counts reconciled 10/10/0/0; all ten default and runtime images passed health checks (256×256 defaults; 384×346 runtime). No CPU reference oracles were available; all ten were skipped. Per-ID image metrics, paths, and CPU status are recorded in `docs/planning/visual-audit-inventory.json`. Defaults: `build/test_output/vis006-batch15-defaults/`; runtime previews: `build/test_output/vis006-batch15/`; test: `integration_test/catalog/vis006_batch15_runtime_preview_test.dart`. No formulas or defaults changed.

- [x] **VIS-006-BATCH-06 — Capture defaults and runtime previews for the next ten uncaptured Explore modules.** Executed strict real-GPU module-default captures and runtime catalog previews for `core.levy_c_curve`, `core.levy_tapestry`, `core.golden_dragon`, `core.twin_dragon`, `core.terdragon`, `core.chair_tiling`, `core.koch_anti_snowflake`, `core.quadratic_koch_island`, `core.cyclosorus_fern`, and `core.menger_sponge_2d`; defaults reconciled 10/10/0/0 and runtime previews passed 10/10. Per-ID default/runtime image metrics, parameters, paths, shader references, and oracle skips are recorded in `docs/planning/visual-audit-inventory.json`. Defaults: `build/test_output/vis006-batch06-defaults/`; runtime previews: `build/test_output/vis006-batch06/`; test: `integration_test/catalog/vis006_batch06_runtime_preview_test.dart`. CPU registry coverage passed; this is not an independent mathematical oracle. No formula, shader, catalog-default, or static-thumbnail changes.

- [x] **VIS-006-BATCH-07 — Capture defaults and runtime previews for the next ten uncaptured Explore modules.** Strict real-GPU module-default capture reconciled selected/generated/failed/skipped as 10/10/0/0 for `core.vicsek_fractal`, `core.penrose_tiling`, `core.fibonacci_word`, `core.rauzy_fractal`, `core.arnoux_rauzy_fractal`, `core.dual_substitution_tiling`, `core.bedford_mcmullen_carpet`, `core.self_affine_finite_type`, `core.pinwheel_tiling`, and `core.z_order_curve`; all ten defaults and runtime-preview images passed image-health verdicts. Per-ID resolved shaders, defaults, metrics, and NOT_SUPPORTED CPU oracle skips are recorded in `docs/planning/visual-audit-inventory.json`. Defaults: `build/test_output/vis006-batch07-defaults/`; runtime previews: `build/test_output/vis006-batch07/`; test: `integration_test/catalog/vis006_batch07_runtime_preview_test.dart`. No formulas, shaders, catalog defaults, or static thumbnails changed.

- [x] **VIS-006-BATCH-08 — Capture defaults and runtime previews for the next ten uncaptured Explore modules.** Strict real-GPU defaults and actual catalog GPU previews passed for `core.greek_cross_fractal`, `core.sierpinski_pentagon`, `core.hexaflake`, `core.pentaflake`, `core.cantor_dust`, `core.apollonian_gasket`, `core.ford_circles`, `core.steiner_chain`, `core.cesaro_fractal`, and `core.cantor_set`; default counts reconciled 10/10/0/0 and all runtime image verdicts passed at 384x346. Defaults and metrics: `build/test_output/vis006-batch08-defaults/thumbnail_report.json`; runtime images: `build/test_output/vis006-batch08/`; test: `integration_test/catalog/vis006_batch08_runtime_preview_test.dart`. CPU reference oracles were skipped for all ten. No formula, shader, default, or static thumbnail changed.

- [x] **VIS-006-BATCH-09 — Capture defaults and runtime previews for the next ten uncaptured Explore modules.** Strict forced-GPU defaults reconciled selected/generated/failed/skipped as 10/10/0/0 for `core.fractal_canopy`, `core.benesi`, `core.schottky_limit_set`, `core.henon`, `core.tinkerbell`, `core.gingerbreadman`, `core.lozi`, `core.duffing`, `core.ikeda`, and `core.clifford`. All default captures (256×256) and actual catalog runtime previews (384×346) passed image-health checks; reference math oracles were explicitly skipped for all ten. Details and per-module metrics are recorded in `docs/planning/visual-audit-inventory.json`; artifacts are under `build/test_output/vis006-batch09-defaults/` and `build/test_output/vis006-batch09/`; test: `integration_test/catalog/vis006_batch09_runtime_preview_test.dart`. No formula, shader, module default, or static thumbnail changed.

- [x] **VIS-006-BATCH-10 — Capture defaults and runtime previews for the next ten uncaptured Explore modules.** Strict forced-GPU defaults reconciled selected/generated/failed/skipped as 10/10/0/0 for `core.peter_de_jong`, `core.svensson`, `core.gumowski_mira`, `core.arnold_cat`, `core.standard_map`, `core.zaslavsky`, `core.kicked_rotator`, `core.chua_circuit`, `core.sprott_a`, and `core.burke_shaw`. All defaults (256×256) and actual runtime catalog previews (384×346) passed image-health checks; all ten mathematical reference oracles were skipped because none is registered. Per-ID metrics, paths, and existing shader references are in `docs/planning/visual-audit-inventory.json`; outputs are under `build/test_output/vis006-batch10-defaults/` and `build/test_output/vis006-batch10/`; runtime test: `integration_test/catalog/vis006_batch10_runtime_preview_test.dart`. No formula, shader, module default, or static thumbnail changed.

- [x] **VIS-006-BATCH-11 — Capture defaults and runtime previews for the next ten uncaptured Explore modules.** Strict forced-GPU module-default captures reconciled selected/generated/failed/skipped as 10/10/0/0 for `core.arneodo`, `core.dadras`, `core.chen`, `core.lu_chen`, `core.halvorsen`, `core.scroll_waves`, `core.rikitake`, `core.aizawa`, `core.rabinovich_fabrikant`, and `core.nose_hoover`. All ten defaults (256×256) and actual runtime catalog GPU previews (384×346) passed image-health checks; no reference mathematical oracles were registered. Per-ID shaders, paths, and image metrics are recorded in `docs/planning/visual-audit-inventory.json`; artifacts are under `build/test_output/vis006-batch11-defaults/` and `build/test_output/vis006-batch11/`; runtime test: `integration_test/catalog/vis006_batch11_runtime_preview_test.dart`. No formulas, shaders, defaults, or static thumbnails changed.

- [x] **SMOOTH-001-COVERAGE-03 — Extend regression coverage to another supported shader family.** Added Phoenix memory-map coverage for its escaped-magnitude smooth formula, inside-set output, and standard palette mapping; a numeric regression distinguishes smooth palette coordinate 1/64 from raw iteration coordinate 3/64 for the test point. Coverage is now ten bounded families (14 shaders), not a complete inventory. Formatter, analyzer, and focused coverage/regression tests passed; see `goals.json`.
  - Payoff: find another applicable uncovered family and preserve formula-specific handling.
  - Scope: reconcile the shader-family inventory with `test/shaders/smooth_coloring_family_coverage_test.dart`; add a focused source assertion for the next applicable uncovered family. Do not alter shader formulas or claim full inventory coverage from a partial sample.
  - Sources: `TODO.md` P1-3, `test/shaders/smooth_coloring_family_coverage_test.dart`, and `docs/engineering/performance/SHADER_OPTIMIZATIONS.md`.
  - Acceptance: assert that family's smooth formula, palette use, and inside-set output; pass formatter, analyzer, and focused regression tests; update the bounded family/shader table. Dependency: SMOOTH-001-COVERAGE-02. Ownership: repository backlog; check active work before dispatch.

#### Done

- [x] **VIS-004 — Verify the Featured Launch Set viewer starts.** GPU first-view checks cover all nine IDs: the shared user-flow test covers `mandelbrot`, `burning_ship`, `phoenix`, `barnsley_fern`, `lorenz_2d`, `julia`, and `koch_snowflake`; dedicated tests cover `newton_z3` and `nova`. The shared flow reports 12 tests passed. The dedicated Newton and Nova tests each report the GPU first frame and configured module state. See the exact commands in `goals.json`.

- [x] **VIS-005 — Reconcile Explore and research-library IDs.** The inventory validator and catalog integrity test pass. It records 1,027 Explore IDs (core=1,027; performance=0) and all 200 manifest IDs. The 200 research rows are explicitly `missing_app_renderer`; this inventory result is not visual-render evidence. Native CPU formula coverage remains in VIS-006.
  - Scope: map each Explore ID to its module and shader, and give each research ID an explicit app-renderer status and source reference. Do not change formulas or implement missing modules during inventory.
  - Sources: `research/fractals-library/AGENTS.md`, `research/fractals-library/data/fractal_manifest.json`, `test/catalog/catalog_id_integrity_test.dart`, and [`docs/planning/visual-fidelity-audit-next.md`](docs/planning/visual-fidelity-audit-next.md).
  - Acceptance: counts reconcile to both Explore groups and all 200 manifest IDs; each row has an explicit status and mapping or source reference. Checks: `flutter test test/catalog/catalog_id_integrity_test.dart --reporter expanded`, `python research/fractals-library/scripts/validate_manifest.py`, and `python research/fractals-library/scripts/validate_visual_inventory.py`.

- [x] **VIS-006 — Capture and inspect the initial seven-module GPU batch.** Captures or runtime previews are recorded for `core.burning_ship`, `core.four_wing`, `core.julia`, `core.lorenz_2d`, `core.mandelbrot`, `core.rossler_2d`, and `core.thomas_attractor`. Visual findings for Four-Wing, Lorenz, Rössler, and Thomas remain follow-ups; this batch does not complete the broader goal. See `goals.json` and the inventory artifact references.

- [x] **SMOOTH-001 — Run the current smooth-coloring regression set.** Focused checks cover four families and seven shaders. The broader applicable shader inventory remains open under `SMOOTH-001-COVERAGE-01`.

**Remaining visual-audit evidence:** the inventory records capture/runtime-preview evidence for 127 of 1,027 Explore rows, leaving 900 uncaptured; 200 research rows have no app renderer. The `first_view` field is populated for nine Explore rows; missing first-view evidence is not implied by GPU capture records. `cpu_formula` is `not audited` in 1,164 of the 1,227 inventory rows. These entries are explicitly NOT_CHECKED for CPU correctness and first-view behavior; GPU capture success does not qualify either. The earlier 1,020-entry GPU run timed out and is not full-coverage evidence. Do not record a final audit verdict until the accepted scope is accounted for.

- [x] GPU deep zoom not switching to CPU at all; adjust fallback thresholds/hysteresis
- [x] **Panning bugs at high zoom** — Fixed 2026-08-12 by migrating
  camera/render vectors from Float32-backed `vector_math` to
  `vector_math_64`; verified at `1e12` zoom and from viewport-edge gestures
  (`fractal_view_state_test.dart`, `fractal_renderer_gesture_test.dart`)
- [x] **Auto-zoom not continuous** — fixed: zero-dwell transitions between zoom legs; elapsed-time animation, speed changes, and interruption/resume are covered by auto-explore service/planner tests ✅ verified 2026-10-03
  - **Verified:** `flutter test test/features/auto_explore/auto_explore_service_test.dart test/features/auto_explore/auto_explore_zoom_planner_test.dart` (48 tests passed)

## Launch Visual Audit Handoff

Canonical plan: [`docs/planning/visual-fidelity-audit-next.md`](docs/planning/visual-fidelity-audit-next.md). The thumbnail decision is resolved: 320×320 launch-set thumbnail media outputs, no static catalog thumbnail bundle; 256×256 staged smoke is allowed. High-resolution hero stills remain a separate configurable output.

### Now

None: the current Featured Launch Set Chromium smoke and 320×320 GPU capture gates are complete. Remaining launch-media selection and icon visual sign-off require product-owner judgment.

### Blocked / Needs decision


- [ ] **MEDIA-002 — Select launch hero stills.** Scope: choose 6–8 from the captured Featured Launch Set plus separate 3D/tiling candidates (`mandelbulb` and `spectre_monotile` or `hat_monotile`); no source asset publication. Acceptance: record the selected module IDs and artifact paths, covering 2D escape-time, Newton, IFS, attractor, tiling, and one 3D example as required by the runbook. Dependency: candidate output from MEDIA-001 and supplemental high-resolution captures must exist. Blocker: selection is taste-based and requires product-owner judgment; owner not recorded. See [`docs/planning/LAUNCH_MEDIA.md`](docs/planning/LAUNCH_MEDIA.md).
  - Goal: MEDIA-002.
- [ ] **VIS-003 — App icon visual sign-off.** Scope: inspect the existing adaptive launcher and store artwork in representative device masks; do not treat missing files as the issue or redesign without approval. Acceptance: product owner records accept/request-change and any exact crop/design correction. Blocker: visual acceptance criteria/approval are owner-controlled; inputs and dimensions were checked, but visual acceptance is not claimed. Ownership: owner decision required.
  - Goal: VIS-003.

### Done

- [x] **WEB-001 — Run the Featured Launch Set Chromium smoke.** The exact filtered Chromium smoke passed all nine modules with zero failures or warnings; independent review confirmed the runtime regression fixture and smoke result. Evidence: native task `t_411791c4`, review run 135; reports `test/results/catalog-smoke-chromium.json` and `test/results/playwright-results.json`.
- [x] **MEDIA-001 — Verify 320×320 launch-thumbnail captures.** Forwarded `FORCE_GPU_RENDER=true` to avoid the integration placeholder, then captured all nine Featured Launch Set images on the AMD Radeon RX 6800 XT. All nine PNGs are 320×320 with zero failed renders and zero `qualityWarnings`; each render audit passed. Evidence: native task `t_8b02fb11`, run 165; `build/test_output/launch_media/thumbnail_report.json`. The descriptive launch metric flags `barnsley_fern` as near-black (mean luminance 12.9604, dark-pixel ratio 0.9365); this is not a formal quality warning and remains relevant to owner selection.
- [x] **VIS-000 — Correct thumbnail policy and classify catalog golden artifacts.** PRD and CONTEXT now reflect the resolved 320×320 launch-media scope; runtime catalog rendering remains the shipped policy. The audit plan records the tracked golden-failure images separately from the four passing golden comparisons.

## Documentation scope questions

### Blocked / Needs decision

- [ ] **DOC-PRD-001 — Reconcile current product-scope ownership.** Goal: resolve `BLK-20261005-004` and identify whether root `PRD.md` or the current backlog/README owns active scope where they differ. Default applied: treat conflicting, unimplemented root-PRD items as historical until revalidated; do not add product scope meanwhile. Scope: documentation and goal records only; no feature implementation. Acceptance: owner chooses A or B in `BLOCKERS.md`, then the PRD/backlog mark each affected item as active, deferred, or out of scope with consistent links. Source: [`PRD.md`](PRD.md), [`docs/planning/PRD.md`](docs/planning/PRD.md), and [`BLOCKERS.md`](BLOCKERS.md). Ownership: repository backlog.

### P0-3: Dynamic Iteration Adjustment

- [x] Increase max iteration slider beyond 500 (now 5000)
- [x] Automatically raise iteration count when zooming in (adaptive step-up)
- [x] Adaptive logic: start low, progressively increase based on zoom growth
- [x] Convergence detection: compare previous frame, stop when changes < threshold
- [x] Works on both GPU and CPU fallback paths

---

## P1 — HIGH PRIORITY (Deep Zoom & GPU Quality)

### P1-1: Perturbation Theory Improvements

#### P1-0: Escape-Time Shader SkSL Fix (COMPLETED 2026-04-05)
- [x] **Escape-time shader GPU compilation fix** — 204 shaders had SkSL-incompatible `%` operator
  - **Root cause:** SkSL doesn't support `%` (modulo) operator on integers
  - **Fix:** Replaced `x % N` with `x - (x / N) * N` across all affected shaders
  - **Files fixed:** All shaders with `(schemeInt - 50) % 4` palette cycling
  - **Verified:** `buffalo_gpu.frag` now compiles on GPU (previously failed)
  - **Impact:** All escape-time fractals now render correctly on GPU instead of falling back to CPU

#### P1-1a: Fix Perturbation Artifact Bug (COMPLETED 2026-04-05)

- [x] Raised perturbation overflow threshold from `1e6` to `1e12` in `shaders/escape_time_family/core/escape_time_perturb_gpu.frag`
- [ ] Follow-up only if artifacts recur: replace discontinuous fallback with smoother reference-orbit transition

#### P1-1b: Extend Perturbation to Julia Variants

**Target Fractals (Priority Order):**
- [x] `julia` - core Julia (2026-07-02: flat-render bug fixed; unified into
  escape-time wrapper via julia mode, `julia_perturb_module.dart` deleted)
- [x] `celtic_julia`, `buffalo_julia`, `burning_ship_julia`, `tricorn_julia`
  (2026-07-02: julia-mode flag reusing base deltas)
- [x] 26 preset-c julias (`f0143`-`f0176` series) routed as z²+c julia mode
- [ ] `phoenix_julia`, cubic/power/trig/perpendicular variants — need new
  shader deltas; deferred (see spec Out of scope)

**Implementation:**
- Julia variants use `uExtra2` shader flag: `dz0 = pixel offset`, `dc = 0`
- Each variant reuses its base formula's existing delta function (no new deltas)
- All julia variants now routed through unified `escape_time_perturb_module`
- `kJuliaVariantSpecs` table maps catalog IDs to (base formula, fixed c)
- F-series preset julias read `juliaCReal`/`juliaCImag` from module params

**Files:**
- `lib/core/modules/escape_time_perturb_module.dart` (unified wrapper + variant table)
- `shaders/escape_time_family/core/escape_time_perturb_gpu.frag` (julia mode flag)
- `lib/features/renderer/policy/precision_ladder_policy.dart` (routing gate)
- `lib/features/renderer/policy/render_plan.dart` (resolver simplification)
- Deleted: `lib/core/modules/julia_perturb_module.dart`

#### P1-1c: Add Period Detection for Reference Orbit (COMPLETED 2026-07-02)

- [x] **Period detection shipped** in `computeEscapeTimePerturbOrbitBytes`
  (`lib/core/modules/escape_time_perturb_module.dart`)
  - Detects approximate cycles (eps 1e-9, max period 64) with a
    consecutive-pair confirmation so Phoenix's `(z, z_prev)` state is safe
  - On detection, stops iterating and fills the orbit texture tail by
    repeating the cycle bytes (byte-identical for exact cycles, ≤1 LSB for
    attracting cycles)
  - Orbit computation extracted to a pure, GPU-free testable function
  - **Verified:** `test/perturb_orbit_period_test.dart` (exact 1- and
    2-cycles byte-identical vs full iteration; chaotic center has no false
    positives; escaping center unchanged)

- [x] **Julia orbit encoding bug fixed 2026-07-02** — `julia_perturb_module.dart`
  still used the old 16-bit packing that mismatched the shader's 24-bit decode,
  degrading the Julia reference orbit to ~8 effective bits (decode error
  ~1.7e-2 vs intended ~4.8e-7). Now delegates to `packPerturbOrbitComponent`.
  **Verified:** `test/julia_perturb_orbit_encoding_test.dart`

### P1-2: Series Approximation (Deep Zoom Speedup)

**What it does:** Precompute early iterations as polynomial series, skip actual iteration when safe.

**Performance gain:** 10x-100x speedup at extreme zoom.

#### P1-2a: Series Approximation on GPU

**Implementation Approach:**
```glsl
// Add to escape_time_perturb_gpu.frag
uniform sampler2D uSeriesCoeffs;  // Texture with precomputed coefficients
uniform int uSeriesLength;         // Number of terms

vec2 computeSeries(vec2 dc, int n) {
    // Evaluate polynomial using Horner's method
    // Z_n ≈ sum_{k=0}^{N} a_k * dc^k
}

void main() {
    // ...
    for (int n = 0; n < MAX_ITERS; n++) {
        if (n < uSeriesLength && dc_magnitude_small) {
            Z_n = computeSeries(dc, n);  // Skip iteration
        } else {
            Z_n = fetchOrbit(n) + deltaIterate(n, dc);  // Full perturbation
        }
    }
}
```

**Files to Create:**
- `lib/core/modules/series_approximation.dart` — Coefficient computation

**Files to Modify:**
- `shaders/escape_time_perturb_gpu.frag`
- `lib/core/modules/escape_time_perturb_module.dart`

#### P1-2b: Series Approximation on CPU

**Implementation:**
```dart
// Compute series coefficients during reference orbit calculation
List<Complex> computeSeriesCoefficients(Complex c, int terms) {
    // a_0 = 0
    // a_1 = 1 (for Mandelbrot)
    // a_2 = 2*z_1
    // a_3 = 2*z_2 + 2*z_1^2
    // ... derive recursively
}
```

### P1-3: Smooth Coloring in ALL Shaders

**Current State:** Smooth-coloring code appears in multiple shaders, including `shaders/escape_time_family/core/escape_time_perturb_gpu.frag`. No complete inventory or regression test verifies coverage across the applicable polynomial escape-time shader set.

**Target:** Audit all applicable polynomial escape-time shaders and add or confirm formula-appropriate smooth coloring. The earlier estimate of approximately 80 shaders has not been rechecked.

**Example Formula:** This expression is used by the perturbation shader. Check each recurrence and magnitude value before applying it to another shader.
```glsl
float smoothVal = float(it) - log2(log2(max(1e-12, finalMag2))) + 4.0;
```

**Shader Files to Audit:** (Priority order; these are review targets, not confirmed failures)
1. `shaders/legacy/escape_time/mandel_step_smooth.frag`
2. `shaders/legacy/escape_time/julia.frag`
3. `shaders/legacy/escape_time/burning_ship.frag`
4. Applicable files under `shaders/escape_time_family/`

See [`docs/engineering/performance/SHADER_OPTIMIZATIONS.md`](docs/engineering/performance/SHADER_OPTIMIZATIONS.md) for current coverage limits and checks.

### P1-4: Arbitrary Precision for Extreme Zoom (CPU)

**Current Limit:** Double precision ~1e12 with df2 shader, then arbitrary precision CPU.

**Implementation Options:**

| Approach | Pros | Cons |
|----------|------|------|
| Integer arrays (base 10^9) | Fast, portable | Complex implementation |
| `decimal` package | Easy | Slow, large numbers |
| MPFR bindings | Fast, proven | Native code, complex |

**Recommended:** Custom integer array implementation for performance.

**Files to Create:**
- `lib/core/math/big_decimal.dart` — Arbitrary precision arithmetic
- `lib/core/math/big_complex.dart` — Complex number with BigDecimal

### P1-5: True Plane Anchors (AR-Ready)

**From PRD:** "Integrate true plane anchors (vertical + horizontal)"

**Implementation:**
1. Detect dominant line/plane in fractal boundary via edge detection
2. Anchor navigation to detected geometry
3. Enable "tap to place" on fractal boundaries

**Status:** Not started, deferred.

---

## P2 — IMPORTANT PRODUCT POLISH

### P2-1: GPU Visual Quality

- [ ] **Smooth coloring** in all escape-time shaders (see P1-3)
- [x] **Palette texture system** — Pass palette as texture uniform
- [ ] **Color cycling animation** — Perturbation shader supports time shift; roll out beyond perturbation path
- [x] **User palette selection** — Select from viewer controls
- [ ] **Regression test** — Assert no banding artifacts

### P2-2: UI/UX Improvements

- [x] **Controls redesign** — HUD overlay shipped (`FractalControlsHud`)
- [ ] **Controls snap/collapse** — More aggressive
- [ ] **Overflow menu** — Move non-critical actions
- [ ] **Auto-pilot improvements** — Smooth path, dwell behavior
- [x] **Manual corrections** — Auto-explore yields to continuous gestures,
  adopts the corrected zoom/direction, and replans one-shot wheel/keyboard
  corrections (`auto_explore_service_test.dart`)

### P2-3: Preset & Export

- [ ] **Preset thumbnails** — Auto-generate on save
- [x] **Custom palettes** — Save/load gradients
- [ ] **Bookmarks** — Save coordinates + formula + palette
- [ ] **Share presets** — One-tap Instagram/X/WhatsApp
- [ ] **Frame lock** — Exact viewer-to-export fidelity

### P2-4: Catalog Hardening

- [x] Registry covers 545 escape-time entries + 37 raymarched 3D + shared/custom promotions = 1019 production fractals plus 1 scientific visualization (1027 debug/test modules including diagnostics)
- [ ] **PRD manifest loader** — `assets/catalog/prd_catalog.json`
- [x] ID lock/integrity tests
- [x] Filter/sort + list/grid toggle
- [x] Persist catalog view mode
- [x] **Add 4+ new formulas** — Catalog has grown beyond the old 370 baseline

### P2-5: Export Hardening

- [x] Export pauses auto-navigation
- [x] Separate Save vs Share
- [ ] **Resume policy prompt** — After export
- [ ] **Share QA** — WhatsApp/Instagram/X/gallery

---

## P3 — ENHANCED DEEP ZOOM (Googol-Scale)

### P3-1: Googol-Scale Architecture (10^100+)

**Target:** Enable zoom beyond 10^100.

**Components Required:**

| Component | Status | Files |
|-----------|--------|-------|
| Arbitrary precision math | 🔶 Planning | `big_decimal.dart`, `big_complex.dart` |
| Reference orbit (big float) | 🔶 Planning | `escape_time_perturb_module.dart` |
| Series approximation (GPU) | 🔶 Planning | `series_approximation.dart` |
| Delta iteration (big float) | 🔶 Planning | `escape_time_perturb_gpu.frag` |
| Period detection | 🔶 Planning | `escape_time_perturb_module.dart` |

### P3-2: Perturbation for All Polynomial Fractals

**Target:** ~80 fractals total with perturbation support.

**Progress:**
- Currently routed: 9 IDs (`julia` + 8 generic escape-time IDs)
- Julia variants: ~30 candidates (core `julia` done; variants still open)
- Other polynomial: ~40 candidates

**To Implement:**
1. Add delta formulas for all unique polynomial patterns
2. Create universal perturbation wrapper
3. Add to `kPerturbableEscapeTimeIds`

### P3-3: Chunked Rendering for Extreme Zoom

**Why:** At googol-scale, single-frame render may be too slow.

**Solution:** Tile-based parallel rendering with edge feathering.

```dart
// Divide viewport into NxN tiles
// Render tiles in parallel
// Stitch with edge blending
class ChunkedRenderer {
    List<ui.Image> tiles;
    Future<void> renderTile(int x, int y);
    ui.Image stitchTiles(List<ui.Image> tiles);
}
```

---

## P4 — NEW FRACTAL FORMULAS

### P4-1: New Escape-Time Fractals

- [x] **Target met:** Catalog grew beyond the old 370 baseline to 1014 production fractals.
- [ ] Next formula work should be quality-gated: only add researched formulas with tests, stable IDs, and shader assets.

### P4-2: New 3D Fractals

- [x] 3D shader compatibility blockers fixed.
- [ ] Next 3D work should prioritize visual QA and thumbnails over raw count.

---

## COMPLETED ITEMS

### Deep Zoom
- [x] Perturbation theory shader (9 routed IDs: Julia + 8 generic escape-time IDs)
- [x] Double-float shader (`mandelbrot_df2.frag`) for 5e6-1e12
- [x] Reference orbit cache (LRU singleton)
- [x] Deep zoom precision policy with hysteresis
- [x] Dynamic iteration scaling with zoom

### Rendering
- [x] GPU-primary with CPU fallback
- [x] Tile-based CPU renderer (96px, spiral, cancel-on-gesture)
- [x] Smooth coloring in perturbation shader
- [x] Palette texture support + cached sampler adapter
- [x] **Batched orbit-texture rasterization** (2026-07-02) — shared
  `rasterizePerturbOrbitBytes` (one `drawVertices` call) replaces the
  per-pixel `drawRect` loops duplicated in both perturbation modules
  (~4,000 draw ops per navigation step → 1; measured 3.33ms → 1.38ms per
  build at max iterations). Byte-exactness locked by
  `test/perturb_orbit_texture_test.dart` (software rasterizer) and
  `integration_test/rendering/perturb_orbit_texture_gpu_test.dart`
  (real GL pipeline; run with `-d linux`, needs `xvfb-run` when headless)

### Quality
- [x] 64 palette support + selector
- [x] Screen-reader labels
- [x] GPU→CPU threshold tuning
- [x] Catalog integrity tests

### Testing
- [x] Focused TODO refresh checks passed: catalog integrity, controls HUD, palette texture/cache tests
- [x] 19 integration test files
- [x] Golden tests (phone/tablet × dark/highContrast)
- [x] Semantic audit

---

## CPU PATH — MAINTENANCE ONLY

**Policy:** No further performance investment.

**Maintained for:**
- Emulator testing
- Broken GPU fallback
- Extreme zoom beyond GPU capability

**Current capabilities:**
- Double precision
- Tile-based progressive rendering
- 2x2 AA refine pass
- Smooth escape-time coloring

---

## OUT OF SCOPE

- **Arenaton** — Not part of this repo
- **Video recording** — Deferred
- **Runtime shader compilation** — Deferred
- **User-defined formulas** — Deferred (would require interpreter)

---

## FILE MANIFEST

### Critical Files to Modify

| File | Change | Priority |
|------|--------|----------|
| `shaders/escape_time_family/core/escape_time_perturb_gpu.frag` | Add smoother fallback / series approx if needed | P1 |
| `lib/core/modules/escape_time_perturb_module.dart` | Period detection, more polynomial IDs | P1 |
| `lib/core/modules/builders/escape_time_catalog.dart` | Add perturbation configs | P1 |
| `lib/features/renderer/policy/precision_ladder_policy.dart` | Threshold tuning | P2 |
| `lib/features/renderer/cpu/cpu_fractal_renderer.dart` | BigDecimal support | P3 |

### Files to Create

| File | Purpose | Priority |
|------|---------|----------|
| `lib/core/modules/series_approximation.dart` | Series coeff computation | P1 |
| `lib/core/math/big_decimal.dart` | Arbitrary precision | P3 |
| `lib/core/math/big_complex.dart` | Big complex number | P3 |
| `lib/core/modules/perturbation_catalog.dart` | Universal perturbation builder | P3 |

---

## RESEARCH SOURCES

### Perturbation Theory
- K.I. Martin — "Perturbation techniques for the Mandelbrot set"
- Fractalforums.com — "Perturbation Theory" (1000+ posts)
- Deepzoom.com — Practical perturbation implementation

### Series Approximation
- Paul Derbyshire — "Optimizing Mandelbrot Computation"
- Smart Internet — Series approximation algorithms

### Implementation References
- FractInt — Classic fractal software (C, historical)
- KFract — Open source perturbation
- Mandelbrot Explorer — Modern Windows app

---

## SUCCESS CRITERIA

| Milestone | Verification |
|-----------|--------------|
| No artifacts at z=5.10e+6 | Visual test, screenshot comparison |
| 3D fractals render | Launch app, navigate to Mandelbulb |
| Julia perturbation | Zoom Julia to 1e10, verify smooth |
| Series approx 10x speedup | Benchmark frame time before/after |
| Googol-scale zoom | Zoom to 10^50, verify no precision loss |

---

## NOTES

- **Perturbation ≠ Universal** — Only ~80/370 fractals can use it
- **IFS/Attractors/Cellular** — Require completely different deep zoom strategies (if any)
- **Series approximation** — Only helps when zoomed into areas that escape late
- **Period detection** — Critical for stability at extreme zoom
