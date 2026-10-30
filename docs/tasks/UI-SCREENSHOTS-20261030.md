# Screenshot-driven mobile UI repair — 2026-10-30

> Status: implementation and local engineering qualification complete at
> `8e5cec8e3133d3c7e0643b8b6b80c766f3559077`. Delivery readback is separate;
> no new production release is authorized by this task.

## Approved scope

The owner supplied nine Android screenshots, requested a critique, then asked to
implement the whole proposed repair. Preserve existing fractal mathematics,
rendering, saved views, link payloads, export behaviour and accessibility. This is
implementation authority, not a new release/publication request.

## Acceptance criteria

1. Primary viewer actions adapt to actual available width and text scale. No
   mid-word labels, lost actions, clipped focus indicators or targets below 48
   logical pixels. Overflow actions remain discoverable through More.
2. Wallpaper targets remain intelligible (Home/Lock/Both or localized equivalents)
   on narrow screens. Every preset and save-copy option can scroll fully above
   the fixed Apply area, including system/keyboard insets.
3. Sharing clearly distinguishes an interactive view link from an image. Show
   artwork/name/context rather than a serialized URL wall; full URL is optional
   disclosure, while actual Copy/Share retains the complete original payload.
   Actions align and adapt to enlarged text; platform errors remain visible.
4. Palette layout adapts to width and text scale. Selected state is distinguishable
   by checkmark/semantics as well as theme-aware styling. Swatches use the actual
   palette data. Investigate misleading names without changing existing palette
   indices, persisted IDs or render colours merely to fit a name.
5. More groups save/share, explore/animation and visual effects, with unambiguous
   immediate versus settings actions and explicit accessible effect state. Keep
   every existing supported action, export lock, photosensitivity handling and
   navigation callback.
6. Controls show explicit Reset view / Reset parameters actions, a clear editing
   hierarchy, and compact mathematical disclosure with complete accessible details
   and qualification text. No mathematical assertion or warning is removed.
7. Shared sheets have consistent header/close/spacing/scroll/footer treatment using
   existing theme and sizing patterns. Keep high-contrast/large-target support;
   do not shrink the user's selected text scale.

## Execution / boundaries

- Independent isolated writers: toolbar/actions; shared sheet/share/wallpaper;
  palette/controls. Parent is sole writer of this integration checkout and owns
  share-preview caller wiring, merged localization generation, cross-feature
  integration, review and final qualification.
- Existing branches/worktrees and task queue are preserved. Do not adopt stale
  UI snapshots that restore removed music or obsolete controls.
- Scope excludes shader rewrites or declaring the supplied Tangent/Svensson
  artwork incorrect without mathematical/rendering evidence.

## Verification plan

- Reproduce source-attributable layout/interaction failures before fixes; retain
  focused red/green tests and commands.
- Exercise at least 320/360/390 logical-pixel phone widths, enlarged text up to
  2x/3x where applicable, English/Spanish, short landscape and system insets.
  Assert full short-label visibility, reachable content, semantics/selected state,
  link payload fidelity, action callbacks and 48-pixel targets numerically.
- Validate palette names/index/ID/colours and preview data with model/render tests;
  prevent silent saved-view colour changes.
- Run focused widget/model tests and analysis, then the unchanged pinned offline
  gate on the merged source. Preserve pubspec.lock and original failed attempts.
- Run real source-bound Waydroid UI journeys and inspect retained captures of the
  affected surfaces; verify opening/closing sheets, scrolling to final options,
  selection/reset behaviour and actual copy/share/export flows. Use the existing
  designated target, serialize device operations, and keep emulator/hardware and
  human-acceptance distinctions explicit.
- No source/artifact publication or production-store upload is implied by these
  implementation checks. Append actual results only after execution.

## Integration evidence (in progress)

- Scoped implementation commits: toolbar/More `7d2bc892`, shared sheets/link/
  wallpaper `1fc958a5`, palettes/controls/maths `9387f20b`. Their focused runs
  passed 417, 258 and 443 tests respectively (overlapping sets; not a summed
  full-suite count). Independent reviewers reran 46 toolbar and 75 palette/
  controls tests and independently matched every compatibility-fixture index,
  legacy ID and colour byte against `322ddeee`.
- Parent adds real optional renderer thumbnails, freezes link/name before async
  capture, and bounds capture to two seconds. Five caller tests cover success,
  failure, timeout/late completion, dismissal and immutable link payloads.
- Review found errors behind the modal and a before-frame double-share race.
  Both reproduced red; inline live-region errors and an entry guard fix them.
  The integrated share family passes 67 tests. Earlier toolbar/share composition
  passed 238 tests and analysis. Logs are retained under the canonical checkout's
  `.git/ui-screenshots-20261030/` directory.
