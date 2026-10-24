<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# Flutter Fractal Forge

## Purpose

## Key Files

| File | Description |
|------|-------------|
| `lib/main.dart` | App entry point, service initialization, root widget with Provider setup |
| `pubspec.yaml` | Dependencies and shader/asset declarations |
| `l10n.yaml` | Localization configuration |
| `analysis_options.yaml` | Dart analyzer rules |
| `PRD.md` | Product requirements document |
| `TODO.md` | Remaining tasks and features |
| `docs/engineering/performance/PERFORMANCE.md` | Performance optimization notes |
| `docs/engineering/performance/SHADER_OPTIMIZATIONS.md` | GPU shader optimization strategies |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `lib/` | Application source code - models, modules, services, features (see `lib/AGENTS.md`) |
| `shaders/` | 220+ GLSL fragment shaders for GPU fractal rendering (see `shaders/AGENTS.md`) |
| `research/fractals-library/` | 200 fractal definitions organized by mathematical category (see `research/fractals-library/AGENTS.md`) |
| `test/` | Unit and widget tests (see `test/AGENTS.md`) |
| `integration_test/` | Integration and screenshot tests (see `integration_test/AGENTS.md`) |
| `assets/` | App icons and 250+ catalog thumbnail images (see `assets/AGENTS.md`) |
| `scripts/` | Shell scripts for screenshots, emulator automation (see `scripts/AGENTS.md`) |
| `android/` | Android platform configuration |
| `ios/` | iOS platform configuration |
| `macos/` | macOS platform configuration |
| `windows/` | Windows platform configuration |
| `linux/` | Linux platform configuration |
| `web/` | Web platform configuration |

## For AI Agents

### Architecture Overview

```
State Management: Provider + ChangeNotifier (FractalController)
Rendering: GLSL fragment shaders via Flutter's FragmentShader API
Module System: Declarative EscapeTimeConfig catalog + custom builder functions
Navigation: HomeScreen -> Catalog -> Viewer (with FractalController per tab)
```

### Working In This Directory
- Build with: `flutter run -d linux`
- Flutter 3.44.6 stable / Dart 3.12.2, Flutter desktop (Linux primary)
- If local linker tooling is needed, keep it outside the repo and on `PATH`.
- Provider is used for DI; FractalController is the primary state holder
- Most fractals use the escape-time builder pattern (declarative config + shader)

### Key Patterns
- **Module system**: `FractalModule` defines a fractal type (id, shader, params, presets, uniform setter). Registered in `ModuleRegistry`
- **Escape-time catalog**: Standard fractals defined declaratively in `escape_time_catalog.dart`; custom fractals (Julia, Phoenix, Mandelbulb) have dedicated builders
- **Shader uniforms**: Each module's `setUniforms` callback maps Dart params to GLSL uniforms
- **Safe/boot modes**: `SAFE_MODE` and `BOOT_STEP` environment vars for incremental debugging

### Testing Requirements
- Run unit tests: `flutter test`
- Run integration tests: `flutter test integration_test/`
- Widget tests use `pumpWidget` with mock stores/services

### Common Gotchas
- Class fields typed as `Object` do NOT get type-promoted in Dart; assign to local variable first
- `image` package v4.x API changes: `compositeImage` (not `copyInto`), frame list for GIF
- Shader assets must be registered in `pubspec.yaml` under `flutter.shaders`

## Dependencies

### External
- `provider` ^6.1.2 - State management
- `vector_math` ^2.1.4 - Math for 3D transforms
- `image` ^4.0.0 - Image encoding/export
- `shared_preferences` ^2.5.5 - Local persistence
- `path_provider` ^2.1.0 - File system paths
- `share_plus` ^13.2.0 - Share/export
- `url_launcher` ^6.3.2 - External links and deep links
- `package_info_plus` ^10.2.1 - App version metadata
- `fftea` ^1.5.0 - Fourier analysis
- `web` ^1.1.1 - Web target support

<!-- omh:agent-instructions:begin -->
## Common offline integration gate

