+++
schema = 1
id = "NUM-WALL-05"
title = "Qualify installed Android Number Walls and accessible interaction.**"
short = "Qualify installed Android Number Walls and accessible interaction.**"
status = "done"
goal = "NUM-WALL-001"
section = "Next"
rank = 4000
depends_on = ["NUM-WALL-03", "NUM-WALL-04"]
touches = ["integration_test/flows/number_wall_journey_test.dart", "docs/engineering/test-plan.md"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "Reuse the composed Number Walls journey on a named installed Android device; verify keyboard/TalkBack focus for prime Apply, sequence/style/randomizer and cell inspector, interruption/backgrounding and actual saved PNG/gallery visibility. No binary upload, rollout or store publication."
acceptance = ["Device/certificate/build/backend identity and exact test results are retained. Custom prime entry and long decimal labels do not overflow; settings/export survive allowed lifecycle events without stale updates. Gallery PNG decodes with matching cells and dimensions. TalkBack navigation and enlarged text/high-contrast controls work. Missing hardware remains NOT_CHECKED and cannot close parent acceptance or block independent offline implementation."]
checks = ["Planned: `flutter test integration_test/flows/number_wall_journey_test.dart -d DEVICE_ID --reporter expanded` with the actual named device replacing DEVICE_ID; perform and record TalkBack and gallery/readback steps from the test plan. No attached-device or executed-pass claim is made during planning."]
exclusions = []
closure = "coordinator_verified"
closure_evidence = "tasks/evidence/NUM-WALL-05.toml"
+++

- Section: Next.
- Payoff: prove actual device viewing, cancellation, accessible controls and gallery output.
- Sources: [Accepted outcome and decided design](docs/engineering/spec.md#number-walls-and-modular-windows), [verification owner](docs/engineering/test-plan.md#number-wall-verification), `integration_test/flows/user_flows_test.dart`.
- Ownership: Repository backlog, unassigned; needs real device access at qualification time, not a new product decision.
- Next action: Use an available named Android device after the integrated feature exists; retain exact unavailable access if held.
- Dependency evidence: NUM-WALL-04 creates integration_test/flows/number_wall_journey_test.dart (its Checks and Next action); this task Scope reuses that composed journey and its Checks run the same target on Android. The target is absent at 81bb05232f431a1b8344a38d87c573f28bc9adf6 and is being authored in the live NUM-WALL-04 worktree. Retain NUM-WALL-03; NUM-WALL-04 is an artifact producer prerequisite, not a dependency inferred from the hot test-plan path. See docs/tasks/qualification-overlap-review.md.
- Pending live: NOT_CHECKED: source-bound installed Android Number Walls composed journey and actual renderer/backend identity on an install-safe test target. Available WayDroid is not a physical phone; its release-signed installed APK has unknown source binding and was preserved. No Android test executed or Number Walls PNG was produced.
- Pending live: NOT_CHECKED: natural-viewport EN/ES custom-prime Apply and long-decimal layout, keyboard focus/activation, 2x text/high contrast and actual TalkBack navigation/spoken status. Attached target has no TalkBack package or enabled accessibility service; physical-device/operator qualification remains separate.
- Pending live: NOT_CHECKED: real Android background/resume/navigation during pending validation/grid/export, committed settings restoration and stale-completion protection.
- Pending live: NOT_CHECKED: actual MediaStore row publication, content-URI PNG readback with exact cell/zero-mask and 1280x720 checks, Gallery visibility/readability and human composition review. Local export-file success must not substitute for best-effort MediaStore publication.
