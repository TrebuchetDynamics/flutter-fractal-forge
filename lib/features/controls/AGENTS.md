<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# controls

## Purpose

Parameter control panel for adjusting fractal parameters in real-time. Generates sliders, toggles, and dropdowns dynamically from the active module's parameter schema.

## Key Files

| File                            | Description                                                                                                                                                                        |
| ------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `param_control_plan.dart`       | `NumericParamControlPlan` - replayable range/clamp/label contract shared by every numeric parameter slider. Handles float and integer parameters.                                  |
| `module_control_sections.dart`  | `moduleControlSections` - the one table of widget sections keyed by module id. `FractalModule` declares data only, so a section widget is registered here instead.                 |
| `widgets/`                      | Specialized controls (number-wall colour swatch, prime editor, randomization) used by the viewer controls HUD.                                                                      |

The user-facing control panel is `FractalControlsHud` in `lib/features/viewer/chrome/fractal_controls_hud.dart` (a viewer overlay, not a modal sheet). The former `FractalControlsSheet` modal was unused and has been removed.

Which widget a parameter gets comes from `FractalParameter.resolvedControl` (declared, or derived from its type). Whether the shared effect toggles apply comes from `FractalModule.hidesEffectControls`. Do not add a module-id or parameter-id check to a control surface; see
[ADR 0004](../../../docs/adr/0004-control-surfaces-get-controls-from-declarations.md).

## For AI Agents

### Working In This Directory

- Controls are generated dynamically from `FractalModule.parameters`
- A parameter that needs a different widget declares `control: FractalParamControl...`
- The HUD owns its height arithmetic (`ControlsHudMetrics`); a host asks it, and never re-derives the header formula
- The HUD's `content:` seam has one adapter (the Gaussian map). Make the HUD headless only when a second host appears
- Each parameter type maps to a specific widget (Slider, Switch, DropdownButton)
- Parameter values stored as `Object` in FractalController - use local variable for type promotion
- Dart gotcha: `Object` fields do NOT type-promote; assign to `final v = value;` first

### Testing Requirements

- `test/features/controls/param_control_plan_test.dart`
- `test/features/controls/param_control_declaration_test.dart` (declared controls and module capabilities)
- `test/fractal/fractal_controls_hud_test.dart` (HUD widget behavior)
- `test/fractal/controls_presentation_test.dart`
- `test/fractal/controls_hud_metrics_test.dart` (height contract)

## Dependencies

### Internal

- `core/models/fractal_parameter.dart` - Parameter schema definitions
- `core/controllers/fractal_controller.dart` - FractalController for state updates

<!-- MANUAL: -->

<!-- karpathy-guidelines:start -->

## Karpathy-Inspired Agent Guardrails

Source: https://github.com/forrestchang/andrej-karpathy-skills at commit `2c60614`.

These guardrails supplement the local instructions above. Local project, safety, and user-specific rules win on conflict.

Tradeoff: they bias toward caution over speed for non-trivial work; use judgment for obvious one-line fixes.

### Think Before Coding

- State assumptions and choose the simplest reversible solution supported by repository evidence. Ask only when a missing decision prevents safe, authorized work; continue independent work meanwhile.
- Briefly record material tradeoffs and select a reasonable default for routine local work.
- Push back when a simpler approach meets the goal.

### Simplicity First

- Build the minimum code that solves the requested problem.
- Avoid speculative features, single-use abstractions, and unnecessary configurability.
- If the solution is growing large, stop and simplify before continuing.

### Surgical Changes

- Touch only files and lines required by the request.
- Preserve existing style, comments, and nearby code unless the task requires changing them.
- Clean up only dead code introduced by your own change; mention unrelated dead code instead of deleting it.

### Goal-Driven Execution

- Convert the request into verifiable success criteria before editing.
- For multi-step work, state a short plan with a verification check for each step.
- Loop until the relevant tests, builds, or manual checks prove the goal is met.

<!-- karpathy-guidelines:end -->

<!-- karpathy-project-adjustment:start -->

## Project-Specific Karpathy Adjustment

This section localizes the Karpathy guardrails for `workspace-sidon/trebuchet-dynamics/flutter-fractal-forge/lib/features/controls`. Source inspiration: https://github.com/forrestchang/andrej-karpathy-skills at commit `2c60614`.

- Project family: Sidon fractal/rendering and visual-app workspace.
- Local focus: GPU/fractal rendering, Flutter/Electron apps, shaders, accessibility, and measurable visual behavior.
- Stack cues: Flutter/Dart.
- Evidence to prefer: test output, analyzer/linter output, screenshot/pixel checks when relevant, shader compile logs, frame/performance metrics, and exact UI state text.
- Surgical boundary: do not rely on visual vibes; validate rendering numerically and describe results in screen-reader-friendly text.
- For underspecified visual work, derive measurable acceptance criteria from existing patterns and accessibility requirements, implement a reversible improvement, and validate it. Escalate only a material unresolved product decision; continue other work.

<!-- karpathy-project-adjustment:end -->

## Autowork local execution

Follow the repository-root Autowork policy for autonomous local planning,
implementation, verification and scoped commits. Keep this directory’s technical
contracts and live-operation limits; ordinary local work needs no owner reply.
