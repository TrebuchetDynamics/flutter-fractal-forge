+++
schema = 1
id = "NUM-WALL-05"
title = "Qualify installed Android Number Walls and accessible interaction.**"
short = "Qualify installed Android Number Walls and accessible interaction.**"
status = "open"
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
+++

- Section: Next.
- Payoff: prove actual device viewing, cancellation, accessible controls and gallery output.
- Sources: [Accepted outcome and decided design](docs/engineering/spec.md#number-walls-and-modular-windows), [verification owner](docs/engineering/test-plan.md#number-wall-verification), `integration_test/flows/user_flows_test.dart`.
- Ownership: Repository backlog, unassigned; needs real device access at qualification time, not a new product decision.
- Next action: Use an available named Android device after the integrated feature exists; retain exact unavailable access if held.
- Dependency evidence: NUM-WALL-04 creates integration_test/flows/number_wall_journey_test.dart (its Checks and Next action); this task Scope reuses that composed journey and its Checks run the same target on Android. The target is absent at 81bb05232f431a1b8344a38d87c573f28bc9adf6 and is being authored in the live NUM-WALL-04 worktree. Retain NUM-WALL-03; NUM-WALL-04 is an artifact producer prerequisite, not a dependency inferred from the hot test-plan path. See docs/tasks/qualification-overlap-review.md.
