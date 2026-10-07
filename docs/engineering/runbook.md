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

`.gitlab-ci.yml` is the CI pipeline source. Standard validation runs tracked-artifact checks, script tests, dependency resolution, analysis, and unit/widget tests. A protected, manually invoked release flow is gated by `RELEASE_MODE` and required secret variables. Keep secrets in the CI secret store; do not copy them into logs or repository files.

Release preparation and publication use `scripts/release.sh` through the defined protected pipeline. Follow `docs/engineering/release/` and the specific platform checklist. Do not publish, deploy, or change a live release as a diagnostic step.

## Diagnosis and recovery limits

- For a failing test, preserve the complete failing command and output, then run the smallest relevant test target.
- For GPU-only behavior, compare a supported hardware target with the software/emulator result and state the backend in the report.
- For web-preview build problems, use `docs/deployment/WEB_PREVIEW_GITHUB_PAGES.md` for local build checks. Deployment rollback is defined there for the existing hosting service; it is not a general application rollback mechanism.
- No general production backup/restore procedure is defined for this client application. Do not claim data recovery beyond the app's documented local persistence behavior.
