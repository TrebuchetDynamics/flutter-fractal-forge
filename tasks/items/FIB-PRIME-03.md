+++
schema = 1
id = "FIB-PRIME-03"
title = "Qualify Fibonacci prime-degree viewing and exports on real supported targets.**"
short = "Qualify Fibonacci prime-degree viewing and exports on real supported targets.**"
status = "open"
goal = "FIB-PRIME-001"
section = "Needs decision"
rank = 51000
depends_on = ["FIB-PRIME-02"]
touches = ["integration_test/flows/fibonacci_complex_journey_test.dart", "test/playwright/web-image-creation-journey.spec.mjs", "docs/engineering/test-plan.md"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "Run real catalog -> edit c/N/view -> save/reopen -> PNG journeys on named available Linux, browser and installed Android targets after implementation. Check actual accessible legend/default usefulness and decoded outputs; platform results remain separate. Needs target/access, not a new mathematical or product-design decision."
acceptance = ["Each selected target records build/backend/device identity, actual journey result and same-state PNG readback with EN/ES/narrow/large-text/high-contrast coverage. GPU transparency and refused unsupported CPU transparency are truthful. Missing targets remain explicitly unavailable and cannot qualify the feature; offline implementation is not blocked by absent device access. No deployment, store upload or broader release inferred."]
checks = ["Planned: `flutter test integration_test/flows/fibonacci_complex_journey_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded`; same target on an actual named Android device when authorized; `npx --no-install playwright test test/playwright/web-image-creation-journey.spec.mjs --project=chromium --workers=1 --grep Fibonacci --reporter=list` with the existing owned configured host and allowed listener policy. No Number Walls-only port waiver transfers. All journeys NOT_RUN."]
exclusions = []
+++

- Section: Needs decision.
- Sources: [Owner outcome](PRD.md#fibonacci-prime-degree-julia-fractal), [decided contract](docs/engineering/spec.md#fibonacci-prime-degree-julia), [checks](docs/engineering/test-plan.md#fibonacci-prime-degree-julia-verification), [retained research](research/fibonacci-prime-degree-julia.md).
- Ownership: Repository backlog, unassigned; preserve existing ordering/owners. Planning-only; no implementation, migration, scheduling or publication dispatched.
- Next action: After FIB-PRIME-02, obtain a named authorized target and run the composed journey, retaining actual unavailable targets. No worker dispatch or target access is granted by saving this plan.
