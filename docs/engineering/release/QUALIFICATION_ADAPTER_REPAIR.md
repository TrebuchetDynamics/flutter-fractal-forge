# Release qualification adapter repair — 2026-10-26

## Follow-up unblock repairs — 2026-10-29

The owner requested all remaining release blockers be addressed. These repairs
remove evidenced software defects without changing any qualification verdict by
assertion or waiving unavailable external requirements.

- Web readback treats only the exact `_headers` member as consumed Pages
  configuration. Its archived bytes must match the qualified manifest, and its
  declared headers must be observed on the corresponding served responses.
  Ordinary underscore-prefixed files remain hash-checked. Readback follows
  bounded HTTPS redirects, rejects an off-origin final response, and checks both
  the immutable deployment URL and the existing canonical production site.
  The root route is checked directly against `index.html`, even when the index
  URL does not redirect. Stale identity, changed bytes or incorrect cache/content
  headers fail closed and cannot trigger a duplicate upload.
- F-Droid scanning mounts only explicit public recipe/support/category inputs,
  not the full upstream checkout. All existing secret-marker, symlink,
  special-file, mount and rootless-runtime restrictions remain in force.
- Generated F-Droid source and issue links use the canonical GitHub upstream,
  removing dependence on an excluded project GitLab mirror. The public
  F-Droid definitions fetch is not a project mirror or CI dispatch.
- F-Droid recipes set `TAR_OPTIONS=--no-same-owner` for SDK extraction inside
  rootless builds. This avoids unmapped archive-owner IDs without changing SDK
  sources, host UID mappings or archive payloads. Non-runtime `docs/qa` evidence
  archives are removed only from the isolated F-Droid source tree; runtime code,
  licenses and the repository's original evidence remain intact.
- The pinned scanner ignores `--exit-code` for source-scan problems. A regression
  reproduced its false-success case; the caller now also verifies its terminal
  clean-scan summary. Official lint and source scans then completed for 1131,
  1132 and 1133 at app source
  `8fa9b06cc1bc2fa22b21b7da77c884e816ab5714`, reporting `0 problems found` with
  empty owned-process cleanup. Failed earlier attempts remain retained. This is
  source-scan evidence, not Android-device or maintainer acceptance.

Qualification utilities and frozen app artifacts have separate source identities.
Record the utility hashes and target app revision when reconciling an existing
artifact. Do not rewrite a failed campaign, rebuild an already-deployed artifact
merely to replace its receipt, or substitute a new commit for its recorded source.

The live custom-domain cache policy remains an independent gate: the configured
zone minimum is 14400 seconds, while the artifact requests 300 for bootstrap and
0 for the main bundle. The available token can read the setting but cannot access
Cache Rules or legacy Page Rules. No zone-wide setting was changed because other
sites may share the zone. Scoped rule access is required for a host-specific
repair. Android still needs privileged guest-network diagnosis of its unreachable
designated Waydroid target. No supported Windows/Apple executor was registered.
Linux retained-image, locale/inspired-entry coverage and human-review evidence
must be supplied by actual captures and review, never by receipt flags.

## Original repair record

The user requested fixes for the [unsuccessful seven-lane release attempt](ALL_PLATFORMS_1.1.112_ATTEMPT.md). This change repairs executable qualification defects; it is **not a new platform release or a waiver of missing evidence**. The removed 22 backlog tasks are not recreated.

## Linux and browser repairs

- Linux now calls the existing reserved-port native integration driver rather than unsupported raw `flutter test -d linux`. A real current `AUTOWORK_PORT_BASE` is mandatory; no expired allocation is reused and no port is invented by the adapter.
- Exit zero alone cannot qualify the native command. The adapter reads the official callback and protocol receipt from private scratch and checks source revision, fixture/driver/wrapper hashes, pinned SDK, exact allocated loopback listener, exit status and empty owned cleanup. Invalid/missing receipts fail. A valid automated receipt still leaves human/retained-image/EN/ES/inspired coverage **unknown**, not passed.
- Web no longer silently binds default 4173–4272. Missing or invalid allocations yield explicit unknown checks without starting a server or browser.
- The owned web server must serve the exact archive identity and `main.dart.js` hash. Playwright's own server is disabled explicitly to prevent foreign/stale-server reuse.
- Browser exit zero is insufficient. JSON reports must contain actual passing Chromium case results from the requested spec, reconciled with the counters. Missing/malformed/empty/all-skipped/flaky/error reports and expected-failure cases cannot masquerade as passing journeys.
- `scripts/run-release-command.py` owns native/browser command lifetimes. A separate Linux subreaper handles detached descendants, gives commands graceful termination before forced cleanup, reaps only owned children, and uses PID start-time plus pidfd identity for signals. Existing HTTP servers and unrelated processes are not selected for cleanup. A command exiting zero with leaked descendants is a failure.