- First merged full Flutter run: **3291 passed, 8 skipped, 32 failed**. Failures
  exposed unreconciled test assumptions (primary-only palette entry, GridView
  versus SliverGrid, old misleading palette names, IME padding ownership and
  contextual Random labels). Assertions are being reconciled without dropping
  visibility, exact inset, compatibility or independent localization checks.
  Its original shell wrapper incorrectly printed a final PASS after a failed
  `&&` list; that marker/exit is invalid. The retained wrapper note records the
  effective failure. Python/Bats were not reached. A correctly guarded full
  rerun remains required.
- The native fixture requires an exact source commit, actual FragmentShader
  painters and nonblank real share-preview pixels. It exercises EN/ES,
  390x780/1x, 360x640/2x, 320x568/3x and 640x360/3x with navigation insets and
  large-target/high-contrast settings. Viewport/text metrics are test overrides,
  not changes to Waydroid's host profile. **Native execution, capture inspection,
  final merged gate and composition review remain pending.** No release upload.

### Qualification follow-up

- Correctly guarded second gate at `1df4815b`: analysis clean, **3323 Flutter
  tests passed / 8 skipped**. During Python checks the external Paseo checkout
  disappeared; pytest failed restoring its working directory, Bats was not
  reached and final lock/source readback was unavailable. The **combined gate
  failed**. Its log survives under the canonical `.git` evidence directory.
  The removal's actor/cause is not established; do not attribute it to pytest.
- All code was already committed. Recovered the unchanged candidate in the
  ignored, Git-locked `.worktrees/ui-screenshots-recovery-20261030` worktree and
  regenerated package metadata offline rather than copying stale bindings.
- First native run at clean `1df4815b` genuinely loaded GPU shaders and verified
  nonblank real previews in both languages. It failed after Copy when More was
  not hit-testable during transient success feedback. That run is **failed**,
  not full native acceptance. Private app-document captures could not be read
  through Waydroid's restricted `run-as`; no privilege/service changes were made.
- Follow-up fixture uses app-scoped external captures, waits boundedly for actual
  success feedback to expire, includes unmodified native viewport captures and
  native chooser open/cancel (never sends to a recipient), selects the final
  palette and invokes both distinct resets. One real lock-wallpaper Apply is
  tested on the designated disposable Waydroid profile, with save-copy off.
  These new native checks remain pending execution.
- Strengthened both IME application-flow assertions to check the actual inner
  navigation component, outer keyboard remainder **and their sum**, not only a
  filtered outer owner. The focused application tests pass **10 tests**.
  In the restored checkout, Python passes **454 tests, 1 skip, 148 subtests**;
  Bats passes **25 tests**. Later combined runs are recorded below.

### Visual closeout findings after `2e501443`

- At `2e501443`, the guarded full offline gate passed: **3324 Flutter tests /
  8 skips, 454 Python tests / 1 skip / 148 subtests, 25 Bats tests**, clean
  analysis and unchanged lockfile. Combined native run 11 also passed **2/2
  journeys**, with 85 fixture PNGs, two native chooser captures, exact built/
  installed APK hash readback, clean source and unchanged host metrics. These
  are real passes for that source, not retroactive passes for earlier attempts.
- Inspection of those captures nevertheless exposed a visual gap: Material
  ChoiceChip's inherited single-line/fade layout hid the meaningful suffix of
  optimized wallpaper presets at enlarged text. A retained independent
  paragraph-box regression reproduced **6 failures / 2 passes**. Reuse the
  existing responsive radio-style option for presets instead; preserve every
  label, callback, selected/checked group state, 48/56 target and themed icon
  contrast. Do not clamp text or weaken the footer-clearance assertion.
- Inspection also caught a **test-startup gap**, not a production palette bug:
  manually constructing FlutterFractalsApp omits main's PaletteService startup.
  Earlier native picker captures therefore showed the honest unavailable-preview
  fallback. Restore real singleton initialization in the fixture and require the
  initial/final selected previews to match actual stop positions/ARGB values,
  with no fallback icon. Old native passes alone do not qualify that palette
  presentation path.
- The corrected wallpaper family passes **50 tests**, including full EN/ES
  preset-label painting and selected-icon contrast; analysis is clean. Final
  source-bound offline/native reruns and visual inspection remain pending for
  these closeout corrections. No export/native service rewrite was made from
  the old timeout: its precise stalled await was not established, while later
  actual Apply runs completed feedback/capture in seconds.

## Final qualification — `8e5cec8e`

All seven approved UI acceptance criteria are implemented and engineering-checked
within the limits below. This records actual checks, not owner aesthetic approval
or production/hardware qualification.