Full check: flutter pub get --offline --enforce-lockfile && flutter analyze --no-pub && flutter test --no-pub && /usr/bin/python3 -m pytest test/research test/scripts -q && bats test/scripts/*.bats

Setup: on the provisioned Linux host, enclose Full check in a subshell with `FLUTTER_ROOT="$AUTOWORK_CACHE/flutter-3.44.6"`, `PUB_CACHE="$AUTOWORK_CACHE/pub-cache"` and `PATH="$FLUTTER_ROOT/bin:/usr/bin:$PATH"` exported (set `FLUTTER_ROOT` before expanding it in `PATH`). This selects the pinned Flutter 3.44.6/Dart 3.12.2 and binds child `python3` invocations to the same existing interpreter as the explicit `/usr/bin/python3` above. Before running, compare `flutter --version` with `fdroid/flutter.version` and run `/usr/bin/python3 -c 'import sys, pytest, jinja2, markupsafe; print(sys.executable, sys.version, pytest.__version__, jinja2.__version__); assert callable(markupsafe.soft_str)'`. The ambient Python 3.14.7 lacks pytest; do not install packages or change host/profile state to repair this binding. Revalidate the provisioned imports on each host; see [MAIN-CHECK-01](docs/tasks/MAIN-CHECK-01.md) for module paths, the evidence discrepancy and verification limits.

Verification: run from the execution checkout root with the pinned isolated/provisioned Flutter SDK and existing Python/Bats tooling. The offline, lockfile-enforced preflight regenerates checkout-local package metadata before the unchanged test families; do not copy a producer checkout's project-root binding into an export. Preserve and verify `pubspec.lock`. The command declaration is not a passing suite result. Missing tools, failed tests or timeouts must remain failures, not skipped success. Device/browser journeys and production/live qualification remain separate task gates. Do not use the device-changing pre-release gate as this offline command.
<!-- omh:agent-instructions:end -->

<!-- MANUAL: -->

<!-- karpathy-guidelines:start -->
## Karpathy-Inspired Agent Guardrails

Source: https://github.com/forrestchang/andrej-karpathy-skills at commit `2c60614`.

These guardrails supplement the local instructions above. Local project, safety, and user-specific rules win on conflict.

Tradeoff: they bias toward caution over speed for non-trivial work; use judgment for obvious one-line fixes.

### Think Before Coding

- State assumptions and choose the simplest reversible solution supported by repository evidence. Ask only when a missing decision prevents safe, authorized work; continue independent work meanwhile.
- Briefly record material tradeoffs and select a reasonable default for routine local work.
- Push back when a simpler approach meets the goal.

### Simplicity First

- Build the minimum code that solves the requested problem.
- Avoid speculative features, single-use abstractions, and unnecessary configurability.
- If the solution is growing large, stop and simplify before continuing.

### Surgical Changes

- Touch only files and lines required by the request.
- Preserve existing style, comments, and nearby code unless the task requires changing them.
- Clean up only dead code introduced by your own change; mention unrelated dead code instead of deleting it.

### Goal-Driven Execution

- Convert the request into verifiable success criteria before editing.
- For multi-step work, state a short plan with a verification check for each step.
- Loop until the relevant tests, builds, or manual checks prove the goal is met.
<!-- karpathy-guidelines:end -->

<!-- karpathy-project-adjustment:start -->
## Project-Specific Karpathy Adjustment

This section localizes the Karpathy guardrails for `workspace-sidon/trebuchet-dynamics/flutter-fractal-forge`. Source inspiration: https://github.com/forrestchang/andrej-karpathy-skills at commit `2c60614`.

- Project family: Sidon fractal/rendering and visual-app workspace.
- Local focus: GPU/fractal rendering, Flutter/Electron apps, shaders, accessibility, and measurable visual behavior.
- Stack cues: Flutter/Dart.
- Evidence to prefer: test output, analyzer/linter output, screenshot/pixel checks when relevant, shader compile logs, frame/performance metrics, and exact UI state text.
- Surgical boundary: do not rely on visual vibes; validate rendering numerically and describe results in screen-reader-friendly text.
- For underspecified visual work, derive measurable acceptance criteria from existing patterns and accessibility requirements, implement a reversible improvement, and validate it. Escalate only a material unresolved product decision; continue other work.
<!-- karpathy-project-adjustment:end -->

<!-- autowork-local-authority:start -->
## Autowork: autonomous local progress

An Autowork invocation or recurring Autowork job authorizes routine local
repository improvement: plan, implement, test, document and make scoped local
commits. Choose reasonable reversible implementation details without waiting for
an owner, parent session or another profile to approve them. This section replaces
older owner-acknowledgement and blanket main-only development requirements for
that local work; it does not override product safety or explicit task exclusions.

- Read the current task and repository state. Repair attributable task metadata,
  links and missing backlog structure from source evidence; preserve existing
  decisions and never invent acceptance, ownership release or completed checks.
- If no task is runnable, inspect implementation, tests, docs and UI/accessibility
  for a concrete improvement. Record a bounded task with acceptance criteria and
  dependencies, then execute it. Keep a few independent ready tasks when evidence
  supports them; do not manufacture busywork or count planning as implementation.
- Separate offline implementation and tests from device, production and other
  live qualification. Complete the local task while retaining an explicit pending
  live task; never mark the combined feature qualified from offline evidence.
- Use supported isolated task branches/worktrees when needed. Keep one writer per
  workspace. A historical ACTIVE claim alone is not a permanent veto: check actual
  worker/session activity and candidate changes. Preserve prior work; adopt an
  idle candidate only after verifying it is no longer being written. If activity
  cannot be established, select non-overlapping work instead of guessing.
- The current Autowork coordinator may review and integrate its verified local
  changes into canonical main without a separate parent/owner acknowledgement.
  Serialize canonical writes, inspect fresh status, preserve unrelated dirty
  work, and use the supported integration path. Do not bypass runtime guards,
  repin evidence to hide drift, force-push, reset or discard another writer's work.
- After a repeated blocker, take a different concrete action in the same run:
  repair the local cause, execute independent work, or report one precise external
  input that is genuinely unavailable. Do not repeatedly audit the same hold.
- Run checks proportional to the change. Commit only attributable, verified work.
  Report task ID/title, actual changes, checks, commit, next task and exact remaining
  blocker. Distinguish local commit, integration, push and live acceptance.
- Existing explicit publication authority remains valid; this policy alone does
  not authorize remote publication, deployment, money movement, secret access or
  destructive/live operations. Preserve paused jobs and task-specific exclusions.
<!-- autowork-local-authority:end -->
