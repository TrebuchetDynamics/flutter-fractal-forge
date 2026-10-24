+++
schema = 1
id = "BESICOVITCH-01"
title = "Prototype a finite Perron-tree shader after design acceptance.**"
short = "Prototype a finite Perron-tree shader after design acceptance.**"
status = "open"
goal = "BESICOVITCH-VIZ-001"
section = "Needs decision"
rank = 52000
depends_on = []
touches = ["lib/core/models/perron_tree_model.dart", "lib/core/modules/", "shaders/ifs_and_geometric/perron_tree_gpu.frag", "pubspec.yaml", "test/models/perron_tree_model_test.dart", "test/modules/perron_tree_test.dart", "docs/engineering/test-plan.md"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "Proposed one finite geometric visualization: published translated-triangle construction, independent CPU geometry checks, three rotated equilateral fans, bounded fragment coverage and optional luminous styling. Initial proposed depth cap 5 shares 32 horizontal-offset floats and tests at most 96 triangles per pixel. These are design budgets, not measured performance. Reuse existing 2D camera and captured export state; no unrelated escape-time controls or new dependency/framework."
acceptance = ["Validate the translation schedule, original unit-segment orientation intervals, complete unoriented direction coverage by three fans and valid finite area bounds without relying on pixel samples or unreviewed applet captions. Actual Flutter shader draw/decoded PNGs stay finite, show the derived model and separate geometric coverage from glow; record real backend/timings before claiming interactive performance. Label finite approximation/inspired variants honestly, distinguish needle direction sampling from continuous rotation, and preserve frozen-state export/static reduced-motion behavior."]
checks = ["Future, NOT_RUN: create and run `flutter test --no-pub test/models/perron_tree_model_test.dart test/modules/perron_tree_test.dart --reporter expanded`, compile/draw the actual shader, read back real PNGs and compare against independent CPU geometry, then run the root common offline gate on the integrated source. Geometry/claim validation must precede a faithful/Perron label. No prototype or app test was run during research."]
exclusions = []
+++

- Section: Needs decision.
- Sources: [Research and shader feasibility](research/besicovitch-shader.md#shader-feasibility).
- Ownership: Proposed work, unassigned; preserve current ordering and all existing saved attempts. Research saves this proposal, not execution authority.
- Question: Accept implementing the finite Perron-tree visualization? Default until answered: retain this proposal without dispatch, migration, schedules or publication.
- Next action: On explicit acceptance, derive and test the source-based finite geometry before adding a shader; do not transplant the reference applet's unreviewed area/all-direction captions.
