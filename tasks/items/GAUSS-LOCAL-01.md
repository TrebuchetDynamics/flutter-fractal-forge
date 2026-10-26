+++
schema = 1
id = "GAUSS-LOCAL-01"
title = "Measure bounded Gaussian execution and retain local growth/export evidence"
short = "Gaussian B128 cancellation and real local exports"
status = "open"
goal = "GAUSS-MOAT-001"
section = "Now"
rank = 2000
depends_on = ["GAUSS-MOAT-03-QUALIFY", "GAUSS-MOAT-04-GROWTH", "NATIVE-PORT-DRIVER-01"]
touches = ["lib/core/models/gaussian_moat_model.dart", "test/modules/gaussian_moat_model_test.dart", "test/features/viewer/gaussian_moat_walk_test.dart", "integration_test/flows/gaussian_moat_journey_test.dart", "docs/qa/gaussian-local-20261026/"]
resources = ["live"]
kind = "implementation"
ownership = "worker"
scope = "Complete the executable local portion left by Gaussian live qualification without waiting for a physical device. Extend existing model/walk tests for B=128, bounded work/chunks/yield/cancel/stale-publication behavior; add minimal opt-in diagnostic instrumentation only if required for measured evidence. Execute the existing Gaussian journey on named owned Linux/Xvfb with assigned reserved ports; retain actual pre-walk/paused-growth PNG bytes and state instead of losing all temporary outputs. Record actual wall-clock generation/search/chunk/cancellation and process-memory observations where measurable, with honest unknowns. Deliver a source-bound local evidence manifest under docs/qa/gaussian-local-20261026/. Preserve formulas, caps and existing interaction semantics."
acceptance = ["Executable regressions exercise B=128 and cancellation with no stale publication, probe-count and existing 8ms/1024-probe cooperative budget semantics; actual scheduling overshoot is measured, not falsely promised impossible. A source-only assertion or plan is insufficient.", "Official native journey succeeds and actual retained PNGs decode with selected dimensions and frozen-walk/growth state equivalence. Record named backend and actual measurements. Software/native-only evidence stays local; no physical accessibility, MediaStore/gallery or human composition verdict is inferred."]
checks = ["Run flutter test --no-pub test/modules/gaussian_moat_model_test.dart test/features/viewer/gaussian_moat_walk_test.dart and added telemetry tests; flutter analyze --no-pub on changed paths. Use supported native reserved-port wrapper for integration_test/flows/gaussian_moat_journey_test.dart with FORCE_GPU_RENDER=true. Independently decode retained PNGs and reconcile manifest/source/state/telemetry; require successful protocol receipt and owned cleanup; git diff --check."]
exclusions = ["No Android install/uninstall/reset, production service, signing/credentials, package installation, remote publication or borrowed listener waiver. Software results are not hardware/physical/human qualification. Do not close the original human/device-gated tasks.", "No new formula, changed finite cap, broad controller/render rewrite or cross-platform performance guarantee."]
live = "authorized"
+++
- Sources: docs/tasks/UNBLOCK-20261026.md#execute-these-items-not-another-readiness-report
