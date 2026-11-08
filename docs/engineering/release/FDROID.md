# Official F-Droid release pipeline

Fractal Forge targets the official F-Droid catalog with reproducible builds. F-Droid builds each Android ABI package from the public source commit, verifies it against the developer-signed reference APK, and publishes the verified developer-signed package.

## Automated release contract

`./release.sh all --publish=X.Y.Z` includes the `fdroid` stage before publication. The stage:

1. verifies `fdroid/version.properties` matches `X.Y.Z` and the Android version code;
2. validates the upstream Fastlane listing and version-code changelog;
3. builds `armeabi-v7a`, `arm64-v8a`, and `x86_64` release APKs with `FDROID_BUILD=1`, which disables upstream signing;
4. checks each APK's application ID, version name, ABI, derived version code (`base * 10 + {1,2,3}`), and absence of a signature;
5. deletes build output, builds all three a second time, and requires byte-for-byte equality;
6. creates a deterministic fdroiddata metadata archive bound to the full release commit and the upstream reference-binary URLs.

The GitLab `fdroid` and `fdroid-scan` jobs repeat the source-build and reproducibility gates, then run official `fdroid lint` and `fdroid scanner` checks before release publication. Start the pipeline with root `release.sh`.

Prepare the next release through GitLab (including F-Droid):

```bash
./release.sh all --prepare=1.1.105
```

Outputs are written below `release-artifacts/fdroid/`:

- `fractal-forge-fdroid-vX.Y.Z-ABI-unsigned.apk` — three verification artifacts; do not distribute them;
- matching `.provenance` and `.sha256` files for each unsigned ABI APK;
- `fractal-forge-fdroiddata-vX.Y.Z.tar.gz` and `.sha256`;
- `fdroiddata/metadata/com.trebuchetdynamics.fractal.forge.yml`.

## Release preparation

Before creating each release tag:

1. Update `fdroid/version.properties` so `versionName=X.Y.Z` and `versionCode=Z` match the repository's release policy.
2. Add `fastlane/metadata/android/en-US/changelogs/Z.txt` with at most 500 characters.
3. Update the Fastlane title/descriptions when store-facing text changes. The short description must be at most 80 characters and must not end with a period.
4. Commit these changes before running the release orchestrator. The official metadata uses the full tagged commit, never a branch name.

The first release eligible for catalog submission is `1.1.97`. `v1.1.93` predates unsigned source-build support, `v1.1.94` was superseded after a clean-checkout scanner failure, `v1.1.95` was superseded when ABI splits and reproducible reference binaries became requirements, and `v1.1.96` was superseded after the catalog binary scan exposed retained unused Play Core references and APK dependency metadata. Earlier tags must not be submitted as the initial F-Droid build.

## One-time official catalog submission