The new process supervisor requires Linux pidfd support, consistent with this local release executor. Native Windows/Apple adapters remain unavailable; this does not pretend that a Linux supervisor supplies native builds.

## Verification

TDD reproduced the original unsupported native command and unsafe listener default, browser summary false positives, and absent descendant cleanup before implementing fixes. Tests execute the real archive/HTTP-serving path with browser command doubles and controlled real subprocess trees, including a detached grandchild and an unrelated process which must survive. They are regression tests, not actual application/device qualification.

On the isolated adapter candidate:

- `/usr/bin/python3 -m pytest test/research test/scripts -q`: **300 passed, 1 skipped, 131 subtests passed**.
- `bats test/scripts/*.bats`: **25 passed**.
- `git diff --check`: passed.

These counts describe the initial adapter patch before composition with the independently tested Android/container patches. The composed candidate at `d13be3bd` additionally includes explicit disposable-device forwarding, the [Android safety gate](ANDROID_GATE_SAFETY.md) and [F-Droid container adapter](FDROID_CONTAINER.md).

Composed validation passed **383 Python tests, 1 skipped, 131 subtests**, plus **25 Bats tests**, syntax checks, diff checks, and `shellcheck -x` on the three shell scripts. An initial ShellCheck invocation without `-x` reported SC1091 for the existing sourced identity script; the corrected invocation followed that source and passed. The actual composed F-Droid wrapper's mountless/networkless `--version` probe again exited zero with `399ac60`. Independent reviews found no remaining integration blockers after fixes for ambiguous Android flags, summary-only browser receipts and descendant cleanup.

No full Flutter or hardware/device pass is inferred from these script regressions. Actual source scanning, reproducible builds, native/browser qualification and publication were not performed by this repair.

## F-Droid tooling and genuine external inputs

The official image already pinned in `.gitlab-ci.yml` was pulled through rootless Podman using anonymous authentication, without host package or profile changes:

```text
registry.gitlab.com/fdroid/docker-executable-fdroidserver@sha256:2ad114edee50aad92fcc83fe7d801d8922780a021db070ae9f4c49f6f647c037
```

An actual no-network, no-mount `podman run --rm --network=none IMAGE --version` exited zero and printed **399ac60**. That is the observed tool identifier, not an invented semantic version. Image availability alone is not a source scan, reproducible build, Android qualification or F-Droid maintainer acceptance. The coordinator honors an explicit executable `FDROID_BIN` so isolated tooling can be selected without a host PATH/profile change.

Windows and Apple build routes are declared in GitLab CI, but the accepted campaign still defers GitLab and has no verified available remote native executor/qualification adapter. Do not confuse configured runner names with actual usable hosts, signed/notarized Apple output or store submission.

The existing Waydroid instance is already the [owner-designated Android test target](../testing/waydroid-headless.md#standing-owner-designation-use-this-waydroid-target), reaffirmed 2026-10-26; do not request a new designation. Use its documented app-replacement scope, matching gate acknowledgement and exclusive worker access. Still required before all-platform publication: actual source-bound device/gallery/accessibility checks on that target, a legitimate allocated qualification run, hardware-browser smoke and attributable image-review evidence, native Windows/macOS/Xcode execution and Apple signing/store prerequisites, and completed F-Droid scans/reproducibility plus external acceptance where applicable. No code change can supply these observations merely by setting receipt flags. No publisher or device operation was called by this adapter repair.
