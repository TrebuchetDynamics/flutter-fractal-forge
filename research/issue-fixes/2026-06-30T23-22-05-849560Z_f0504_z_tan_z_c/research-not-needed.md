# Research not needed

Local view/gesture bug. The issue is `f0504_z_tan_z_c` ("pans in the wrong direction").

Source/test evidence:
- `f0504_z_tan_z_c` is built generically via `buildEscapeTimeModule` from
  `shared_escape_expression_catalog.dart` and shares the same `z·tan(z)+c`
  recurrence (`evalVariant` variant 13) with no module-specific pan/view code,
  so the symptom is not specific to this fractal's math — it is a generic
  keyboard-pan bug that reproduces on a rotated view regardless of module.
- The repro `shareUrl` carries `rz=-1.2425537109375` (~-71°), i.e. the view is
  rotated when the user pans.
- Drag and fling panning already account for `view.rotation.z` via
  `_screenDeltaToWorldDelta` in
  `lib/features/renderer/widgets/renderer/input/gesture_handler.dart`
  (fixed previously in commit `73ee93f6`, "Fix pan-fling ignoring rotation on
  rotated 2D views").
- Keyboard arrow-key panning in
  `lib/features/viewer/navigation/viewer_interactions.dart`
  (`_viewerOnKeyEvent`) was never updated to match: it added/subtracted
  `panStep` directly to `pan.x`/`pan.y` in unrotated world space, so once the
  view is rotated, pressing e.g. the right arrow moves the view along the
  unrotated world x-axis instead of the screen-relative right direction —
  exactly "pans in the wrong direction".
- Fix: added `_rotatedKeyboardPanStep`, applying the same rotation-matrix
  convention as `_screenDeltaToWorldDelta` to each arrow key's screen-relative
  step before adding it to `pan`. For `rotation.z == 0` this is the identity,
  so the existing (unrotated) keyboard-pan behavior is unchanged.
- Focused regression test:
  `test/fractal_viewer_screen_widget_test.dart` —
  "keyboard arrow keys pan in screen-relative direction on a rotated view".
  Confirmed red→green: fails with `differs by 0.08...` against the
  pre-fix code, passes after the fix.
