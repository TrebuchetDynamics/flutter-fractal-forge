# Multi-platform releases

Run `scripts/release.sh all --dry-run` to inspect the release sequence without
building, dispatching workflows, deleting evidence, or publishing.

Before publishing, update `fdroid/version.properties` and `CHANGELOG.md`, commit,
and push. The next numeric Git tag determines the default Android release
identity; `pubspec.yaml` is not the published build counter.

```bash
scripts/release.sh all --publish=1.1.104 --build-number=104
```

The orchestrator runs analyzer, host tests, and Android device gates before
building Android, F-Droid reference artifacts, Linux, Windows, and Apple apps.
It verifies source identity and artifact checksums before creating a draft
GitHub release, deploying the website, and uploading to Google Play. Play
defaults to the internal track with draft status; use `PLAY_TRACK` and
`PLAY_RELEASE_STATUS` explicitly for another destination.

Windows and Apple builds use GitHub-hosted native runners and check out the
exact release commit. `--prepare=VERSION --build-number=NUMBER` permits build
stages without publication. It does not create or replace device-gate evidence.

```bash
scripts/release.sh windows apple --prepare=1.1.104 --build-number=104
```

Apple archives are explicitly named `macos-unsigned` and `ios-unsigned`.
macOS may carry an ad-hoc signature; neither artifact is notarized or ready for
an Apple store. iOS requires signing and provisioning before installation on a
device. App Store/TestFlight submission and macOS notarization require Apple
developer credentials and remain separate from this unsigned build workflow.

If publication is interrupted after all builds and evidence succeed, resume
from `github`, `website`, or `play` without repeating completed device gates:

```bash
scripts/release.sh all --publish=1.1.104 --build-number=104 --resume-from=website
```

Resume verifies that the manifest still belongs to the current commit and
release identity. Keep the complete artifact/evidence directory intact.
Official F-Droid publication is performed by F-Droid after reviewing its source
build recipe; creating the metadata archive does not publish to their catalog.
