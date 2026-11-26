# UI-OVERLAY-RESPONSIVE-BROWSER-01 — local Chromium audit

Issue #21. Reproduce using the [owned Chromium procedure](../engineering/test-plan.md#owned-chromium-overlay-audit-21). This is a browser audit, not a screenshot baseline or a release gate.

## Source and setup

- Built `94d7820e18599c0fcfef3d1b5a1a291f1ce271b7` (unchanged production source) with the documented lock-enforced pub get and release web smoke build; both exited 0. Flutter 3.47.9, Dart 3.13.7, engine revision `89c39edfdf`. `main.dart.js` SHA-256: `1ff77a455f7db49e45d8c48255e72672ca2244cd2cc9e48841df52f913a8222e`.
- Schema1 [manifest](../../test/fixtures/ui_overlay_capture_matrix.json) SHA-256: `8ae46bc05b584c12c40dfc8ba8d6d47576d149033dbc11fb320dfcbe2db0da73`. No availability declarations changed. Counts: 69 baseline, 14 ES/high-contrast native1x, one OLED. The nine excluded states and the union of 49 component-only rows (including all 20 3× and two synthetic-keyboard rows) have explicit reasons in the reports.
- Playwright 1.59.1, Chromium 147.0.7727.15, DPR1, emulated reduced motion, CanvasKit release JS and SwiftShader. Runtime font requests observed include Material Icons and Roboto; the source declares Poppins, Inter and JetBrains Mono, which does not prove browser or native font parity. The shell used a private mode-0700 scratch directory, an OS-assigned loopback port, one worker and no existing profile/service worker.
- `pubspec.lock`: `b0677b30481bb5321a7e365eb64dc9b28a71987d3fa32626ff13aa90c328adc8`; `rust/Cargo.lock`: `97ff3cde076b918449b860fd6b9099b3e30372603a9ebc92187d21f24848f559`. Both unchanged.

## Reproduction and failure paths

The audited invocation was `UI_OVERLAY_CAPTURE_DIR="$TMPDIR/audit" timeout --kill-after=10s 900s npx --no-install playwright test --config=playwright.overlays.config.mjs --project=chromium --workers=1`, with `PLAYWRIGHT_PORT` unset (config allocates a free loopback candidate and starts its own server). The smoke GPU iteration cap is 10, not a production rendering benchmark. No preview playback, audio, auto-explore, file export, copy or share was started.

The case guard and Edit journey at the three standard viewports passed (4 tests, exit 0). Relative, checkout-local, nonempty and invalid-port setup inputs were refused. An owned test listener on the requested port produced `[Errno 98] Address already in use`; the listener still accepted a connection afterward. The repair is to choose a fresh external directory or a new OS-assigned port once, not to borrow or stop the listener. The focused Flutter manifest/component suite passed (10 tests, exit 0).

The existing `smoke-session-conflict.spec.mjs` was run against the unchanged frozen web bundle with the same owned-server settings (exit 1: `getByText(/Newton Fractal/)` not visible after the viewer Back control appeared). This is outside the overlay harness; neither its assertion nor the app was changed. The legacy coordinate-based viewer suite and download journeys were not used for overlay evidence.

## Visual observations and bounded follow-up

- `edit-menu--baseline--375x667--native1x.png`: the full-width sheet shows the Edit title, Close, and Controls over Mandelbrot. The lower tools continue beneath the bottom of the visible scroll area; a hover tooltip overlaps the bottom rows. At 768×1024 the sheet has side margins and exposes Fullscreen view; at 1440×900 it is centered with substantially more visible fractal on both sides. The visible headers and action labels in these samples were not horizontally cut off.
- The ES/high-contrast Controls images show the translated formula and bright-yellow values. **The painted `Controles` title is nearly black against the dark sheet at both stress sizes**, although it appears in the accessible viewer name. The landscape title patch contains `#000000` glyph pixels on `#0a0a0a` (about 1.06:1 from the sampled pixels). Check the Controls HUD's title foreground against its actual high-contrast surface; DOM scroll width and semantic presence cannot detect this.
- At 768×1024 and 1440×900 the 2D and 3D Controls HUDs were captured, but remained open after an actionable Close click. Looper and Auto-Explore exposed open sheets, but another Flutter semantics node intercepted the tested Close or Export GIF pointer target; Escape was tried for ordinary dismissal, not used to upgrade failed pointer trials. Follow up on wide HUD dismissal and shared header/action hit testing on web.
- The Random categories keyboard entry could not be focused in the tested Chromium viewports. This is an unproved browser reachability path, not a claim that the Flutter sheet does not exist. Provide or validate a browser-accessible secondary action for this route. The three `batch-selection` rows retain a different failure: [the shipping preset launcher passes `onBatchExport: null` on web](../../lib/features/viewer/dialogs/viewer_dialogs.dart); no job was started. The manifest's requested rows were neither relabeled as supported nor dropped.
- At 667×375 the scrolled theme sheet exposes selected `Alto contraste` and `Cancelar`; the top card is partly outside the scroll area in the terminal image. The narrow Looper terminal image visibly shows `Exportar GIF`, but its pointer trial did not succeed. Visible paint is not proof that a target can be used. In the OLED sample the dark Export sheet shows the Quick Presets scroller, the purple Save image button and the intentionally disabled Save & share web action; neither action was invoked.

## Retained evidence and verdict

**Not layout-qualified.** The full invocation exited 1 after all 84 browser rows: 78 main viewport PNGs, 62 passing rows, 22 failed rows and no missing verdicts. Six failed before the requested surface could be captured (three batch selection and three Random categories); 16 retained images but failed a dismissal or reachability check. There are 25 additional `--top` / `--terminal` images, not extra coverage rows. All 103 recorded PNGs independently decoded at the exact IHDR dimensions and matched their recorded hashes. Document horizontal overflow was false in 78 rows and unknown in six; there were no recorded console errors, page errors or failed resource requests. Paint, actionability, and focus were assessed separately. The focused rerun after adding return-scroll to the Presets parent passed all three preset-rename rows plus the selection guard (exit 0); this resolves the phone rename check in the full run, leaving 21 failed rows after reconciling that rerun. It does not change the original report or the audit verdict.

| Artifact | Private local path |
| --- | --- |
| Full audit index, machine report, PNGs, traces and Playwright report | `/tmp/tmp.mpjiIfxHvo/audit/` (`report.md`, `captures.json`, `*.png`, `diagnostics/`, `playwright.json`) |
| Targeted preset-rename rerun | `/tmp/tmp.mpjiIfxHvo/rename/` |
| Existing saved-session reproduction and diagnostics | `/tmp/tmp.mpjiIfxHvo/selected/` |

Full-audit `captures.json` SHA-256: `e943145aaf388fd6b3e73b65e3f02bd1d957fba840e02d41e2e11e120d29d7d0`; `report.md`: `489e2106ca5b64b1624ef18aaabb4a8127191c6d4445d5d0ac9ab6de14c876a1`. The private host directory was retained. The audit's `127.0.0.1:49629` listener no longer accepted a connection after exit, and there was no remaining audit browser profile process. Run logs and the file-reconciliation check are in the task's excluded `.orbi/` directory. No screenshots, traces, baselines, production source or lockfile changes are committed.

The full root offline gate passed on the delivered source with a private `TMPDIR` (exit 0: locked pub get, Rust fmt/clippy/tests, Flutter analyze and 3,704 tests, Python and Bats; both locks unchanged). Its summary is retained at `/tmp/tmp.mpjiIfxHvo/gate-tmp/offline-gate-UYtNci/offline-gate.json`. This gate does not override the nonpassing browser audit.