The existing submission is [fdroiddata !46920](https://gitlab.com/fdroid/fdroiddata/-/merge_requests/46920). Update that merge request in place; do not open a duplicate. Its source repository is [TrebuchetDynamics/flutter-fractal-forge on GitLab](https://gitlab.com/TrebuchetDynamics/flutter-fractal-forge). Published reference APKs remain hosted on GitHub.

Official publication requires one human-reviewed fdroiddata merge:

1. Complete and push the first eligible release tag.
2. Download the `fdroid-source-build-X.Y.Z` workflow artifact or use the local output from the `fdroid` stage.
3. Extract `fractal-forge-fdroiddata-vX.Y.Z.tar.gz`.
4. Copy `fdroiddata/metadata/com.trebuchetdynamics.fractal.forge.yml` into a fork of [fdroid/fdroiddata](https://gitlab.com/fdroid/fdroiddata).
5. Run `fdroid readmeta`, `fdroid lint`, `fdroid scanner`, and `fdroid build com.trebuchetdynamics.fractal.forge` using the current F-Droid buildserver image.
6. Update the existing `New app: Fractal Forge` merge request (!46920) and address packager review.

After that merge, `UpdateCheckMode: Tags` and `fdroid/version.properties` allow F-Droid's update checker to discover later release tags and create update merge requests.

## Policy and signing notes

- The source tree includes `pubspec.lock`, and the recipe uses `flutter pub get --enforce-lockfile` with a build-local `PUB_CACHE` so dependencies are scanned.
- Flutter `3.47.9` is pinned in `fdroid/flutter.version`; the fdroiddata recipe extracts that pin and checks out the same revision from F-Droid's `flutter@stable` srclib.
- Android builds use F-Droid NDK alias `r28c`, corresponding to upstream NDK `28.2.13676358`.
- The unused Google Play Feature Delivery dependency was removed so both Play and F-Droid builds avoid a non-free runtime dependency. Android dependencies resolve only from Google Maven or Maven Central.
- Flutter 3.44.6's official Android embedding retains unused Play Store deferred-component type references. The app declares no deferred components and `releaseRuntimeClasspath` contains no Play Core dependency; this is recorded in the generated `MaintainerNotes` for packager review.
- Reference APKs are signed with the dedicated upstream upload key whose certificate SHA-256 is pinned as `AllowedAPKSigningKeys`. Keep the private key and credentials outside the repository, with tested offline backups.
- Google Play App Signing may use a different distribution key. Users switching between Play and F-Droid builds may therefore need to uninstall the existing app first.

## KIFS crash and catalog submission continuation

Status: Accepted

The owner requested F-Droid deployment, then requested this planning-only pass for the unresolved Adreno 610 crash, updated release qualification, and maintainer acceptance. This section records that scope. It does not claim a fix, a qualified candidate, or catalog publication.

### Evidence and current state

- [Reviewer finding](https://gitlab.com/fdroid/fdroiddata/-/merge_requests/46920): on 2026-10-09, MiggiV2 reported that opening KIFS Menger Sponge in v1.1.104 (1042, arm64-v8a) reproducibly killed the app on Redmi Note 8T, Android 13, Adreno 610. The log included `IOCTL_KGSL_GPU_COMMAND failed: errno 35`, followed by SIGKILL. Menger Cross 3D and Mandelbulb worked.
- [Pipeline #2832429861](https://gitlab.com/fdroid/fdroiddata/-/pipelines/2832429861) passed for fdroiddata commit `16238180cb87bc3e488bfa0bc461ca99e51eea67`. This predates the reviewer finding and cannot qualify a newer app candidate.
- The existing MR was reopened in the preceding deployment attempt. [Follow-up note 4185349142](https://gitlab.com/fdroid/fdroiddata/-/merge_requests/46920#note_4185349142) acknowledges the unresolved finding. Reopening is not publication.
- Current main already contains a candidate mitigation integrated by `fffb687a2a261afecebbb076af039ef4ffc6a19a`: `mengerSpongeDE` uses `MAX_KIFS_ITERATIONS = 8` and returns early for removed cells. The catalog sets default/max iterations to 8. `test/modules/kifs_menger_gpu_safety_test.dart` covers bounds, distinct Sponge/Cross pixels, a 64px maximum-quality render, Mandelbulb, and two analytic distance samples. These are not Adreno watchdog or release-resolution proofs. No tests or device journeys ran during this planning pass.
- `fdroid/version.properties` currently reads 1.1.122/122. This is an observed marker, not a reserved release identity or a qualified release. Reconcile live tags, reference assets, and consumed version codes before freezing the candidate. `fdroid/flutter.version` currently pins 3.47.9. Earlier MR prose uses 3.44.6.
- Existing release task `RELEASE-002-75` is closed and retains pending F-Droid/live gates. Preserve its history. The saved FDROID-001 through FDROID-005 batch below owns the KIFS/Adreno continuation. Planning observed an in-flight Waydroid task, `ACAD-013-4142ef42`; recheck device ownership before a device run.

### Planner decisions and bounds

1. Reuse the bounded fold mitigation first. Do not rewrite the shader or remove the module merely because hardware evidence is missing. Strengthen executable regression coverage around the existing behavior. Change production code only for a reproduced failure, preserving the Sponge/Cross distinction and the shared 16-float uniform layout.
2. Keep existing invariants: Sponge default/max/preset iterations 8, scale range 2.0–5.0, default steps 120, Cathedral steps 150, Cross default/max iterations 12/20 and variant 1. Preserve the existing numerical sample assertions and nonblank/distinct pixel checks. A source-string assertion is not a GPU safety result.
3. Add a focused installed-app test at `integration_test/flows/kifs_menger_safety_test.dart`. Exercise catalog entry, Cathedral, supported parameter extremes, rotation, pan/zoom, leave/re-enter, and the two working control fractals. Planner acceptance scenario: three cold starts and a 60-second interaction/render soak per default and Cathedral state, at the actual device viewport. Record elapsed time, pixel-health observations, process survival and timestamp-bounded app/GPU logs. These durations/repetitions are new planner choices, not measured results or a universal FPS promise.
4. Use the designated Waydroid instance for Android release tests under the existing consent and transport contract. Never demand a physical phone instead. Waydroid cannot resolve an Adreno-specific driver claim. Obtain a separate retest from the original reviewer or an already-authorized comparable Adreno 610 target. No new device access or purchase is implied. Without that evidence, retain the hardware-specific blocker.
5. Use one reviewed immutable release candidate with exact source, SDK, lockfile, version, certificate and ABI identities. Reuse the current build/scanner adapters and existing GitHub reference-binary destination. Do not distribute unsigned verification APKs. The limited F-Droid MR/source/ref-artifact activity requested by the owner does not resume unrelated GitLab mirroring, CI or release publication, Play, website, or other platforms.
6. Build/scan qualification can proceed while awaiting Adreno feedback once local coverage and Waydroid qualification exist. Final acceptance handoff waits for both. FDROID-004 may update the existing MR's candidate recipe and request maintainer build verification before qualification is complete. It must label that head unqualified and retain every missing gate. This is a verification request, not a qualified submission or catalog publication. Source/artifact changes invalidate the affected evidence. A missing official buildserver, signer, image/cache or network input is a specific qualification blocker, not an excuse to waive a check or install tooling silently.
7. Do not create a duplicate MR or automatically merge it. Update !46920 in place, report every maintainer response, and distinguish submitted, CI-passed, merged, and publicly indexed. Only F-Droid controls acceptance and catalog publication.

### Saved task batch and checks

| Task | Outcome | Prerequisites |
| --- | --- | --- |
| FDROID-001-29b7a401 | Reuse/verify the existing mitigation and add installed regression coverage | None |
| FDROID-002-29b7a402 | Run the focused test and required Android gate on Waydroid | FDROID-001-29b7a401 |
| FDROID-003-29b7a403 | Obtain candidate-bound Adreno 610 reviewer retest evidence | FDROID-002-29b7a402 |
| FDROID-004-29b7a404 | Freeze and qualify updated F-Droid source, metadata and three ABI reference binaries | FDROID-002-29b7a402 |
| FDROID-005-29b7a405 | Update !46920, address review and read back acceptance/catalog state | FDROID-003-29b7a403, FDROID-004-29b7a404 |

All execution checks were proposed/unrun in the planning pass. FDROID-001 local results are recorded below. FDROID-002 subsequently passed three focused KIFS Waydroid journeys; its mandatory Android gate attempts timed out and release qualification remains incomplete (see the installed evidence below). Exact commands and setup are in the task records. Local checks use the root AGENTS.md pinned offline gate. Official qualification additionally requires twice-built identical unsigned ABI APKs, lint/source and binary scans, official reproducibility against signed references, and the relevant Android release gate. The restricted local container adapter supplies lint/scanner only, not `fdroid build`, `readmeta` or `rewritemeta`; those need the official supported tool/buildserver environment or maintainer CI.

This is one complete bounded batch, not a rolling roadmap. The first task uses normal local worker execution. Device/build/publication and external follow-up belong to the coordinator with exclusive resource coordination. FDROID-003 and FDROID-004 have no product dependency on each other, but their shared live, MR and release-candidate resources must serialize mutable candidate/artifact work. FDROID-004 also reserves Waydroid for any final-candidate rerun. Do not retain a resource lease while waiting for an external reply. The saved FDROID-003/004/005 records have typed `live = "authorized"` under the existing owner deploy-fdroid grant recorded by xel in `9aba8f4d`. Its documentary date is 2026-11-07, not a verified timestamp of the original instruction. This corrects the earlier pre-grant denial; it is not a new release request or authority expansion. FDROID-004 permits qualified reference artifacts at the existing GitHub destination and an explicitly unqualified candidate recipe/CI verification request in existing !46920. FDROID-003 permits candidate-bound reviewer follow-up; FDROID-005 permits final submission/readback only after FDROID-003/004 qualify. Live admission remains coordinator-owned: bind each actual operation to its reviewed candidate/artifact hashes, satisfy prerequisites and acquire the applicable exclusive leases. Release those leases while awaiting external replies. Preserve every source, signing, reproducibility, device, privacy and compatibility gate. Waydroid consent is not publication authority. No duplicate MR, self-merge, unrelated GitLab activity, Play/website release, new credentials, paid capacity, evidence repinning or qualification waiver is implied. Expected implementation delivery is one local test/repair merge plus a release-identity/metadata merge if needed. Each code-bearing delivery retains the existing required independent review and merged-tree gates. The planning commit is separate. No runner is started, no task is dispatched, and no hardware or catalog acceptance is inferred from task creation.

### FDROID-001 local regression evidence

Baseline: `0cf41c31cc86fe7de75bd437aec0d4b670c47632`. Before edits, `flutter test --no-pub test/modules/kifs_menger_gpu_safety_test.dart --reporter expanded` passed all six tests. No local failure reproduced. The bounded fold remains a **candidate mitigation, not Adreno-qualified**. The shader and catalog remain byte-identical to this baseline:

| Retained production file | SHA-256 |
| --- | --- |
| `shaders/ifs_and_geometric/raymarched_3d/kifs_menger_gpu.frag` | `3d4db8598e7f759d690ff37729dd65f99c05c86829ea5da8c41e615850825795` |
| `lib/core/modules/builders/raymarched_3d/catalog_impl.dart` | `4192187a726eb909738ef93c52b4e23487948f0a2b5c072dab7c8911e2b5cde8` |

The existing host raster case now checks registered Default and Cathedral settings, the original 64px quality sample, and all eight scale/iteration/step boundary combinations. The supported bounds are scale 2–5, iterations 5–8 and steps 20–200. The shader still caps ray marching at 150 evaluations; testing the UI maximum of 200 does not change that cap. Each frame must be opaque, contain more than 16 RGB colors, and show horizontal foreground contrast in more than 0.5% of pixels. The background gradient varies only vertically, so it cannot satisfy the foreground check. Existing Sponge/Cross pixel distinctions, Cross 12/20 iteration bounds, Mandelbulb rendering, and center/corner analytic assertions remain.

Local verification used Flutter 3.47.9/Dart 3.13.7 from the shared cache and `/usr/bin/python3` 3.12.3. The pinned version matched `fdroid/flutter.version`; pytest, Jinja2 and `markupsafe.soft_str` imports passed. `flutter pub get --offline --enforce-lockfile` passed. The lockfile SHA-256 remains `d919ab7eb6ad10b5939c81092b6f1657ba84642109ca677684184ccf30c55451`.

- The focused safety file passed all six tests after extension.
- The required five-file command passed all 20 tests: safety, `three_d_catalog_identity_test.dart`, `uniform_layout_test.dart`, `raymarched_3d_builder_test.dart` and `raymarched_3d_pan_target_test.dart`.
- `flutter analyze --no-pub`, Dart formatting and `git diff --check` passed.
- Installed execution: **NOT_RUN**, deferred to FDROID-002. Host raster results are not native viewport, watchdog, hardware-GPU or release-build evidence. The coordinator owns the merged-tree full gate and independent review.

### Installed regression procedure for FDROID-002

`integration_test/flows/kifs_menger_safety_test.dart` implements one process journey. It uses the registered catalog cards and viewer, selects Cathedral through the preset sheet, and keeps the current viewport and device pixel ratio. It runs a wall-clock soak of at least 60 seconds for each of Default and Cathedral. Rotation and two-finger pan/zoom must change the controller state. Exact parameter extremes use the controller's public editing seam. The journey then leaves and re-enters KIFS and opens Menger Cross variant 1 and Mandelbulb as controls.

The test captures only the renderer boundary, not viewer chrome. It rejects missing shader snapshots, exceptions, transparent pixels, blank frames and background-only gradients. `KIFS_SAMPLE` records UTC time, PID, effective parameters/camera, pixel dimensions, sampled color count and horizontal foreground fraction. `KIFS_COMPLETE` and integration `reportData` record both soak durations and process survival only after the full journey succeeds. A start line or partial samples are not a pass. Thresholds are regression signals, not image-quality or performance certification.

After FDROID-002 admits the designated Waydroid target, use a clean candidate checkout and the pinned offline environment. Encode the existing device consent with matching `ANDROID_DEVICE` and `ANDROID_DISPOSABLE_DEVICE`. Run three separate process launches, not three widget remounts:

```sh
test -n "$ANDROID_DEVICE" && test "$ANDROID_DEVICE" = "$ANDROID_DISPOSABLE_DEVICE" || exit 1
test -z "$(git status --porcelain)" || exit 1
source_revision="$(git rev-parse HEAD)"
for launch in 1 2 3; do
  adb -s "$ANDROID_DEVICE" shell am force-stop com.trebuchetdynamics.fractal.forge || exit 1
  autowork-run timeout 600 flutter test --no-pub --no-uninstall \
    integration_test/flows/kifs_menger_safety_test.dart -d "$ANDROID_DEVICE" \
    --dart-define=FORCE_GPU_RENDER=true \
    --dart-define=KIFS_SOURCE="$source_revision" \
    --dart-define=KIFS_COLD_START="$launch" --reporter expanded \
    > "$TMPDIR/kifs-cold-$launch.log" 2>&1 || exit 1
done
```

Retain each command's exit code, complete test log and timestamp-bounded app/GPU logs under the existing device-test contract. Do not clear logs or reset the device. Reconcile all three launch IDs, start/end UTC times, PIDs, two completed soaks, eight extreme samples, controls and re-entry before claiming three cold-start passes. The test cannot collect Android driver logs or attest external force-stop operations itself. FDROID-002 owns that evidence and the Android release gate. Waydroid remains container/emulator evidence; FDROID-003 still owns the candidate-bound Adreno retest.

### FDROID-002 installed evidence — 2026-11-08

[Sanitized receipts and resume instructions](../../qa/fdroid-kifs/README.md)
record three passing cold-start journeys at source
`6ec81df95e936fb82c9a0a13f0aa4a80113de6c1`, with all six soaks exceeding
60 seconds, eight supported parameter extremes per launch, gestures, re-entry,
Cross/Mandelbulb controls, nonblank/distinct frames and bounded app/GPU logs.
The reviewed production source is unchanged; the source commit repairs the
installed test stimulus and preserves shared logcat in the gate. The test uses
Flutter's registered text input, not the native IME. Cross's fixed variant uses
the registered default when absent from editable controller params.

The actual target was booted Android 13 Waydroid, native 1600×2560/DPR 1.5,
AMD/Mesa OpenGL ES—not Adreno. Tested debug identity was `1.1.0+38`; it is not
the F-Droid marker `1.1.122/122` or a frozen production release. Receipts identify
each instrumented APK hash, source, SDK, lockfile and process interval.

**Android gate: INCOMPLETE, not passed.** The full invocation timed out after
1,700 seconds during host tests. A separate bounded device-only continuation
also timed out during integration execution. Production build, restoration,
offline, performance and production-soak qualification remain pending. Resume
the full gate under exclusive ownership with adequate scheduled runtime; retain
these timeouts. No publication occurred. Waydroid is container/emulator evidence;
FDROID-003's candidate-bound Adreno 610 verdict remains explicitly pending.

### FDROID-003 reviewer readback — 2026-11-08

The [sanitized discussion readback and exact resume condition](../../qa/fdroid-kifs/README.md#fdroid-003-adreno-reviewer-evidence--unresolved)
identify MiggiV2's unresolved crash thread in !46920. The crash-related notes
retain the v1.1.104 finding and existing acknowledgement, not a mitigated
candidate retest. **FDROID-003 remains open; Adreno confirmation is pending.**
No new request was posted: FDROID-002's Android gate is incomplete, and its debug
receipts supply no qualified production APK with a safe artifact URL and hash.
Resume the existing-thread request once the reviewed source/version and exact
distributable APK are bound. Do not substitute Waydroid or historical CI evidence.
Any later candidate change requires renewed hardware binding before final submission.

### FDROID-004 local build and scan evidence — 2026-11-08

[Source-bound hashes, live inventory and qualification gaps](../../qa/fdroid-kifs/README.md#fdroid-004-source-build-and-scan-evidence--unqualified)
record two byte-identical clean builds for each unsigned ABI at source
`0e4d9338ee581a555da86293cae7a4768bff769f`, using the unchanged
`1.1.122/122` marker. Package, ABI, derived codes 1221/1222/1223 and absence
of signatures passed verification. The cached official adapter (`399ac60`)
passed lint and preparation/source scans for all three recipes with exactly one
terminal `0 problems found` summary. These are **local build/scan results, not
complete release qualification**.

Readback still shows !46920 at v1.1.104 and GitHub's latest published release at
v1.1.112. Neither is the tested source or a reusable reference for it. No release
identity was changed or reserved, and no MR, tag, reference asset or catalog was
published. Signed references, official buildserver verification and the
final-candidate Android gate remain pending. FDROID-004 must not be treated as a
qualified handoff to FDROID-005. The coordinator can request explicitly unqualified
maintainer build verification in !46920 during FDROID-004; that prerequisite must
not be deferred to FDROID-005. Adreno confirmation remains independent.

### FDROID-005 final submission disposition — 2026-11-08

[Submission verdicts and resume condition](../../qa/fdroid-kifs/README.md#fdroid-005-submission-disposition--2026-11-08)
record **NOT_RUN final submission and NOT_VERIFIED catalog publication** at
baseline `f081af5d1a70c5a3f8c46701879927a59f6ac16c`. FDROID-003/004 task-store
closure is not their missing live qualification. Candidate-bound Adreno evidence,
signed references, official verification and the final Android gate remain
pending. This pass performed no live operation or fresh MR/catalog readback.
Historical !46920 head/pipeline results cannot qualify the mitigated candidate.

Resume final review/submission only after those prerequisites qualify the same
source/artifact identities under coordinator admission and operation leases.
Maintainer acceptance and matching public package/version/source/hash/signer
readback remain separate external gates. Keep acceptance open until observed;
metadata upload, CI success and merge alone are not publication.

Authoritative references:

- [Submitting to F-Droid quick start](https://f-droid.org/en/docs/Submitting_to_F-Droid_Quick_Start_Guide/)
- [Build metadata reference](https://f-droid.org/en/docs/Build_Metadata_Reference/)
- [F-Droid inclusion policy](https://f-droid.org/en/docs/Inclusion_Policy/)
- [Reproducible builds](https://f-droid.org/en/docs/Reproducible_Builds/)
