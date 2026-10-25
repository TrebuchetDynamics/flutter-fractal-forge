+++
schema = 1
id = "NATIVE-PORT-DRIVER-01"
title = "Repair the reserved-port native integration driver prerequisite"
short = "Supported native test driver"
status = "done"
goal = "NUM-WALL-001"
section = "Now"
rank = 2000
depends_on = []
touches = ["scripts/run-native-integration.sh", "test_driver/integration_test.dart", "test/scripts/test_reserved_native_driver.py", "docs/engineering/runbook.md"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "Repair the concrete NUM-WALL-04 environment hold without rerunning the same unsupported flutter test flag. Inspect pinned Flutter 3.44.6 DriveCommand/RunCommandBase and official integration_test host driver. Establish one supported invocation of the EXISTING native journey with explicit VM listener ports inside the actual AUTOWORK_PORT_BASE..+99 allocation, no DDS/devtools random listener, private scratch, bounded execution and owned cleanup. Reuse the existing integration test protocol, fixture and retained candidate; do not duplicate the 80-file Number Walls implementation or alter app/formula behavior. If flutter drive is supported, provide only the minimal reusable driver/invocation and focused regression tests, then qualify it with an existing benign native fixture. Exact Number Walls artifact rerun remains with NUM-WALL-04. If no supported native route meets all policies, retain the exact technical failure instead of claiming success."
acceptance = ["The pinned official SDK accepts the driver invocation and the actual integration_test binding reports terminal success/failure for the existing target; no plugin-not-detected, timeout, missing result or supplemental flutter run output becomes a passed driver result.", "All VM/service listeners use the native task-allocated range and loopback; missing/invalid allocation refuses before launch. Bounded failure/signal cleanup retains logs and proves owned resources terminated without touching other applications. No SDK patch, arbitrary-port exception, installation, dependency change or port-policy weakening.", "Focused offline command/cleanup regressions demonstrate refusal and nonzero propagation; one supported owned native fixture run records exact revision, command, result and cleanup. Missing native proof stays pending. Preserve all NUM-WALL-04 Linux/browser parity, rendering, PNG and replay acceptance; this prerequisite does not close NUM-WALL-04 or NUM-WALL-05."]
checks = ["/usr/bin/python3 -m pytest test/scripts/test_reserved_native_driver.py -q", "bash scripts/run-native-integration.sh --help", "git diff --check"]
exclusions = ["No arbitrary listener ports, SDK/host/profile changes, new dependencies, device/Android/production/live qualification, app/shader/model changes, discarded artifacts, weakened assertions, acceptance waiver or publication grant."]
closure = "coordinator_verified"
closure_evidence = "tasks/evidence/NATIVE-PORT-DRIVER-01.toml"
+++
- Sources: docs/engineering/runbook.md#owned-linux-runtime-with-reserved-ports; tasks/items/NUM-WALL-04.md; retained NUM-WALL-04 attempt-2 validation failure; pinned packages/flutter_tools/lib/src/commands/drive.dart
- Pending live: NUM-WALL-05 installed Android/device, MediaStore/gallery and TalkBack qualification remains unperformed and separate.
- Pending live: Physical hardware-GPU and human visual/screen-reader qualification are not established by the Linux/Xvfb driver fixture.
