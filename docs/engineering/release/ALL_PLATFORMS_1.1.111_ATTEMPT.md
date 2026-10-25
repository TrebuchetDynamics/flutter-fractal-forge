# All-platform 1.1.111 continuation — 2026-10-25

## Result: partial, not an all-platform release

The user authorized all-platform release and Git commit/push after the confirmed
Play upload. Android/Play was preserved and read back; independent non-Android
builders/checks were attempted where the host supported them. **No additional
platform was published in this continuation.** Missing or failed checks were not
waived, and GitLab was not used.

| Lane | Actual outcome | Publication |
| --- | --- | --- |
| Android/Play | Existing 1.1.111 (111), exact AAB hash and production/completed status confirmed again | Previously published; no rebuild or repeat upload |
| Web | Release archive, all asset hashes, two edited-image browser journeys and one saved-data test pass | Not attempted: documented pre-deploy hardware-browser smoke remains unestablished by this SSH/headless run |
| Linux | Native release archive builds; full journey reports 11 passed, 1 skipped, 1 failed | Not attempted: edited Mandelbrot/Mandelbulb journey failed; existing retained-image, EN/ES/inspired-entry and attributable human-review requirements also remain |
| F-Droid | Current-host preflight finds no official F-Droid CLI | Skipped-unavailable: official source scan/reproducibility qualification unavailable; external maintainer acceptance is separate |
| Windows | No supported Windows native host in this execution environment | Skipped-unavailable; no native journey/export proof |
| macOS | No Darwin/Xcode host in this execution environment | Skipped-unavailable; no native journey, signing/notarization proof |
| iOS | No Darwin/Xcode host in this execution environment | Skipped-unavailable; no signed/provisioned build, journey/store qualification or configured approved store publisher |

The existing [web deployment procedure](../../deployment/WEB_PREVIEW_GITHUB_PAGES.md#pre-deploy-hardware-smoke)
requires a normal hardware-accelerated browser smoke before public deployment;
headless Chromium results below are not recorded as that check. Current live web
version/review/availability was not queried or changed in this continuation.

## Frozen source and checks

All new platform work ran in an isolated worktree at the actual Play build source:
`5f00e5a384faf1b6be1656f17277f5851feeec73`, version/build **1.1.111 / 111**, pinned
Flutter **3.44.6**, lockfile SHA-256
`22b29dbd8f71276012a54b9bdc62ba88408f967a86b34075986c17e1c4506ec3`.
Runtime/build/test files were compared with the already-tested checkout before
execution: 1,710 tracked files matched, ordered path/NUL/content SHA-256
`fc797687b50da57fee91ba7d83c36a41ebd9970775b7790311bf98cabd5752f8`.
Checkout-local dependency metadata was regenerated offline with the pinned SDK;
no producer checkout's project-root package binding was copied.

The existing common gate was actually rerun in this clean source checkout:
privacy text, frozen source integrity, analysis and the full Flutter suite passed
(**2,990 passed, 8 skipped**). The earlier full offline gate's Python/Bats outcomes
remain separately recorded in the [Play record](PLAY_1.1.111.md); this invocation
of `common_gate` does not claim to rerun those families.

Later main integration `dffd81a551c13ce12f97bbb162a1fce5f64d7d34` introduced the
Number Walls feature while these checks were running. Those new app/shader/
manifest changes were **not injected into the frozen 111 candidate**. Git delivery
of later work and a new production release identity require their own matching
checks; an old artifact receipt is not qualification of that new composition.

## Actual builder/qualification evidence

The existing `scripts/release_platform_lanes.py` lane functions were used for host
availability, build/provenance verification and mapped qualification. No new
publisher implementation, authentication bypass, fake seven-lane prepare result
or modified source identity was used. The observation JSON is explicitly **not**
an input accepted by `--publish`.

The existing prepare CLI cannot select lanes or import the already-published Play
receipt; rerunning it would rebuild Android. That limitation was preserved rather
than manufacturing a verified Android lane or reusing version 111 for a changed
bundle. Any future automated campaign reuse needs a supported, tested receipt/
lane-reuse mechanism with the same identity and evidence gates.

### Web

- `scripts/release.sh web-build --prepare=1.1.111 --build-number=111`, through the
  existing coordinator's local-stage environment: build and provenance passed.
- Archive: `fractal-forge-web-v1.1.111.tar.gz`, **22,661,139 bytes**, SHA-256
  `e78e6aff7f23e644d759b164c21051c57328ed8e5add333ca08fc3a8ad7d5d75`.
- Archive inventory and **631** file hashes verified against embedded identity.
- `web-image-creation-journey.spec.mjs`: **2 passed**, no flaky/skipped cases.
- `production-saved-session.spec.mjs`: **1 passed**, no flaky/skipped cases.
- Existing Playwright modules/browser caches and cached Wrangler were available
  without installation. Only configured Cloudflare key **presence** was checked;
  credential values were not read for publication or printed. No deploy occurred.

### Linux

- `scripts/release.sh linux --prepare=1.1.111 --build-number=111`, through the
  existing local-stage environment: build and provenance passed.
- Archive: `fractal-forge-linux-x64-v1.1.111.tar.gz`, **21,628,745 bytes**, SHA-256
  `f5dc5ed6ffd70cf8053d4d4ee210a59555f06688ec178d73b5e2bca6486109e5`.
- The actual full `user_flows_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true`
  command ran on an owned Xvfb display with TCP disabled, not the user's desktop.
- `Linux 2D and 3D journey saves edited mathematical PNG artifacts` failed with
  `Bad state: No element` in `scrollUntilVisible` at `user_flows_test.dart:270`,
  after the Mandelbrot save. A complete two-image journey was not established.
- The native qualification adapter also deliberately retains unknown requirements
  for image comparison, EN/ES/inspired coverage and attributable human review,
  even when an automated command passes. A build alone cannot admit Linux.

## Retained local artifacts and next inputs

The ignored execution directory is
`.worktrees/all-platform-1.1.111-20261025/release-artifacts/all-platform-1.1.111/`:

- `observed-results.json`: separate per-lane outcomes, frozen identity, and actual
  Play preservation readback; `publishersCalled` is false.
- `stage-logs/common/`, `stage-logs/web/`, `stage-logs/linux/`: commands, exits,
  output, provenance and qualification records.
- `scratch/web-browser_journey-*/` and `scratch/web-saved_data-*/`: JSON/HTML
  reports, screenshots/results and stdout/stderr retained outside ephemeral
  system scratch cleanup.
- The two build archives and provenance sidecars above.

Next: supply actual hardware-browser smoke evidence for web, repair/retest the
Linux journey and complete its remaining review gates, provide supported native
hosts and signing/store qualification for Windows/Apple, and make official
F-Droid scan/reproducibility tooling available through the approved route. Do not
publish empty GitHub releases, label unsigned Apple archives store releases, or
claim F-Droid delivery without maintainer acceptance.

## Git delivery

The verified Waydroid fixes and Play record were committed and pushed to origin
main as `0dc1158fe4b2338196ffcd6febacc49a986777d8`. The original local release
branch, including the built-source ancestor and publication note, was also pushed
as `release/play-1.1.111-20261025` at
`e867d1b65f9966c5ae3b7bd1f9f48c9142cc9a43`. Both refs were read back from origin.
Runtime `.pi-subagents/` logs/transcripts are not source delivery and remain
untracked; credentials, build outputs and release artifacts were not committed.
