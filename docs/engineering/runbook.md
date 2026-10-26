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

## Android testing over SSH

**Waydroid is already the owner-designated Android test target**, reaffirmed
2026-10-26; do not ask the owner to designate it again. Follow the
[standing target contract and setup guide](testing/waydroid-headless.md#standing-owner-designation-use-this-waydroid-target)
for current ADB serial/model verification, permitted app replacement, matching gate
acknowledgement and exclusive worker access. The observed serial is
`192.168.240.112:5555`; its IP can change. A release-signed app installed inside
this test container is not by itself a personal-device blocker.

Use that guide's networking/key-recovery procedures only if connectivity actually
needs repair; do not restart a healthy session. The designation is settled, but
export/gallery tests, actual artifact/source checks and technical release gates
still need their real outcomes. Waydroid remains emulator/container evidence, not
physical-device/hardware-GPU proof or general publication authority.

## CI and release operations

GitLab execution is currently deferred by the [owner release policy](../../PRD.md#independent-platform-release-policy). The configured pipeline below is reference material, not permission to mirror, log in, dispatch or publish. Use the [independent-platform preparation contract](release/MULTIPLATFORM.md#independent-platform-release-campaign) for the supported non-GitLab route and keep publication separate.

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

Do not enable bulk `dart_fix`, package mutation, app lifecycle control or hot restart for this inspection profile. Tests/formatting can use existing Flutter CLI commands; enable additional MCP tools only when that worker actually needs and is authorized to use them. Roots are scope metadata, not a complete security sandbox. Persistent Hermes setup must use the approved connector flow with appropriate approval; never hand-edit MCP configuration or another profile. APP-001-47's retained session completed initialize/list_tools, checkout-only roots add/remove, symbol lookup and scoped analysis; this is static tooling qualification, not runtime or whole-app quality. See the [source-bound capability record and replay manifest](test-plan.md#mcp-assisted-app-quality-verification).

Interpreter selection: the installed Python MCP SDK may be available in an existing environment but absent from the worker's default `python3`. The retained APP-001-47 session used an existing Python 3.11 environment with MCP SDK 1.26.0; its task-named standalone Python 3.14.7 lacked `mcp`. Reuse a verified existing environment, not an assumed PATH binding; do not install packages, create a bridge or modify the worker/profile. An import-only probe is not protocol/workspace qualification. Within the context managers, use the discovered schemas: `roots` with `{command: add, uris: [checkout_file_uri]}`, `lsp` with `{command: resolveWorkspaceSymbol, query: symbol}`, and `analyze_files` with `{roots: [{root: checkout_file_uri, paths: scoped_paths}], applyFixes: false}`. Remove the same root in `finally`, exit both contexts, and retain the timeout and actual results. This ephemeral client is a temporary inspection route, not a persistent production integration.

### Owned Linux runtime with reserved ports

APP-005-7f exercised an alternative to automatic DDS discovery using only the pinned SDK and an ephemeral inspection client. Start an owned Linux/Xvfb debug app with `flutter run`, `--no-dds --no-devtools`, and both `--device-vmservice-port` and `--host-vmservice-port` set explicitly inside the task's reserved range. Keep Xvfb TCP disabled (`-nolisten tcp`) and app preferences/cache in private scratch. For the composed fixture, use `-t integration_test/flows/app_quality_test.dart --dart-define=FORCE_GPU_RENDER=true`, optionally setting `APP_QUALITY_CAPTURE_DIR` and `APP_QUALITY_SOURCE` with `--dart-define` to retain native PNGs and state/semantics sidecars. Without the capture directory the assertions still run, but no retained-image claim is possible.

Launch the SDK's `dart tooling-daemon --machine --port <reserved-dtd-port>` separately. Its machine response supplies the URI and the trusted-client secret for **that owned daemon only**. Register only the just-launched app using the standard DTD `ConnectedApp.registerVmService` RPC (`uri`, `secret`, `name`), not an unrestricted daemon, proxy or persistent profile change. The URI must be the app's **WebSocket VM-service URI**: convert the printed HTTP scheme to `ws` and append `ws` to its trailing slash. An HTTP URI is rejected as an unsupported WebSocket scheme. Keep connection URIs/secrets private; never enumerate or attach other workers' apps.

Initialize the official MCP stdio session, discover schemas, add only the checkout root, then call `dtd` with `{command: connect, uri: owned_dtd_uri}` and `listConnectedApps`. Use the returned explicit app URI for `get_runtime_errors` (`appUri`, `clearRuntimeErrors: false`) and `widget_inspector` (`command: get_widget_tree`, `summaryOnly: true`, `appUri`). Retain actual tool results, not just successful transport. Disconnect, remove the root, exit both client contexts, and terminate the owned daemon/app/display. APP-005-7f's three samples returned widget trees and `No runtime errors found`; sampling is not an assurance about errors outside that interval, screen readers or hardware GPUs.

The pinned `flutter test` command does **not** accept `--host-vmservice-port`; its native integration path constructs debugging options without a caller-specified raw VM-service port (`packages/flutter_tools/lib/src/commands/test.dart`). A DDS port alone does not bind that raw listener. Do not run it on arbitrary ports, patch the SDK or relax the task's port policy. `flutter run` output remains **supplemental native evidence**, not a passed driver/protocol gate. See [the historical composed-batch result](test-plan.md#app-005-7f-composed-batch-evidence).

For a supported host-protocol run, use [`scripts/run-native-integration.sh`](../../scripts/run-native-integration.sh) and the official SDK `integrationDriver` adapter in [`test_driver/integration_test.dart`](../../test_driver/integration_test.dart). Flutter 3.44.6's `DriveCommand` inherits `RunCommandBase.createDebuggingOptions`, including both VM-service port options. With DDS disabled, the explicit host port is not reassigned to DDS and the device port binds the Linux VM listener. No separate DTD, DevTools, WebDriver or host Dart VM-service listener is needed.

Prerequisites: existing Linux build tools, `/usr/bin/python3`, `xvfb-run`/Xvfb, the pinned provisioned SDK and offline package cache. Use the **actual** task-provided `AUTOWORK_PORT_BASE` and `TMPDIR`; do not substitute another allocation or use an arbitrary temporary directory. From the task checkout:

```sh
export FLUTTER_ROOT="$AUTOWORK_CACHE/flutter-3.44.6"
export PUB_CACHE="$AUTOWORK_CACHE/pub-cache"
export PATH="$FLUTTER_ROOT/bin:/usr/bin:$PATH"
flutter pub get --offline --enforce-lockfile

autowork-run timeout --kill-after=10s 660 bash scripts/run-native-integration.sh \
  integration_test/flows/double_tap_anchor_test.dart --timeout 600 \
  --dart-define=FORCE_GPU_RENDER=true
```

The wrapper refuses missing/invalid allocations before launch and uses the allocation's base port for **both** `--device-vmservice-port` and `--host-vmservice-port`. It fixes `-d linux --debug --no-pub --no-dds --no-devtools --no-publish-port --no-keep-app-running`, and only accepts extra `--dart-define=KEY=VALUE` arguments. `INTEGRATION_TEST_SHOULD_REPORT_RESULTS_TO_NATIVE=false` selects host collection rather than the Android/XCTest platform channel; it does not disable assertions or result collection. The official adapter requests and decodes the binding's terminal response. Only its success callback writes `protocol-success.json`; exit zero without this response is failure. App text such as “All tests passed” or a plugin-not-detected warning is not a substitute.

Each run prints its private `$TMPDIR/native-integration-*` evidence directory. Preserve `driver.log`, `outputs/`, and `run.json` (source revision and target/driver/wrapper hashes, exact command, SDK identity, observed TCP listeners, exit status and cleanup). XDG preferences/cache/data/state and test outputs are isolated there; Xvfb uses `-nolisten tcp`. Linux `/proc` listener sampling is an audit, not a network sandbox: supported launch flags prevent random VM/service listeners, and an observed owned listener other than the reserved IPv4 loopback endpoint aborts the run. The supervisor bounds the **whole** build/driver run (default 600 seconds; maximum 1200), handles INT/TERM, terminates only its new process group with TERM then KILL, reaps owned orphan children, and records remaining PIDs. Timeout exits 124; signals exit 128 + signal; other driver failures remain nonzero. A pass requires `exit_code: 0`, `protocol_success: true`, and `cleanup.remaining_pids: []`. On failure inspect the retained log/receipt; never clean up by application name or kill another port owner.

NATIVE-PORT-DRIVER-01 qualification (2026-10-25 UTC): the command above ran the **unchanged** double-tap/pan fixture at source baseline `5558c33898c247d241553c426324338170ccca7c` plus the hash-bound driver/wrapper candidate. Pinned Flutter framework `ee80f08bbf97172ec030b8751ceab557177a34a6` / Dart 3.12.2 accepted the flags; the binding completed its test and teardown (`+2`), and the official host adapter received success and exited 0. The only observed TCP listener was `127.0.0.1:20200`, within that worker's actual `20200..20299` allocation; no DDS/DevTools listener or plugin-not-detected warning occurred. Owned cleanup recorded no remaining PIDs. GDK monitor/cursor and OpenGL resize warnings remain in the private log; this is protocol/gesture qualification on Linux/Xvfb, not hardware-GPU or visual-quality acceptance. The worker report retains the evidence path and exact candidate hashes. Focused offline regressions cover allocation refusal, fixed invocation/private outputs, nonzero/missing-response propagation, and bounded timeout/signal cleanup without terminating an unrelated process.

This prerequisite does **not** qualify Number Walls or close NUM-WALL-04/NUM-WALL-05. NUM-WALL-04 must reuse its retained candidate and existing native journey through this supported invocation, then retain its exact Linux/browser cell parity, rendering, PNG and replay evidence. Its historical supplemental `flutter run` output must not be relabeled as a passed driver run. Installed-device/Android and physical hardware qualification remain separate.

## Offline-check export preparation

The retained main-check run at `76db6aa` reported clean analysis, then `flutter test --no-pub` crashed before completing tests with `Bad state: No element` in `testCompilerBuildNativeAssets`. This is failed/incomplete history, not verification of a later commit. Its scratch checkout has been removed, so its generated dependency metadata cannot now be confirmed.

The inspected pinned Flutter 3.44.6 native-assets builder looks up a package whose resolved root URI exactly equals the current project URI. Before retrying in a fresh isolated export, inspect that binding, the actual SDK and lockfile, and whether `.dart_tool` points outside the candidate. The common offline gate now begins with `flutter pub get --offline --enforce-lockfile` from the execution checkout root, regenerating only checkout-local dependency metadata with the pinned toolchain and provisioned offline cache; preserve and verify `pubspec.lock`. A stale root URI is not a confirmed cause of the removed attempt. Do not rewrite shared metadata or SDK sources, install tools, bypass native-assets checks, or record an interrupted suite as passing. Retain the actual test aggregates and exit codes for every family. This prerequisite repair neither starts a runner nor grants wider operations.

A controlled reproduction for `ACAD-008-74` exported source `ea7cc6e77e8cd6c2dfbb6a4d3761f4deae65bd81` into a private checkout and deliberately left its `flutter_fractals` package entry bound to the producer checkout. With the pinned Flutter 3.44.6, `flutter test --no-pub test/screens/app_version_test.dart --reporter expanded` exited 1 with the same `Bad state: No element` stack in `testCompilerBuildNativeAssets`. Running `flutter pub get --offline --enforce-lockfile` in that private checkout and repeating the identical test command exited 0. This confirms the failure mechanism and bounded repair, not the unavailable historical metadata. No SDK sources or dependency constraints were edited, and no application/shader code or package installation was introduced.

The subsequent full offline rerun on that source base plus the gate/runbook repair completed on 2026-10-20 UTC with every stage exiting 0: offline lockfile-enforced dependency preparation; clean analysis; 2,850 Flutter tests passed with 8 skipped; 262 Python tests passed with 1 skipped; and all 25 Bats checks passed. The complete tracked-input snapshot SHA-256 was `7e676264aa6faa34ae2bbc2860703d2d68e8fa5d7caffd9b544318f053c3ab4e`; it and `pubspec.lock` remained unchanged during execution. The run used the pinned Flutter 3.44.6/Dart 3.12.2, existing Python/Bats tooling, and a process-local `PYTHONPATH` selecting the already-provisioned MarkupSafe source for Jinja2 compatibility; no package was installed. Per-stage output, exits, and the controlled failing/passing reproduction are retained with the task's private check receipt. This is offline qualification only, not device/browser/GPU qualification or release approval. Subsequent edits correct the explanatory source identifier, record these results, and close the queue entry; they change no executable input.


## Queue and retained-check handoff

The owner retains `TODO.md` as the central queue and `goals.json` as its synchronized index. Preserve IDs, relative priority, focus and completed history. The installed `autowork tasks` validator expects `tasks/`; its read-only preparation check currently refuses conversion because historical slots/consumers remain. This is an execution-tool compatibility gap, not permission to migrate the owner's queue, clear historical attempts, restart a paused runner or relabel tasks runnable. Documentation validation checks the retained queue directly and reports the tool mismatch separately.

`ACAD-008-74` is completed and archived; `7ae1dbd6` integrated the bounded metadata preparation and recorded full offline evidence. A stopped runner can still display an older failed-main notice and old slot questions. Read current committed tasks and source-bound logs before acting on that cache: historical slot names alone are not live ownership or a fresh user decision. APP-001-47, ACAD-007-f8 and SINEWARP-001-aa still need their own retained-candidate/composed checks; the common repair is reusable setup, not automatic acceptance of their different inputs. No runner/slot/report mutation is part of Docs Sync.
