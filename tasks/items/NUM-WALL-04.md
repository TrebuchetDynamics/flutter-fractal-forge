+++
schema = 1
id = "NUM-WALL-04"
title = "Qualify Number Walls on Linux and web with real artifacts.**"
short = "Qualify Number Walls on Linux and web with real artifacts.**"
status = "open"
goal = "NUM-WALL-001"
section = "Next"
rank = 3000
depends_on = ["NUM-WALL-03"]
touches = ["integration_test/flows/number_wall_journey_test.dart", "test/playwright/number-wall-journey.spec.mjs", "docs/engineering/test-plan.md"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "Exercise catalog -> six sources -> custom prime -> style/randomize/undo -> save/reopen -> PNG with real Linux rendering and browser. Record default/worst-budget computation, cancellation responsiveness, bounded memory and actual screenshots. No new formulas, release or device acceptance."
acceptance = ["Native/browser cell matrices agree for identical inputs, PNGs decode at requested dimensions with matching cells, gallery/card/inspector labels stay honest, defaults visibly show documented windows rather than placeholders. Capture EN/ES/narrow/high-contrast/text-scale states and classify clipping/visual defects. Large/unverified prime and worst zero-window jobs remain cancellable with no stale commit. Retain actual timings/environment, not promised unlimited zoom or fabricated performance scores. Widget-font/renderer substitutions are not live qualification. Include an actual replay/import case on native and browser proving an invalid or unfinished modulus cannot replace the committed grid, followed by a valid outside-quick-pick replay and matching PNG."]
checks = ["Planned new integration target: `flutter test integration_test/flows/number_wall_journey_test.dart -d linux --reporter expanded`; `flutter build web`; use the repository's Playwright runner on `test/playwright/number-wall-journey.spec.mjs` (record its exact command after adding the target); decode/read back PNG downloads and saved files. All are NOT_RUN. Add that replay/invalid-state case to the existing planned native/browser journeys rather than another harness."]
exclusions = []
+++

- Section: Next.
- Payoff: verify useful defaults, exact parity and saved/exported artwork beyond widget fixtures.
- Sources: [Accepted outcome and decided design](docs/engineering/spec.md#number-walls-and-modular-windows), [verification owner](docs/engineering/test-plan.md#number-wall-verification), `integration_test/flows/user_flows_test.dart`, `test/playwright/`.
- Ownership: Repository backlog, unassigned. Linux/browser qualification is distinct from Android installed-device checks.
- Next action: Add the composed native/browser journeys and capture real same-state grid/export artifacts.
