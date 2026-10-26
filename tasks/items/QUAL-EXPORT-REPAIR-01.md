+++
schema = 1
id = "QUAL-EXPORT-REPAIR-01"
title = "Repair stale native catalog search and complete edited 2D/3D export journey"
short = "Fix stale search; retain both edited PNGs"
status = "open"
goal = "REL-JOURNEY-001"
section = "Now"
rank = 1000
depends_on = ["QUAL-EVIDENCE-01", "NATIVE-PORT-DRIVER-01"]
touches = ["integration_test/flows/user_flows_test.dart", "integration_test/helpers/ui_test_helpers.dart", "lib/features/catalog/", "test/catalog/", "test/fractal/fractal_catalog_screen_widget_test.dart", "docs/qa/export-journey-repair-20261026/"]
resources = ["live"]
kind = "implementation"
ownership = "worker"
scope = "Reproduce QUAL-EVIDENCE-01 stale Mandelbrot query before Mandelbulb in the original user_flows_test journey. Trace real search field/input focus/controller behavior; fix only the proven test-helper or production catalog layer and add focused regression coverage. Retain existing assertions and both module journeys. Execute the unchanged semantic journey through scripts/run-native-integration.sh on owned Linux/Xvfb using the actual assigned worker range, and retain both real edited Mandelbrot/Mandelbulb PNG/state pairs plus source/SDK/backend/protocol/cleanup receipts. Add source-bound result documentation under docs/qa/export-journey-repair-20261026/. No broad catalog refactor."
acceptance = ["A regression reproduces and then rejects stale query/results after returning from Mandelbrot and searching Mandelbulb. No added arbitrary sleeps, deleting the second module, catch-and-ignore, relaxed pixel assertions or synthetic exports. Root-cause evidence distinguishes helper failure from product failure.", "Original complete native fixture reaches official terminal protocol success with both edited PNGs retained and independently decoded at selected dimensions, with actual state and hashes; owned cleanup remaining_pids is empty. Preserve failed historical receipts. A repeated failed capture is not completion of this repair."]
checks = ["Run focused catalog/helper regression before and after repair; run flutter analyze --no-pub on changed Dart. Execute scripts/run-native-integration.sh integration_test/flows/user_flows_test.dart with FORCE_GPU_RENDER=true, pinned Flutter and the actual worker allocation. Decode both retained real files, validate source/state/dimensions/hash manifest and protocol_success true / exit 0 / empty remaining_pids. Run relevant existing catalog search/widget tests; git diff --check."]
exclusions = ["No Android install/uninstall/reset, production service, signing/credentials, package installation, remote publication or borrowed listener waiver. Software results are not hardware/physical/human qualification. Do not close the original human/device-gated tasks."]
live = "authorized"
+++
- Sources: docs/tasks/UNBLOCK-20261026.md#evidence-motivating-the-repair
