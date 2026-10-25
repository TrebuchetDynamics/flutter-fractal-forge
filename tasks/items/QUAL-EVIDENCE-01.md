+++
schema = 1
id = "QUAL-EVIDENCE-01"
title = "Retain actual Linux edited-export evidence for delegated qualification review"
short = "Retain edited Linux PNGs and qualification input matrix"
status = "open"
goal = "REL-JOURNEY-001"
section = "Now"
rank = 2000
depends_on = ["REL-JOURNEY-02-LINUX", "NATIVE-PORT-DRIVER-01"]
touches = ["docs/qa/delegated-qualification-20261025/", "integration_test/flows/user_flows_test.dart"]
resources = ["live"]
kind = "implementation"
ownership = "worker"
scope = "Execute the existing source-bound Linux 2D/3D edited image journey using scripts/run-native-integration.sh and the pinned SDK with an actual assigned worker port range. Retain actual Mandelbrot/Mandelbulb exported PNGs outside temporary deletion plus source/harness/SDK/backend hashes, decoded dimensions/content and truthful viewer-state sidecars. If necessary add only capture/provenance instrumentation to the existing journey, without weakening assertions or changing product behavior. Produce docs/qa/delegated-qualification-20261025/README.md and a machine-readable manifest linking private retained artifacts and actual missing inputs across the 23 retained tasks. Read-only target inventory is allowed; do not attach to other sessions. This is evidence preparation, not human acceptance or publication."
acceptance = ["Actual edited-state 2D/3D PNGs survive the test, decode at selected dimensions and retain measured content checks and immutable source/backend/SDK/state provenance. State unavailable from an existing receipt must be captured, never reconstructed as if observed. If the permitted native route is unavailable, retain the exact failure and do not fabricate a successful capture.", "Use actual reserved ports and official terminal protocol success; record cleanup. Classify hardware versus software and Waydroid versus physical device. For every retained task identify the missing human/source/device/manifest input without silently clearing its hold or claiming qualification. No external-effect checks or credentials."]
checks = ["Use docs/engineering/runbook.md#owned-linux-runtime-with-reserved-ports and scripts/run-native-integration.sh with integration_test/flows/user_flows_test.dart and FORCE_GPU_RENDER=true on the allocated range. Require successful protocol receipt and empty remaining_pids. Decode retained actual PNG bytes; reconcile hashes/dimensions/viewer state with manifest and source. Run affected tests if capture instrumentation changes; git diff --check."]
exclusions = ["Only owned local Linux evidence collection and read-only target inventory are authorized. No Android install/uninstall/reset, remote service, credential use, signing, upload, deployment, new listener waiver, package install, production operation or human visual acceptance. Keep retained-task holds until their exact inputs exist."]
live = "authorized"
+++
- Sources: docs/tasks/DELEGATED-DECISIONS-20261025.md#execution-and-release-of-holds
