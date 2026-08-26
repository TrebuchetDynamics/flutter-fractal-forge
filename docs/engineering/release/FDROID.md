# Official F-Droid release pipeline

Fractal Forge targets the official F-Droid catalog. F-Droid builds the Android package from the public source commit, signs it with an isolated per-app F-Droid key, and publishes it. This repository does not upload or sign an APK for F-Droid.

## Automated release contract

`scripts/release.sh all --publish=X.Y.Z` includes the `fdroid` stage before publication. The stage:

1. verifies `fdroid/version.properties` matches `X.Y.Z` and the Android version code;
2. validates the upstream Fastlane listing and version-code changelog;
3. builds a universal release APK with `FDROID_BUILD=1`, which disables upstream signing;
4. checks the application ID, version name, version code, all three supported ABIs, and absence of an APK signature;
5. deletes build output, builds a second time with the release commit timestamp as `SOURCE_DATE_EPOCH`, and requires byte-for-byte equality;
6. creates a deterministic fdroiddata metadata archive bound to the full release commit.

The tag workflow in `.github/workflows/fdroid-source-build.yml` repeats the source-build and reproducibility gates, then runs official `fdroid lint` and `fdroid scanner` checks for every `vX.Y.Z` tag.

Run the stage directly while preparing a release:

```bash
FLUTTER_BIN=/path/to/flutter \
  scripts/release.sh fdroid \
  --prepare=1.1.95 \
  --build-number=95
```

Outputs are written below `release-artifacts/fdroid/`:

- `fractal-forge-fdroid-vX.Y.Z-unsigned.apk` — verification artifact only; do not distribute it;
- `fractal-forge-fdroid-vX.Y.Z-unsigned.apk.provenance` and `.sha256`;
- `fractal-forge-fdroiddata-vX.Y.Z.tar.gz` and `.sha256`;
- `fdroiddata/metadata/com.trebuchetdynamics.fractal.forge.yml`.

## Release preparation

Before creating each release tag:

1. Update `fdroid/version.properties` so `versionName=X.Y.Z` and `versionCode=Z` match the repository's release policy.
2. Add `fastlane/metadata/android/en-US/changelogs/Z.txt` with at most 500 characters.
3. Update the Fastlane title/descriptions when store-facing text changes. The short description must be at most 80 characters and must not end with a period.
4. Commit these changes before running the release orchestrator. The official metadata uses the full tagged commit, never a branch name.

The first release eligible for catalog submission is `1.1.95`. `v1.1.93` predates unsigned source-build support, and `v1.1.94` was superseded before submission after the official source scanner rejected optional removal paths that were absent from a clean checkout. Neither tag should be submitted as the initial F-Droid build.

## One-time official catalog submission

Official publication requires one human-reviewed fdroiddata merge:

1. Complete and push the first eligible release tag.
2. Download the `fdroid-source-build-X.Y.Z` workflow artifact or use the local output from the `fdroid` stage.
3. Extract `fractal-forge-fdroiddata-vX.Y.Z.tar.gz`.
4. Copy `fdroiddata/metadata/com.trebuchetdynamics.fractal.forge.yml` into a fork of [fdroid/fdroiddata](https://gitlab.com/fdroid/fdroiddata).
5. Run `fdroid readmeta`, `fdroid lint`, `fdroid scanner`, and `fdroid build com.trebuchetdynamics.fractal.forge` using the current F-Droid buildserver image.
6. Open a `New App: com.trebuchetdynamics.fractal.forge` merge request and address packager review.

After that merge, `UpdateCheckMode: Tags` and `fdroid/version.properties` allow F-Droid's update checker to discover later release tags and create update merge requests.

## Policy and signing notes

- The source tree includes `pubspec.lock`, and the recipe uses `flutter pub get --enforce-lockfile` with a build-local `PUB_CACHE` so dependencies are scanned.
- Flutter is pinned to `3.44.6` through F-Droid's official Flutter srclib.
- Android builds use F-Droid NDK alias `r28c`, corresponding to upstream NDK `28.2.13676358`.
- The unused Google Play Feature Delivery dependency was removed so both Play and F-Droid builds avoid a non-free runtime dependency. Android dependencies resolve only from Google Maven or Maven Central.
- Flutter 3.44.6's official Android embedding retains unused Play Store deferred-component type references. The app declares no deferred components and `releaseRuntimeClasspath` contains no Play Core dependency; this is recorded in the generated `MaintainerNotes` for packager review.
- F-Droid's default signature differs from the Google Play signature. Users switching between Play and F-Droid builds must uninstall the existing app first. Reproducible upstream-signed publishing is intentionally not enabled until cross-builder byte identity is independently established with F-Droid infrastructure.

Authoritative references:

- [Submitting to F-Droid quick start](https://f-droid.org/en/docs/Submitting_to_F-Droid_Quick_Start_Guide/)
- [Build metadata reference](https://f-droid.org/en/docs/Build_Metadata_Reference/)
- [F-Droid inclusion policy](https://f-droid.org/en/docs/Inclusion_Policy/)
- [Reproducible builds](https://f-droid.org/en/docs/Reproducible_Builds/)
