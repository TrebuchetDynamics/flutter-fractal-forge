+++
schema = 1
id = "ICON-ZJ-02"
title = "Replace app and store icon assets with the approved app capture.**"
short = "Replace app and store icon assets with the approved app capture.**"
status = "open"
goal = "GOAL-VIS-003"
section = "Next"
rank = 11000
depends_on = ["VIS-003", "ICON-ZJ-01"]
touches = ["**"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "After existing owner sign-off, install the staged source/derivatives at existing asset paths; retain raw capture/state under `assets/icon/zig_zag_julia/`; update the existing provenance manifest, alternate raster alias and configured generated launcher/favicon resources. Narrowly support fully opaque RGBA icons in the listing validator with regressions; keep other image groups RGB. Update affected store docs/test-plan/changelog to actual implementation. Latest direct owner authority additionally permits icon-only Play API publication after approving B. No listing text/video, screenshots, feature graphic, release track, binary upload, version bump, package rename, new platform support or dependency changes."
acceptance = ["Approved composition and source hashes match every delivered derivative; master/foreground 1024px, Play 512px opaque sRGB 32-bit PNG at most 1024 KB, in-app mark 64px. Existing configured platform icon resources and Android adaptive XML/padding/background are coherent; no active raster alias retains old artwork. Icon-only opaque-RGBA validation passes and transparent/wrong-size/oversize icons fail; existing RGB campaign fixtures and strict RGB non-icon validation remain valid. HomeScreen logo renders without asset errors. Generated files and Android proof/device review match the approved candidate, without claiming publication."]
checks = ["Planned, unrun: `dart run flutter_launcher_icons`; `python3 -m unittest test/scripts/test_app_icon_assets.py test/scripts/test_play_store_listing.py`; `scripts/update-play-store-listings.sh --validate-only`; `flutter test test/screens/home_screen_widget_test.dart`; `flutter analyze`; `git diff --check`. Add the new asset/provenance regression fixture as part of this work. Inspect generated Android masks/resources and verify an installed launcher on a real device; record unavailable platform builds separately, never as passed. Do not run listing `--dry-run` (it stages remote edits), `--audit` or `--commit` as local validation."]
exclusions = []
+++

- Sources: [Accepted outcome and planner decisions](docs/engineering/spec.md#app-derived-zig-zag-julia-icon), `pubspec.yaml`, `assets/fractal-forge-icon-source.json`, `docs/store_listing/assets.json`, `scripts/play_store_listing.py`, `lib/features/home/home_screen.dart`.
- Prior ownership: Artwork/listing application is recorded above; waiting on VIS-003’s deferred installed-device qualification. No active implementation ownership is claimed by this questionnaire.
- Owner authorization: “Good . Change the new app icon in app and playstore” explicitly authorizes B asset application and icon-only listing publication now. This is not a device-qualification or broader release waiver. VIS-003 retains its unexecuted installed-device check.
- Progress: Approved B assets and configured Android/iOS/web/Windows/macOS icons are regenerated and applied in the canonical working checkout. Sixteen asset tests, 11 home widget tests, full Flutter analysis and 25 listing/publisher regressions pass on the isolated coherent candidate; canonical installed-asset and home smoke checks also pass. The icon-only Play edit was committed across all 15 live locales. Fresh-edit readback matches B SHA256 `c22c4fde194800588d21ad3ef2047749bb6335ce4b3fff605c00b1a054396c41` in every locale and proves complete live text/video dictionaries plus all inspected non-icon image metadata/order unchanged. No binary, release track or remote Git update was performed. This is delivered asset/listing work, not installed-device qualification; original device acceptance and task completion remain open.
- Prior next action: Verify the installed B launcher on an Android test device when available and record the remaining VIS-003 verdict; no device is attached. Existing installed apps receive the launcher change with a future binary update, which this icon-only instruction did not publish. Do not re-upload the already verified listing icon merely to refresh evidence.
- Payoff: retain the approved app-derived identity across the existing installed/listing assets.
- Previous section: Needs decision.
- Prior owner decision: 2026-10-18 reconciliation of the existing deferral — defer this successor with VIS-003 until an authorized Android test device is available; retain B approval and do not repeat the Play upload. No acceptance or binary-release waiver.
- Dependencies: ICON-ZJ-01, VIS-003.
- Touches: none before conversion; ** stands for the whole repository
- Held by: EVIDENCE-GATE: VIS-003 installed-launcher verdict on a separately authorized Android target; no repeated upload
- Owner decision: 2026-10-25: Delegated by user to assistant. Preserve approved B artwork and delivered listing work. Prepare provenance; retain actual installed-launcher check. No redesign, install, repeated upload or broader release. Decision resolved; remaining input: VIS-003 installed-launcher verdict on a separately authorized Android target; no repeated upload. See docs/tasks/DELEGATED-DECISIONS-20261025.md.
- Next action: Complete the authorized preparation separately; retain this hold until VIS-003 installed-launcher verdict on a separately authorized Android target; no repeated upload. Use supported release only after exact evidence exists; unchanged acceptance is not waived.
