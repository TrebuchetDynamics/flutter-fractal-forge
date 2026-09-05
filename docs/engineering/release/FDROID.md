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

Official publication requires one human-reviewed fdroiddata merge:

1. Complete and push the first eligible release tag.
2. Download the `fdroid-source-build-X.Y.Z` workflow artifact or use the local output from the `fdroid` stage.
3. Extract `fractal-forge-fdroiddata-vX.Y.Z.tar.gz`.
4. Copy `fdroiddata/metadata/com.trebuchetdynamics.fractal.forge.yml` into a fork of [fdroid/fdroiddata](https://gitlab.com/fdroid/fdroiddata).
5. Run `fdroid readmeta`, `fdroid lint`, `fdroid scanner`, and `fdroid build com.trebuchetdynamics.fractal.forge` using the current F-Droid buildserver image.
6. Open a `New app: Fractal Forge` merge request using the App Inclusion template and address packager review.

After that merge, `UpdateCheckMode: Tags` and `fdroid/version.properties` allow F-Droid's update checker to discover later release tags and create update merge requests.

## Policy and signing notes

- The source tree includes `pubspec.lock`, and the recipe uses `flutter pub get --enforce-lockfile` with a build-local `PUB_CACHE` so dependencies are scanned.
- Flutter `3.44.6` is pinned in `fdroid/flutter.version`; the fdroiddata recipe extracts that pin and checks out the same revision from F-Droid's `flutter@stable` srclib.
- Android builds use F-Droid NDK alias `r28c`, corresponding to upstream NDK `28.2.13676358`.
- The unused Google Play Feature Delivery dependency was removed so both Play and F-Droid builds avoid a non-free runtime dependency. Android dependencies resolve only from Google Maven or Maven Central.
- Flutter 3.44.6's official Android embedding retains unused Play Store deferred-component type references. The app declares no deferred components and `releaseRuntimeClasspath` contains no Play Core dependency; this is recorded in the generated `MaintainerNotes` for packager review.
- Reference APKs are signed with the dedicated upstream upload key whose certificate SHA-256 is pinned as `AllowedAPKSigningKeys`. Keep the private key and credentials outside the repository, with tested offline backups.
- Google Play App Signing may use a different distribution key. Users switching between Play and F-Droid builds may therefore need to uninstall the existing app first.

Authoritative references:

- [Submitting to F-Droid quick start](https://f-droid.org/en/docs/Submitting_to_F-Droid_Quick_Start_Guide/)
- [Build metadata reference](https://f-droid.org/en/docs/Build_Metadata_Reference/)
- [F-Droid inclusion policy](https://f-droid.org/en/docs/Inclusion_Policy/)
- [Reproducible builds](https://f-droid.org/en/docs/Reproducible_Builds/)
