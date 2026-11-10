+++
schema = 1
id = "UI-OVERLAY-SHELL-INSETS-02"
title = "Share bottom-sheet keyboard and navigation inset policy"
short = "Share bottom-sheet keyboard and navig..."
status = "done"
section = "Next"
rank = 23000
depends_on = []
touches = ["lib/shared/widgets/app_bottom_sheet.dart", "test/shared/"]
resources = []
kind = "implementation"
ownership = "coordinator"
scope = "Only duplicated keyboard/navigation inset calculations in AppBottomSheet and AppDraggableBottomSheet; retain separate height and scroll-controller ownership."
acceptance = ["Both public shells use one private inset policy without changing their public constructors or draggable controller behavior.", "Interface tests cover gesture-only navigation, button navigation, keyboard smaller/larger than navigation, and constrained landscape; viewport bounds reserve the larger obstruction without double counting."]
checks = ["Pinned Flutter focused shared-shell, export, wallpaper and history widget tests; analyzer on changed files; independent review."]
exclusions = ["No universal overlay manager, feature content migrations, publication or device qualification."]
closure = "coordinator_verified"
closure_evidence = "tasks/evidence/UI-OVERLAY-SHELL-INSETS-02.toml"
+++
- Sources: Owner UI overlay refactor request; /tmp/architecture-review-20261110-ui-overlays.html candidate 2; source-confirmed duplicate formulas.
