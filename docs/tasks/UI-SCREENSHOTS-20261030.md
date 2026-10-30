# Screenshot-driven mobile UI repair — 2026-10-30

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
