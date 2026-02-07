# UI/UX Diagram (JSON)

This repo includes a machine-readable UI/UX map at:

- `ui_ux_diagram.json`

It is **inferred from the current Flutter widget tree and navigation code** under `lib/`.

## Schema (pragmatic, not a formal JSON Schema)

Top-level keys:

- `app`
  - `entrypoint`: app widget and `home` screen (from `MaterialApp.home`).
  - `global_state`: providers/singletons that screens consume (`Provider` / `ChangeNotifierProvider`).
- `screens`: list of UI surfaces.
  - A surface can be a full page (`kind: "screen"`) or a modal (`kind: "modalBottomSheet"`).
  - Each item should include:
    - `id`: stable identifier used by the navigation graph
    - `name`: human label
    - `widget`: Dart widget class name (or inline description if anonymous)
    - `file`: source path where implemented
    - `navigation`: how it is reached (root/tab/push/modal)
    - `key_components`: important widgets/actions on that surface
    - `state_flows`: how state is read/written, and what actions cause changes
- `navigation_graph`
  - `nodes`: list of screen/sheet IDs
  - `edges`: directed transitions (tab switch, push route, modal open)
- `implementation_index`: convenience index mapping major widgets/services to file paths.

## Conventions used

- **File references** are relative to repo root (e.g. `lib/features/viewer/fractal_viewer_screen.dart`).
- **State flows** use these fields when relevant:
  - `reads`: provider IDs from `app.global_state`
  - `writes`: provider IDs or local state variables mutated
  - `services`: non-widget helpers called as part of a user action (export/share, persistence)
- Some modals are **inline widgets** (e.g. export options bottom sheets defined inside a screen); these are represented with `widget: "(inline in ...)"` and still have a `file`.

## Keeping it accurate

If you add new navigation (named routes, dialogs, new screens), update:

- `screens[]` (add a new surface + file reference)
- `navigation_graph.edges[]` (add transitions)
- `app.global_state[]` (if you add new providers/stores)
