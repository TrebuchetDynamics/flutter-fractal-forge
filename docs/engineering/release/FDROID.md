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
- Existing release task `RELEASE-002-75` is closed and retains pending F-Droid/live gates. Preserve its history. No existing task record names the KIFS/Adreno finding. The current runner has an in-flight Waydroid task, `ACAD-013-4142ef42`; coordinate device ownership rather than starting a competing run.

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

All execution checks are proposed/unrun in this pass. Exact commands and setup are in the task records. Local checks use the root AGENTS.md pinned offline gate. Official qualification additionally requires twice-built identical unsigned ABI APKs, lint/source and binary scans, official reproducibility against signed references, and the relevant Android release gate. The restricted local container adapter supplies lint/scanner only, not `fdroid build`, `readmeta` or `rewritemeta`; those need the official supported tool/buildserver environment or maintainer CI.

This is one complete bounded batch, not a rolling roadmap. The first task uses normal local worker execution. Device/build/publication and external follow-up belong to the coordinator with exclusive resource coordination. FDROID-003 and FDROID-004 have no product dependency on each other, but their shared live, MR and release-candidate resources must serialize mutable candidate/artifact work. FDROID-004 also reserves Waydroid for any final-candidate rerun. Do not retain a resource lease while waiting for an external reply. Live records remain coordinator-owned with `live = "denied"` until that coordinator records the structured grant for the actual operation/candidate under the existing deployment request and Waydroid consent. This is admission bookkeeping, not a request for renewed target or publication approval. Expected implementation delivery is one local test/repair merge plus a release-identity/metadata merge if needed. Each code-bearing delivery retains the existing required independent review and merged-tree gates. The planning commit is separate. No runner is started, no task is dispatched, and no hardware or catalog acceptance is inferred from task creation.

Authoritative references:

- [Submitting to F-Droid quick start](https://f-droid.org/en/docs/Submitting_to_F-Droid_Quick_Start_Guide/)
- [Build metadata reference](https://f-droid.org/en/docs/Build_Metadata_Reference/)
- [F-Droid inclusion policy](https://f-droid.org/en/docs/Inclusion_Policy/)
- [Reproducible builds](https://f-droid.org/en/docs/Reproducible_Builds/)
