+++
schema = 1
id = "NUM-WALL-03"
title = "Colour, randomize and export the same completed wall.**"
short = "Colour, randomize and export the same completed wall.**"
status = "open"
goal = "NUM-WALL-001"
section = "Next"
rank = 2000
depends_on = ["NUM-WALL-02"]
touches = ["lib/features/number_walls/", "lib/features/renderer/", "lib/features/viewer/export/", "lib/core/services/export/", "lib/core/services/rendering/palette/", "lib/features/controls/", "lib/l10n/", "shaders/number_theory/number_wall_gpu.frag", "test/number_walls/", "test/export/"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "Add binary-zero and binned-residue palette modes, foreground/zero/background colours, optional grid, manual reproducible randomizer/undo and exact-grid offscreen PNG integration. Reuse existing palette/editor/export UI and save services; prime arithmetic never moves into shader floats. Randomizing modulus is explicit opt-in and uses verified quick-pick primes, not the typed custom prime by default. No autoplay or new continuous animation framework."
acceptance = ["Zero mask survives all styling and large-prime residue binning; colour-only changes do not recompute determinants. Randomization creates valid materialized settings, can be undone/replayed and does not create composite moduli or silently replace a typed prime. Export freezes the complete committed grid/style/viewport; other output dimensions rerasterize identical cells, not a new sequence/prime/depth. Decoded PNGs match same-state viewer cells and chosen background/alpha rules; no unrelated escape-time fallback. Cancellation, navigation and stale jobs preserve ownership. Unsupported auxiliary animation/effect tools are disclosed/disabled only for this module; ordinary modules keep their behavior."]
checks = ["Planned: `flutter test test/number_walls/number_wall_style_export_test.dart test/number_walls/number_wall_randomizer_test.dart test/export/viewer_export_session_test.dart --reporter expanded`; `flutter test --platform chrome test/number_walls/number_wall_style_export_test.dart --reporter expanded`; `flutter analyze`; decode actual exported PNG artifacts and compare sampled cell centres/zero mask against the immutable grid. New targets and pixel checks are NOT_RUN."]
exclusions = []
+++

- Section: Next.
- Payoff: attractive configurable artwork with reproducible settings and matching PNG output.
- Sources: [Accepted outcome and decided design](docs/engineering/spec.md#number-walls-and-modular-windows), [owner scope](PRD.md#number-walls-catalog-category), `lib/features/viewer/export/viewer_export_session.dart`, `lib/features/renderer/models/fractal_render_snapshot.dart`, `lib/core/services/rendering/palette/palette_shader_adapter.dart`, `lib/core/services/export/export_service.dart`, `test/export/viewer_export_session_test.dart`.
- Ownership: Repository backlog, unassigned; no publication or schedule authority.
- Next action: Pin colour-only/no-recompute and immutable export ownership tests, then implement presentation and PNG reuse.
