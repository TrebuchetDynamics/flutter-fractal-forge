# Local operations runbook

## Scope

This runbook covers local development and the repository's existing CI/release entry points. Production publishing is owner-authorized and is not performed by these local procedures. Website deployment has a separate approval-gated procedure in [`../deployment/WEB_PREVIEW_GITHUB_PAGES.md`](../deployment/WEB_PREVIEW_GITHUB_PAGES.md).

## Prerequisites

- Flutter SDK and Dart bundled with Flutter, available on `PATH`.
- Repository dependencies resolved with `flutter pub get`.
- A configured Flutter device for interactive or integration runs. Linux builds also require the platform build tools described by Flutter's Linux desktop setup.

## Start and validate locally

1. From the repository root, run `flutter pub get`.
2. Run `flutter devices` and select an available target.
3. Run `flutter run -d <device-id>`; use `chrome` for a browser preview or `linux` for a Linux desktop run when those targets are configured.
4. Confirm the catalog appears and a selected module opens in the viewer. A visible catalog alone does not verify every shader or platform feature.
5. Run `flutter analyze` and `flutter test` for code changes. For device behavior, use the relevant integration test and record the device/backend.

Expected signals are successful process completion and passing test output. If dependencies cannot resolve, confirm the Flutter SDK and lockfile match the repository before changing dependency constraints. If a shader fails to load, capture the test/log output and check `pubspec.yaml` asset registration and module uniform bindings. Do not treat a software-rendered emulator as proof of hardware GPU correctness.

## CI and release operations

`.gitlab-ci.yml` is the CI pipeline source. Standard validation runs tracked-artifact checks, script tests, dependency resolution, analysis, and unit/widget tests. Release pipelines run on protected refs when triggered through GitLab’s API or web interface with `RELEASE_MODE=prepare` or `publish`; preflight checks require the applicable secret variables. Keep secrets in the CI secret store; do not copy them into logs or repository files.

The public release entry point is root `release.sh`; protected CI jobs use `scripts/release.sh` as their stage worker. Follow `docs/engineering/release/` and the specific platform checklist. Do not publish, deploy, or change a live release as a diagnostic step.

## Diagnosis and recovery limits

- For a failing test, preserve the complete failing command and output, then run the smallest relevant test target.
- For GPU-only behavior, compare a supported hardware target with the software/emulator result and state the backend in the report.
- For web-preview build problems, use `docs/deployment/WEB_PREVIEW_GITHUB_PAGES.md` for local build checks. Deployment rollback is defined there for the existing hosting service; it is not a general application rollback mechanism.
- No general production backup/restore procedure is defined for this client application. Do not claim data recovery beyond the app's documented local persistence behavior.

## Official Dart Flutter MCP workflow

Scope: developer tooling only. See [the accepted bounded plan](spec.md#mcp-assisted-app-quality); this recipe installs nothing and grants no app mutation, profile setup, live-service or publication authority.

Use the task's pinned isolated/provisioned Flutter 3.44.6 SDK rather than upgrading `/home/xel/flutter`. Inspect `"$FLUTTER_SDK/bin/cache/dart-sdk/bin/dart" --version` and `mcp-server --help`; SDK tool defaults may differ from upstream documentation. The verified read-only probe used this stdio server argument set:

```sh
"$FLUTTER_SDK/bin/cache/dart-sdk/bin/dart" mcp-server \
  --disable all --enable roots --enable lsp --enable analyze_files \
  --enable dtd --enable get_runtime_errors --enable widget_inspector
```

MCP is a protocol, not an interactive shell: connect through the current native client's supported tools/resources/roots features, or use the installed Python MCP SDK's `stdio_client` and `ClientSession` context managers for an ephemeral scoped session. No custom bridge, npm package or application dependency is needed. With redirected notebook output, give `stdio_client` a real private scratch-backed `errlog` file handle; do not assume redirected stderr has `fileno()`. Read result model fields from that installed SDK (`server_info`/`input_schema`, or `model_dump(by_alias=True)`), not guessed camelCase attributes. Initialize, list tools and verify the allowlist; then `roots` add only the task checkout URI (`command: add`, `uris: [file URI]`). Use `lsp`'s discovered schema for symbols and `analyze_files` for scoped diagnostics. Record actual results and close both contexts within a bounded timeout.

For runtime inspection, connect only to an explicit DTD URI of a named owned debug/profile application. The official source describes `--print-dtd` and requires DDS for Flutter DTD discovery; verify flags against the installed runtime before launching. Do not enumerate-and-attach arbitrary other repositories' apps, mutate user preferences or publish connection URIs. Preserve existing reserved-port and loopback rules; NUM-WALL-01's ephemeral-port exception does not apply here. If an owned target cannot be launched/attached within existing access and port constraints, retain that exact runtime limitation and use static/widget checks for independent fixes. The final runtime check stays NOT_RUN until a compatible authorized target exists.

Do not enable bulk `dart_fix`, package mutation, app lifecycle control or hot restart for this inspection profile. Tests/formatting can use existing Flutter CLI commands; enable additional MCP tools only when that worker actually needs and is authorized to use them. Roots are scope metadata, not a complete security sandbox. Persistent Hermes setup must use the approved connector flow with appropriate approval; never hand-edit MCP configuration or another profile. The planning probe tested initialize/list_tools/cleanup only, not runtime attachment or app quality.

## Offline-check export preparation

The retained main-check run at `76db6aa` reported clean analysis, then `flutter test --no-pub` crashed before completing tests with `Bad state: No element` in `testCompilerBuildNativeAssets`. This is failed/incomplete history, not verification of a later commit. Its scratch checkout has been removed, so its generated dependency metadata cannot now be confirmed.

The inspected pinned Flutter 3.44.6 native-assets builder looks up a package whose resolved root URI exactly equals the current project URI. Before retrying in a fresh isolated export, inspect that binding, the actual SDK and lockfile, and whether `.dart_tool` points outside the candidate. Regenerate only candidate-local dependency metadata with the pinned toolchain and provisioned offline cache when needed; preserve and verify `pubspec.lock`. A stale root URI is a diagnosis to check, not a confirmed cause of the removed attempt. Do not rewrite shared metadata or SDK sources, install tools, bypass native-assets checks, or record an interrupted suite as passing. Rerun the unchanged common offline gate after its prerequisites are valid and retain the actual test aggregate/exit. Technical recovery belongs to the existing runner; this note neither starts it nor grants wider operations.
