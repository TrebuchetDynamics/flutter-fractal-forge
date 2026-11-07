+++
schema = 1
id = "RUST-M0-IMAGES"
title = "Retain source-bound representative Flutter reference renders"
short = "Capture real 2D 3D discrete and inspired-module defaults and edited views."
status = "open"
goal = "RUST-ENGINE-001"
section = "Next"
rank = 1000
depends_on = ["RUST-M0-CONTRACTS"]
touches = ["test/migration/reference_render_test.dart", "test/migration/support/reference_capture.dart", "migration/baseline/reference-renders/", "docs/planning/refactor-plan.md"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "Consume baseline v1 inventory. Add a real Flutter draw/readback harness using existing render paths at 256x256, time zero and opaque module defaults for mandelbrot, julia, burning_ship, newton_z3, lorenz_2d, sierpinski_triangle, number_wall, mandelbulb, milnor_brieskorn, plus deterministic edited Mandelbrot/Mandelbulb views. Use actual Number Walls certified display path. Default run validates pixels in memory; explicit MIGRATION_REFERENCE_OUT scratch output writes PNGs and per-state manifest with source/settings/backend/toolchain and encoded/decoded hashes, then explicitly promote reference artifacts. Retain independent health/classification/provenance; no academic or device qualification from nonblack pixels."
acceptance = ["Given every named real descriptor and state, reference_render_test.dart draws/readbacks finite 256x256 RGBA output and verifies renderer inputs and state bindings; missing modules, failed draws or substituted paths fail visibly rather than skip.", "Given an opt-in artifact capture, manifest and PNG readback agree on dimensions/alpha/state/hash; a second same-backend capture records equality or measured variance without inventing a cross-GPU pixel-perfect threshold. Inspired status and software backend remain labelled."]
checks = ["flutter test --no-pub test/migration/reference_render_test.dart test/modules/catalog_preset_render_health_test.dart", "flutter test --no-pub test/migration/reference_render_test.dart --dart-define=MIGRATION_REFERENCE_OUT=/tmp/fractal-m0-reference-a && flutter test --no-pub test/migration/reference_render_test.dart --dart-define=MIGRATION_REFERENCE_OUT=/tmp/fractal-m0-reference-b", "( export FLUTTER_ROOT=\"$AUTOWORK_CACHE/flutter-3.47.9\"; export PUB_CACHE=\"$AUTOWORK_CACHE/pub-cache\"; export PATH=\"$FLUTTER_ROOT/bin:/usr/bin:$PATH\"; flutter --version && /usr/bin/python3 -c 'import sys, pytest, jinja2, markupsafe; print(sys.executable, sys.version, pytest.__version__, jinja2.__version__); assert callable(markupsafe.soft_str)' && scripts/ci/offline-gate.sh --python-bin /usr/bin/python3 )"]
exclusions = ["No state/render replacement, ID renames, saved-data schema changes, publication or live device mutation in this offline task.", "Do not edit the seven pre-existing dirty test files; use isolated execution and preserve their work."]
+++
- Sources: docs/planning/refactor-plan.md#flutter-shell-and-rust-engine-migration
- Consumes: RUST-M0-CONTRACTS baseline v1 descriptors and source hashes. Produces: reference-renders/manifest.json and actual PNGs with captured input/backend hashes.
- Planner call: reuse catalog_preset_render_health_test.dart:36-66 real FragmentProgram seam plus actual Number Walls renderer; one bounded state per test avoids shared raster deadlines. A renderer failure is a failure; task-owned harness fixes allowed, source behavior changes are not.
- Repo obligations triggered: spec.md Rendering interface and Number walls contract; test-plan.md distinguishes image health from mathematical/platform qualification. Update migration evidence only. Artifact generation is a deliverable, not an action performed during planning; no production/CI/manifest edits.
- Next action: implement missing representative readback test, then capture; commands unrun.
- Check setup: output paths denote private task scratch. Harness decodes both capture sets, validates manifests and reports measured same-backend pixel variance; byte equality is not a fabricated hardware parity gate.