### Offline gate

The unchanged, correctly guarded full command passed once on the clean committed
candidate, in **780.524 seconds**:

- Flutter **3.44.6 / Dart 3.12.2**, matching `fdroid/flutter.version`.
- Offline lockfile-enforced dependency preflight; clean analyzer.
- **3334 Flutter tests passed, 8 declared skips, 0 failures**.
- **454 Python tests passed, 1 skip, 148 subtests passed**.
- **25 Bats tests passed**.
- Source/tree/index remained unchanged. `pubspec.lock` SHA-256 remained
  `22b29dbd8f71276012a54b9bdc62ba88408f967a86b34075986c17e1c4506ec3`.

Evidence: `merged-offline-gate-5.{log,exit,json}` under the canonical checkout's
`.git/ui-screenshots-20261030/` directory. Earlier failed gates and invalid-wrapper
markers remain retained and do not acquire a passing verdict from this run.

### Source-bound Waydroid journeys and visual inspection

Final native run `waydroid-12-swatches` passed **2/2 complete EN/ES journeys** on
`192.168.240.112:5555`, native model `WayDroid x86_64 Device`, Android 13. Both
languages cover 390x780/1x, 360x640/2x, 320x568/3x and 640x360/3x, navigation
insets, high contrast and large targets. The fixture also captures the unchanged
native viewport before test metric overrides.

- Required actions are present, reachable, at least 48/56 as applicable, and the
  measured primary words do not split. Fatal hit-test warnings remain enabled;
  the passing run has none.
- Every destination and preset is activated with selected-state checks. Preset
  labels are fully painted, not faded/clipped. The final save-copy option stays
  above fixed Apply; close targets are reached after scrolling lazy headers.
- Actual renderer previews are nonblank; Copy preserves the full original URI.
  Both actual Android share choosers opened, their localized content was retained,
  and only their verified empty scrim was tapped to cancel. No recipient was
  selected and no message was sent.
- Production PaletteService initialization runs. Initial/final selected previews
  must use the exact palette stop positions/ARGB values, with no fallback icon;
  palette 63 is selected and checked in every profile. All 64 legacy indices,
  persisted IDs and colour stops additionally remain baseline-fixture verified.
- Both resets are invoked against deliberately edited state: Reset view preserves
  parameters; Reset parameters restores the original parameter map without
  changing the reset view. Full formula/qualification details remain present.
- One real lock-wallpaper Apply, with save-copy off, reaches success feedback and
  capture. Independent system readback changes **Lock ID 8 to 9**, while System
  ID **4 stays unchanged**. This is the designated disposable profile, not an
  unrelated device/profile. Earlier unlocated stalls remain failed history; no
  speculative export/native-service rewrite was made.
- **85 app PNGs** fully decode and match recorded dimensions/source. Each has at
  least **138 distinct sampled RGB colours**; unobscured toolbar artwork also
  passes nonblank/colour-variation checks. The parent inspected the corrected
  full preset text, real swatches and EN/ES contact sheets. Two native chooser
  captures and XML readbacks are retained separately.

Built and independently installed test APK SHA-256:
`e64d7f35d159f66fe33e4bfd59874e2b9b77f99412dc83060eaf47500b09b57b`.
Source and lock remained clean/unchanged; host WM size and font scale did not
change. Receipts, original PNGs, contact sheets, decoded image-health report and
exact commands are retained beside `waydroid-12-swatches.json` and
`final-native-image-health.json` in the evidence directory.

### Local preview and delivery boundary

A normal `lib/main.dart` **x86_64 debug preview**, rather than the instrumentation
runner, was built, installed and cold-launched on the same Waydroid target. Exact
build/install APK readback matches SHA-256:
`600cf0f3dd140211aceb738ed06575ac55104034f085a9f96b40152c011a8f01`.
See `normal-preview.json`; the retained APK is
`fractal-forge-ui-8e5cec8e-x86_64-debug.apk` in the evidence directory.

The qualifying implementation/test source is `8e5cec8e`; this documentation-only
follow-up does not repin either build or gate evidence. Canonical integration is
serialized with existing repository locks and recorded separately in
`integration-readback.json`. Source push targets only the existing GitHub origin;
its independent readback is retained in `push-readback.json`. GitLab is excluded.
Production upload is not part of this coding task. Play 1.1.115 remains the last
published Android release.

**Limits:** Waydroid/container evidence, not physical-device/hardware-GPU proof.
Phone/landscape dimensions and enlarged text use test-only Flutter metrics, not
actual OS rotation/font-setting journeys. Framework semantics are checked; no
TalkBack voice journey, web/browser journey or production qualification is
claimed. These remain separate release/device gates, not waived checks.
