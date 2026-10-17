# Multi-platform releases

## Independent platform release campaign

Status: Accepted

The 2026-10-17 owner request supersedes the all-or-nothing publication policy below: attempt every platform, skip a platform-specific error, and continue qualified independent lanes. See [the accepted policy](../../../PRD.md#independent-platform-release-policy). This is a planned workflow, NOT implemented behavior. The current launcher/CI/evidence/publisher path still depends on GitLab and a complete artifact set. Do not invoke the no-argument release command expecting best-effort behavior.

The PRD's explicit GitLab deferral governs this campaign. The older resumption statement below is conflicting operating history, not new authorization. Keep GitLab login, mirror, CI dispatch and release publication excluded unless separately resumed. Implement a host-independent route reusing the existing local/native builders and evidence checks; never set GITLAB_CI or fabricate CI/device evidence to get around a guard.

| Lane | Candidate and destination | Required lane-local proof |
| --- | --- | --- |
| Android/Play | Signed AAB and configured ABI APKs; Play production/completed | Existing device/journey/gallery checks; certificate/version/hash validation; live upload readback |
| F-Droid | Reproducible unsigned APKs plus metadata | Existing reproducibility, official lint/source scans and relevant Android qualification; maintainer acceptance is external, not automatic production publication |
| Web | Verified web bundle; existing Cloudflare Pages production project | Real 2D/3D edited-state PNG journey, browser/saved-data checks, asset validation and deployed-site readback |
| Linux | Verified native tarball; published GitHub release | Native launch/journey/export checks, packaging/provenance/checksums and download readback |
| Windows | Verified native ZIP; published GitHub release | Actual supported Windows host, native journey/export/packaging checks and download readback |
| macOS | Distribution-ready native app/package; configured production distribution | Actual macOS host, native journey/export, required signing/notarization and artifact readback; unsigned archive alone is insufficient |
| iOS | Signed/provisioned production submission | Actual macOS/Xcode host, iOS journey/export and store prerequisites; current unsigned archive path is insufficient |

Planner's orchestration contract:
- Snapshot candidate identity once. Per-lane records bind exact artifacts, sizes/hashes, source/version/SDK/lock identity, checks, error stage, skipped reason and observed publication identifiers. No stale prior-version substitution, missing-row success, empty-artifact publication or cross-lane credential prerequisite.
- Keep the common source/integrity/privacy/compatibility validation barrier. Build each independent lane with isolated output; gate its evidence and publisher on that lane's required checks, not the existence of unrelated artifacts. Generate checksums/SBOM/notices for the admitted subset only while retaining explicit records for every omitted lane.
- A stage dependency prevents only its own lane/dependents. Do not implement this as global `allow_failure`, `|| true`, disabled validation, or marking missing artifacts verified. A shared defect stops all affected lanes and is not relabeled platform-local merely to publish.
- Use existing build/test timeouts; planner's initial queue-availability deadline is 15 minutes per unavailable native host, explicitly configurable before the run. Retain timing/timeout/error logs. Missing hosts/signing/credentials are skipped-unavailable, not fake build attempts; no installation or paid capacity is implied by this plan.
- Reuse the same immutable artifacts on retry. Read remote tag/release/deployment/store state before repeating an uncertain write. No force-tag, destructive rollback or repeat Play upload based only on a timeout. Keep unknown publication separate from skipped-failed.
- The final machine/human report says complete or partial with per-lane proof; all-skipped/common-gate failure is nonzero and publishes nothing. A partial success must not claim all-platform readiness. Apple store/F-Droid acceptance still require their real external outcomes.

Preparation and publication are separate queue tasks. Apple signing/store submission is not implemented by the current scripts: if no existing approved production route, signing or native host is available, record skipped-unavailable; this campaign does not authorize building a new store-submission system or buying access. No proposed CLI flag in this plan is an existing supported command. Existing `REL-JOURNEY-*` and their live follow-ups retain their IDs, proof and access gates; reuse them rather than creating duplicate product qualification tasks. Existing user task order/focus and paused schedules are unchanged.

## Current release status

Historical operating note (2026-10-16; conflicts with the current PRD deferral):
this document recorded resumed GitLab release scope. GitLab remains the only CI
executor, and every existing build, Android-device, cross-platform journey and
evidence gate still applies; this is not a qualification waiver. GitLab `main` is
mirrored at the release commit and publication is dispatched through
`scripts/gitlab_release.py` (`release.sh`). Even `--target play` still depends on
GitLab CI; there is no verified non-GitLab release route.

Readiness as of 2026-10-16: the GitLab project's `main` pipelines fail with zero
jobs because no runners are available for the required tags
(`saas-linux-medium-amd64`, `saas-windows-medium-amd64`, `saas-macos-medium-m1`,
`fractal-android-device`). Before a full release can finish, verify the GitLab
account identity, register/enable runners for those tags (including a protected
tagged Android device runner with a connected device), and configure the
protected CI/CD variables below. Publication is therefore not yet dispatched; do
not bypass guards or pretend that this documentation changes script behavior.

Run the complete release from the repository root:

```bash
./release.sh                       # detect next patch, prepare, push, release, wait
./release.sh --dry-run             # preview next patch using cached tags; no changes/network
./release.sh --prepare             # automatically prepare/build/verify without publication
./release.sh --publish=1.1.105      # dispatch an explicitly prepared version
PLAY_TRACK=production PLAY_RELEASE_STATUS=completed ./release.sh --target play --publish=1.1.108
```

No arguments means the full publishing pipeline. The script requires committed
app changes. `--target play` limits publication to Play: it does not deploy the
website or publish GitLab/GitHub releases, and keeps every existing validation,
platform-build, Android-device, F-Droid-scan and evidence gate. Play defaults to
production/completed. Explicitly set `PLAY_TRACK=internal PLAY_RELEASE_STATUS=draft`
only when a nonproduction release is requested. Play-only preflight does not need
GitHub/Cloudflare credentials.

For automatic version preparation, the script requires committed
app changes, fetches tags from `origin` and `gitlab`, then increments the highest
numeric `vMAJOR.MINOR.PATCH` tag. An already prepared version newer than the tags
is reused after a failed preparation/dispatch. The patch is the Android build
number. The script updates `fdroid/version.properties`, generates missing
Fastlane and changelog notes from commit subjects, commits only those metadata
files, and pushes both remotes before dispatching CI. Existing authored release
notes are preserved. `pubspec.yaml` remains the development version.

Both remotes must exist and the GitLab branch must be protected. A dirty tree,
divergent/behind branch, failed push, or mismatched pipeline commit stops the
release; the script never force-pushes. If a release tag already exists and a
publication job fails, retry that job in GitLab using its verified artifacts.
The no-argument command starts the next patch after a tagged release.

GitLab project: <https://gitlab.com/TrebuchetDynamics/flutter-fractal-forge>.
Configure `glab auth login --hostname gitlab.com`; `GLAB_BIN` can select an
installation outside PATH. `GITLAB_RELEASE_PROJECT` or `--project` selects another
GitLab project. The CLI checks authentication and submits one pipeline; it never
builds locally or dispatches GitHub Actions. `--no-wait` returns the pipeline URL
immediately; Ctrl-C stops watching without canceling the remote build. The default
wait is four hours, adjustable with `--timeout=SECONDS`.

For the first mirror setup:

```bash
git remote add gitlab https://gitlab.com/TrebuchetDynamics/flutter-fractal-forge.git
git push gitlab main --tags
```

The automatic release command pushes both remotes. For ordinary development CI,
push the branch to GitLab. GitHub is the upstream source and published
release mirror; GitLab is the **only CI executor**. `.gitlab-ci.yml` runs analyzer,
full Flutter host tests, shell/Python regression tests, research tests, and the
emitted Dart integration check for branches and merge requests. The protected
default branch also runs the five Android integration suites on the device runner. No active GitHub
Actions workflows remain. GitHub-only pushes do not trigger GitLab checks: push
the same branch to GitLab and review its pipeline there.

## Release jobs and gates

| Job | Result |
| --- | --- |
| android | Verified signed AAB and three ABI APKs |
| device-gate | Existing Android integration, offline, soak and performance checks |
| linux | Linux x64 tarball |
| windows | Native Windows x64 ZIP |
| apple (macos / ios) | Native unsigned application archives |
| web | Validated web bundle, including landing assets and shaders |
| fdroid | Twice-built reproducible unsigned APKs and fdroiddata metadata |
| fdroid-scan | Official metadata lint and source scan for all three ABIs |
| evidence | Complete artifact set, commit/version/checksum verification, SBOM, notices, device evidence |
| publish | GitLab packages/release plus published GitHub release |
| deploy-web / deploy-play | Deploy the verified web archive and upload the verified AAB |

Release jobs run only for an explicit API/web pipeline on a protected branch.
Ordinary pushes and tags never publish. Every build and the Android device gate
must succeed before evidence can pass. Both evidence and F-Droid scanning must
succeed before publication. There are no optional platform failures in the current implementation; changing that behavior is explicitly planned by the newer independent-platform policy above, not already delivered.

Publication jobs share a resource group. Play defaults to `production` and
`completed`; explicit `PLAY_TRACK` and `PLAY_RELEASE_STATUS` overrides remain
available for owner-requested test releases. Google Play listing metadata is updated
by the existing uploader. GitHub releases are published by default; explicitly set
`GITHUB_RELEASE_DRAFT=true` for a requested draft. GitLab releases are published with
checksummed downloads. Deployment retries reuse the same pipeline's evidence;
retry failed jobs in GitLab instead of rebuilding already-published binaries.
Artifacts expire after seven days; published GitLab packages remain available.

The pipeline does not make Apple archives App Store-ready: certificates,
provisioning, notarization, and Apple store submission are still required.
F-Droid has no APK upload publication API; its maintainers must accept metadata
and its own builders reproduce the APKs. These are explicit limits, not bypassed
checks. This migration preserves the existing unsigned Apple build behavior.

## Runner setup

- Linux jobs: GitLab hosted `saas-linux-medium-amd64`, a digest-pinned
  Android toolchain image; bootstrap installs Flutter **3.44.6** from the official Git tag.
- Windows: GitLab hosted `saas-windows-medium-amd64`; Git Bash and Visual Studio
  must be available. The job installs the pinned Flutter checkout.
- Apple: GitLab hosted `saas-macos-medium-m1`, `macos-15-xcode-16`. Hosted macOS
  requires a supported GitLab plan or open-source-program access. Alternatively,
  use an owned macOS runner and change its tag/image in `.gitlab-ci.yml`.
- Device gate: register a **protected**, tagged shell runner
  `fractal-android-device`, with Flutter 3.44.6, Android SDK/JDK, adb, and a usable
  Android device (or the existing Waydroid environment). Disable untagged jobs.
  The device gate is serialized. Do not run untrusted merge-request jobs on it.

GitLab account identity verification is required before CI jobs can run (this is
separate from `glab` login). Runner access and compute quota must be configured
before a full release
can finish. Missing native/device runners leave jobs pending; they are not
silently skipped. `fdroid/flutter.version` is the canonical SDK pin used by
Linux/native bootstrap and F-Droid metadata. The container supplies Android
build tools; its bundled Flutter version is replaced by the canonical pin.

## Protected CI variables

Create these in GitLab **Settings → CI/CD → Variables**, restricted to protected
refs. Use GitLab **File** type where specified. Do not commit their contents.

| Variable | Type | Purpose |
| --- | --- | --- |
| `ANDROID_KEYSTORE_BASE64` | Masked variable | Base64-encoded Android upload keystore (same pinned certificate) |
| `ANDROID_KEY_PROPERTIES_FILE` | File | `storePassword`, `keyPassword`, `keyAlias`; job adds absolute `storeFile` |
| `PLAY_SERVICE_ACCOUNT_JSON` | File | Existing Play service account JSON |
| `GH_TOKEN` | Masked variable | GitHub repo contents write for release and tag |
| `CLOUDFLARE_API_TOKEN` | Masked variable | Scoped Pages deployment token |
| `CLOUDFLARE_ACCOUNT_ID` | Variable | Account containing the Pages project, if account discovery is ambiguous |

Android signing is needed for both prepare and publish. Publication credentials
are checked before a publishing pipeline starts its builds. GitLab package and
release publication uses its job-scoped `CI_JOB_TOKEN`. Keep the default branch
protected and enable GitLab's prevention of outdated deployment jobs. No tokens
are placed in command arguments, artifacts, or repository files by the new
publisher; signing properties are job-local and excluded from artifacts.
