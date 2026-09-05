# GitLab releases

Run releases from the repository root:

```bash
./release.sh all --dry-run
./release.sh all --prepare=1.1.105   # build and verify, without publishing
./release.sh all --publish=1.1.105   # build, verify, publish; waits for completion
```

Replace the example version with the next unused release. The patch is the
Android build number. Commit `fdroid/version.properties` with the same identity,
update release notes, and push that commit to **both** GitHub and GitLab first.
The script refuses a dirty tree, unprotected branch, mismatched remote commit,
or mismatched version marker. An existing tag cannot be moved to another commit.
`--build-number=105` is optional when it matches the version patch.

GitLab project: <https://gitlab.com/tamez.jm/flutter-fractal-forge>.
Configure `glab auth login --hostname gitlab.com`; `GLAB_BIN` can select an
installation outside PATH. `GITLAB_RELEASE_PROJECT` or `--project` selects another
GitLab project. The CLI checks authentication and submits one pipeline; it never
builds locally or dispatches GitHub Actions. `--no-wait` returns the pipeline URL
immediately; Ctrl-C stops watching without canceling the remote build. The default
wait is four hours, adjustable with `--timeout=SECONDS`.

For the first mirror setup:

```bash
git remote add gitlab https://gitlab.com/tamez.jm/flutter-fractal-forge.git
git push gitlab main --tags
```

Push subsequent changes to both remotes. GitHub is the upstream source and draft
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
| publish | GitLab packages/release plus existing GitHub draft release |
| deploy-web / deploy-play | Deploy the verified web archive and upload the verified AAB |

Release jobs run only for an explicit API/web pipeline on a protected branch.
Ordinary pushes and tags never publish. Every build and the Android device gate
must succeed before evidence can pass. Both evidence and F-Droid scanning must
succeed before publication. There are no optional platform failures.

Publication jobs share a resource group. Play defaults remain `internal` and
`draft`; set protected GitLab variables `PLAY_TRACK=production` and
`PLAY_RELEASE_STATUS=completed` when production rollout is intended. Google Play
listing metadata is updated by the existing uploader. GitHub releases remain
**drafts**, matching the prior release policy. GitLab releases are published with
checksummed downloads. Deployment retries reuse the same pipeline's evidence;
retry failed jobs in GitLab instead of rebuilding already-published binaries.
Artifacts expire after seven days; published GitLab packages remain available.

The pipeline does not make Apple archives App Store-ready: certificates,
provisioning, notarization, and Apple store submission are still required.
F-Droid has no APK upload publication API; its maintainers must accept metadata
and its own builders reproduce the APKs. These are explicit limits, not bypassed
checks. This migration preserves the existing unsigned Apple build behavior.

## Runner setup

- Linux jobs: GitLab hosted `saas-linux-medium-amd64`, Flutter image **3.44.6**.
- Windows: GitLab hosted `saas-windows-medium-amd64`; Git Bash and Visual Studio
  must be available. The job installs the pinned Flutter checkout.
- Apple: GitLab hosted `saas-macos-medium-m1`, `macos-15-xcode-16`. Hosted macOS
  requires a supported GitLab plan or open-source-program access. Alternatively,
  use an owned macOS runner and change its tag/image in `.gitlab-ci.yml`.
- Device gate: register a **protected**, tagged shell runner
  `fractal-android-device`, with Flutter 3.44.6, Android SDK/JDK, adb, and a usable
  Android device (or the existing Waydroid environment). Disable untagged jobs.
  The device gate is serialized. Do not run untrusted merge-request jobs on it.

Runner access and GitLab compute quota must be configured before a full release
can finish. Missing native/device runners leave jobs pending; they are not
silently skipped. `fdroid/flutter.version` is the canonical SDK pin used by
native bootstrap and F-Droid metadata; update the Linux image/pin assertion in
`.gitlab-ci.yml` alongside it when upgrading Flutter.

## Protected CI variables

Create these in GitLab **Settings → CI/CD → Variables**, restricted to protected
refs. Use GitLab **File** type where specified. Do not commit their contents.

| Variable | Type | Purpose |
| --- | --- | --- |
| `ANDROID_KEYSTORE_BASE64` | Masked variable | Base64-encoded Android upload keystore (same pinned certificate) |
| `ANDROID_KEY_PROPERTIES_FILE` | File | `storePassword`, `keyPassword`, `keyAlias`; job adds absolute `storeFile` |
| `PLAY_SERVICE_ACCOUNT_JSON` | File | Existing Play service account JSON |
| `GH_TOKEN` | Masked variable | GitHub repo contents write for release draft and tag |
| `CLOUDFLARE_API_TOKEN` | Masked variable | Scoped Pages deployment token |
| `CLOUDFLARE_ACCOUNT_ID` | Variable | Account containing the Pages project, if account discovery is ambiguous |

Android signing is needed for both prepare and publish. Publication credentials
are checked before a publishing pipeline starts its builds. GitLab package and
release publication uses its job-scoped `CI_JOB_TOKEN`. Keep the default branch
protected and enable GitLab's prevention of outdated deployment jobs. No tokens
are placed in command arguments, artifacts, or repository files by the new
publisher; signing properties are job-local and excluded from artifacts.
