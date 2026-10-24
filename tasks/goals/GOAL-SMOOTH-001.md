+++
schema = 1
id = "GOAL-SMOOTH-001"
title = "Prove smooth-coloring coverage for supported escape-time shaders"
priority = 4
source = "TODO.md#p1-3-smooth-coloring-in-all-shaders"
status = "partial"
focus = false
depends_on = []
+++

- Legacy ID: SMOOTH-001
- Evidence: executed: dart format --output=none --set-exit-if-changed test/shaders/smooth_coloring_family_coverage_test.dart (pass)
- Evidence: executed: dart format --output=none --set-exit-if-changed test/shaders/smooth_coloring_family_coverage_test.dart && flutter analyze test/shaders/smooth_coloring_family_coverage_test.dart && flutter test test/shaders/smooth_coloring_family_coverage_test.dart test/shaders/smooth_coloring_regression_test.dart test/shaders/escape_time_perturb_smooth_coloring_test.dart test/shaders/mcmullen_map_smooth_coloring_test.dart && git diff --check (pass)
- Evidence: executed: dart format test/shaders/smooth_coloring_family_coverage_test.dart && dart format --output=none --set-exit-if-changed test/shaders/smooth_coloring_family_coverage_test.dart && flutter analyze test/shaders/smooth_coloring_family_coverage_test.dart && flutter test test/shaders/smooth_coloring_family_coverage_test.dart test/shaders/smooth_coloring_regression_test.dart test/shaders/escape_time_perturb_smooth_coloring_test.dart test/shaders/mcmullen_map_smooth_coloring_test.dart && git diff --check (pass)
- Evidence: executed: flutter analyze test/shaders/smooth_coloring_family_coverage_test.dart (pass)
- Evidence: executed: flutter test test/shaders/smooth_coloring_family_coverage_test.dart (pass)
- Evidence: executed: flutter test test/shaders/smooth_coloring_family_coverage_test.dart test/shaders/smooth_coloring_regression_test.dart --reporter expanded (pass)
- Evidence: executed: flutter test test/shaders/smooth_coloring_family_coverage_test.dart test/shaders/smooth_coloring_regression_test.dart test/shaders/escape_time_perturb_smooth_coloring_test.dart test/shaders/mcmullen_map_smooth_coloring_test.dart (pass)
- Evidence: executed: git diff --check (pass)
- Evidence: executed: python3 -c 'from pathlib import Path; p="shaders/escape_time_family/families/multibrot/integer_powers/multibrot4_gpu.frag"; assert Path(p).is_file(); assert p in Path("test/shaders/smooth_coloring_family_coverage_test.dart").read_text(), "SMOOTH-001 incomplete: supported Multibrot d=4 is absent from the family coverage test"' (fail)
- Evidence: inspection: TODO.md#P1-3: four families (7 shaders) covered; complete applicable polynomial escape-time inventory remains open (fail)
- Evidence: inspection: docs/engineering/performance/SHADER_OPTIMIZATIONS.md (pass)
