# Flutter Fractal Forge — Execution TODO

[Backlog history](todo.archive.md). Scope authority is resolved; see [the accepted release contract](PRD.md#active-release-contract).

> **Last comprehensive update:** 2026-08-25 recursive-object 3D expansion. Catalog counts below are reconciled to the current integrity test.
>
> **Source anchors for this refresh:** `test/catalog/catalog_id_integrity_test.dart` (543 escape-time entries, 1020 production fractals, 1 scientific visualization, and 1028 debug/test registry modules including 7 diagnostics), `lib/features/viewer/fractal_viewer_screen.dart` (controls HUD), `lib/core/services/rendering/palette_service.dart` + `palette_shader_adapter.dart` (palette textures).

## Now

Owner interview order: **VIEW-UI-01 / VIEW-UI-02 first**, then **CAT-QUALITY-01 → CAT-QUALITY-02**. Primary focus: `VIEW-UI-001`. Preserve existing Gaussian work and active ownership; OpenAI-math additions remain Proposed. Pilot success: attractive defaults, useful controls and matching PNG export without hunting for good settings; mathematical honesty and accessibility remain mandatory. This is planning priority, not new implementation or scheduling authority. See [the recorded decision](PRD.md#quality-first-planning-priority).

- [ ] **ACAD-008-74 — Restore the full offline check so it reaches its test results.**
  - Goal: APP-QUALITY-001
  - Status: open
  - Section: Now.
  - Payoff: distinguish actual analyzer/test failures from a crashed Flutter test harness so the repository’s offline gate can produce actionable results.
  - Sources: [Accepted app-quality verification boundary](docs/engineering/spec.md#mcp-assisted-app-quality), [offline-check recovery guidance](docs/engineering/runbook.md#offline-check-export-preparation), [repository full offline gate and setup requirement](AGENTS.md#common-offline-integration-gate). Evidence: full checks at `203e406671e6` and `21921a3e6aed` each crashed before any test result with `Oops; flutter has exited unexpectedly: "Bad state: No element"` (reported twice for each); the same pre-result crash recurred twice at `acb267220083`. Worker report at `3c7c8938387d149d9b51ceadd51482d1da3852fe` records candidate-local offline metadata generation, unchanged lockfile, and a complete passing check (2,850 passed, 8 skipped), but that result does not qualify the later crashing revision. The accepted recovery guidance records an older, separate Flutter crash during `testCompilerBuildNativeAssets`, but does not establish a cause for these observed crashes. These incomplete checks are not evidence that any test failed.
  - Touches: `AGENTS.md`, `docs/engineering/runbook.md`.
  - Scope: Make the existing full offline check reach its actual command results by using the repository’s pinned/provisioned Flutter setup and candidate-local metadata, or by accurately restating the repository’s existing `Full check:` command if that is the evidenced blocker. Record the SDK/version and terminal output/exit for every gate stage. Treat `Bad state: No element` as the observed crash, not a confirmed cause. Do not repair product code or name a test as failing unless the recovered full check reports that test failure; do not install or mutate a shared SDK, change dependency constraints, bypass native-assets checks, or run device/browser/live gates.
  - Acceptance: The exact full offline command from `AGENTS.md#common-offline-integration-gate` completes far enough to report terminal results for analysis, Flutter tests, pytest and Bats; retain each actual result and any test-level failures. If it still crashes or a required tool is unavailable, record the exact stage, output and blocker without claiming the gate passed. `pubspec.lock` remains unchanged.
  - Checks: `flutter analyze --no-pub && flutter test --no-pub && python3 -m pytest test/research test/scripts -q && bats test/scripts/*.bats` (run from the repository root using the pinned/provisioned toolchain); verify the actual Flutter version against `fdroid/flutter.version`; `git diff --check`.
  - Dependencies: None.
  - Ownership: Repository backlog, unassigned; preserve existing task ownership. No device, publication, shared-SDK mutation or live-operation authority.
  - Next action: On the worker candidate `9e3bb31748dd602388611b561be2d9079e69cd46`, use the already verified pinned/provisioned Flutter 3.44.6 setup and candidate-local package metadata (the worker report confirms the package root resolves to that candidate and `pubspec.lock` is unchanged); now run the exact `AGENTS.md` Full check and retain each stage's terminal output/exit. The report contains no full-check result, and later full checks crashed before any test result, so do not treat metadata preparation or earlier passing reports as qualification. Treat the crash as an observed harness failure, not a test failure; change only the supported setup or gate definition if evidence identifies the blocker.

## Next


- [ ] **NUM-WALL-02 — Open real Number Walls from their catalog category with restorable controls.**
  - Goal: NUM-WALL-001
  - Status: open
  - Section: Next.
  - Payoff: explore real sequence-dependent walls, not disconnected thumbnail artwork.
  - Sources: [Accepted outcome and decided design](docs/engineering/spec.md#number-walls-and-modular-windows), [owner scope](PRD.md#number-walls-catalog-category), `lib/core/modules/fractal_module.dart`, `lib/core/models/fractal_parameter.dart`, `lib/core/modules/fractal_mathematics.dart`, `lib/features/catalog/data/catalog_repository.dart`, `lib/features/catalog/widgets/catalog_widgets.dart`, `lib/features/renderer/widgets/renderer/fractal_renderer.dart`. [Replay validation boundary](docs/engineering/spec.md#number-walls-replay-validation-boundary).
  - Graph evidence: Fresh 14-file catalog graph, 538 nodes/756 edges, confirms CatalogRepository/CatalogEntry and runtime-thumbnail/controller seams; query truncated, renderer/export unindexed. Direct source inspection owns the required integration details; see spec.
  - Touches: lib/core/controllers/params/fractal_param_randomizer.dart, lib/core/controllers/params/fractal_param_value_normalizer.dart, lib/core/models/fractal_parameter.dart, lib/core/modules/fractals/number_wall_module.dart, lib/core/modules/module_registry.dart, lib/features/catalog/data/catalog_repository.dart, lib/features/controls/fractal_controls.dart, lib/features/controls/param_control_plan.dart, lib/features/renderer/widgets/renderer/fractal_renderer.dart, lib/features/renderer/widgets/renderer/number_wall_exact_renderer.dart, lib/features/viewer/chrome/fractal_controls_hud.dart, lib/l10n/app_en.arb, lib/l10n/app_es.arb, lib/l10n/app_localizations.dart, lib/l10n/app_localizations_en.dart, lib/l10n/app_localizations_es.dart, lib/shared/widgets/fractal_math_summary.dart, pubspec.yaml, shaders/number_theory/number_wall_gpu.frag, test/catalog/catalog_id_integrity_test.dart, test/number_walls/number_wall_catalog_test.dart, test/number_walls/number_wall_state_test.dart
  - Scope: Register one `number_wall` / `core.number_wall` identity and localized Number Walls category; six source choices/presets, typed custom-prime Apply and bounded grid/origin controls. Route exact-grid renderer and genuine sampler shader through viewer/thumbnail paths, with exact Canvas fallback and explicit backend semantics. Add canonical decimal-string parameter/editor/normalizer/persistence handling, preserving existing modules and saved data. No dummy shaders or general catalog rebuild.
  - Acceptance: Search/category/card opens genuine editable default; all six sources switch correctly. Invalid/unverified prime edits retain the prior committed frame; latest valid Apply wins without stale replacement. Prime values round-trip exactly through presets/history/import/deep links on web/native; negative tests preserve older saved modules. Thumbnail readiness/cancellation/cache keys bind actual grid and palette settings, never a generic approximation. Cells inspect exact coordinates/modulus/residue. EN/ES, 320/768/1440 widths, text scaling, keyboard/focus, >=48px targets/high contrast and static reduced-motion display work. Backend modes cannot misrepresent float arithmetic as exact number-wall computation. Every import, deep link and history/session restoration crosses the same exact module-owned certification/commit boundary as Apply; serialized verified status is untrusted. Composite/oversized/unverified replay preserves the prior committed Number Walls settings/grid, startup without a grid shows pending/error, and late completion after newer input or module switch cannot commit.
  - Checks: `flutter test test/number_walls/number_wall_viewer_test.dart test/number_walls/number_wall_state_test.dart test/number_walls/number_wall_catalog_test.dart --reporter expanded`; `flutter test test/catalog/catalog_id_integrity_test.dart test/catalog/catalog_repository_test.dart test/catalog/catalog_thumbnail_audit_test.dart --reporter expanded`; compile the shader; format touched Dart; `flutter analyze`; `git diff --check`. Add/run the state test through actual import, deep-link, history and session-restoration entry paths, covering composite/Carmichael, oversized, deliberately unfinished, valid outside-quick-pick and forged-verification inputs; also run `flutter test --platform chrome test/number_walls/number_wall_state_test.dart --reporter expanded` with the existing port policy and exact parity gate. Required focused state/replay coverage is not yet demonstrated by the worker report. For the required full offline pytest family, use `PYTHONPATH="$AUTOWORK_CACHE/markupsafe-3.0.3${PYTHONPATH:+:$PYTHONPATH}" python3 -m pytest test/research test/scripts -q` when the provisioned Autowork cache is present; this exact invocation passed in the related export worker reports. Missing cache/package remains a blocker, not a passing check.
  - Dependencies: NUM-WALL-01.
  - Ownership: Repository backlog, unassigned; preserve live viewer/catalog workers and existing ordering.
  - Next action: Preserve retained candidate 0632aa7e477570df27a84f473e0c3a27d67a8d3c and its original report; do not reimplement or substitute its pure-Dart browser parity result for the required Chrome widget/state test. Resume through the existing owner only when a supported test route on pinned Flutter 3.44.6 can keep all listeners inside AUTOWORK_PORT_BASE..AUTOWORK_PORT_BASE+99; then execute the unchanged state/replay and complete offline gates on the integrated source and retain independent review. No such route was established by the bounded 2026-10-18 inspection; this remains a technical capability hold, not missing product approval.
  - Browser capability evidence: The pinned SDK's packages/flutter_tools/lib/src/commands/test.dart has no web-port option; src/test/runner.dart invokes FlutterWebPlatform.start without a serverFactory override, and src/test/flutter_web_platform.dart:159–182 defaults to HttpMultiServer.loopback(0). The serverFactory injection point is an internal API, not an already-supported repository test runner. The existing spec's pure-Dart math-browser recovery and the archived OS-assigned-loopback exception are explicitly NUM-WALL-01-only; neither authorizes NUM-WALL-02's widget/state gate or changes its range requirement. Do not patch the SDK, disable browser security, repeat an uncontrolled-port attempt, replace the widget test with the math harness or treat permission as an implemented missing capability. No browser test or full-suite pass is claimed by this planning answer.

- [ ] **NUM-WALL-03 — Colour, randomize and export the same completed wall.**
  - Goal: NUM-WALL-001
  - Status: open
  - Section: Next.
  - Payoff: attractive configurable artwork with reproducible settings and matching PNG output.
  - Sources: [Accepted outcome and decided design](docs/engineering/spec.md#number-walls-and-modular-windows), [owner scope](PRD.md#number-walls-catalog-category), `lib/features/viewer/export/viewer_export_session.dart`, `lib/features/renderer/models/fractal_render_snapshot.dart`, `lib/core/services/rendering/palette/palette_shader_adapter.dart`, `lib/core/services/export/export_service.dart`, `test/export/viewer_export_session_test.dart`.
  - Touches: lib/features/number_walls/, lib/features/renderer/, lib/features/viewer/export/, lib/core/services/export/, lib/core/services/rendering/palette/, lib/features/controls/, lib/l10n/, shaders/number_theory/number_wall_gpu.frag, test/number_walls/, test/export/
  - Scope: Add binary-zero and binned-residue palette modes, foreground/zero/background colours, optional grid, manual reproducible randomizer/undo and exact-grid offscreen PNG integration. Reuse existing palette/editor/export UI and save services; prime arithmetic never moves into shader floats. Randomizing modulus is explicit opt-in and uses verified quick-pick primes, not the typed custom prime by default. No autoplay or new continuous animation framework.
  - Acceptance: Zero mask survives all styling and large-prime residue binning; colour-only changes do not recompute determinants. Randomization creates valid materialized settings, can be undone/replayed and does not create composite moduli or silently replace a typed prime. Export freezes the complete committed grid/style/viewport; other output dimensions rerasterize identical cells, not a new sequence/prime/depth. Decoded PNGs match same-state viewer cells and chosen background/alpha rules; no unrelated escape-time fallback. Cancellation, navigation and stale jobs preserve ownership. Unsupported auxiliary animation/effect tools are disclosed/disabled only for this module; ordinary modules keep their behavior.
  - Checks: Planned: `flutter test test/number_walls/number_wall_style_export_test.dart test/number_walls/number_wall_randomizer_test.dart test/export/viewer_export_session_test.dart --reporter expanded`; `flutter test --platform chrome test/number_walls/number_wall_style_export_test.dart --reporter expanded`; `flutter analyze`; decode actual exported PNG artifacts and compare sampled cell centres/zero mask against the immutable grid. New targets and pixel checks are NOT_RUN.
  - Dependencies: NUM-WALL-02.
  - Ownership: Repository backlog, unassigned; no publication or schedule authority.
  - Next action: Pin colour-only/no-recompute and immutable export ownership tests, then implement presentation and PNG reuse.

- [ ] **NUM-WALL-04 — Qualify Number Walls on Linux and web with real artifacts.**
  - Goal: NUM-WALL-001
  - Status: open
  - Section: Next.
  - Payoff: verify useful defaults, exact parity and saved/exported artwork beyond widget fixtures.
  - Sources: [Accepted outcome and decided design](docs/engineering/spec.md#number-walls-and-modular-windows), [verification owner](docs/engineering/test-plan.md#number-wall-verification), `integration_test/flows/user_flows_test.dart`, `test/playwright/`.
  - Touches: integration_test/flows/number_wall_journey_test.dart, test/playwright/number-wall-journey.spec.mjs, docs/engineering/test-plan.md
  - Scope: Exercise catalog -> six sources -> custom prime -> style/randomize/undo -> save/reopen -> PNG with real Linux rendering and browser. Record default/worst-budget computation, cancellation responsiveness, bounded memory and actual screenshots. No new formulas, release or device acceptance.
  - Acceptance: Native/browser cell matrices agree for identical inputs, PNGs decode at requested dimensions with matching cells, gallery/card/inspector labels stay honest, defaults visibly show documented windows rather than placeholders. Capture EN/ES/narrow/high-contrast/text-scale states and classify clipping/visual defects. Large/unverified prime and worst zero-window jobs remain cancellable with no stale commit. Retain actual timings/environment, not promised unlimited zoom or fabricated performance scores. Widget-font/renderer substitutions are not live qualification. Include an actual replay/import case on native and browser proving an invalid or unfinished modulus cannot replace the committed grid, followed by a valid outside-quick-pick replay and matching PNG.
  - Checks: Planned new integration target: `flutter test integration_test/flows/number_wall_journey_test.dart -d linux --reporter expanded`; `flutter build web`; use the repository's Playwright runner on `test/playwright/number-wall-journey.spec.mjs` (record its exact command after adding the target); decode/read back PNG downloads and saved files. All are NOT_RUN. Add that replay/invalid-state case to the existing planned native/browser journeys rather than another harness.
  - Dependencies: NUM-WALL-03.
  - Ownership: Repository backlog, unassigned. Linux/browser qualification is distinct from Android installed-device checks.
  - Next action: Add the composed native/browser journeys and capture real same-state grid/export artifacts.

- [ ] **NUM-WALL-05 — Qualify installed Android Number Walls and accessible interaction.**
  - Goal: NUM-WALL-001
  - Status: open
  - Section: Next.
  - Payoff: prove actual device viewing, cancellation, accessible controls and gallery output.
  - Sources: [Accepted outcome and decided design](docs/engineering/spec.md#number-walls-and-modular-windows), [verification owner](docs/engineering/test-plan.md#number-wall-verification), `integration_test/flows/user_flows_test.dart`.
  - Touches: integration_test/flows/number_wall_journey_test.dart, docs/engineering/test-plan.md
  - Scope: Reuse the composed Number Walls journey on a named installed Android device; verify keyboard/TalkBack focus for prime Apply, sequence/style/randomizer and cell inspector, interruption/backgrounding and actual saved PNG/gallery visibility. No binary upload, rollout or store publication.
  - Acceptance: Device/certificate/build/backend identity and exact test results are retained. Custom prime entry and long decimal labels do not overflow; settings/export survive allowed lifecycle events without stale updates. Gallery PNG decodes with matching cells and dimensions. TalkBack navigation and enlarged text/high-contrast controls work. Missing hardware remains NOT_CHECKED and cannot close parent acceptance or block independent offline implementation.
  - Checks: Planned: `flutter test integration_test/flows/number_wall_journey_test.dart -d DEVICE_ID --reporter expanded` with the actual named device replacing DEVICE_ID; perform and record TalkBack and gallery/readback steps from the test plan. No attached-device or executed-pass claim is made during planning.
  - Dependencies: NUM-WALL-03.
  - Ownership: Repository backlog, unassigned; needs real device access at qualification time, not a new product decision.
  - Next action: Use an available named Android device after the integrated feature exists; retain exact unavailable access if held.

- [ ] **RELEASE-002-75 — Prepare and qualify every available platform without publication.**
  - Goal: REL-JOURNEY-001
  - Status: open
  - Section: Next.
  - Sources: [Accepted policy](PRD.md#independent-platform-release-policy), [implementation contract](docs/engineering/spec.md#independent-platform-release-orchestration), [lane map](docs/engineering/release/MULTIPLATFORM.md#independent-platform-release-campaign), [verification](docs/engineering/test-plan.md#independent-platform-release-verification).
  - Touches: release-artifacts/, docs/engineering/release/, docs/engineering/test-plan.md, scripts/release_platform_lanes.py, test/scripts/test_release_platform_lanes.py, test/playwright/smoke-session-conflict.spec.mjs, integration_test/flows/user_flows_test.dart
  - Scope: Repair the two evidenced web qualification blockers within the listed lane verifier and saved-data browser test: exclude archive directory entries from the manifest file inventory and establish valid saved-data browser evidence. Then run the implemented prepare-only mode on one immutable reviewed source/SDK/lock/version candidate. Attempt Android/Play, F-Droid, web, Linux, Windows, macOS and iOS on available authorized native hosts. Reuse existing REL-JOURNEY-* tasks/live follow-ups and actual evidence without changing their verdicts. No other lane redesign, publisher calls, tags, pushes, uploads, website deployment, paid capacity, GitLab execution or schedules.
  - Acceptance: Every lane records actual build/check/artifact proof or its exact error/unavailability with logs. Verify source/version/certificate/contents/hashes and mapped journey/signing/reproducibility requirements before marking ready. The Linux lane must include the accepted native image-creation journey (`flutter test integration_test/flows/user_flows_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded`) and report its full journey verdict separately from the retained-image human review; a successful Linux build or unrelated artifact check alone is not Linux journey qualification. Missing host/device/signing/access is skipped-unavailable, not a pass. Shared failures stop affected lanes. Retain unresolved live/human gates; unsigned Apple archives are not production-ready. All-skipped is explicit failure and admits no publication. Use existing stage timeouts and the documented configurable 15-minute unavailable-host queue deadline.
  - Checks: Run `python3 test/scripts/test_release_platform_lanes.py`; run `npx --no-install playwright test test/playwright/smoke-session-conflict.spec.mjs --project=chromium --workers=1 --output="$TMPDIR/release-web-playwright-output" --reporter=list` as the task-owned saved-data browser check. Run the accepted Linux native journey command above on the frozen candidate and preserve its terminal result; run `./release.sh --best-effort --prepare=1.1.108 --build-number=108` with publication disabled against the same frozen candidate identity. Record each stage exit and reconcile every requested/verified/skipped lane, archive file inventory, web asset/browser receipts, Linux journey receipt, artifact hashes/provenance and zero publication effects. Keep the combined `web-image-creation-journey.spec.mjs` result separate: attempt-2 passed the saved-session restoration and 2D/3D export journey but failed an unrelated Gaussian walk pause-control test outside this task’s Touches; do not widen scope to repair it. Use the exact SDK/lockfile and authorized hosts from the accepted lane map; unavailable live/platform gates remain explicit. Prior campaign/build receipts are bound to their recorded candidate and do not qualify a rerun. All rerun checks remain NOT_RUN.
  - Dependencies: RELEASE-001-23.
  - Ownership: Release coordinator; preserve active writers and use only already-authorized hosts/access. Missing private access is not presumed granted.
  - Next action: Do not repeat the timed-out attempt-2 blindly or return to the older 33eae0c candidate. Inspect and retain the newer clean f6a6d9d038af4af5872d973405f1fb07ce0aa64f in .worktrees/autowork-RELEASE-002-75, with attempt-1/report.json and release-artifacts/campaign.json; no task writer was observed during this pass. Its owned fixes are not yet identical in main. The retained campaign binds Flutter 3.44.6, lock hash 22b29dbd8f71276012a54b9bdc62ba88408f967a86b34075986c17e1c4506ec3 and version/build 1.1.108/108 to that exact commit. This pass independently matched its web artifact (4555226a12e59538e3261e995bdc835737fe69f4c5aa18d8ff2679a20e974aeb) and Linux artifact (921e29e089203cfc3fa16fbff7c5580d3e9cab9b6f3f9c86d5de2d4e26e281ac) to recorded sizes/digests; retained host-test/analyzer stage records report terminal exit 0. This is historical candidate evidence, not current-source qualification. The campaign still references a failed synthetic shared-gate.json (sandbox-common-gate-failure): preserve that history separately and regenerate producer-owned evidence from real stage results, never relabel it passing or blend it into a current receipt. Reconcile the candidate through supported review/integration after the active ACAD-008-74 common-gate repair, validating the integrated source and rerunning only changed/missing stages with complete logs and consistent identities. Retain genuine unavailable lanes and Linux human-image review; the APK sent in chat has a different source and does not qualify this campaign. No publisher calls, tags, pushes, uploads, GitLab run or deployment; RELEASE-003-ae remains separately gated.

- [ ] **APP-001-47 — Qualify the official local MCP inspection workflow.**
  - Goal: APP-QUALITY-001
  - Status: open
  - Section: Next.
  - Sources: [Accepted bounded plan](docs/engineering/spec.md#mcp-assisted-app-quality), [owner outcome](PRD.md#mcp-assisted-architecture-and-ui-improvement), [verification](docs/engineering/test-plan.md#mcp-assisted-app-quality-verification), [MCP workflow](docs/engineering/runbook.md#official-dart-flutter-mcp-workflow).
  - Touches: docs/engineering/runbook.md, docs/engineering/test-plan.md
  - Scope: Use the pinned SDK-bundled MCP with an existing native client or the already installed Python MCP SDK, following the runbook. Register only the task checkout root, inspect relevant symbols and analyze scoped paths without automatic fixes. Record a capability baseline for Home/catalog/viewer/settings/export and exact runtime availability. No persistent host/profile configuration, installs, new bridge, application dependency or SDK mutation.
  - Acceptance: Real initialize/list_tools/roots plus scoped symbol/analysis calls succeed and clean up in a bounded session. Record actual tools, SDK/server/client and checkout. Diagnostics remain truthful even if pre-existing failures are found. Record runtime attachment/screenshots only on an explicitly owned authorized target; otherwise mark them NOT_RUN and carry the target/port limitation to final qualification, not as a new owner approval for known code fixes. Existing native client is preferred; ephemeral SDK-client fallback is a supported temporary inspection route, not a production integration. Before APP-002-e0 changes code, record an immutable baseline revision/owned inputs and representative UI state/viewport/locale manifest in the existing test-plan owner. Capture real baseline pixels when an owned target is available; otherwise retain a replayable baseline and mark images NOT_RUN.
  - Checks: Use the runbook server command with the pinned Dart executable; inspect `dart mcp-server --help`; perform real MCP initialize/list_tools, `roots` add with the checkout file URI, then `lsp` and `analyze_files` using their discovered schemas. Record returned results, timeout and closed session. `git diff --check`. All workspace/runtime calls remain planned; the earlier initialize/list_tools-only planning probe is not this task completion.
  - Dependencies: None.
  - Ownership: Repository backlog, unassigned; preserve current writers and source-bound evidence. Planning does not dispatch.
  - Next action: Retain the clean candidate a153169078fc91ff7c4d5b17980a67c7b5a35caa in .worktrees/autowork-APP-001-47-r2; no task writer was observed during this blocker pass. Its report records successful initialize/list_tools, checkout-only roots add/remove, five symbol lookups, scoped analysis and bounded cleanup, plus passing analyzer, Python and Bats checks. The rejected report contains a real failed common Flutter gate (pre-test native-assets crash), not missing MCP client authority. Do not repeat client discovery, install a client, create a bridge or weaken acceptance. ACAD-008-74 already owns the active common-gate recovery: preserve that worker and use verified candidate-local setup with the pinned SDK/unchanged lockfile. Through the supported review/integration path, reconcile this retained document slice and rerun the missing/affected common validation on the integrated inputs, retaining the old failed report and creating fresh truthful candidate-bound evidence rather than editing a failure into a pass. Refresh only source-baseline bindings affected by intervening code; keep the replayable UI manifest, runtime attachment and real screenshots separate and pending. No dispatch, runner/SDK reconfiguration or publication by this planning pass.

- [ ] **APP-002-e0 — Give viewer navigation one owner and honor reduced motion.**
  - Goal: APP-QUALITY-001
  - Status: open
  - Section: Next.
  - Sources: [Accepted bounded plan](docs/engineering/spec.md#mcp-assisted-app-quality), [owner outcome](PRD.md#mcp-assisted-architecture-and-ui-improvement), [verification](docs/engineering/test-plan.md#mcp-assisted-app-quality-verification), [MCP workflow](docs/engineering/runbook.md#official-dart-flutter-mcp-workflow).
  - Touches: lib/features/home/home_screen.dart, lib/features/catalog/fractal_catalog_screen.dart, lib/l10n/, test/screens/home_screen_widget_test.dart, test/fractal/fractal_catalog_screen_widget_test.dart, test/fractal/fractal_viewer_screen_widget_test.dart, test/services/deep_link_service_test.dart, test/a11y/screens/home_screen_a11y_test.dart
  - Scope: Implement the accepted Home-owned viewer route and embedded-catalog opening callback, preserving standalone catalog behavior and launch options. Reuse the active unobstructed viewer for repeated links. Apply the existing accessibility duration helper on forward/reverse Home/catalog transitions. Add only localized busy feedback for a link arriving behind a blocking route; do not alter the shared controller or dismiss that route.
  - Acceptance: Focused RED/GREEN composed regressions deliver repeated platform links after Home and embedded-catalog entry: one viewer route, latest valid state, one Back to preserved catalog/filter/scroll, correct catalog family, no duplicate active-session listeners and existing explicit-link precedence. Busy modal/settings/export leaves controller/in-flight work untouched; retry after dismissal works. Route completion clears ownership safely and navigation works again after reopening. Both OS and in-app reduced motion remove push/pop motion independently; normal transitions and standalone catalog still work. Preserve IDs, saved-state schema, presets and exports.
  - Checks: `flutter test test/screens/home_screen_widget_test.dart test/fractal/fractal_catalog_screen_widget_test.dart test/fractal/fractal_viewer_screen_widget_test.dart test/services/deep_link_service_test.dart test/a11y/screens/home_screen_a11y_test.dart --reporter expanded`; `flutter gen-l10n`; `dart format --output=none --set-exit-if-changed lib/features/home/home_screen.dart lib/features/catalog/fractal_catalog_screen.dart test/screens/home_screen_widget_test.dart test/fractal/fractal_catalog_screen_widget_test.dart test/fractal/fractal_viewer_screen_widget_test.dart`; `flutter analyze`; `git diff --check`. Tests/extensions and application checks are planned, not executed by the planner.
  - Dependencies: APP-001-47.
  - Ownership: Repository backlog, unassigned; preserve current writers and source-bound evidence. Planning does not dispatch.
  - Next action: Reproduce repeated Home and embedded-catalog link routing in the existing harness; keep Home as controller/route owner and add only the narrow callback/route handle needed to remove duplicate ownership.

- [ ] **APP-003-f7 — Suspend auto-explore safely when the app is hidden.**
  - Goal: APP-QUALITY-001
  - Status: open
  - Section: Next.
  - Sources: [Accepted bounded plan](docs/engineering/spec.md#mcp-assisted-app-quality), [owner outcome](PRD.md#mcp-assisted-architecture-and-ui-improvement), [verification](docs/engineering/test-plan.md#mcp-assisted-app-quality-verification), [MCP workflow](docs/engineering/runbook.md#official-dart-flutter-mcp-workflow).
  - Touches: lib/features/auto_explore/auto_explore_service.dart, lib/features/viewer/fractal_viewer_screen.dart, lib/features/viewer/export/, test/features/auto_explore/auto_explore_service_test.dart, test/fractal/fractal_viewer_screen_widget_test.dart, test/export/viewer_export_session_test.dart
  - Scope: Compose app-visibility suspension with existing auto-explore cancellation and export pause ownership. Planner call: foreground return remains paused until explicit visible user Resume. Guard export completion and other resume paths against hidden/disposed state without a general lifecycle framework. Preserve view, configured mode/speed and manual pause/correction behavior.
  - Acceptance: Controlled-clock service and real viewer tests show no zoom/view writes or controller notifications while hidden, no automatic resume merely on foreground, explicit visible Resume works, and an export finishing hidden cannot resurrect motion or future resume intent. Manually paused/corrected behavior and export snapshots remain correct; disposal leaves no pending timer. Do not change formulas, unrelated map jobs or saved-state schema.
  - Checks: `flutter test test/features/auto_explore/auto_explore_service_test.dart test/fractal/fractal_viewer_screen_widget_test.dart test/export/viewer_export_session_test.dart --reporter expanded`; `dart format --output=none --set-exit-if-changed lib/features/auto_explore/auto_explore_service.dart lib/features/viewer/fractal_viewer_screen.dart lib/features/viewer/export/ test/features/auto_explore/auto_explore_service_test.dart test/fractal/fractal_viewer_screen_widget_test.dart test/export/viewer_export_session_test.dart`; `flutter analyze`; `git diff --check`. New negative/positive fixtures remain planned.
  - Dependencies: APP-002-e0.
  - Ownership: Repository backlog, unassigned; preserve current writers and source-bound evidence. Planning does not dispatch.
  - Next action: First reproduce hidden timer writes and hidden export completion in the viewer harness; repair visibility/resume guards in the existing ownership path, not only the timer producer.

- [ ] **APP-004-cc — Localize settings and export controls with selected semantics.**
  - Goal: APP-QUALITY-001
  - Status: open
  - Section: Next.
  - Sources: [Accepted bounded plan](docs/engineering/spec.md#mcp-assisted-app-quality), [owner outcome](PRD.md#mcp-assisted-architecture-and-ui-improvement), [verification](docs/engineering/test-plan.md#mcp-assisted-app-quality-verification), [MCP workflow](docs/engineering/runbook.md#official-dart-flutter-mcp-workflow).
  - Touches: lib/features/settings/settings_screen.dart, lib/features/export/export_options_sheet.dart, lib/l10n/, test/screens/settings_screen_a11y_test.dart, test/export/export_options_sheet_widget_test.dart, test/features/export/custom_export_dimensions_test.dart
  - Scope: Use existing EN/ES localization at UI boundaries for theme names/descriptions and actual export resolution labels. Give each theme option a single accessible activation/focus node and selected state. Preserve enum/persistence values, custom export dimensions/validation, existing typography/theme/chip/sheet patterns and export data. No theme redesign or unused video UI work.
  - Acceptance: Spanish theme sheet contains localized titles/descriptions and one selected action node per option; EN copy remains coherent. Keyboard activation changes the theme once and reopening preserves selection. Both actual export-sheet locales show localized resolution choices with unchanged selected resolution/dimensions, submission and invalid-custom-size rejection. Existing narrow/large-text/high-contrast guards pass; no duplicate semantic action stops or storage-key changes.
  - Checks: `flutter gen-l10n`; `flutter test test/screens/settings_screen_a11y_test.dart test/export/export_options_sheet_widget_test.dart test/features/export/custom_export_dimensions_test.dart test/export/viewer_export_session_test.dart --reporter expanded`; `dart format --output=none --set-exit-if-changed lib/features/settings/settings_screen.dart lib/features/export/export_options_sheet.dart test/screens/settings_screen_a11y_test.dart test/export/export_options_sheet_widget_test.dart test/features/export/custom_export_dimensions_test.dart`; `flutter analyze`; `git diff --check`. Locale/semantics fixture extensions are planned.
  - Dependencies: APP-002-e0.
  - Ownership: Repository backlog, unassigned; preserve current writers and source-bound evidence. Planning does not dispatch.
  - Next action: Extend the existing Spanish settings test to open the theme sheet and parameterize the existing export-sheet harness locale; localize only actual UI labels and add selected semantics without changing serialized enums.

- [ ] **APP-005-7f — Verify the composed architecture and UI improvement batch.**
  - Goal: APP-QUALITY-001
  - Status: open
  - Section: Next.
  - Sources: [Accepted bounded plan](docs/engineering/spec.md#mcp-assisted-app-quality), [owner outcome](PRD.md#mcp-assisted-architecture-and-ui-improvement), [verification](docs/engineering/test-plan.md#mcp-assisted-app-quality-verification), [MCP workflow](docs/engineering/runbook.md#official-dart-flutter-mcp-workflow).
  - Touches: docs/engineering/test-plan.md, docs/engineering/runbook.md, test/screens/, test/a11y/, test/fractal/, test/export/, integration_test/flows/, test/playwright/web-image-creation-journey.spec.mjs
  - Scope: Close the bounded first batch with existing whole-app regression and real runtime/UI evidence for Home/catalog/viewer/settings/export. Add only missing composed fixtures, not an equivalent new testing framework or speculative app features. Use explicit source/tool/backend/viewport/locale bindings and existing available-host journeys. Record broader findings as proposed follow-ups in the existing queue without expanding this batch.
  - Acceptance: All changed-path regressions and full offline guards pass on integrated code. Distinct EN/ES, small/desktop, large-text/high-contrast/reduced-motion states preserve reachability, focus, catalog/session state and export dimensions; real matched screenshots support any visual claim. On an owned compatible available debug target, MCP runtime/widget inspection and actual navigation are exercised. Existing Linux/browser edited 2D/3D PNG journeys pass where available, with matching source/artifacts. Missing target/port setup or mandatory runtime checks remain explicit pending qualification, never a pass; do not close this task without its required available-target runtime evidence. Existing physical Android/human/platform gates are not waived or certified by this task. Paired comparisons must use APP-001-47’s pinned pre-change baseline and matching state/backend. If initial pixels were unavailable, replay that baseline on an authorized target; do not compare different states or synthesize before-images.
  - Checks: `flutter analyze`; `flutter test`; `flutter test integration_test/flows/user_flows_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded`; `npx --no-install playwright test test/playwright/web-image-creation-journey.spec.mjs --project=chromium --workers=1`; MCP `get_runtime_errors` and `widget_inspector` on the explicit owned target using discovered schemas; inspect matched actual screenshots/semantics at the fixtures in the test plan; `git diff --check`. All composed runtime/application checks remain NOT_RUN.
  - Dependencies: APP-003-f7, APP-004-cc.
  - Ownership: Repository backlog, unassigned; preserve current writers and source-bound evidence. Planning does not dispatch.
  - Next action: Verify integrated behavior and source-bound baseline/candidate images through the existing journeys and MCP inspection. Keep unavailable live checks pending; report the bounded batch result, not whole-app perfection or release readiness.

- [ ] **SINEWARP-001-aa — Implement the bounded recursive sine-warped sphere.**
  - Goal: SINE-WARP-001
  - Status: open
  - Section: Next.
  - Sources: [Accepted implementation](docs/engineering/spec.md#recursive-sine-warped-sphere), [source study and finite design](research/recursive-sine-sphere.md), [owner outcome](PRD.md#recursive-sine-warped-sphere), [verification](docs/engineering/test-plan.md#recursive-sine-warped-sphere-verification). [Intersection oracle](docs/engineering/spec.md#sine-sphere-intersection-oracle).
  - Touches: lib/core/models/recursive_sine_sphere_model.dart, lib/core/modules/, lib/l10n/, shaders/3d_and_hypercomplex/raymarched_volumes/recursive_sine_sphere_gpu.frag, pubspec.yaml, docs/catalog/, test/modules/, test/catalog/, shaders/3d_and_hypercomplex/raymarched_volumes/recursive_sine_sphere_kernel.glsl, test/shaders/, README.md, docs/planning/visual-audit-inventory.json, docs/play-store-localized-listings.json, research/academic/coverage.json, test/features/catalog/three_d_catalog_identity_test.dart, test/fixtures/animation_capability_inventory.json, test/screens/settings_screen_a11y_test.dart, web/landing.html
  - Scope: Implement the exact finite cyclic map and independent scalar reference, dedicated module/shader, existing camera prefix, bounded controls, source/math metadata, EN/ES labels and one stable catalog identity per the accepted study. No arbitrary implicit shapes, framework, dependencies or changes to existing formulas/IDs. The explicitly listed derivative catalog counts, labels and admission inventories may change only to keep this one new identity consistent; no store/website publication or other content redesign.
  - Acceptance: Independent fixtures reproduce simultaneous cyclic updates and scaled composition; depth 0 or strength 0 is the correct sphere, nonzero phase is deterministic, nonfinite/out-of-range inputs are handled visibly under existing validation, and field/normal/ray loops remain finite and bounded. Derive the Lipschitz/enclosure bounds and use conservative stepping plus residual/bracket-based convergence, not a fictitious SDF. Register recursive_sine_sphere and its shader with correct declared uniforms, persisted params, optional animation/frozen export time and metadata admission. No misleading power/bailout control, fake CPU fallback, hidden depth substitution or other ID changes. Actual shader compilation and focused tests pass; real capture qualification remains the dependent task. Independent analytic sphere hit/miss and selected independently bracketed warped-ray fixtures verify nearest intersection and residual, not only scalar fields. Classify tangent/unresolved cases and declare precision/tolerances. Any test-only hit/depth output must execute the same production intersection kernel, not a second marcher or public debug control.
  - Checks: Implement planned `test/modules/recursive_sine_sphere_test.dart`, then run `flutter test test/modules/recursive_sine_sphere_test.dart test/modules/raymarched_3d_pan_target_test.dart test/catalog/catalog_id_integrity_test.dart --reporter expanded`; `flutter gen-l10n`; `flutter analyze`; `flutter build linux --debug` for actual shader compilation; `dart format --output=none --set-exit-if-changed lib/core/models/recursive_sine_sphere_model.dart lib/core/modules/fractals/recursive_sine_sphere_module.dart test/modules/recursive_sine_sphere_test.dart`; `git diff --check`. Use pinned isolated SDK/tooling; all application/shader commands remain NOT_RUN. Add these ray fixtures to the planned recursive_sine_sphere_test.dart and support the small production-kernel diagnostic fixture only if needed for actual renderer comparison; compile any such shader with the original asset/runtime contract.
  - Dependencies: None.
  - Ownership: Repository backlog, unassigned; inspect writers before execution. Study/planning does not dispatch or publish.
  - Next action: Retain the clean implementation 6cb7b894f623c5dc59fb0d78e57b181a0aa1e33a in .worktrees/autowork-SINEWARP-001-aa-r2, not a fresh rewrite. Its report records 56 focused tests, shader compilation, Linux build and analyzer passes, but the full Flutter suite timed out after 1800 seconds: that failure remains real. The read-only review found unfinished acceptance: the shader fixture only loads/sets uniforms, CPU intersection fixtures cannot certify GLSL hits, and two hardcoded warped distances lack retained independent bracketing/nearest-crossing provenance. Complete independent sphere silhouette-hit/tangent/interior status/residual and warped-nearest brackets with declared precision; distinguish miss, budget exhaustion and unresolved/tangent cases in test evidence. Prove visible production validation for nonfinite/out-of-range ingress rather than only model rejection or silent module clamping. Reuse the existing field/intersection code in the already permitted shared .glsl kernel and narrow diagnostic fixture so production and test output cannot diverge; no second marcher or public debug control. Actual named-backend draw/readback and capture/export qualification remains SINEWARP-002-47. Reconcile only the listed coupled metadata/count consumers, preserve formulas/IDs and inspect actual changed files before integration. Coordinate common-gate prerequisites with the active ACAD-008-74 worker without rewriting its contract; diagnose the first incomplete full-suite stage with bounded focused checks, then complete the original common gate and supported review/integration with truthful new evidence. Do not turn compilation/CPU agreement, a timeout or the old report into a GPU/full-suite pass. No owner rescoping, new dependency, dispatch, runner mutation or publication is required.

- [ ] **SINEWARP-002-47 — Qualify sine-sphere defaults, saved views and real PNG export.**
  - Goal: SINE-WARP-001
  - Status: open
  - Section: Next.
  - Sources: [Accepted implementation](docs/engineering/spec.md#recursive-sine-warped-sphere), [source study and finite design](research/recursive-sine-sphere.md), [owner outcome](PRD.md#recursive-sine-warped-sphere), [verification](docs/engineering/test-plan.md#recursive-sine-warped-sphere-verification).
  - Touches: integration_test/rendering/recursive_sine_sphere_test.dart, test/modules/recursive_sine_sphere_test.dart, lib/core/modules/fractals/recursive_sine_sphere_module.dart, docs/engineering/test-plan.md, docs/planning/, shaders/3d_and_hypercomplex/raymarched_volumes/recursive_sine_sphere_kernel.glsl, test/shaders/
  - Scope: Add the scoped actual renderer journey for the implemented identity. Qualify baseline/default/higher-detail settings, camera pan/rotation, controls, saved restoration and same-state PNG/transparency on available supported targets. Tune default framing/presets within the decided math and bounds from actual captures; do not redesign the surface, replace source math, silently reduce detail or use the source video as app artwork.
  - Acceptance: Named-backend real captures show the ordinary sphere control, nonblank framed warped default and visibly finer detail without unexplained holes/non-convergent pixels. Report default/max timings and convergence limitations rather than inventing FPS thresholds. Changing/restoring phase, depth, strength, radius, camera and palette yields the same requested geometry and corresponding decoded PNG; animation-off/reduced-motion freezes time and export matches its frozen state. Existing catalog, saved-state and export guards pass. Record Linux/browser/device outcomes independently; unavailable physical/human checks remain pending, never certified by numerical tests or screenshots alone. Compare selected actual production-renderer hit/silhouette/depth samples with the independent sphere/warped-ray oracle at declared precision/tolerances. Viewer/export agreement alone cannot satisfy this requirement.
  - Checks: Implement planned `integration_test/rendering/recursive_sine_sphere_test.dart`, then run `flutter test integration_test/rendering/recursive_sine_sphere_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded`; `flutter test test/modules/recursive_sine_sphere_test.dart test/modules/raymarched_3d_pan_target_test.dart test/catalog/catalog_id_integrity_test.dart --reporter expanded`; `flutter analyze`; inspect actual baseline/default/detail PNG dimensions, hashes, transparency/content and source/backend/state binding; `git diff --check`. Reuse existing browser/edited-PNG journey tooling for this identity when supported, retaining exact skips. All these app/GPU/export checks are planned. Exercise the independent ray oracle and actual production hit/depth samples in the existing planned integration target; report non-convergence separately, never as a certified hit.
  - Dependencies: SINEWARP-001-aa.
  - Ownership: Repository backlog, unassigned; inspect writers before execution. Study/planning does not dispatch or publish.
  - Next action: After SINEWARP-001-aa is complete, use its same-production-kernel diagnostic and independently derived ray brackets to implement the already planned integration target. Draw/read actual production hit/silhouette/depth values on a named authorized backend and compare them at declared camera, coordinate basis and precision/tolerances; report miss, tangent/stagnation and budget exhaustion separately. The retained candidate shader test only compiles/sets uniforms and does not supply this evidence. Then capture sphere-control/default/detail states, saved/restored/animated-frozen states and corresponding decoded PNGs; correct only demonstrated framing/preset defects. Preserve independent Linux/browser/device verdicts and pending physical/human review; no invented pixels or second test marcher.

- [ ] **ACAD-007-f8 — Prepare a verified academic pilot approval brief.**
  - Goal: ACAD-001
  - Status: open
  - Section: Next.
  - Sources: [Accepted gap-closure contract](docs/engineering/spec.md#decision-ready-academic-review-package), [verification](docs/engineering/test-plan.md#plan-gap-completion-checks).
  - Touches: research/academic/reviews/, scripts/research/academic/, test/research/test_academic_review_package.py, research/academic/README.md
  - Scope: Produce the bounded metadata-only source/rights shortlist already requested by the owner, using the existing pilot and any reviewed identity aliases. Where reviewed aliases are absent, propose evidence-backed current-identity mappings explicitly marked unreviewed, with original labels and ambiguity retained; do not populate the reviewed-alias file. At most 12 actual pilot identities and 12 proposed papers; preserve raw run identity/queues. Verify bibliographic facts from existing material and public metadata/landing pages, not article content acquisition. No new broad search campaign, full text/PDF/OCR, provider install, screening self-approval or accepted mathematical claims.
  - Acceptance: A concise review brief and machine-readable companion under research/academic/reviews/ bind proposed paper IDs to retained pilot records and identities to existing reviewed aliases or clearly separate proposed/unreviewed mappings. Raw labels, proposed canonical IDs, mapping evidence and unresolved ambiguity are preserved. The empty reviewed-alias source is a supported input case, never an invented approval. Authors, stable identifiers, year, exact version/source links, equation relevance and rights evidence are verified or explicitly missing. Present a genuinely bibliographically verified subset for owner identity/inclusion/acquisition decisions; a pending identity mapping does not make a paper approved or acquisition-ready. Missing family coverage stays a gap; planned Number Walls is not counted implemented. All actual identity-approval/actor/claim fields remain pending, distinct from recommendations. Programmatic uniqueness/membership/count checks and original-input hashes pass. ACAD-03 remains human-gated after this task. Equation relevance is a proposed/unreviewed screening rationale from existing notes or metadata, not a source-checked mathematical claim or permission to read new full text.
  - Checks: Implement the planned focused package fixture/validator extension, then run `pytest test/research/test_academic_review_package.py test/research/test_academic_library.py test/research/test_academic_bindings.py -v`; cover empty reviewed aliases, existing reviewed mappings, proposed mappings, ambiguous/unresolved identities and rejected false approval flags. Reconcile exact shortlisted paper and identity sets with retained results and explicit mapping status; verify original pilot/raw queue and reviewed-alias bytes unchanged and actual decisions remain blank/pending; `git diff --check`. Provider/source metadata observations must carry actual URLs/retrieval/version evidence. These checks and the package remain NOT_RUN.
  - Dependencies: ACAD-02.
  - Ownership: Repository backlog, unassigned; preserve live writers and existing gates. Planning does not dispatch.
  - Next action: Retain the clean approval-brief/validator candidate 139d64cf2f2277c53314e4ed59eb91f4e0f69540 in .worktrees/autowork-ACAD-007-f8-r2; no task writer was observed during this blocker pass. The report records 19 focused tests, a valid six-paper/12-identity package and byte-preserved pilot/alias inputs; verify its source-bound logs and original-input hashes before reusing that proof. Reuse the existing brief, not a new search or invented identity approval. Its failed common checks are the pre-test Flutter native-assets crash and missing MarkupSafe in the default Python environment. ACAD-008-74 owns the active shared-gate recovery; preserve it. The already provisioned .git/autowork-execution/cache/markupsafe-3.0.3 and cache/python-markupsafe both successfully imported MarkupSafe/Jinja2 during this pass: use an existing compatible cache via process-local PYTHONPATH, not a provider/package install or dependency-constraint change. Rerun missing/affected common checks against the reconciled candidate and retain old failures; use the supported review/integration path with a fresh truthful report. Actual mapping, inclusion, acquisition and claim approvals remain pending under ACAD-03; no full-text acquisition, approved-alias edits, screening self-approval or publication.
  - Owner decision: 2026-10-18 — Prepare proposed mappings; keep approvals pending. Existing reviewed aliases may be reused, but missing aliases do not block metadata preparation. No identity, inclusion, acquisition or mathematical-claim approval is supplied by this decision.

- [ ] **EXPORT-001-f3 — Commit native exports without partial completed files.**
  - Goal: REL-JOURNEY-001
  - Status: open
  - Section: Next.
  - Sources: [Accepted gap-closure contract](docs/engineering/spec.md#native-export-commit-boundary), [verification](docs/engineering/test-plan.md#plan-gap-completion-checks).
  - Touches: lib/core/services/export/export_service.dart, lib/core/services/export/batch_export_service.dart, test/export/export_service_test.dart, test/export/batch_export_service_test.dart, docs/engineering/test-plan.md
  - Scope: Use one small same-directory staging/commit primitive in the existing export services for native single images, batch items and contact sheets. Preserve validated names/directories, existing APIs/metadata/encoded bytes/size policy and separate MediaStore behavior. Add a minimal injected write/commit seam for deterministic tests rather than real full-disk tests. No general persistence framework, preference-save changes, resumable exports, startup cleanup sweep, web download changes or live service operations.
  - Acceptance: For native single-image, batch-item and contact-sheet outputs, a partial stage write, commit/replace failure, cancellation before commit or destination collision leaves no partial completed filename, preserves any prior destination byte-for-byte, and cleans only this attempt’s stage. Commit only by a same-directory operation whose replacement semantics are supported and safe; never delete the destination first, and fail closed without changing it when safe replacement is unavailable. The successful commit is the cancellation boundary: complete committed outputs may remain and are reported truthfully, never premature item-success. Deterministic tests exercise each failure mode separately in all three output paths, plus successful retry and recreated-service behavior; abandoned stages are never treated as completed exports and unrelated files are never deleted. Successful retry yields expected decodable bytes; existing cancellation/metadata/filename guards pass. A mirror/gallery failure does not erase or falsely qualify an already committed local file.
  - Checks: `flutter test test/export/export_service_test.dart test/export/batch_export_service_test.dart --reporter expanded`; in both suites, verify partial-write/commit-failure/pre-commit-cancel/collision/old-destination-preservation/retry/recreated-service cases independently for single-image, batch-item and contact-sheet outputs; `dart format --output=none --set-exit-if-changed lib/core/services/export/export_service.dart lib/core/services/export/batch_export_service.dart test/export/export_service_test.dart test/export/batch_export_service_test.dart`; `flutter analyze`; `git diff --check`. Real filesystem/provider/device qualification remains separate; tests and platform qualification are not claimed passed by this task text.
  - Dependencies: None.
  - Ownership: Repository backlog, unassigned; preserve live writers and existing gates. Planning does not dispatch.
  - Next action: First reproduce failed-write/final-path behavior with deterministic service-level fault seams, then route the three existing native image paths through same-directory staging and a commit boundary. Do not alter the currently running release worker’s contract or preference storage.

## Needs decision

- [ ] **ICON-ZJ-02 — Replace app and store icon assets with the approved app capture.**
  - Goal: VIS-003
  - Sources: [Accepted outcome and planner decisions](docs/engineering/spec.md#app-derived-zig-zag-julia-icon), `pubspec.yaml`, `assets/fractal-forge-icon-source.json`, `docs/store_listing/assets.json`, `scripts/play_store_listing.py`, `lib/features/home/home_screen.dart`.
  - Status: open
  - Scope: After existing owner sign-off, install the staged source/derivatives at existing asset paths; retain raw capture/state under `assets/icon/zig_zag_julia/`; update the existing provenance manifest, alternate raster alias and configured generated launcher/favicon resources. Narrowly support fully opaque RGBA icons in the listing validator with regressions; keep other image groups RGB. Update affected store docs/test-plan/changelog to actual implementation. Latest direct owner authority additionally permits icon-only Play API publication after approving B. No listing text/video, screenshots, feature graphic, release track, binary upload, version bump, package rename, new platform support or dependency changes.
  - Acceptance: Approved composition and source hashes match every delivered derivative; master/foreground 1024px, Play 512px opaque sRGB 32-bit PNG at most 1024 KB, in-app mark 64px. Existing configured platform icon resources and Android adaptive XML/padding/background are coherent; no active raster alias retains old artwork. Icon-only opaque-RGBA validation passes and transparent/wrong-size/oversize icons fail; existing RGB campaign fixtures and strict RGB non-icon validation remain valid. HomeScreen logo renders without asset errors. Generated files and Android proof/device review match the approved candidate, without claiming publication.
  - Checks: Planned, unrun: `dart run flutter_launcher_icons`; `python3 -m unittest test/scripts/test_app_icon_assets.py test/scripts/test_play_store_listing.py`; `scripts/update-play-store-listings.sh --validate-only`; `flutter test test/screens/home_screen_widget_test.dart`; `flutter analyze`; `git diff --check`. Add the new asset/provenance regression fixture as part of this work. Inspect generated Android masks/resources and verify an installed launcher on a real device; record unavailable platform builds separately, never as passed. Do not run listing `--dry-run` (it stages remote edits), `--audit` or `--commit` as local validation.
  - Dependencies: ICON-ZJ-01, VIS-003.
  - Ownership: Artwork/listing application is recorded above; waiting on VIS-003’s deferred installed-device qualification. No active implementation ownership is claimed by this questionnaire.
  - Owner authorization: “Good . Change the new app icon in app and playstore” explicitly authorizes B asset application and icon-only listing publication now. This is not a device-qualification or broader release waiver. VIS-003 retains its unexecuted installed-device check.
  - Progress: Approved B assets and configured Android/iOS/web/Windows/macOS icons are regenerated and applied in the canonical working checkout. Sixteen asset tests, 11 home widget tests, full Flutter analysis and 25 listing/publisher regressions pass on the isolated coherent candidate; canonical installed-asset and home smoke checks also pass. The icon-only Play edit was committed across all 15 live locales. Fresh-edit readback matches B SHA256 `c22c4fde194800588d21ad3ef2047749bb6335ce4b3fff605c00b1a054396c41` in every locale and proves complete live text/video dictionaries plus all inspected non-icon image metadata/order unchanged. No binary, release track or remote Git update was performed. This is delivered asset/listing work, not installed-device qualification; original device acceptance and task completion remain open.
  - Next action: Verify the installed B launcher on an Android test device when available and record the remaining VIS-003 verdict; no device is attached. Existing installed apps receive the launcher change with a future binary update, which this icon-only instruction did not publish. Do not re-upload the already verified listing icon merely to refresh evidence.
  - Payoff: retain the approved app-derived identity across the existing installed/listing assets.
  - Section: Needs decision.
  - Owner decision: 2026-10-18 reconciliation of the existing deferral — defer this successor with VIS-003 until an authorized Android test device is available; retain B approval and do not repeat the Play upload. No acceptance or binary-release waiver.

- [ ] **ACAD-04 — Backfill academic evidence across every scoped catalog identity in bounded batches.**
  - Goal: ACAD-001
  - Status: open
  - Section: Needs decision.
  - Sources: [Accepted academic research outcome](PRD.md#academic-research-library), [accepted integration contract](docs/engineering/spec.md#academic-source-to-renderer-evidence), [library rollout/coverage contract](research/academic/README.md), [verification owner](docs/engineering/test-plan.md#academic-evidence-verification), `docs/planning/visual-audit-inventory.json`, `research/fractals-library/data/fractal_manifest.json`.
  - Touches: research/academic/, TODO.md, goals.json
  - Scope: After the pilot establishes the contract, progress family by family over the generated identity inventory, at most 25 unresolved identities per execution batch. Reuse reviewed family evidence only with effective-formula/parameter relationship checks. Preserve original namespaces and distinguish published identities, parameter variants, reference-only definitions and planned entries. Continue the same task/evidence ledger without inventing one task per paper or resetting consumed run budgets.
  - Acceptance: Every scoped current ID is assessed or explicitly remains in the counted unresolved set; union totals reconcile exactly with no silent denominator shrink. Actual source availability, human approvals, formula comparison, numerical and visual evidence are separate. Batches retain reproducible manifests and exact continuation; source gaps/conflicts produce bounded correction/access items, not fabricated citations. Full task/goal completion requires all promised assessments, not merely creating coverage rows; a no-source result never becomes mathematically verified. Newly added modules enter the same inventory without rewriting historic snapshots.
  - Checks: Run the versioned ACAD-01 coverage validator against pinned source manifests and current catalog export; programmatically compare selected/processed/remaining IDs and evidence multiplicity for every batch; repeat import must be byte-stable. Run existing `forge doctor --strict-app-catalog`, manifest and visual inventory validators after attributable metadata changes. Live full-text/review checks require their actual decisions; all backfill is NOT_RUN.
  - Dependencies: ACAD-03.
  - Ownership: Repository backlog, unassigned; preserve per-subset human review/access gates and existing quality task ownership. No timer, publication or blanket all-papers download.
  - Next action: Wait for ACAD-03’s approved pilot and actual per-subset human decisions; preparation proceeds independently under ACAD-007-f8. Do not begin broad acquisition/backfill or treat a prepared metadata shortlist as approval.
  - Owner decision: 2026-10-18 reconciliation of the existing deferral — defer this successor with ACAD-03 until its pilot and human source/acquisition/claim gates are satisfied. Acceptance remains unchanged; this is not completion or approval.


- [ ] **CAT-QUALITY-03 — Decide curated discovery with the complete catalog still accessible.**
  - Goal: CAT-QUALITY-001. Payoff: improve the first experience while preserving mathematical and visual variety.
  - Sources: [Quality plan](docs/planning/visual-fidelity-audit-next.md#quality-without-losing-variety), [accepted outcome](PRD.md#catalog-quality-and-variety), `docs/planning/visual-audit-inventory.json`, `lib/features/catalog/data/catalog_repository.dart`, `lib/core/modules/fractal_mathematics.dart`.
  - Graph evidence: Fresh partial 38-file code-only Graphify scan: CatalogRepository (`catalog_repository.dart:15,20,57`), CatalogEntry (`catalog_entry.dart:12,30`), FractalMathematics (`fractal_mathematics.dart:11,45`) and LaunchVisualMetrics (`launch_visual_metrics.dart:9`). Extracted nodes are source-corroborated; five self-loops/duplicate-label warnings and truncated queries remain. Shaders/viewer/export/docs semantics are not indexed. See the quality plan for queries and receipt path.
  - Scope: Proposed: small curated collection using existing cards/filters and source-reviewed family/group metadata; full catalog/search/favorites remain accessible. Record adopt/revise/defer before product UI work. No destructive deduplication, renaming, certification badge or remote ranking service.
  - Acceptance: Owner records the discovery/promotion decision. If adopted, bind exact representative IDs and honest qualifications to pilot evidence, preserve full supported ID availability and state, EN/ES, keyboard/screen-reader access and restored search/filter behavior. Proposed layout is not counted as implemented.
  - Checks: Decision record plus planned catalog search/math-navigation/a11y/ID regression and named 320px/768px layouts at text scale 2; these checks are NOT_RUN until an approved UI change is implemented.
  - Dependencies: CAT-QUALITY-02.
  - Ownership: Product owner decision; proposed UI remains Needs decision. No implementation or schedule is authorized.
  - Owner decision: 2026-10-16 — Keep curated discovery undecided until the quality pilot provides concrete examples. Retain Needs decision, CAT-QUALITY-02 dependency and current complete-catalog access; no curated UI implementation is accepted by this answer.
  - Next action: Bring concrete pilot results and representative catalog examples before requesting the adopt/revise/defer decision.

- [ ] **MEDIA-002 — Select launch hero stills.** Scope: choose 6–8 from the captured Featured Launch Set plus separate 3D/tiling candidates (`mandelbulb` and `spectre_monotile` or `hat_monotile`); no source asset publication. Acceptance: record the selected module IDs and artifact paths, covering 2D escape-time, Newton, IFS, attractor, tiling, and one 3D example as required by the runbook. Dependency: candidate output from MEDIA-001 and supplemental high-resolution captures must exist. Blocker: selection is taste-based and requires product-owner judgment; owner not recorded. See [`docs/planning/LAUNCH_MEDIA.md`](docs/planning/LAUNCH_MEDIA.md).
  - Goal: MEDIA-002. Payoff: choose representative launch imagery without publishing assets.
  - Sources: `docs/planning/LAUNCH_MEDIA.md` and MEDIA-001 evidence above.
  - Dependencies: MEDIA-001 (existing verified launch captures). Supplemental 3D/tiling captures and owner selection remain acceptance prerequisites; no new capture task is invented.
  - Ownership: product owner decision required; no publication is authorized.
  - Scope: select 6–8 captured stills covering the existing launch-media family requirements; exclude publication and new rendering work.
  - Acceptance: owner records selected IDs and artifact paths, including supplemental 3D/tiling candidates. Required captures must exist before selection.
  - Owner decision: 2026-10-16 — Prepare one contact sheet from qualified candidates, flag missing 3D/tiling images, then ask the owner to choose. This is preparation for selection, not final image approval or publication.
  - Next action: Reuse qualified MEDIA-001 artifacts to prepare a labeled contact sheet with exact IDs/paths and explicit missing 3D/tiling slots. Do not silently add unqualified captures, invent missing images or select the final 6–8 on the owner’s behalf. Keep final selection pending until the concrete preview is available.

- [ ] **VIS-003 — App icon visual sign-off.** Scope: inspect the existing adaptive launcher and store artwork in representative device masks; do not treat missing files as the issue or redesign without approval. Acceptance: product owner records accept/request-change and any exact crop/design correction. Blocker: visual acceptance criteria/approval are owner-controlled; inputs and dimensions were checked, but visual acceptance is not claimed. Ownership: owner decision required.
  - Goal: VIS-003. Payoff: obtain an explicit artwork acceptance decision.
  - Sources: `docs/store_listing/ASSET_SPECS.md` and the Slice D input checks in `docs/planning/visual-fidelity-audit-next.md`.
  - Target clarification: The owner now requests an app-derived Zig-Zag Julia replacement; see [the prospective branding override](docs/engineering/spec.md#app-derived-zig-zag-julia-icon). Review staged ICON-ZJ-01 candidates and record their exact hashes/crop corrections plus representative Android device/mask observations from the disposable preview build (retain APK hash); no canonical integration is needed to obtain that preview. Historical SVG input checks are not approval of the replacement; original owner-controlled acceptance remains unchanged. ICON-ZJ-02 waits for this sign-off.
  - Owner approval: B/open-spiral composition was selected, followed by explicit instruction to apply it in the app and Play Store. No further design-choice interview is needed. Remaining live qualification is actual installed Android launcher presentation; no device is attached and that check is not claimed.
  - Checks: Planned owner review of ICON-ZJ-01 proof at native icon sizes, actual Android launcher presentation and the recorded capture/provenance; save explicit accept/request-change with exact candidate hashes. No execution or publication from this review task.
  - Dependencies: none.
  - Ownership: artwork approved; installed-device qualification deferred until an Android test device is available. No redesign or release is authorized.
  - Owner decision: 2026-10-16 — Defer installed-device qualification; retain B approval and do not repeat the Play upload. This defers the check, not its acceptance criterion. Keep VIS-003 and ICON-ZJ-02 open; do not re-request composition approval.
  - Next action: Wait for an available Android test device, then verify the installed launcher and record the actual outcome. No new download, upload, binary release or runner change is authorized.
  - Scope: review existing adaptive launcher/store artwork in representative masks; exclude unapproved redesign or release.
  - Acceptance: owner records accept/request-change and exact requested crop or design corrections.

- [ ] **OAI-VIS-01-IFS — Decide a self-similar measure overlap explorer.**
  - Goal: OAI-VIS-001. Payoff: add a distinct experience only if it meets the catalog quality bar.
  - Sources: [Pinned shortlist and papers](docs/planning/visual-fidelity-audit-next.md#openai-mathematics-visual-candidate-shortlist), [Quality plan](docs/planning/visual-fidelity-audit-next.md#quality-without-losing-variety), OpenAI commit `fd4aeeb2ee4fc729c18d98444fed42fd0529eeeb`, existing module/inventory overlap inspection.
  - Graph evidence: partial seven-file Graphify scan; CatalogRepository:15, ModuleRegistry:64, FractalMathematics:11 are source-correlated. Truncated query/duplicate-label warning; source corroborates declarative entries and shader model. Proof/viewer/export semantics unindexed.
  - Scope: Proposed candidate decision, not implementation. Exact affine-composition entropy versus branch entropy; measure versus attractor; reuse Cantor/IFS where truthful. Preserve existing IDs/state; no shaders, dependencies, migration, renderer rewrite, dispatch or schedule.
  - Acceptance: record select/revise/defer with exact finite model, distinctness, compatibility approach, approximation labels, resource caps and discriminating correctness/render/export checks. Choose at most one initial prototype; do not claim theorem verification from a finite image or source README.
  - Checks: inspect referenced pinned paper/model and scope; adopt the candidate-specific fixtures in the shortlist, then bind exact planned test targets before any implementation. Product tests/Lean rebuilds are NOT_RUN.
  - Dependencies: none; proposals do not bypass current focus or existing quality gates.
  - Ownership: product owner choice, repository backlog; Needs decision. Planning does not authorize implementation.
  - Owner decision: 2026-10-16 — Defer this proposal; prioritize existing quality and academic research. This does not change the existing focus/order or authorize a prototype.
  - Next action: Keep this proposal in Needs decision, deferred rather than completed; do not select or implement it unless the owner later revisits it.

- [ ] **OAI-VIS-02-SLE — Decide a seeded SLE curve explorer.**
  - Goal: OAI-VIS-001. Payoff: add a distinct experience only if it meets the catalog quality bar.
  - Sources: [Pinned shortlist and papers](docs/planning/visual-fidelity-audit-next.md#openai-mathematics-visual-candidate-shortlist), [Quality plan](docs/planning/visual-fidelity-audit-next.md#quality-without-losing-variety), OpenAI commit `fd4aeeb2ee4fc729c18d98444fed42fd0529eeeb`, existing module/inventory overlap inspection.
  - Graph evidence: partial seven-file Graphify scan; CatalogRepository:15, ModuleRegistry:64, FractalMathematics:11 are source-correlated. Truncated query/duplicate-label warning; source corroborates declarative entries and shader model. Proof/viewer/export semantics unindexed.
  - Scope: Proposed candidate decision, not implementation. Reviewed Loewner numerical scheme, deterministic Brownian seed and bounded refinement; do not label random walks SLE. Preserve existing IDs/state; no shaders, dependencies, migration, renderer rewrite, dispatch or schedule.
  - Acceptance: record select/revise/defer with exact finite model, distinctness, compatibility approach, approximation labels, resource caps and discriminating correctness/render/export checks. Choose at most one initial prototype; do not claim theorem verification from a finite image or source README.
  - Checks: inspect referenced pinned paper/model and scope; adopt the candidate-specific fixtures in the shortlist, then bind exact planned test targets before any implementation. Product tests/Lean rebuilds are NOT_RUN.
  - Dependencies: none; proposals do not bypass current focus or existing quality gates.
  - Ownership: product owner choice, repository backlog; Needs decision. Planning does not authorize implementation.
  - Owner decision: 2026-10-16 — Defer this proposal; prioritize existing quality and academic research. This does not change the existing focus/order or authorize a prototype.
  - Next action: Keep this proposal in Needs decision, deferred rather than completed; do not select or implement it unless the owner later revisits it.

- [ ] **OAI-VIS-03-VORONOI — Decide a finite Poisson–Voronoi crossing explorer.**
  - Goal: OAI-VIS-001. Payoff: add a distinct experience only if it meets the catalog quality bar.
  - Sources: [Pinned shortlist and papers](docs/planning/visual-fidelity-audit-next.md#openai-mathematics-visual-candidate-shortlist), [Quality plan](docs/planning/visual-fidelity-audit-next.md#quality-without-losing-variety), OpenAI commit `fd4aeeb2ee4fc729c18d98444fed42fd0529eeeb`, existing module/inventory overlap inspection.
  - Graph evidence: partial seven-file Graphify scan; CatalogRepository:15, ModuleRegistry:64, FractalMathematics:11 are source-correlated. Truncated query/duplicate-label warning; source corroborates declarative entries and shader model. Proof/viewer/export semantics unindexed.
  - Scope: Proposed candidate decision, not implementation. Explicit finite geometry/adjacency, monotone occupancy and crossing fixtures; preserve percolation and Voronoi crackle identities. Preserve existing IDs/state; no shaders, dependencies, migration, renderer rewrite, dispatch or schedule.
  - Acceptance: record select/revise/defer with exact finite model, distinctness, compatibility approach, approximation labels, resource caps and discriminating correctness/render/export checks. Choose at most one initial prototype; do not claim theorem verification from a finite image or source README.
  - Checks: inspect referenced pinned paper/model and scope; adopt the candidate-specific fixtures in the shortlist, then bind exact planned test targets before any implementation. Product tests/Lean rebuilds are NOT_RUN.
  - Dependencies: none; proposals do not bypass current focus or existing quality gates.
  - Ownership: product owner choice, repository backlog; Needs decision. Planning does not authorize implementation.
  - Owner decision: 2026-10-16 — Defer this proposal; prioritize existing quality and academic research. This does not change the existing focus/order or authorize a prototype.
  - Next action: Keep this proposal in Needs decision, deferred rather than completed; do not select or implement it unless the owner later revisits it.

- [ ] **OAI-VIS-04-UST — Decide uniform spanning tree and loop-erased path explorer.**
  - Goal: OAI-VIS-001. Payoff: broaden mathematically distinct experiences without a quantity-driven catalog expansion.
  - Sources: [Candidate plan](docs/planning/visual-fidelity-audit-next.md#openai-mathematics-visual-candidate-shortlist), [Expanded shortlist](docs/planning/visual-fidelity-audit-next.md#expanded-candidates--additional-source-backed-proposals), [Quality plan](docs/planning/visual-fidelity-audit-next.md#quality-without-losing-variety), pinned OpenAI result 231 at `fd4aeeb2ee4fc729c18d98444fed42fd0529eeeb`, current inventory overlap receipt.
  - Graph evidence: four-file partial code-only scan; ModuleRegistry:64, FractalMathematics:11, CatalogRepository:15 corroborated in source; truncated query and duplicate-label warning, complete model/shader semantics unindexed.
  - Scope: Proposed finite-model candidate choice only. Seeded branching trees, a highlighted unique path and animated loop erasure on a capped finite grid. Wilson sampling is an established finite uniform-spanning-tree approach; the paper concerns the free spanning forest on infinite graphs, not a new finite algorithm. No explicit spanning-tree/loop-erased ID matched the recorded inventory. Maze CA, brownian_tree_dla and levy_brownian_paths exist, but neither maze rules nor diffusion-limited aggregation is a uniform spanning tree. Do not substitute DLA or relabel an existing identity. No new IDs, dependencies, shaders, saved-state migrations, dispatch or schedule during planning.
  - Acceptance: owner records select/revise/defer and exact finite model, sampler/boundary conditions, resource caps, uncertainty disclosures and compatibility contract; choose at most one initial prototype across the shortlist. No finite output is proof of the continuum/infinite theorem.
  - Checks: planned discriminating fixtures: Every vertex belongs to one acyclic connected tree, edge count V-1, unique paths; exact tiny-graph enumeration checks the sampling law, replay same seed, disclose rooting/free/wired boundary choice, cancel long walks and cap walk work without silently biasing accepted samples. Bind actual test targets before approved implementation; model/render/platform checks are NOT_RUN.
  - Dependencies: none; decision proposals cannot bypass existing quality gates or primary focus.
  - Ownership: product owner choice; Needs decision, unassigned. No implementation authority.
  - Owner decision: 2026-10-16 — Defer this proposal; prioritize existing quality and academic research. This does not change the existing focus/order or authorize a prototype.
  - Next action: Keep this proposal in Needs decision, deferred rather than completed; do not select or implement it unless the owner later revisits it.

- [ ] **OAI-VIS-05-DIMER — Decide double-dimer nested-loop explorer.**
  - Goal: OAI-VIS-001. Payoff: broaden mathematically distinct experiences without a quantity-driven catalog expansion.
  - Sources: [Candidate plan](docs/planning/visual-fidelity-audit-next.md#openai-mathematics-visual-candidate-shortlist), [Expanded shortlist](docs/planning/visual-fidelity-audit-next.md#expanded-candidates--additional-source-backed-proposals), [Quality plan](docs/planning/visual-fidelity-audit-next.md#quality-without-losing-variety), pinned OpenAI result 226 at `fd4aeeb2ee4fc729c18d98444fed42fd0529eeeb`, current inventory overlap receipt.
  - Graph evidence: four-file partial code-only scan; ModuleRegistry:64, FractalMathematics:11, CatalogRepository:15 corroborated in source; truncated query and duplicate-label warning, complete model/shader semantics unindexed.
  - Scope: Proposed finite-model candidate choice only. Draw two independent perfect matchings of a bounded bipartite lattice, then their superposition: doubled edges and closed loops. Color by loop identity/nesting and retain the two matchings for inspection. The cited paper proves a half-plane Temperleyan scaling limit; generic finite rectangles are not automatically that law. No dimer ID matched the inventory. Related to SLE/CLE but distinct finite perfect-matching model; keep it one entry, not one catalog item per loop color. No new IDs, dependencies, shaders, saved-state migrations, dispatch or schedule during planning.
  - Acceptance: owner records select/revise/defer and exact finite model, sampler/boundary conditions, resource caps, uncertainty disclosures and compatibility contract; choose at most one initial prototype across the shortlist. No finite output is proof of the continuum/infinite theorem.
  - Checks: planned discriminating fixtures: One matched edge per vertex in each matching, degree two with multiplicity in the superposition, doubled edges treated separately, loop decomposition exhausts remaining edges and small exact matchings check sampling. Distinguish exact uniform sampling from a finite MCMC approximation; report burn-in/convergence limitations rather than claim uniformity. Bind actual test targets before approved implementation; model/render/platform checks are NOT_RUN.
  - Dependencies: none; decision proposals cannot bypass existing quality gates or primary focus.
  - Ownership: product owner choice; Needs decision, unassigned. No implementation authority.
  - Owner decision: 2026-10-16 — Defer this proposal; prioritize existing quality and academic research. This does not change the existing focus/order or authorize a prototype.
  - Next action: Keep this proposal in Needs decision, deferred rather than completed; do not select or implement it unless the owner later revisits it.

- [ ] **OAI-VIS-06-HEIGHT — Decide six-vertex height and contour explorer.**
  - Goal: OAI-VIS-001. Payoff: broaden mathematically distinct experiences without a quantity-driven catalog expansion.
  - Sources: [Candidate plan](docs/planning/visual-fidelity-audit-next.md#openai-mathematics-visual-candidate-shortlist), [Expanded shortlist](docs/planning/visual-fidelity-audit-next.md#expanded-candidates--additional-source-backed-proposals), [Quality plan](docs/planning/visual-fidelity-audit-next.md#quality-without-losing-variety), pinned OpenAI result 225 at `fd4aeeb2ee4fc729c18d98444fed42fd0529eeeb`, current inventory overlap receipt.
  - Graph evidence: four-file partial code-only scan; ModuleRegistry:64, FractalMathematics:11, CatalogRepository:15 corroborated in source; truncated query and duplicate-label warning, complete model/shader semantics unindexed.
  - Scope: Proposed finite-model candidate choice only. Show lattice arrows, a finite discrete height map and contour bands for the ice model. Enforce two arrows in and two out at every interior vertex; display a=b=1 and c weight, boundary conditions and sector. Result 232 supplies a related triangular-Lipschitz-height variant, grouped here rather than booked separately. No six_vertex/height/gaussian_free ID matched. Ordinary procedural noise is not a Gaussian free field or an ice-model sampler. Similar colors do not establish equivalent mathematical identity. No new IDs, dependencies, shaders, saved-state migrations, dispatch or schedule during planning.
  - Acceptance: owner records select/revise/defer and exact finite model, sampler/boundary conditions, resource caps, uncertainty disclosures and compatibility contract; choose at most one initial prototype across the shortlist. No finite output is proof of the continuum/infinite theorem.
  - Checks: planned discriminating fixtures: Ice constraints hold; oriented height increments are path-consistent under the stated boundary/sector convention; tiny configurations have correct weights; seed replay and sampler limitations are disclosed. A torus can have nonzero winding, so do not claim a globally periodic scalar height outside a zero-winding sector. Finite height samples are not exact continuum GFF samples. Bind actual test targets before approved implementation; model/render/platform checks are NOT_RUN.
  - Dependencies: none; decision proposals cannot bypass existing quality gates or primary focus.
  - Ownership: product owner choice; Needs decision, unassigned. No implementation authority.
  - Owner decision: 2026-10-16 — Defer this proposal; prioritize existing quality and academic research. This does not change the existing focus/order or authorize a prototype.
  - Next action: Keep this proposal in Needs decision, deferred rather than completed; do not select or implement it unless the owner later revisits it.

- [ ] **OAI-VIS-07-FK — Decide fortuin–Kasteleyn cluster and interface explorer.**
  - Goal: OAI-VIS-001. Payoff: broaden mathematically distinct experiences without a quantity-driven catalog expansion.
  - Sources: [Candidate plan](docs/planning/visual-fidelity-audit-next.md#openai-mathematics-visual-candidate-shortlist), [Expanded shortlist](docs/planning/visual-fidelity-audit-next.md#expanded-candidates--additional-source-backed-proposals), [Quality plan](docs/planning/visual-fidelity-audit-next.md#quality-without-losing-variety), pinned OpenAI result 223 at `fd4aeeb2ee4fc729c18d98444fed42fd0529eeeb`, current inventory overlap receipt.
  - Graph evidence: four-file partial code-only scan; ModuleRegistry:64, FractalMathematics:11, CatalogRepository:15 corroborated in source; truncated query and duplicate-label warning, complete model/shader semantics unindexed.
  - Scope: Proposed finite-model candidate choice only. Finite square-lattice random-cluster configurations with visible bond probability p, cluster weight q, clusters, boundary wiring and exploration interface. The finite law weights configurations by p^open*(1-p)^closed*q^clusters; it is not independent percolation when q differs from one. Treat q=1 and q=2 as configurations of one family. Existing percolation is not this finite random-cluster law; coordinate with OAI-VIS-03-VORONOI and preserve its ID. It also relates to OAI-VIS-02-SLE but finite lattice connectivity is a different model. Reuse a future common model only if justified by real callers, not a speculative graph framework. No new IDs, dependencies, shaders, saved-state migrations, dispatch or schedule during planning.
  - Acceptance: owner records select/revise/defer and exact finite model, sampler/boundary conditions, resource caps, uncertainty disclosures and compatibility contract; choose at most one initial prototype across the shortlist. No finite output is proof of the continuum/infinite theorem.
  - Checks: planned discriminating fixtures: Tiny exact partition-function/cluster-count fixtures, q=1 reduction to independent bonds, correct wired/free cluster counting and Dobrushin interface rules, seed replay and explicit sampler mixing gaps. Do not infer arbitrary-q uniformity or SLE convergence from a colorful sample. The inspected first paper covers 1<=q<4; the index lists broader companions, whose hypotheses must be reviewed separately. Bind actual test targets before approved implementation; model/render/platform checks are NOT_RUN.
  - Dependencies: none; decision proposals cannot bypass existing quality gates or primary focus.
  - Ownership: product owner choice; Needs decision, unassigned. No implementation authority.
  - Owner decision: 2026-10-16 — Defer this proposal; prioritize existing quality and academic research. This does not change the existing focus/order or authorize a prototype.
  - Next action: Keep this proposal in Needs decision, deferred rather than completed; do not select or implement it unless the owner later revisits it.

- [ ] VIEW-UI-01-LIVE — Live checks for VIEW-UI-01
  Goal: VIEW-UI-001
  Sources: [Existing goal contract](docs/engineering/spec.md#viewer-chrome-footprint-and-action-consistency); `todo.archive.md` retains the original offline task and evidence.
  Scope: Run the live checks the offline work for VIEW-UI-01 left pending.
  Acceptance: Each check passes on the real target:
  - Physical-device screen-reader/TalkBack/VoiceOver and device-rotation qualification.
  - Hardware-GPU and bundled production-font qualification; the Linux/Xvfb run uses software llvmpipe/native font fallback.
  Checks: Live qualification by an authorized person; offline evidence does not count.
  Dependencies: VIEW-UI-01.
  Status: open
  - Owner decision: 2026-10-16 — Defer until a suitable test device and reviewer are available; preserve every acceptance check. Deferral is neither completion nor a release waiver.
  - Next action: Keep this live task open in Needs decision. Resume qualification planning when suitable target/reviewer access exists; retain screen-reader, rotation, hardware-GPU and production-font checks. Do not substitute offline results for real-target evidence.

- [ ] VIEW-UI-02-LIVE — Live checks for VIEW-UI-02
  Goal: VIEW-UI-001
  Sources: [Existing goal contract](docs/engineering/spec.md#viewer-chrome-footprint-and-action-consistency); `todo.archive.md` retains the original offline task and evidence.
  Scope: Run the live checks the offline work for VIEW-UI-02 left pending.
  Acceptance: Each check passes on the real target:
  - Same-state native screenshots, production typography validation, and physical-device/screen-reader acceptance remain outstanding. Flutter 3.44.6 qualification was not run; this environment provides Flutter 3.44.2.
  Checks: Live qualification by an authorized person; offline evidence does not count.
  Dependencies: VIEW-UI-02.
  Status: open
  - Owner decision: 2026-10-16 — Defer until target/reviewer access is available; preserve native screenshots, typography and screen-reader checks. Deferral is neither completion nor a release waiver.
  - Next action: Keep this live task open in Needs decision. When target/reviewer access exists, reconcile exact SDK receipts and complete the retained real-target acceptance; historical environment wording is not proof of current SDK absence.

- [ ] GAUSS-MOAT-02-WALK-LIVE — Live checks for GAUSS-MOAT-02-WALK
  Goal: GAUSS-MOAT-001
  Sources: [Existing goal contract](PRD.md#gaussian-moat-walking-visualization); `todo.archive.md` retains the original offline task and evidence.
  Scope: Run the live checks the offline work for GAUSS-MOAT-02-WALK left pending.
  Acceptance: Each check passes on the real target:
  - Physical-device visual, accessibility, and performance qualification.
  Checks: Live qualification by an authorized person; offline evidence does not count.
  Dependencies: GAUSS-MOAT-02-WALK.
  Status: open
  - Owner decision: 2026-10-16 — Defer until a suitable physical device and reviewer are available; preserve visual, accessibility and performance gates. Deferral is neither completion nor a release waiver.
  - Next action: Keep this live task open in Needs decision. Resume qualification planning when actual device/reviewer access exists; retain original physical-device acceptance rather than substituting offline model tests.

- [ ] QUAT-NORM-01-SLICE-LIVE — Live checks for QUAT-NORM-01-SLICE
  Goal: QUAT-NORM-001
  Sources: [Existing goal contract](PRD.md#prime-norm-quaternion-companion); `todo.archive.md` retains the original offline task and evidence.
  Scope: Run the live checks the offline work for QUAT-NORM-01-SLICE left pending.
  Acceptance: Each check passes on the real target:
  - Human review and device/visual qualification of responsive layout, screen-reader/list selection, and rendered quaternion points remain pending; offline mathematical and regression tests do not qualify device behavior.
  Checks: Live qualification by an authorized person; offline evidence does not count.
  Dependencies: QUAT-NORM-01-SLICE.
  Status: open
  - Owner decision: 2026-10-16 — Defer until a suitable device and human reviewer are available; retain all qualification checks. Deferral is neither completion nor a release waiver.
  - Next action: Keep this live task open in Needs decision. Resume when target/reviewer access exists and inspect actual responsive layout, screen-reader/list selection and rendered points; offline math does not supply this verdict.

- [ ] REL-JOURNEY-02-LINUX-LIVE — Live checks for REL-JOURNEY-02-LINUX
  Goal: REL-JOURNEY-001
  Sources: [Existing goal contract](PRD.md#active-release-contract); `todo.archive.md` retains the original offline task and evidence.
  Scope: Run the live checks the offline work for REL-JOURNEY-02-LINUX left pending.
  Acceptance: Each check passes on the real target:
  - Human visual review of exported image composition/readability; the integration test deletes its temporary PNGs after numerical checks.
  Checks: Live qualification by an authorized person; offline evidence does not count.
  Dependencies: REL-JOURNEY-02-LINUX.
  Status: open
  - Owner decision: 2026-10-16 — Have the runner prepare retained real-export images for human review; keep visual acceptance pending. This does not approve unseen output or waive real-target checks.
  - Next action: Prepare representative real edited-state Linux PNG exports using the existing journey path, retain the actual files and provenance instead of only deleted temporary artifacts, and present them for composition/readability review. Keep this task open until an attributable human verdict; do not fabricate images or infer visual acceptance from numerical PNG checks.

- [ ] **ACAD-03 — Review approved source mathematics against a representative renderer pilot.**
  - Goal: ACAD-001
  - Status: open
  - Section: Needs decision.
  - Sources: [Accepted academic research outcome](PRD.md#academic-research-library), [accepted integration contract](docs/engineering/spec.md#academic-source-to-renderer-evidence), [source review and rights contract](research/academic/README.md), [verification owner](docs/engineering/test-plan.md#academic-evidence-verification), `lib/core/modules/fractal_mathematics.dart`, `lib/shared/widgets/fractal_math_summary.dart`.
  - Touches: research/academic/reviews/, research/academic/mappings/, research/academic/families/, research/academic/coverage.json, test/research/, test/modules/
  - Scope: After attributable human decisions, acquire only the approved legal source subset and draft/verify exact source-span-to-effective-renderer dossiers for at most 12 pilot identities. Compare algebra, initialization, recurrence/rules, parameter clamps/uniform bindings, termination, numerical approximations and independent fixtures. Reuse existing Number Walls sources and CAT-QUALITY evidence; do not rewrite their plans or pretend planned renderers exist. Feynman outputs, if separately authorized, remain untrusted draft notes until checked; no installation or remote experiments implied.
  - Acceptance: Each included claim has actual source/version/page/equation evidence and a separate source/implementation/numerical verdict. Unsupported/contradicted/inaccessible entries stay qualified or open; no abstract-only certification or fabricated oracle. Record actual reviewers and distinguish draft extraction from human-accepted extraction/final claims. Reproducible testable mathematical mismatches become bounded tasks under their existing owners, without automatic formula changes. Store only licensed/approved redistributable metadata and brief excerpts in Git; private PDFs/OCR stay ignored with rights/hash manifests.
  - Checks: After approval only, build a separate acquisition-only staging directory with `results.jsonl` filtered to exactly the approved source IDs; bind its digest/decision IDs and assert selected equals approved before fetch. Never assume standalone `oa fetch` consults screening.jsonl or target it at all discovery results. Read actual fetch report/failures/files/digests/rights rather than treating exit zero as complete success. Run ACAD-01 validators plus newly added source-derived fixture tests via `pytest test/research -v` and the exact affected `flutter test ...` targets. Record commands/outcomes; all acquisition/source review/numerical checks remain NOT_RUN now.
  - Dependencies: ACAD-02, ACAD-007-f8.
  - Ownership: Owner must approve inclusion/exclusion and legal full-text acquisition subset; ResearchForge also requires human acceptance of extracted/final claims. Do not impersonate the owner. Keep this task non-executable until decisions are recorded and section is reconciled.
  - Default if no answer: Metadata-only pilot and independent offline tooling proceed; no source acquisition or accepted-claim upgrade.
  - Owner decision: 2026-10-16 — Keep source review gated; have the runner finish the concrete source/rights queue first under ACAD-02. No blanket source inclusion, acquisition or accepted-claim approval is granted; keep ACAD-03 in Needs decision and preserve its dependencies.
  - Next action: Wait for the bounded verified review package owned by ACAD-007-f8, then present its exact actionable subset and explicit gaps for attributable owner identity-mapping, inclusion/acquisition decisions. Package completion is not approval: keep ACAD-03 in Needs decision until those decisions are actually recorded; no full-text fetch, accepted extraction or claim upgrade from metadata preparation. Preserve original pilot run/provenance and all prior source/rights gates.

- [ ] SMOOTH-001-INVENTORY-01-LIVE — Live checks for SMOOTH-001-INVENTORY-01
  Goal: SMOOTH-001
  Sources: [Existing goal contract](TODO.md#p1-3-smooth-coloring-in-all-shaders); `todo.archive.md` retains the original offline task and evidence.
  Scope: Run the live checks the offline work for SMOOTH-001-INVENTORY-01 left pending.
  Acceptance: Each check passes on the real target:
  - Hardware-GPU visual qualification was not run; the source-level checks do not establish rendered appearance or performance.
  Checks: Live qualification by an authorized person; offline evidence does not count.
  Dependencies: SMOOTH-001-INVENTORY-01.
  Status: open
  - Owner decision: 2026-10-16 — Defer hardware-GPU qualification; retain source-test evidence without calling it visual proof. Deferral is neither completion nor a release waiver.
  - Next action: Keep this live task open in Needs decision until a named hardware-GPU qualification session is planned; preserve its actual-rendering and performance requirements without reclassifying source assertions as rendered evidence.

- [ ] REL-JOURNEY-03-ANDROID-LIVE — Live checks for REL-JOURNEY-03-ANDROID
  Goal: REL-JOURNEY-001
  Sources: [Existing goal contract](PRD.md#active-release-contract); `todo.archive.md` retains the original offline task and evidence.
  Scope: Run the live checks the offline work for REL-JOURNEY-03-ANDROID left pending.
  Acceptance: Each check passes on the real target:
  - Connect a named Android device and run the shared edited Mandelbrot/Mandelbulb image-creation journey.
  - Add or confirm a platform-specific journey target that reads back and decodes the actual MediaStore PNGs and verifies gallery visibility; current shared journey checks its app export file only and does not verify MediaStore/gallery state.
  - Record each saved image's selected dimensions, readable PNG content, edited viewer state, device ID, backend and exact command. Keep emulator evidence separate from physical-device qualification.
  Checks: Live qualification by an authorized person; offline evidence does not count.
  Dependencies: REL-JOURNEY-03-ANDROID.
  Status: open
  - Owner decision: 2026-10-16 — Defer until a named Android test device is available; retain gallery/MediaStore and PNG-readback requirements. Deferral is neither completion nor a release waiver.
  - Next action: Keep this live task open in Needs decision. When a named device is available, verify the actual edited Mandelbrot/Mandelbulb MediaStore/gallery outputs, decode PNGs, and record dimensions/content, device/backend and exact commands. Keep physical-device and emulator verdicts distinct.

- [ ] ACAD-01-LIVE — Live checks for ACAD-01
  Goal: ACAD-001
  Sources: [Existing goal contract](PRD.md#academic-research-library); `todo.archive.md` retains the original offline task and evidence.
  Scope: Run the live checks the offline work for ACAD-01 left pending.
  Acceptance: Each check passes on the real target:
  - Human adjudication of title-collision suggestions and identity aliases remains pending; unresolved identities intentionally stay coverage gaps.
  Checks: Live qualification by an authorized person; offline evidence does not count.
  Dependencies: ACAD-01.
  Status: open

- [ ] SMOOTH-001-INVENTORY-02-LIVE — Live checks for SMOOTH-001-INVENTORY-02
  Goal: SMOOTH-001
  Sources: [Existing goal contract](TODO.md#p1-3-smooth-coloring-in-all-shaders); `todo.archive.md` retains the original offline task and evidence.
  Scope: Run the live checks the offline work for SMOOTH-001-INVENTORY-02 left pending.
  Acceptance: Each check passes on the real target:
  - Visual or hardware-GPU qualification for the checked Multibrot shaders was not run; source and numeric fixtures are offline evidence only.
  Checks: Live qualification by an authorized person; offline evidence does not count.
  Dependencies: SMOOTH-001-INVENTORY-02.
  Status: open

- [ ] CAT-QUALITY-01-LIVE — Live checks for CAT-QUALITY-01
  Goal: CAT-QUALITY-001
  Sources: [Existing goal contract](PRD.md#catalog-quality-and-variety); `todo.archive.md` retains the original offline task and evidence.
  Scope: Run the live checks the offline work for CAT-QUALITY-01 left pending.
  Acceptance: Each check passes on the real target:
  - Physical-device and human visual acceptance are not performed here. Repaired after-state comparisons, control exercise, named-target performance measurement, and edited-state PNG equivalence remain explicitly NOT_CHECKED for follow-up qualification; no artifacts or passes were fabricated.
  Checks: Live qualification by an authorized person; offline evidence does not count.
  Dependencies: CAT-QUALITY-01.
  Status: open

- [ ] ACAD-02-LIVE — Live checks for ACAD-02
  Goal: ACAD-001
  Sources: [Existing goal contract](PRD.md#academic-research-library); `todo.archive.md` retains the original offline task and evidence.
  Scope: Run the live checks the offline work for ACAD-02 left pending.
  Acceptance: Each check passes on the real target:
  - Network pilot searches were not rerun during this retry; historical pilot artifacts are preserved. Retry arXiv failures when provider availability/rate limits permit; failures are not zero-hit evidence.
  - Human relevance, version/license review and any lawful acquisition approval for 906 pending records; no include/exclude decision or full-text acquisition was made.
  Checks: Live qualification by an authorized person; offline evidence does not count.
  Dependencies: ACAD-02.
  Status: open

- [ ] VIS-006-LIVE — Live checks for VIS-006
  Goal: VIS-006
  Sources: [Existing accepted visual scope](docs/planning/visual-fidelity-audit-next.md#accepted-focus); `todo.archive.md` retains the original capture contract/evidence.
  Scope: Run the live checks the offline work for VIS-006 left pending.
  Acceptance: Each check passes on the real target:
  - Optional human visual sign-off; local Linux GPU capture and contact-sheet inspection completed.
  Checks: Live qualification by an authorized person; offline evidence does not count.
  Dependencies: VIS-006, VIS-005 (existing goal prerequisite).
  Status: open

- [ ] QUAT-NORM-02-WALK-LIVE — Live checks for QUAT-NORM-02-WALK
  Goal: QUAT-NORM-001
  Sources: [Existing accepted companion contract](PRD.md#prime-norm-quaternion-companion); `todo.archive.md` retains the original offline task and evidence.
  Scope: Run the live checks the offline work for QUAT-NORM-02-WALK left pending.
  Acceptance: Each check passes on the real target:
  - Physical-device gesture/accessibility/native export qualification remains unrun.
  Checks: Live qualification by an authorized person; offline evidence does not count.
  Dependencies: QUAT-NORM-02-WALK.
  Status: open

- [ ] **RELEASE-003-ae — Publish the verified platform subset after scoped production approval.**
  - Goal: REL-JOURNEY-001
  - Status: open
  - Section: Needs decision.
  - Sources: [Accepted policy](PRD.md#independent-platform-release-policy), [implementation contract](docs/engineering/spec.md#independent-platform-release-orchestration), [lane map](docs/engineering/release/MULTIPLATFORM.md#independent-platform-release-campaign), [verification](docs/engineering/test-plan.md#independent-platform-release-verification).
  - Touches: release-artifacts/, fdroid/version.properties, fastlane/metadata/android/, CHANGELOG.md, docs/engineering/release/
  - Scope: After explicit scoped production authority and the verified prepare report, publish only its immutable eligible subset; skip lane-local errors and continue independent eligible lanes. Defaults: GitHub published/non-prerelease, Play production/completed, existing Cloudflare production project. No GitLab action, new destination, internal/test release or broader credential authority. Retain Apple/F-Droid external acceptance limits.
  - Acceptance: Read back every successful external effect at its exact release asset/deployment/store target with matching candidate/artifact identity. Report complete/partial/failure and every omitted or publication-unknown lane explicitly. Reconcile ambiguous writes before retry. Never rebuild/swap qualified artifacts, force tags, publish empty releases or label unsigned Apple/maintainer-pending F-Droid output production-delivered. No survivors/failed common validation means no publication. Preserve supported halt/higher-version replacement recovery limits.
  - Checks: Before the separately authorized publish command, verify attributable approval, live consumed Android versions and current tag/release/deployment state; bind exact manifests/digests and read back each target afterward. Exercise retry safety with mocks before any real write and retain actual outcomes. All publication/readback checks are NOT_RUN by planning.
  - Dependencies: RELEASE-002-75.
  - Ownership: Owner approval of the concrete prepared production subset is required; signing/store access cannot be self-approved. Keep non-executable until actual decisions exist.
  - Next action: Present the prepare report and exact missing access/authority; request only genuinely missing production approval for that subset. This planning request is not that approval.

- [ ] CAT-QUALITY-02-LIVE — Live checks for CAT-QUALITY-02
  - Goal: CAT-QUALITY-001
  - Sources: [Quality plan](docs/planning/visual-fidelity-audit-next.md#quality-without-losing-variety), [accepted outcome](PRD.md#catalog-quality-and-variety); original offline contract retained under CAT-QUALITY-02 in `todo.archive.md`.
  - Touches: docs/planning/visual-fidelity-audit-next.md
  - Ownership: Await authorized live-target access and human review; this metadata repair grants neither.
  Scope: Run the live checks the offline work for CAT-QUALITY-02 left pending.
  Acceptance: Each check passes on the real target:
  - Physical/mobile platform and applicable REL-JOURNEY edited-save/share/readback qualification remain unrun; host AMD Linux captures are not cross-platform qualification.
  - No independent registered reference oracle exists for these three formulas; no mathematical certification or human formula review is claimed.
  Checks: Live qualification by an authorized person; offline evidence does not count.
  Dependencies: CAT-QUALITY-02.
  Status: open

- [ ] QUAT-NORM-03-QUALIFY-LIVE — Live checks for QUAT-NORM-03-QUALIFY
  - Goal: QUAT-NORM-001
  - Sources: [Accepted companion](PRD.md#prime-norm-quaternion-companion), [accepted slice design](docs/engineering/spec.md#prime-norm-quaternion-companion); parent qualification contract retained in `todo.archive.md`.
  - Touches: docs/engineering/test-plan.md
  - Ownership: Await authorized live targets and human review; metadata repair grants neither.
  Scope: Run the live checks the offline work for QUAT-NORM-03-QUALIFY left pending.
  Acceptance: Each check passes on the real target:
  - Android qualification remains pending until a named Android device is available; run the journey and verify decoded exported PNGs on that target. Linux evidence used Xvfb and is not a physical GPU qualification.
  Checks: Live qualification by an authorized person; offline evidence does not count.
  Dependencies: QUAT-NORM-03-QUALIFY.
  Status: open

- [ ] VIS-006-BATCH-20-LIVE — Live checks for VIS-006-BATCH-20
  - Goal: VIS-006
  - Sources: [Accepted visual scope](docs/planning/visual-fidelity-audit-next.md#accepted-focus), [visual inventory](docs/planning/visual-audit-inventory.json); parent capture contract retained in `todo.archive.md`.
  - Touches: docs/planning/visual-fidelity-audit-next.md
  - Ownership: Await human visual review; metadata repair is not acceptance.
  Scope: Run the live checks the offline work for VIS-006-BATCH-20 left pending.
  Acceptance: Each check passes on the real target:
  - Human visual review of recognizability/framing for the captured previews; image-health pass is not visual or mathematical certification.
  Checks: Live qualification by an authorized person; offline evidence does not count.
  Dependencies: VIS-006-BATCH-20, VIS-005 (existing goal prerequisite).
  Status: open

- [ ] GAUSS-MOAT-04-GROWTH-LIVE — Live checks for GAUSS-MOAT-04-GROWTH
  - Goal: GAUSS-MOAT-001
  - Sources: [Accepted growth plan](docs/engineering/spec.md#gaussian-moat-walking-visualization), [growth details](docs/engineering/spec.md#bounded-radius-growth-and-visual-direction); parent contract retained in `todo.archive.md`.
  - Touches: docs/engineering/test-plan.md
  - Ownership: Await authorized live targets and human review; metadata repair grants neither.
  Scope: Run the live checks the offline work for GAUSS-MOAT-04-GROWTH left pending.
  Acceptance: Each check passes on the real target:
  - GAUSS-MOAT-03-QUALIFY real journey and live/device qualification remain separate pending gates; offline capture tests are not live qualification.
  Checks: Live qualification by an authorized person; offline evidence does not count.
  Dependencies: GAUSS-MOAT-04-GROWTH.
  Status: open

- [ ] GAUSS-MOAT-03-QUALIFY-LIVE — Live checks for GAUSS-MOAT-03-QUALIFY
  - Goal: GAUSS-MOAT-001
  - Sources: [Accepted scope](PRD.md#gaussian-moat-walking-visualization), [bounded design](docs/engineering/spec.md#gaussian-moat-walking-visualization); parent qualification contract retained in `todo.archive.md`.
  - Touches: docs/engineering/test-plan.md
  - Ownership: Await authorized live targets and human review; metadata repair grants neither.
  Scope: Run the live checks the offline work for GAUSS-MOAT-03-QUALIFY left pending.
  Acceptance: Each check passes on the real target:
  - Android journey has not run on a named device; decode its selected-dimension PNG and verify actual MediaStore/gallery persistence/readability. Keep emulator and physical-device evidence separate.
  - B=128 cap/chunk/job/cancellation telemetry and real target-specific timing/memory remain unmeasured. Xvfb and the single B=32 Chromium observation do not establish physical GPU or cross-target performance.
  - Complete live EN/ES, responsive, keyboard/focus and screen-reader qualification on the named platforms, plus human review of exported mathematical composition, remains pending.
  Checks: Live qualification by an authorized person; offline evidence does not count.
  Dependencies: GAUSS-MOAT-03-QUALIFY.
  Status: open

- [ ] RELEASE-001-23-LIVE — Live checks for RELEASE-001-23
  - Goal: REL-JOURNEY-001
  - Sources: [Accepted policy](PRD.md#independent-platform-release-policy), [implementation contract](docs/engineering/spec.md#independent-platform-release-orchestration), [lane map](docs/engineering/release/MULTIPLATFORM.md#independent-platform-release-campaign); parent contract retained in `todo.archive.md`.
  - Touches: docs/engineering/test-plan.md
  - Ownership: Await authorized targets and separately scoped live-operation approval; metadata repair grants neither.
  Scope: Run the live checks the offline work for RELEASE-001-23 left pending.
  Acceptance: Each check passes on the real target:
  - Run the actual Linux native edited-view and decoded-PNG journey on a supported Linux target; the offline test used controlled subprocess doubles.
  - Qualify Windows, macOS and iOS journey/export gates on their supported hosts; until lane-local receipts exist those lanes remain unknown and are not publishable.
  - On authorized targets, validate real Android device qualification, Play remote bundle/track readback, Cloudflare deployment asset readback and GitHub asset download readback. No live service or signing operation was performed.
  - Complete external F-Droid acceptance and Apple signing/store qualification where applicable.
  Checks: Live qualification by an authorized person; offline evidence does not count.
  Dependencies: RELEASE-001-23.
  Status: open

## Done

## Goal coverage — visual-fidelity scope

<!-- goals:coverage:begin -->

Generated from `goals.json` by `goals.py render`. `met` requires an executed, passing check.

| Goal | Status | Evidence | Task |
| --- | --- | --- | --- |
| VIS-004: Verify the Featured Launch Set default and viewer-start flow | met | executed <code>dart format --output=none --set-exit-if-changed integration_test/flows/vis004_newton_z3_first_view_test.dart &amp;&amp; flutter analyze integration_test/flows/vis004_newton_z3_first_view_test.dart &amp;&amp; git diff --check</code> → pass; executed <code>dart format --output=none --set-exit-if-changed integration_test/flows/vis004_nova_first_view_test.dart</code> → pass; executed <code>flutter analyze integration_test/flows/vis004_nova_first_view_test.dart</code> → pass; executed <code>flutter test integration_test/flows/user_flows_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded</code> → pass; executed <code>flutter test integration_test/flows/vis004_newton_z3_first_view_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded</code> → pass; executed <code>flutter test integration_test/flows/vis004_newton_z3_first_view_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (pass; observed gpu_first_frame module=newton_z3 backend=gpu at 207ms, assertions synchronized to that frame)</code> → pass; executed <code>flutter test integration_test/flows/vis004_nova_first_view_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (pass; observed gpu_first_frame module=nova backend=gpu; default pan=(0,0), zoom=1.5, iterations=200, relaxation=1.0, colorScheme=2)</code> → pass; executed <code>git diff --check</code> → pass; inspection <code>TODO.md#VIS-004: all nine Featured Launch Set IDs have executed GPU first-view evidence</code> → pass; inspection <code>TODO.md#VIS-004: prior real-GPU and viewer-start checks cover four modules</code> → pass | — |
| VIS-005: Reconcile the visual audit across Explore and the research library | met | executed <code>flutter test test/catalog/catalog_id_integrity_test.dart --reporter expanded (15 tests passed; includes live Explore inventory reconciliation)</code> → pass; executed <code>python research/fractals-library/scripts/validate_manifest.py</code> → pass; executed <code>python research/fractals-library/scripts/validate_visual_inventory.py</code> → pass; inspection <code>TODO.md#VIS-005: prior broad audit timed out and research definitions are not mapped</code> → fail; inspection <code>docs/planning/visual-audit-inventory.json: 1,027 Explore IDs and 200 manifest IDs have explicit renderer status and references</code> → pass | — |
| VIS-006: Audit mapped fractals in reconciled batches | partial | executed <code>Artifact reconciliation: 20/20 batch-11 PNGs exist; 10 default images are 256x256 and 10 runtime images are 384x346; all targets have captured inventory metrics and no failures/skips</code> → pass; executed <code>CATALOG_THUMB_ONLY=&lt;ten VIS-006-BATCH-12 IDs&gt; CATALOG_THUMB_USE_MODULE_DEFAULTS=true STRICT_CATALOG_THUMBS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch12-defaults flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=10/10/0/0; all default image-health pass)</code> → pass; executed <code>CATALOG_THUMB_ONLY=&lt;ten VIS-006-BATCH-15 IDs&gt; CATALOG_THUMB_USE_MODULE_DEFAULTS=true STRICT_CATALOG_THUMBS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch15-defaults flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.arneodo,core.dadras,core.chen,core.lu_chen,core.halvorsen,core.scroll_waves,core.rikitake,core.aizawa,core.rabinovich_fabrikant,core.nose_hoover CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch11-defaults STRICT_CATALOG_THUMBS=true FORCE_GPU_RENDER=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=10/10/0/0; all default images 256x256; strict image-health pass)</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.buddhabrot_approx,core.anti_buddhabrot,core.nebulabrot,core.wolfram_rule30,core.rule90_linear_ca,core.rule150_linear_ca,core.cyclic_cellular_automaton,core.greenberg_hastings_ca,core.klausmeier_vegetation,core.gerhardt_schuster_tyson_ca CATALOG_THUMB_USE_MODULE_DEFAULTS=true STRICT_CATALOG_THUMBS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch19-defaults flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=10/10/0/0; all default image verdicts pass)</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.burning_ship CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-burning-ship-defaults STRICT_CATALOG_THUMBS=true FORCE_GPU_RENDER=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=1/1/0/0; 256x256; 1209 colors; blackPixelRatio=0.2008; math oracle pass)</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.druid,core.inverse_mandelbrot,core.glynn,core.simonbrot,core.shark_fin,core.manowar,core.spider,core.collatz,core.popcorn,core.talis CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch03-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=10/10/0/0; all ten GPU image metrics pass; no CPU oracles registered)</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.four_wing CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-four-wing-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=1/1/0/0; 256x256, 785 colors, blackPixelRatio=0.0, nonBlack=1.0, verdict pass; shader receives bailout=8; oracle skipped)</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.fractal_canopy,core.benesi,core.schottky_limit_set,core.henon,core.tinkerbell,core.gingerbreadman,core.lozi,core.duffing,core.ikeda,core.clifford CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch09-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=10/10/0/0; all 256x256 and strict image verdict pass; all math oracles skipped)</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.greek_cross_fractal,core.sierpinski_pentagon,core.hexaflake,core.pentaflake,core.cantor_dust,core.apollonian_gasket,core.ford_circles,core.steiner_chain,core.cesaro_fractal,core.cantor_set CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch08-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=10/10/0/0; strict render health pass)</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.greek_cross_fractal,core.sierpinski_pentagon,core.hexaflake,core.pentaflake,core.cantor_dust,core.apollonian_gasket,core.ford_circles,core.steiner_chain,core.cesaro_fractal,core.cantor_set CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch08-defaults-review STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.householder,core.zeta_newton,core.magnet_newton,core.hypercomplex_newton,core.quaternion_julia_2d,core.tessarine_julia,core.split_complex,core.dual_complex,core.bicomplex,core.sine_julia CATALOG_THUMB_USE_MODULE_DEFAULTS=true STRICT_CATALOG_THUMBS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch14-defaults flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.julia CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-julia-defaults STRICT_CATALOG_THUMBS=true FORCE_GPU_RENDER=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=1/1/0/0; 256x256; 2298 colors; verdict pass; Julia C=(-0.8,0.156), iterations=160, bailout=4.0; math oracle pass; render warmup 2092.344ms; capture 278.926ms)</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.julia_dual,core.phoenix,core.tricorn,core.celtic,core.buffalo,core.multibrot3,core.nova,core.nova_julia,core.fatou,core.gamma_fractal CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch01-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.koch_snowflake CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-koch-followup STRICT_CATALOG_THUMBS=true FORCE_GPU_RENDER=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.levy_c_curve,core.levy_tapestry,core.golden_dragon,core.twin_dragon,core.terdragon,core.chair_tiling,core.koch_anti_snowflake,core.quadratic_koch_island,core.cyclosorus_fern,core.menger_sponge_2d CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch06-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=10/10/0/0; each 256x256; all render verdicts pass; no reference math oracles)</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.log_spiral,core.lyapunov,core.logistic_lyapunov,core.circle_map_lyapunov,core.sine_map_lyapunov,core.tent_map,core.hopalong,core.pickover_biomorph,core.feigenbaum,core.gauss_map CATALOG_THUMB_USE_MODULE_DEFAULTS=true STRICT_CATALOG_THUMBS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch18-defaults flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.lorenz_2d CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-lorenz-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed=1/1/0; image 256x256, 641 colors, nonBlack=1.0)</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.mandelbrot CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-mandelbrot-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=1/1/0/0; 256x256; 941 colors; blackPixelRatio=0.1749; nonBlack=0.8251; verdict pass; math oracle pass)</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.perpendicular_julia,core.tricorn_julia,core.burning_ship_julia,core.multibrot_neg2,core.heart,core.cosine_mandelbrot,core.tangent_mandelbrot,core.sinh_mandelbrot,core.cosh_mandelbrot,core.tanh_mandelbrot CATALOG_THUMB_USE_MODULE_DEFAULTS=true STRICT_CATALOG_THUMBS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch17-defaults flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (10/10/0/0; all metrics pass; math oracle skipped 10)</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.perpendicular_julia,core.tricorn_julia,core.burning_ship_julia,core.multibrot_neg2,core.heart,core.cosine_mandelbrot,core.tangent_mandelbrot,core.sinh_mandelbrot,core.cosh_mandelbrot,core.tanh_mandelbrot CATALOG_THUMB_USE_MODULE_DEFAULTS=true STRICT_CATALOG_THUMBS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch17-defaults flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=10/10/0/0; all image health pass)</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.perpendicular_mandelbrot,core.lambda,core.magnet_type_1,core.magnet_type_2,core.magnet_type_3,core.power_sum,core.cactus,core.astroid,core.deltoid,core.eisenstein CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch02-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=10/10/0/0; 10/10 math oracle skipped for lack of stable known-point checks)</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.peter_de_jong,core.svensson,core.gumowski_mira,core.arnold_cat,core.standard_map,core.zaslavsky,core.kicked_rotator,core.chua_circuit,core.sprott_a,core.burke_shaw CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch10-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=10/10/0/0; all defaults 256x256; all strict metrics pass; reference oracles skipped)</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.rossler_2d CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-rossler-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=1/1/0/0; image 256x256, 1245 colors, blackPixelRatio=0.0, nonBlack=1.0, verdict pass; math oracle skipped: no reference oracle)</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.secant_cosecant,core.taylor,core.rational_map,core.lattes_map_julia,core.complex_henon_julia_slice,core.matrix_logistic_spectrum,core.barnsley_j2,core.barnsley_j3,core.celtic_julia,core.buffalo_julia CATALOG_THUMB_USE_MODULE_DEFAULTS=true STRICT_CATALOG_THUMBS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch16-defaults flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=10/10/0/0; all ten default image-health pass; reference math oracle skipped 10)</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.tetration,core.sierpinski_triangle,core.sierpinski_carpet,core.koch_snowflake,core.dragon_curve,core.barnsley_fern,core.pythagorean_tree,core.hilbert_curve,core.peano_curve,core.gosper_curve CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch04-defaults STRICT_CATALOG_THUMBS=false flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=10/10/0/0; all image-health verdicts pass)</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.tetration,core.sierpinski_triangle,core.sierpinski_carpet,core.koch_snowflake,core.dragon_curve,core.barnsley_fern,core.pythagorean_tree,core.hilbert_curve,core.peano_curve,core.gosper_curve CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch04-strict STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=10/9/1/0; Koch strict black-ratio threshold failure)</code> → fail; executed <code>CATALOG_THUMB_ONLY=core.thomas_attractor CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-thomas-attractor-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=1/1/0/0; 256x256, 979 colors, blackPixelRatio=0.0, nonBlack=1.0; verdict pass; no math oracle)</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.vicsek_fractal,core.penrose_tiling,core.fibonacci_word,core.rauzy_fractal,core.arnoux_rauzy_fractal,core.dual_substitution_tiling,core.bedford_mcmullen_carpet,core.self_affine_finite_type,core.pinwheel_tiling,core.z_order_curve CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch07-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (10/10/0/0; all defaults image verdict pass; math oracles skipped 10)</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.vicsek_fractal,core.penrose_tiling,core.fibonacci_word,core.rauzy_fractal,core.arnoux_rauzy_fractal,core.dual_substitution_tiling,core.bedford_mcmullen_carpet,core.self_affine_finite_type,core.pinwheel_tiling,core.z_order_curve CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch07-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded; FORCE_GPU_RENDER=true flutter test integration_test/catalog/vis006_batch07_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.yu_wang,core.zhou_chen,core.tsucs,core.rayleigh_benard,core.robinson,core.globo_toroid,core.tamari,core.wang_sun_cang,core.newton_z3,core.halley CATALOG_THUMB_USE_MODULE_DEFAULTS=true STRICT_CATALOG_THUMBS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch13-defaults flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=10/10/0/0)</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.yu_wang,core.zhou_chen,core.tsucs,core.rayleigh_benard,core.robinson,core.globo_toroid,core.tamari,core.wang_sun_cang,core.newton_z3,core.halley CATALOG_THUMB_USE_MODULE_DEFAULTS=true STRICT_CATALOG_THUMBS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch13-defaults flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=10/10/0/0)</code> → pass; executed <code>FORCE_GPU_RENDER=true FORCE_RUNTIME_CATALOG_THUMBNAILS=true flutter test integration_test/catalog/vis006_batch18_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded</code> → pass; executed <code>FORCE_GPU_RENDER=true flutter test integration_test/catalog/vis006_batch07_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (10/10 runtime previews pass; 384x346 metrics)</code> → pass; executed <code>FORCE_GPU_RENDER=true flutter test integration_test/catalog/vis006_batch08_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded</code> → pass; executed <code>FORCE_GPU_RENDER=true flutter test integration_test/catalog/vis006_batch11_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (10/10 actual runtime GPU previews; 384x346; all image-health verdicts pass)</code> → pass; executed <code>FORCE_GPU_RENDER=true flutter test integration_test/catalog/vis006_batch13_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (10/10 actual GPU previews pass; dimensions 384x346)</code> → pass; executed <code>FORCE_GPU_RENDER=true flutter test integration_test/catalog/vis006_batch14_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded</code> → pass; executed <code>FORCE_GPU_RENDER=true flutter test integration_test/catalog/vis006_julia_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (384x346; 1314 colors; blackPixelRatio=0.0; nonBlack=1.0; verdict pass; first_thumbnail_displayed=1909ms)</code> → pass; executed <code>FRESH 2026-10-06: CATALOG_THUMB_ONLY=core.four_wing CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-four-wing-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=1/1/0/0; 256x256, 785 colors, verdict pass)</code> → pass; executed <code>FRESH 2026-10-06: dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_four_wing_runtime_preview_test.dart (0 changed) &amp;&amp; flutter analyze integration_test/catalog/vis006_four_wing_runtime_preview_test.dart (no issues) &amp;&amp; python research/fractals-library/scripts/validate_visual_inventory.py (1027 Explore, 200 manifest; pass) &amp;&amp; git diff --check (pass)</code> → pass; executed <code>FRESH 2026-10-06: flutter test integration_test/catalog/vis006_four_wing_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (384x346; 481 colors; verdict pass)</code> → pass; executed <code>RenderMathOracle.evaluate in strict GPU report: all ten targets explicitly skipped because no reference oracle exists; cpu_formulas.dart registry inspection confirmed native _cpu_ implementations for all ten (not CPU correctness tests)</code> → pass; executed <code>STRICT batch04 GPU defaults capture selected=10 generated=9 failed=1 skipped=0; Koch blackPixelRatio=0.301254 exceeds threshold &lt;0.2; failure recorded and follow-up t_b2bbfadc created</code> → fail; executed <code>VIS-006 remaining-scope reconciliation after Thomas Attractor batch: mapped core Explore rows remain uncaptured; batch completes this module only</code> → fail; executed <code>VIS-006 scope closure check: requested all mapped Explore definitions and first-view behavior are not covered by this Four Wing-only batch</code> → fail; executed <code>dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch04_runtime_preview_test.dart &amp;&amp; flutter analyze integration_test/catalog/vis006_batch04_runtime_preview_test.dart &amp;&amp; python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; python -m json.tool docs/planning/visual-audit-inventory.json &gt; /dev/null &amp;&amp; git diff --check</code> → pass; executed <code>dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch04_runtime_preview_test.dart &amp;&amp; flutter analyze integration_test/catalog/vis006_batch04_runtime_preview_test.dart &amp;&amp; python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; python -m json.tool docs/planning/visual-audit-inventory.json &gt; /dev/null &amp;&amp; git diff --check (all pass)</code> → pass; executed <code>dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch06_runtime_preview_test.dart &amp;&amp; flutter analyze integration_test/catalog/vis006_batch06_runtime_preview_test.dart &amp;&amp; flutter test integration_test/catalog/vis006_batch06_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (10/10 actual runtime GPU previews pass; each 384x346; per-image metrics emitted)</code> → pass; executed <code>dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch07_runtime_preview_test.dart &amp;&amp; flutter analyze integration_test/catalog/vis006_batch07_runtime_preview_test.dart</code> → pass; executed <code>dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch09_runtime_preview_test.dart &amp;&amp; flutter analyze integration_test/catalog/vis006_batch09_runtime_preview_test.dart &amp;&amp; python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; python -m json.tool docs/planning/visual-audit-inventory.json &gt; /dev/null &amp;&amp; git diff --check</code> → pass; executed <code>dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch13_runtime_preview_test.dart &amp;&amp; flutter analyze integration_test/catalog/vis006_batch13_runtime_preview_test.dart &amp;&amp; python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; python -m json.tool docs/planning/visual-audit-inventory.json &gt; /dev/null &amp;&amp; git diff --check</code> → pass; executed <code>dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch13_runtime_preview_test.dart &amp;&amp; flutter analyze integration_test/catalog/vis006_batch13_runtime_preview_test.dart &amp;&amp; python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; python -m json.tool docs/planning/visual-audit-inventory.json &gt; /dev/null &amp;&amp; git diff --check HEAD</code> → pass; executed <code>dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch16_runtime_preview_test.dart &amp;&amp; flutter analyze integration_test/catalog/vis006_batch16_runtime_preview_test.dart</code> → pass; executed <code>dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch17_runtime_preview_test.dart &amp;&amp; flutter analyze integration_test/catalog/vis006_batch17_runtime_preview_test.dart &amp;&amp; flutter test integration_test/catalog/vis006_batch17_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (10 actual GPU runtime previews, 384x346, all metrics pass)</code> → pass; executed <code>dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch18_runtime_preview_test.dart &amp;&amp; flutter analyze integration_test/catalog/vis006_batch18_runtime_preview_test.dart &amp;&amp; python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; python ~/.hermes/shared-skills/repo-docs/scripts/goals.py validate . &amp;&amp; git diff --check</code> → pass; executed <code>dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch19_runtime_preview_test.dart &amp;&amp; flutter analyze integration_test/catalog/vis006_batch19_runtime_preview_test.dart &amp;&amp; python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; git diff --check</code> → pass; executed <code>dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_mandelbrot_runtime_preview_test.dart &amp;&amp; flutter analyze integration_test/catalog/vis006_mandelbrot_runtime_preview_test.dart &amp;&amp; python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; python -m json.tool docs/planning/visual-audit-inventory.json &amp;&amp; git diff --check (all passed)</code> → pass; executed <code>dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_thomas_attractor_runtime_preview_test.dart &amp;&amp; flutter analyze integration_test/catalog/vis006_thomas_attractor_runtime_preview_test.dart (formatted; no issues)</code> → pass; executed <code>dart format --output=none --set-exit-if-changed integration_test/flows/vis006_first_view_test.dart</code> → pass; executed <code>dart format --output=none --set-exit-if-changed integration_test/flows/vis006_first_view_test.dart &amp;&amp; flutter analyze integration_test/flows/vis006_first_view_test.dart &amp;&amp; flutter test integration_test/flows/vis006_first_view_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded</code> → pass; executed <code>dart format --output=none --set-exit-if-changed integration_test/flows/vis006_first_view_test.dart &amp;&amp; flutter analyze integration_test/flows/vis006_first_view_test.dart &amp;&amp; python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; python -m json.tool docs/planning/visual-audit-inventory.json &gt; /dev/null &amp;&amp; git diff --check</code> → pass; executed <code>dart format --output=none --set-exit-if-changed lib/core/modules/builders/escape_time_catalog/ifs_geometric_fractals.dart &amp;&amp; flutter analyze lib/core/modules/builders/escape_time_catalog/ifs_geometric_fractals.dart</code> → pass; executed <code>dart format --output=none --set-exit-if-changed lib/core/modules/common_params.dart test/modules/module_registry_widget_test.dart</code> → pass; executed <code>dart format integration_test/catalog/vis006_batch03_runtime_preview_test.dart --set-exit-if-changed &amp;&amp; flutter analyze integration_test/catalog/vis006_batch03_runtime_preview_test.dart &amp;&amp; git diff --check</code> → pass; executed <code>dart format integration_test/catalog/vis006_batch17_runtime_preview_test.dart &amp;&amp; flutter analyze integration_test/catalog/vis006_batch17_runtime_preview_test.dart &amp;&amp; flutter test integration_test/catalog/vis006_batch17_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (10/10 actual runtime GPU previews, all 384x346 and metric verdict pass)</code> → pass; executed <code>dart format integration_test/catalog/vis006_four_wing_runtime_preview_test.dart (Formatted 1 file; 0 changed)</code> → pass; executed <code>dart format integration_test/catalog/vis006_julia_runtime_preview_test.dart &amp;&amp; flutter analyze integration_test/catalog/vis006_julia_runtime_preview_test.dart &amp;&amp; python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; python -m json.tool docs/planning/visual-audit-inventory.json &amp;&amp; git diff --check (all passed)</code> → pass; executed <code>flutter analyze integration_test/catalog/vis006_four_wing_runtime_preview_test.dart (No issues found)</code> → pass; executed <code>flutter analyze integration_test/flows/vis006_first_view_test.dart</code> → pass; executed <code>flutter analyze lib/core/modules/common_params.dart test/modules/module_registry_widget_test.dart</code> → pass; executed <code>flutter test integration_test/catalog/vis006_batch01_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded</code> → pass; executed <code>flutter test integration_test/catalog/vis006_batch02_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (10/10 runtime GPU previews; 384x346; metrics captured; all verdicts pass)</code> → pass; executed <code>flutter test integration_test/catalog/vis006_batch03_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (ten runtime catalog previews; each image metric verdict pass)</code> → pass; executed <code>flutter test integration_test/catalog/vis006_batch04_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded</code> → pass; executed <code>flutter test integration_test/catalog/vis006_batch04_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (10/10 GPU runtime previews pass; 384x346)</code> → pass; executed <code>flutter test integration_test/catalog/vis006_batch04_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (10/10 runtime previews pass; 384x346 metrics)</code> → pass; executed <code>flutter test integration_test/catalog/vis006_batch08_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (10/10 GPU catalog previews; 384x346; all image verdicts pass)</code> → pass; executed <code>flutter test integration_test/catalog/vis006_batch09_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (10/10 actual GPU runtime previews pass; all 384x346)</code> → pass; executed <code>flutter test integration_test/catalog/vis006_batch10_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (10/10 actual runtime GPU previews; 384x346; all image-health verdicts pass)</code> → pass; executed <code>flutter test integration_test/catalog/vis006_batch12_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (10/10 actual runtime previews; all pass)</code> → pass; executed <code>flutter test integration_test/catalog/vis006_batch13_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded</code> → pass; executed <code>flutter test integration_test/catalog/vis006_batch15_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded</code> → pass; executed <code>flutter test integration_test/catalog/vis006_batch16_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (10/10 actual runtime GPU previews pass; each 384x346; per-image metrics emitted)</code> → pass; executed <code>flutter test integration_test/catalog/vis006_batch19_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded</code> → pass; executed <code>flutter test integration_test/catalog/vis006_batch19_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (10/10 actual runtime GPU previews, 384x346; all image verdicts pass)</code> → pass; executed <code>flutter test integration_test/catalog/vis006_burning_ship_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (384x346; 1063 colors; blackPixelRatio=0.2151; verdict pass)</code> → pass; executed <code>flutter test integration_test/catalog/vis006_four_wing_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (core.four_wing runtime preview 384x346; 481 colors, blackPixelRatio=0.0, nonBlack=1.0, verdict pass)</code> → pass; executed <code>flutter test integration_test/catalog/vis006_julia_dual_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded</code> → pass; executed <code>flutter test integration_test/catalog/vis006_lorenz_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (runtime catalog preview 384x346; 3008 colors; nonBlack=1.0)</code> → pass; executed <code>flutter test integration_test/catalog/vis006_mandelbrot_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (384x346; 603 colors; blackPixelRatio=0.1772; nonBlack=0.8228; verdict pass)</code> → pass; executed <code>flutter test integration_test/catalog/vis006_rossler_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (runtime catalog preview 384x346; 421 colors; blackPixelRatio=0.0; nonBlack=1.0; verdict pass)</code> → pass; executed <code>flutter test integration_test/catalog/vis006_thomas_attractor_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (384x346; 876 colors; blackPixelRatio=0.0; nonBlack=1.0; verdict pass)</code> → pass; executed <code>flutter test integration_test/flows/vis006_first_view_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded</code> → pass; executed <code>flutter test integration_test/flows/vis006_first_view_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (15/15 pass; five target modules logged gpu_first_frame backend=gpu and matched module default preset)</code> → pass; executed <code>flutter test integration_test/flows/vis006_first_view_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (5/5 GPU first frames; each controller module, params, pan and zoom matched module default preset)</code> → pass; executed <code>flutter test integration_test/flows/vis006_first_view_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (observed gpu_first_frame modules=fatou,gamma_fractal,lambda,nova_julia,perpendicular_mandelbrot; backend=gpu; default params/view matched; 10/10 total passed)</code> → pass; executed <code>flutter test test/cpu/cpu_formula_coverage_test.dart --reporter expanded (4 tests passed; CPU formula registry coverage; no independent correctness claim)</code> → pass; executed <code>flutter test test/cpu/cpu_formula_coverage_test.dart --reporter expanded (4 tests passed; confirms data-driven CPU approximation coverage, not native Thomas ODE correctness)</code> → pass; executed <code>flutter test test/cpu/cpu_formula_coverage_test.dart --reporter expanded (4 tests passed; registry/finite-color coverage, not independent mathematical correctness)</code> → pass; executed <code>flutter test test/cpu/cpu_formula_coverage_test.dart --reporter expanded (4 tests passed; resolves each escape-time catalog module and verifies finite CPU color output, including native formulas in this batch)</code> → pass; executed <code>flutter test test/modules/module_registry_widget_test.dart --plain-name 'Rossler bailout schema preserves configured default'</code> → pass; executed <code>git diff --check</code> → pass; executed <code>inventory reconciliation: prior VIS-006 captures occupy Explore rows 0–72; this task scope occupies the next ten source-ordered rows 73–82; all ten referenced shader assets exist</code> → pass; executed <code>python - batch17 report/artifact/inventory reconciliation (10 target rows captured; selected/generated/failed/skipped=10/10/0/0; ten 384x346 runtime PNGs; next uncaptured order advances to core.log_spiral, core.lyapunov, core.logistic_lyapunov) &amp;&amp; python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; python -m json.tool docs/planning/visual-audit-inventory.json &gt;/dev/null &amp;&amp; python ~/.hermes/shared-skills/repo-docs/scripts/goals.py validate . &amp;&amp; git diff --check</code> → pass; executed <code>python -c "import json; d=json.load(open('docs/planning/visual-audit-inventory.json')); r=d['rows']; x=[i for i in r if i.get('source')=='Explore' and i.get('group')=='core']; captured=[i for i in x if i.get('runtime_preview','').startswith('captured in VIS-006:') or i.get('runtime_preview','').startswith('captured in VIS-006 ')]; print(f'Explore core rows={len(x)}; captured entries={len(captured)}; remaining={len(x)-len(captured)}'); assert len(captured)==len(x), 'VIS-006 has remaining mapped entries'" (exit 1: 1027 Explore core rows; 3 captured; 1024 remaining)</code> → fail; executed <code>python -m json.tool docs/planning/visual-audit-inventory.json &gt; /dev/null</code> → pass; executed <code>python -m json.tool docs/planning/visual-audit-inventory.json &gt;/dev/null</code> → pass; executed <code>python /home/xel/.hermes/shared-skills/repo-docs/scripts/goals.py fmt . &amp;&amp; python /home/xel/.hermes/shared-skills/repo-docs/scripts/goals.py validate . &amp;&amp; python /home/xel/.hermes/shared-skills/repo-docs/scripts/goals.py render . &amp;&amp; python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; python -m json.tool docs/planning/visual-audit-inventory.json &gt;/dev/null &amp;&amp; git diff --check HEAD</code> → pass; executed <code>python VIS-006-BATCH-08 reconciliation assertion: exact ten IDs and order, shader assets, per-ID inventory records, default report 10/10/0/0, ten runtime PNGs</code> → pass; executed <code>python batch17 reconciliation: source-order exact target IDs, 10 shader paths exist, defaults report and runtime PNG count 10 each, inventory rows captured</code> → pass; executed <code>python research/fractals-library/scripts/validate_visual_inventory.py</code> → pass; executed <code>python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch10_runtime_preview_test.dart &amp;&amp; flutter analyze integration_test/catalog/vis006_batch10_runtime_preview_test.dart &amp;&amp; python -m json.tool docs/planning/visual-audit-inventory.json &gt; /dev/null &amp;&amp; git diff --check</code> → pass; executed <code>python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; flutter test test/catalog/catalog_id_integrity_test.dart --reporter expanded</code> → pass; executed <code>python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; python -c "verify ten VIS-006-BATCH-01 cpu_formula fields against cpu_formulas.dart registry and assert 9 native formulas plus julia_dual absent"</code> → pass; executed <code>python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; python -m json.tool docs/planning/visual-audit-inventory.json &gt; /dev/null &amp;&amp; dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_burning_ship_runtime_preview_test.dart &amp;&amp; flutter analyze integration_test/catalog/vis006_burning_ship_runtime_preview_test.dart &amp;&amp; git diff --check</code> → pass; executed <code>python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; python -m json.tool docs/planning/visual-audit-inventory.json &gt; /dev/null &amp;&amp; git diff --check</code> → pass; executed <code>python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; python -m json.tool docs/planning/visual-audit-inventory.json &gt; /dev/null &amp;&amp; git diff --check &amp;&amp; python inventory-count assertion</code> → pass; executed <code>python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; python -m json.tool docs/planning/visual-audit-inventory.json &gt; /dev/null &amp;&amp; git diff --check (1227 rows; pass)</code> → pass; executed <code>python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; python -m json.tool docs/planning/visual-audit-inventory.json &gt;/dev/null &amp;&amp; batch16 artifact/inventory reconciliation assertion &amp;&amp; git diff --check</code> → pass; executed <code>python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; python -m json.tool docs/planning/visual-audit-inventory.json &gt;/dev/null &amp;&amp; dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch08_runtime_preview_test.dart &amp;&amp; flutter analyze integration_test/catalog/vis006_batch08_runtime_preview_test.dart &amp;&amp; git diff --check</code> → pass; executed <code>python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; python -m json.tool docs/planning/visual-audit-inventory.json &gt;/dev/null &amp;&amp; dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch11_runtime_preview_test.dart &amp;&amp; flutter analyze integration_test/catalog/vis006_batch11_runtime_preview_test.dart &amp;&amp; git diff --check</code> → pass; executed <code>python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; python -m json.tool docs/planning/visual-audit-inventory.json &gt;/dev/null &amp;&amp; dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch14_runtime_preview_test.dart &amp;&amp; flutter analyze integration_test/catalog/vis006_batch14_runtime_preview_test.dart &amp;&amp; git diff --check</code> → pass; executed <code>python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; python -m json.tool docs/planning/visual-audit-inventory.json &gt;/dev/null &amp;&amp; dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch19_runtime_preview_test.dart &amp;&amp; flutter analyze integration_test/catalog/vis006_batch19_runtime_preview_test.dart &amp;&amp; git diff --check</code> → pass; executed <code>python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; python -m json.tool docs/planning/visual-audit-inventory.json &gt;/dev/null &amp;&amp; git diff --check</code> → pass; executed <code>python research/fractals-library/scripts/validate_visual_inventory.py (OK: 1027 Explore IDs + 200 manifest IDs; 1227 unique rows)</code> → pass; executed <code>python ~/.hermes/shared-skills/repo-docs/scripts/goals.py validate .</code> → pass; executed <code>python3 VIS-006-BATCH-01 report/inventory/path reconciliation assertion</code> → pass; executed <code>visual inventory JSON candidate integrity and source-order assertion for the five first-view rows</code> → pass; inspection <code>Inspected default and actual runtime-preview PNGs for core.four_wing: both are smooth broad color gradients with sharp sector/wedge boundaries, not a recognizable four-wing orbit; preserve formula pending follow-up</code> → fail; inspection <code>Lorenz captures show a narrow diagonal band over a smooth gradient rather than a recognizable two-lobed silhouette; visual follow-up warranted, formula preserved</code> → fail; inspection <code>Rossler defaults/runtime captures are mostly smooth gradients with a sharp triangular boundary rather than a recognizable orbit; additionally configured bailout=12 is normalized to 8 by shared parameter max=8 before shader uniform mapping; visual/default follow-up warranted, formula preserved</code> → fail; inspection <code>TODO.md#VIS-006: broad batch audit remains to be completed; Lorenz batch only captured</code> → fail; inspection <code>docs/planning/visual-audit-inventory.json: only 7 of 1,027 Explore rows have capture records; 200 manifest rows are missing_app_renderer; no first_viewer field exists; cpu_formula is not audited in 1,224 rows and three rows have limited caveats</code> → fail; inspection <code>shaders/ifs_and_geometric/koch_snowflake_gpu.frag:102-105: edge below 0.02 returns opaque black; observed strict default blackPixelRatio=0.301254 above harness threshold &lt;0.2. No shader/default alteration authorized.</code> → fail | VIS-006-BATCH-20-LIVE, VIS-006-LIVE |
| SMOOTH-001: Prove smooth-coloring coverage for supported escape-time shaders | partial | executed <code>dart format --output=none --set-exit-if-changed test/shaders/smooth_coloring_family_coverage_test.dart</code> → pass; executed <code>dart format --output=none --set-exit-if-changed test/shaders/smooth_coloring_family_coverage_test.dart &amp;&amp; flutter analyze test/shaders/smooth_coloring_family_coverage_test.dart &amp;&amp; flutter test test/shaders/smooth_coloring_family_coverage_test.dart test/shaders/smooth_coloring_regression_test.dart test/shaders/escape_time_perturb_smooth_coloring_test.dart test/shaders/mcmullen_map_smooth_coloring_test.dart &amp;&amp; git diff --check</code> → pass; executed <code>dart format test/shaders/smooth_coloring_family_coverage_test.dart &amp;&amp; dart format --output=none --set-exit-if-changed test/shaders/smooth_coloring_family_coverage_test.dart &amp;&amp; flutter analyze test/shaders/smooth_coloring_family_coverage_test.dart &amp;&amp; flutter test test/shaders/smooth_coloring_family_coverage_test.dart test/shaders/smooth_coloring_regression_test.dart test/shaders/escape_time_perturb_smooth_coloring_test.dart test/shaders/mcmullen_map_smooth_coloring_test.dart &amp;&amp; git diff --check</code> → pass; executed <code>flutter analyze test/shaders/smooth_coloring_family_coverage_test.dart</code> → pass; executed <code>flutter test test/shaders/smooth_coloring_family_coverage_test.dart</code> → pass; executed <code>flutter test test/shaders/smooth_coloring_family_coverage_test.dart test/shaders/smooth_coloring_regression_test.dart --reporter expanded</code> → pass; executed <code>flutter test test/shaders/smooth_coloring_family_coverage_test.dart test/shaders/smooth_coloring_regression_test.dart test/shaders/escape_time_perturb_smooth_coloring_test.dart test/shaders/mcmullen_map_smooth_coloring_test.dart</code> → pass; executed <code>git diff --check</code> → pass; executed <code>python3 -c 'from pathlib import Path; p="shaders/escape_time_family/families/multibrot/integer_powers/multibrot4_gpu.frag"; assert Path(p).is_file(); assert p in Path("test/shaders/smooth_coloring_family_coverage_test.dart").read_text(), "SMOOTH-001 incomplete: supported Multibrot d=4 is absent from the family coverage test"'</code> → fail; inspection <code>TODO.md#P1-3: four families (7 shaders) covered; complete applicable polynomial escape-time inventory remains open</code> → fail; inspection <code>docs/engineering/performance/SHADER_OPTIMIZATIONS.md</code> → pass | SMOOTH-001-INVENTORY-01-LIVE, SMOOTH-001-INVENTORY-02-LIVE |
| MEDIA-002: Select launch hero stills from qualified captures | unmet | inspection <code>TODO.md#MEDIA-002: owner selection remains open</code> → fail | MEDIA-002 |
| VIS-003: Obtain app icon visual sign-off | unmet | inspection <code>TODO.md#VIS-003: owner sign-off remains open</code> → fail | ICON-ZJ-02, VIS-003 |
| DOC-PRD-001: Resolve which documents own active product scope | met | executed <code>python3 "$HERMES_PROFILE/cache/scratch/repo-interview-release-20261011/check_interview_docs.py" "$REPO" (interview documentation/ledger only)</code> → pass; inspection <code>BLOCKERS.md#BLK-20261005-004: conflicting scope statements require owner decision</code> → fail | — |
| REL-JOURNEY-001: Qualify the complete image-creation journey on Android, web and Linux | unverified | inspection <code>PRD.md#active-release-contract: owner accepted the cross-platform journey; complete platform qualification remains unverified</code> → pass | EXPORT-001-f3, REL-JOURNEY-02-LINUX-LIVE, REL-JOURNEY-03-ANDROID-LIVE, RELEASE-001-23-LIVE, RELEASE-002-75, RELEASE-003-ae |
| GAUSS-MOAT-001: Explore exact bounded Gaussian-prime walks with responsive controls and truthful reachability | unmet | executed <code>GAUSS-MOAT-01-MAP manual integration: git apply --check approved-owned.patch on main 7ede12424e6787ad9a514b8cdc9c37f509286b5f failed; three-way recovery leaves spec.md/test-plan.md conflicted because planning prerequisite is absent. Code-only diagnostic 171 tests/analyzer/format pass, not coherent integration qualification. Receipt /home/xel/.hermes/profiles/fractal/autowork/gaussian-moat-map/manual-integration-20261012/receipt.json</code> → fail; executed <code>GAUSS-MOAT-01-MAP offline/local integration only: python3 /home/xel/.hermes/profiles/fractal/autowork/gaussian-moat-map/coherent-continuation-20261012/run-frozen-gate.py at 79ae96506af162cc3f0f2392b631c5bf7229b333; 171 focused tests, analyzer, 8-file format, gen-l10n/source stability, docs/scope/diff pass; independent integration source review approved; git merge --ff-only and exact main/tree/15-path readback pass. No live/platform/milestone qualification.</code> → pass | GAUSS-MOAT-02-WALK-LIVE, GAUSS-MOAT-03-QUALIFY-LIVE, GAUSS-MOAT-04-GROWTH-LIVE |
| QUAT-NORM-001: Explore exact prime-norm quaternion slice walks with camera-independent connectivity | unmet | — | QUAT-NORM-01-SLICE-LIVE, QUAT-NORM-02-WALK-LIVE, QUAT-NORM-03-QUALIFY-LIVE |
| CAT-QUALITY-001: Improve catalog first-impression quality without losing variety or saved identities | unverified | — | CAT-QUALITY-01-LIVE, CAT-QUALITY-02-LIVE, CAT-QUALITY-03 |
| VIEW-UI-001: Reduce intrusive viewer navigation chrome and style overflow consistently | unverified | — | VIEW-UI-01-LIVE, VIEW-UI-02-LIVE |
| OAI-VIS-001: Select a mathematically distinct quality-gated visual candidate from OpenAI math | unverified | — | OAI-VIS-01-IFS, OAI-VIS-02-SLE, OAI-VIS-03-VORONOI, OAI-VIS-04-UST, OAI-VIS-05-DIMER, OAI-VIS-06-HEIGHT, OAI-VIS-07-FK |
| NUM-WALL-001: Explore exact modular number walls with custom primes and matching artwork export | unverified | — | NUM-WALL-02, NUM-WALL-03, NUM-WALL-04, NUM-WALL-05 |
| ACAD-001: Build a traceable academic source-to-mathematics library across all catalog identities | unverified | — | ACAD-007-f8, ACAD-01-LIVE, ACAD-02-LIVE, ACAD-03, ACAD-04 |
| APP-QUALITY-001: Improve app architecture and UI with evidence-backed Flutter MCP tooling | unverified | — | ACAD-008-74, APP-001-47, APP-002-e0, APP-003-f7, APP-004-cc, APP-005-7f |
| SINE-WARP-001: Add a source-attributed recursive sine-warped sphere with matching export | unverified | — | SINEWARP-001-aa, SINEWARP-002-47 |

<!-- goals:coverage:end -->

---

## Architecture Direction (decided 2026-02-15, reaffirmed 2026-04-05)

**GPU-primary, CPU safety net.**
- GPU is the default renderer; many catalog modules share reviewed shader families rather than one shader per fractal
- Live registry lock: 543 escape-time catalog entries, 38 raymarched-3D entries, 9 custom hand-built modules, 1020 production fractals plus 1 scientific visualization (1028 debug/test `ModuleRegistry` modules including 7 diagnostics)
- CPU fallback auto-activates via renderer health/precision policy when GPU output or precision is invalid
- CPU path is maintenance-only (no further performance investment)
- GPU investment: coloring quality, smooth iteration, deep zoom, new formulas

---

## Perturbation Theory — Realistic Capability Assessment

**IMPORTANT:** Perturbation theory CANNOT be applied to all fractals. This section clarifies what's achievable.

### ✅ Perturbation Theory WORKS For (Polynomial Escape-Time)

These fractals use differentiable formulas where `dz_next = f(z+dz, c+dc) - f(z,c)` can be computed:

| Category | Fractals | Count | Status |
|----------|----------|-------|--------|
| Core Mandelbrot family | mandelbrot, multibrot variants | ~20 | 🔶 Mandelbrot uses DF2 path; multibrot3/4/5 perturbation implemented |
| Julia variants | julia, celtic_julia, buffalo_julia, etc. | ~30 | 🔶 Core `julia` perturbation implemented; variants remain open |
| Burning Ship variants | burning_ship, burning_ship_cubic, etc. | ~10 | 🔶 `burning_ship` implemented; variants remain open |
| Phoenix variants | phoenix, phoenix_julia | ~4 | 🔶 `phoenix` implemented; variants remain open |
| Buffalo/Tricorn/Celtic | buffalo, tricorn, celtic | ~6 | ✅ Implemented for core IDs |

**Current shipped GPU perturbation path:** `julia`, `burning_ship`, `buffalo`, `tricorn`, `celtic`, `phoenix`, `multibrot3`, `multibrot4`, `multibrot5`.
**Total achievable with perturbation: ~70-80 fractals**

### ❌ Perturbation Theory DOES NOT Work For

| Category | Reason | Examples |
|----------|--------|----------|
| IFS/Geometric | Uses iterated function systems, not escape-time | Sierpinski, Koch, Barnsley Fern |
| Strange Attractors | Continuous dynamics, not complex iteration | Lorenz, Rossler, Clifford |
| Cellular Automata | Discrete grid-based, not complex plane | Rule 30, Brian's Brain |
| Root-Finding fractals | Newton/Halley method, different algorithm | Newton z³-1, Halley |
| Stochastic | Random sampling, not deterministic | Buddhabrot, DLA |
| Tilings | Substitution rules, not iteration | Penrose, Ammann-Beenker |

**Most of the 1020-production-fractal catalog is still NOT suitable for perturbation; exact category counts need a fresh catalog audit.**

### 📊 Module Registry Breakdown (1020 production fractals; 1028 debug/test modules)

```
Live locks from test/catalog/catalog_id_integrity_test.dart:
├── Escape-time catalog raw unique IDs: 543
├── Raymarched-3D catalog IDs: 38
├── Custom hand-built modules: 9
├── Production fractals: 1020
├── Scientific visualizations: 1
└── Debug/test ModuleRegistry modules including diagnostics: 1028

Perturbation-capable target remains ~70-80 polynomial escape-time fractals.
Currently routed to GPU perturbation: 9 IDs (julia + 8 generic escape-time IDs).
Older 370-count planning rows are retired.
```

---

## P0 — MUST SHIP NEXT

**All open (unchecked) items in this section remain P0 until resolved.**

### P0-1: Critical Render Regressions

- Done: **GPU artifact at z≈5.10e+6** — Color blocks/grid artifacts appear despite perturbation shader ✅ FIXED 2026-04-05
  - **Root cause:** Delta overflow check in `escape_time_perturb_gpu.frag:165` used threshold `1e6` which was too aggressive
  - **Fix:** Changed threshold from `1e6` to `1e12` to avoid false triggers at deep zoom
  - **Verified:** All 350 fractals render correctly (fractal_render_audit_test.dart passed)

- [x] **FractalViewControls parameter mismatch** ✅ FIXED 2026-04-05
  - **Issue:** `fractal_viewer_screen.dart` called `FractalViewControls` with old parameter names
  - **Fix:** Updated to match current widget signature (`onOpenMoreActions` → removed, `onEnterFullscreen` → `onToggleFullscreen`)

- [x] **KIFS Menger Sponge stuck on "Loading shaders..."** — 3D fractal not loading ✅ FIXED 2026-04-05
  - **Root cause:** SkSL compiler doesn't support `%` operator on integers or `clamp(int, int, int)`
  - **Fix:** Replaced with integer-division modulo trick and `float(clamp(float(...)))` pattern
  - **Files fixed:** `shaders/quaternion_julia_2d_gpu.frag`, `shaders/menger_sponge_gpu.frag`, `shaders/menger_3d_slice_gpu.frag`
  - **Verified:** All 14 3D shaders compile successfully (shader_3d_diagnostic_test.dart passed)

- [x] **All 3D fractals broken** — Raymarching not working ✅ FIXED 2026-04-05
  - **Root cause:** Same SkSL incompatibility issues in 3D fractal shaders
  - **Fix:** Applied SkSL-compatible replacements to all affected 3D shaders
  - **Verified:** Build succeeds, all tests pass (864+ passed)

### P0-2: User-Reported Blockers (2026-02-25)

- [x] GPU→CPU fallback too slow when zooming deep; reduce hysteresis/threshold so CPU engages faster
- Done: **Controls too big/too intrusive** — Redesign for smaller, less cluttered UI ✅ 2026-06-06
  - Replaced modal bottom sheet (38% screen height) with semi-transparent HUD overlay
  - Game-like glass-morphism HUD with compact sliders, palette chips, and action buttons
  - Tap-outside-to-dismiss behavior (like game HUD)
  - Fractal visible and updating behind controls
  - New: `fractal_controls_hud.dart` overlay widget
  - Changed: viewer FAB toggles overlay instead of opening modal
  - Tests: 5 new HUD tests + all 18 existing controls tests pass
- Done: **3D fractals not working** — Investigate 3D pipeline/shaders and fix ✅ FIXED 2026-04-05
  - **Root cause:** SkSL `%` and `clamp(int, int, int)` not supported
  - **Fix:** See P0-1 items above
- **App icon visual sign-off** — adaptive launcher and store-art inputs exist; visual presentation acceptance remains open (details in Launch Visual Audit Handoff below).
- [x] **Improve catalog thumbnails** — Larger view size, higher-quality renders ✅ 2026-08-29
  - Raised bounded capture/decode width to 384 px with high-quality filtering
  - Increased thumbnail detail caps to 24 web / 40 native iterations and 24 colors
  - Added layout-aware cache keys so portrait grids never reuse square captures
- [ ] **Visual playtest audit** — cover both Explore groups and all 200 research-library definitions. Check true module defaults, runtime previews, and first viewer renders. Run CPU checks where a native CPU formula exists. Preserve formulas and log failures. The broad audit remains partial: the inventory now records captures for 187 of 1,028 Explore IDs (841 remain uncaptured), and all 200 research definitions have no app renderer. First-view evidence is recorded for 14 Explore rows; CPU formula coverage remains partial. See `VIS-005` and `VIS-006` below.

### Visual Fidelity Audit — current queue

#### Now


  - [x] **VIS-006-BATCH-18 — Capture defaults and runtime previews for the next ten uncaptured Explore modules.** Strict forced-GPU module-default captures reconciled selected/generated/failed/skipped as 10/10/0/0; all ten default images passed image health. In-app runtime GPU previews passed 10/10 at 384x346. Per-ID paths, defaults, and actual image metrics are recorded in `docs/planning/visual-audit-inventory.json`; mathematical oracles are skipped because no reference oracle is registered. Defaults: `build/test_output/vis006-batch18-defaults/`; runtime previews: `build/test_output/vis006-batch18/`; test: `integration_test/catalog/vis006_batch18_runtime_preview_test.dart`. No formulas or defaults changed.
  - [x] **VIS-006-BATCH-14 — Capture defaults and runtime previews for the next ten uncaptured Explore modules.** Strict forced-GPU module-default captures reconciled selected/generated/failed/skipped as 10/10/0/0; all ten default images are 256x256 with strict image-health pass. Actual runtime catalog GPU previews passed 10/10 at 384x346. Per-ID artifacts, image metrics, shader references, and native CPU formula registration (correctness NOT_CHECKED; no formula for Zeta Newton) are recorded in `docs/planning/visual-audit-inventory.json`. The ten math oracles are NOT_CHECKED because no stable reference oracle is registered. Default artifacts: `build/test_output/vis006-batch14-defaults/`; runtime previews: `build/test_output/vis006-batch14/`; test: `integration_test/catalog/vis006_batch14_runtime_preview_test.dart`. No formulas or defaults changed.

- [x] **Initial seven-module GPU batch (historical VIS-006 evidence).** Captures or runtime previews are recorded for `core.burning_ship`, `core.four_wing`, `core.julia`, `core.lorenz_2d`, `core.mandelbrot`, `core.rossler_2d`, and `core.thomas_attractor`. Visual findings for Four-Wing, Lorenz, Rössler, and Thomas remain follow-ups; this batch does not complete the broader goal. See `goals.json` and the inventory artifact references.

- Done: GPU deep zoom not switching to CPU at all; adjust fallback thresholds/hysteresis
- [x] **Panning bugs at high zoom** — Fixed 2026-08-12 by migrating
  camera/render vectors from Float32-backed `vector_math` to
  `vector_math_64`; verified at `1e12` zoom and from viewport-edge gestures
  (`fractal_view_state_test.dart`, `fractal_renderer_gesture_test.dart`)
- [x] **Auto-zoom not continuous** — fixed: zero-dwell transitions between zoom legs; elapsed-time animation, speed changes, and interruption/resume are covered by auto-explore service/planner tests ✅ verified 2026-10-03
  - **Verified:** `flutter test test/features/auto_explore/auto_explore_service_test.dart test/features/auto_explore/auto_explore_zoom_planner_test.dart` (48 tests passed)

## Launch Visual Audit Handoff

Canonical plan: [`docs/planning/visual-fidelity-audit-next.md`](docs/planning/visual-fidelity-audit-next.md). The thumbnail decision is resolved: 320×320 launch-set thumbnail media outputs, no static catalog thumbnail bundle; 256×256 staged smoke is allowed. High-resolution hero stills remain a separate configurable output.

### Now

None: the current Featured Launch Set Chromium smoke and 320×320 GPU capture gates are complete. Remaining launch-media selection and icon visual sign-off require product-owner judgment.

### Blocked / Needs decision



### Done

## Documentation scope questions

Framework research (2026-10-17): [Kotlin Multiplatform versus Flutter assessment](research/kotlin-multiplatform-assessment.md). Recommendation: retain Flutter for the current Android/web/Linux product; direct Android integration and shared Kotlin logic are potential KMP advantages, but shader portability, saved-state compatibility and web qualification make a full rewrite unproven. Open decision: whether a measured framework limitation warrants a bounded comparison experiment. No migration, experiment, new dependencies, implementation or scheduling is authorized; preserve the existing task order and focus.

### Blocked / Needs decision


### P0-3: Dynamic Iteration Adjustment

- [x] Increase max iteration slider beyond 500 (now 5000)
- [x] Automatically raise iteration count when zooming in (adaptive step-up)
- [x] Adaptive logic: start low, progressively increase based on zoom growth
- [x] Convergence detection: compare previous frame, stop when changes < threshold
- [x] Works on both GPU and CPU fallback paths

---

## P1 — HIGH PRIORITY (Deep Zoom & GPU Quality)

### P1-1: Perturbation Theory Improvements

#### P1-0: Escape-Time Shader SkSL Fix (COMPLETED 2026-04-05)
- [x] **Escape-time shader GPU compilation fix** — 204 shaders had SkSL-incompatible `%` operator
  - **Root cause:** SkSL doesn't support `%` (modulo) operator on integers
  - **Fix:** Replaced `x % N` with `x - (x / N) * N` across all affected shaders
  - **Files fixed:** All shaders with `(schemeInt - 50) % 4` palette cycling
  - **Verified:** `buffalo_gpu.frag` now compiles on GPU (previously failed)
  - **Impact:** All escape-time fractals now render correctly on GPU instead of falling back to CPU

#### P1-1a: Fix Perturbation Artifact Bug (COMPLETED 2026-04-05)

- [x] Raised perturbation overflow threshold from `1e6` to `1e12` in `shaders/escape_time_family/core/escape_time_perturb_gpu.frag`
- [ ] Follow-up only if artifacts recur: replace discontinuous fallback with smoother reference-orbit transition

#### P1-1b: Extend Perturbation to Julia Variants

**Target Fractals (Priority Order):**
- [x] `julia` - core Julia (2026-07-02: flat-render bug fixed; unified into
  escape-time wrapper via julia mode, `julia_perturb_module.dart` deleted)
- [x] `celtic_julia`, `buffalo_julia`, `burning_ship_julia`, `tricorn_julia`
  (2026-07-02: julia-mode flag reusing base deltas)
- [x] 26 preset-c julias (`f0143`-`f0176` series) routed as z²+c julia mode
- [ ] `phoenix_julia`, cubic/power/trig/perpendicular variants — need new
  shader deltas; deferred (see spec Out of scope)

**Implementation:**
- Julia variants use `uExtra2` shader flag: `dz0 = pixel offset`, `dc = 0`
- Each variant reuses its base formula's existing delta function (no new deltas)
- All julia variants now routed through unified `escape_time_perturb_module`
- `kJuliaVariantSpecs` table maps catalog IDs to (base formula, fixed c)
- F-series preset julias read `juliaCReal`/`juliaCImag` from module params

**Files:**
- `lib/core/modules/escape_time_perturb_module.dart` (unified wrapper + variant table)
- `shaders/escape_time_family/core/escape_time_perturb_gpu.frag` (julia mode flag)
- `lib/features/renderer/policy/precision_ladder_policy.dart` (routing gate)
- `lib/features/renderer/policy/render_plan.dart` (resolver simplification)
- Deleted: `lib/core/modules/julia_perturb_module.dart`

#### P1-1c: Add Period Detection for Reference Orbit (COMPLETED 2026-07-02)

- [x] **Period detection shipped** in `computeEscapeTimePerturbOrbitBytes`
  (`lib/core/modules/escape_time_perturb_module.dart`)
  - Detects approximate cycles (eps 1e-9, max period 64) with a
    consecutive-pair confirmation so Phoenix's `(z, z_prev)` state is safe
  - On detection, stops iterating and fills the orbit texture tail by
    repeating the cycle bytes (byte-identical for exact cycles, ≤1 LSB for
    attracting cycles)
  - Orbit computation extracted to a pure, GPU-free testable function
  - **Verified:** `test/perturb_orbit_period_test.dart` (exact 1- and
    2-cycles byte-identical vs full iteration; chaotic center has no false
    positives; escaping center unchanged)

- [x] **Julia orbit encoding bug fixed 2026-07-02** — `julia_perturb_module.dart`
  still used the old 16-bit packing that mismatched the shader's 24-bit decode,
  degrading the Julia reference orbit to ~8 effective bits (decode error
  ~1.7e-2 vs intended ~4.8e-7). Now delegates to `packPerturbOrbitComponent`.
  **Verified:** `test/julia_perturb_orbit_encoding_test.dart`

### P1-2: Series Approximation (Deep Zoom Speedup)

**What it does:** Precompute early iterations as polynomial series, skip actual iteration when safe.

**Performance gain:** 10x-100x speedup at extreme zoom.

#### P1-2a: Series Approximation on GPU

**Implementation Approach:**
```glsl
// Add to escape_time_perturb_gpu.frag
uniform sampler2D uSeriesCoeffs;  // Texture with precomputed coefficients
uniform int uSeriesLength;         // Number of terms

vec2 computeSeries(vec2 dc, int n) {
    // Evaluate polynomial using Horner's method
    // Z_n ≈ sum_{k=0}^{N} a_k * dc^k
}

void main() {
    // ...
    for (int n = 0; n < MAX_ITERS; n++) {
        if (n < uSeriesLength && dc_magnitude_small) {
            Z_n = computeSeries(dc, n);  // Skip iteration
        } else {
            Z_n = fetchOrbit(n) + deltaIterate(n, dc);  // Full perturbation
        }
    }
}
```

**Files to Create:**
- `lib/core/modules/series_approximation.dart` — Coefficient computation

**Files to Modify:**
- `shaders/escape_time_perturb_gpu.frag`
- `lib/core/modules/escape_time_perturb_module.dart`

#### P1-2b: Series Approximation on CPU

**Implementation:**
```dart
// Compute series coefficients during reference orbit calculation
List<Complex> computeSeriesCoefficients(Complex c, int terms) {
    // a_0 = 0
    // a_1 = 1 (for Mandelbrot)
    // a_2 = 2*z_1
    // a_3 = 2*z_2 + 2*z_1^2
    // ... derive recursively
}
```

### P1-3: Smooth Coloring in ALL Shaders

**Current State:** Smooth-coloring code appears in multiple shaders, including `shaders/escape_time_family/core/escape_time_perturb_gpu.frag`. No complete inventory or regression test verifies coverage across the applicable polynomial escape-time shader set.

**Target:** Audit all applicable polynomial escape-time shaders and add or confirm formula-appropriate smooth coloring. The earlier estimate of approximately 80 shaders has not been rechecked.

**Example Formula:** This expression is used by the perturbation shader. Check each recurrence and magnitude value before applying it to another shader.
```glsl
float smoothVal = float(it) - log2(log2(max(1e-12, finalMag2))) + 4.0;
```

**Shader Files to Audit:** (Priority order; these are review targets, not confirmed failures)
1. `shaders/legacy/escape_time/mandel_step_smooth.frag`
2. `shaders/legacy/escape_time/julia.frag`
3. `shaders/legacy/escape_time/burning_ship.frag`
4. Applicable files under `shaders/escape_time_family/`

See [`docs/engineering/performance/SHADER_OPTIMIZATIONS.md`](docs/engineering/performance/SHADER_OPTIMIZATIONS.md) for current coverage limits and checks.

### P1-4: Arbitrary Precision for Extreme Zoom (CPU)

**Current Limit:** Double precision ~1e12 with df2 shader, then arbitrary precision CPU.

**Implementation Options:**

| Approach | Pros | Cons |
|----------|------|------|
| Integer arrays (base 10^9) | Fast, portable | Complex implementation |
| `decimal` package | Easy | Slow, large numbers |
| MPFR bindings | Fast, proven | Native code, complex |

**Recommended:** Custom integer array implementation for performance.

**Files to Create:**
- `lib/core/math/big_decimal.dart` — Arbitrary precision arithmetic
- `lib/core/math/big_complex.dart` — Complex number with BigDecimal

### P1-5: True Plane Anchors (AR-Ready)

**From PRD:** "Integrate true plane anchors (vertical + horizontal)"

**Implementation:**
1. Detect dominant line/plane in fractal boundary via edge detection
2. Anchor navigation to detected geometry
3. Enable "tap to place" on fractal boundaries

**Status:** Not started, deferred.

---

## P2 — IMPORTANT PRODUCT POLISH

### P2-1: GPU Visual Quality

- Pending: **Smooth coloring** in all escape-time shaders (see P1-3)
- Done: **Palette texture system** — Pass palette as texture uniform
- [ ] **Color cycling animation** — Perturbation shader supports time shift; roll out beyond perturbation path
- [x] **User palette selection** — Select from viewer controls
- [ ] **Regression test** — Assert no banding artifacts

### P2-2: UI/UX Improvements

- Done: **Controls redesign** — HUD overlay shipped (`FractalControlsHud`)
- Done: **Controls snap/collapse** — 24px vertical handle swipe snaps
  closed/open; 48px touch target, existing accessible toggle retained
- [ ] **Overflow menu** — Existing secondary-action menu is present; circular surface correction is tracked by **VIEW-UI-02**. Further action regrouping remains Proposed; preserve direct-access guarantees.
- [ ] **Auto-pilot improvements** — Smooth path, dwell behavior
- [x] **Manual corrections** — Auto-explore yields to continuous gestures,
  adopts the corrected zoom/direction, and replans one-shot wheel/keyboard
  corrections (`auto_explore_service_test.dart`)

### P2-3: Preset & Export

- [ ] **Preset thumbnails** — Auto-generate on save
- [x] **Custom palettes** — Save/load gradients
- [ ] **Bookmarks** — Save coordinates + formula + palette
- Pending: **Share presets** — One-tap Instagram/X/WhatsApp
- [ ] **Frame lock** — Exact viewer-to-export fidelity

### P2-4: Catalog Hardening

- [x] Registry covers 543 escape-time entries + 38 raymarched 3D + shared/custom promotions = 1020 production fractals plus 1 scientific visualization (1028 debug/test modules including diagnostics)
- [ ] **PRD manifest loader** — `assets/catalog/prd_catalog.json`
- [x] ID lock/integrity tests
- [x] Filter/sort + list/grid toggle
- [x] Persist catalog view mode
- [x] **Add 4+ new formulas** — Catalog has grown beyond the old 370 baseline

### P2-5: Export Hardening

- [x] Export pauses auto-navigation
- [x] Separate Save vs Share
- [ ] **Resume policy prompt** — After export
- Pending: **Share QA** — WhatsApp/Instagram/X/gallery

---

## P3 — ENHANCED DEEP ZOOM (Googol-Scale)

### P3-1: Googol-Scale Architecture (10^100+)

**Target:** Enable zoom beyond 10^100.

**Components Required:**

| Component | Status | Files |
|-----------|--------|-------|
| Arbitrary precision math | 🔶 Planning | `big_decimal.dart`, `big_complex.dart` |
| Reference orbit (big float) | 🔶 Planning | `escape_time_perturb_module.dart` |
| Series approximation (GPU) | 🔶 Planning | `series_approximation.dart` |
| Delta iteration (big float) | 🔶 Planning | `escape_time_perturb_gpu.frag` |
| Period detection | 🔶 Planning | `escape_time_perturb_module.dart` |

### P3-2: Perturbation for All Polynomial Fractals

**Target:** ~80 fractals total with perturbation support.

**Progress:**
- Currently routed: 9 IDs (`julia` + 8 generic escape-time IDs)
- Julia variants: ~30 candidates (core `julia` done; variants still open)
- Other polynomial: ~40 candidates

**To Implement:**
1. Add delta formulas for all unique polynomial patterns
2. Create universal perturbation wrapper
3. Add to `kPerturbableEscapeTimeIds`

### P3-3: Chunked Rendering for Extreme Zoom

**Why:** At googol-scale, single-frame render may be too slow.

**Solution:** Tile-based parallel rendering with edge feathering.

```dart
// Divide viewport into NxN tiles
// Render tiles in parallel
// Stitch with edge blending
class ChunkedRenderer {
    List<ui.Image> tiles;
    Future<void> renderTile(int x, int y);
    ui.Image stitchTiles(List<ui.Image> tiles);
}
```

---

## P4 — NEW FRACTAL FORMULAS

### P4-1: New Escape-Time Fractals

- [x] **Target met:** Catalog grew beyond the old 370 baseline to 1014 production fractals.
- Pending: Next formula work should be quality-gated: only add researched formulas with tests, stable IDs, and shader assets.

### P4-2: New 3D Fractals

- Done: 3D shader compatibility blockers fixed.
- Pending: Next 3D work should prioritize visual QA and thumbnails over raw count.

---

## COMPLETED ITEMS

### Deep Zoom
- [x] Perturbation theory shader (9 routed IDs: Julia + 8 generic escape-time IDs)
- [x] Double-float shader (`mandelbrot_df2.frag`) for 5e6-1e12
- [x] Reference orbit cache (LRU singleton)
- [x] Deep zoom precision policy with hysteresis
- [x] Dynamic iteration scaling with zoom

### Rendering
- [x] GPU-primary with CPU fallback
- [x] Tile-based CPU renderer (96px, spiral, cancel-on-gesture)
- Done: Smooth coloring in perturbation shader
- Done: Palette texture support + cached sampler adapter
- [x] **Batched orbit-texture rasterization** (2026-07-02) — shared
  `rasterizePerturbOrbitBytes` (one `drawVertices` call) replaces the
  per-pixel `drawRect` loops duplicated in both perturbation modules
  (~4,000 draw ops per navigation step → 1; measured 3.33ms → 1.38ms per
  build at max iterations). Byte-exactness locked by
  `test/perturb_orbit_texture_test.dart` (software rasterizer) and
  `integration_test/rendering/perturb_orbit_texture_gpu_test.dart`
  (real GL pipeline; run with `-d linux`, needs `xvfb-run` when headless)

### Quality
- [x] 64 palette support + selector
- [x] Screen-reader labels
- [x] GPU→CPU threshold tuning
- [x] Catalog integrity tests

### Testing
- [x] Focused TODO refresh checks passed: catalog integrity, controls HUD, palette texture/cache tests
- [x] 19 integration test files
- [x] Golden tests (phone/tablet × dark/highContrast)
- [x] Semantic audit

---

## CPU PATH — MAINTENANCE ONLY

**Policy:** No further performance investment.

**Maintained for:**
- Emulator testing
- Broken GPU fallback
- Extreme zoom beyond GPU capability

**Current capabilities:**
- Double precision
- Tile-based progressive rendering
- 2x2 AA refine pass
- Smooth escape-time coloring

---

## OUT OF SCOPE

- **Arenaton** — Not part of this repo
- **Video recording** — Deferred
- **Runtime shader compilation** — Deferred
- **User-defined formulas** — Deferred (would require interpreter)

---

## FILE MANIFEST

### Critical Files to Modify

| File | Change | Priority |
|------|--------|----------|
| `shaders/escape_time_family/core/escape_time_perturb_gpu.frag` | Add smoother fallback / series approx if needed | P1 |
| `lib/core/modules/escape_time_perturb_module.dart` | Period detection, more polynomial IDs | P1 |
| `lib/core/modules/builders/escape_time_catalog.dart` | Add perturbation configs | P1 |
| `lib/features/renderer/policy/precision_ladder_policy.dart` | Threshold tuning | P2 |
| `lib/features/renderer/cpu/cpu_fractal_renderer.dart` | BigDecimal support | P3 |

### Files to Create

| File | Purpose | Priority |
|------|---------|----------|
| `lib/core/modules/series_approximation.dart` | Series coeff computation | P1 |
| `lib/core/math/big_decimal.dart` | Arbitrary precision | P3 |
| `lib/core/math/big_complex.dart` | Big complex number | P3 |
| `lib/core/modules/perturbation_catalog.dart` | Universal perturbation builder | P3 |

---

## RESEARCH SOURCES

### Perturbation Theory
- K.I. Martin — "Perturbation techniques for the Mandelbrot set"
- Fractalforums.com — "Perturbation Theory" (1000+ posts)
- Deepzoom.com — Practical perturbation implementation

### Series Approximation
- Paul Derbyshire — "Optimizing Mandelbrot Computation"
- Smart Internet — Series approximation algorithms

### Implementation References
- FractInt — Classic fractal software (C, historical)
- KFract — Open source perturbation
- Mandelbrot Explorer — Modern Windows app

---

## SUCCESS CRITERIA

| Milestone | Verification |
|-----------|--------------|
| No artifacts at z=5.10e+6 | Visual test, screenshot comparison |
| 3D fractals render | Launch app, navigate to Mandelbulb |
| Julia perturbation | Zoom Julia to 1e10, verify smooth |
| Series approx 10x speedup | Benchmark frame time before/after |
| Googol-scale zoom | Zoom to 10^50, verify no precision loss |

---

## NOTES

- **Perturbation ≠ Universal** — Only ~80/370 fractals can use it
- **IFS/Attractors/Cellular** — Require completely different deep zoom strategies (if any)
- **Series approximation** — Only helps when zoomed into areas that escape late
- **Period detection** — Critical for stability at extreme zoom
