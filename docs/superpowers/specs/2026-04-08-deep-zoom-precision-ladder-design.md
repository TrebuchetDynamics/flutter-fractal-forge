# Deep Zoom Precision Ladder Design

Date: 2026-04-08
Status: Approved in brainstorming, ready for implementation planning
Primary target: Android physical device over ADB

## Goal

Make deep zoom mathematically trustworthy for all supported 2D escape-time fractals while preserving smooth interaction on Android. The viewer should use a coherent precision ladder: fast preview during gestures, exact refinement after gestures settle, and an automatic-first UI with a manual precision override.

## Problem Summary

The current deep-zoom path is not coherent:

- Gesture handling clamps zoom around `1e10`.
- The controller clamps zoom around `1e12`.
- Precision policy thresholds differ by module and are not driven by one central mode decision.
- Mandelbrot has a dedicated double-float path.
- Some escape-time fractals have a perturbation-based GPU preview path.
- CPU fallback exists, but not all 2D escape-time modules have a mathematically exact deep-zoom refinement path yet.

This causes three user-visible issues:

1. Deep zoom behavior is inconsistent across modules.
2. Precision state is not explicit or fully honest.
3. Renderer handoffs are managed as scattered thresholds instead of one system.

## User Intent And Constraints

- Prioritize fractal viewer math correctness first.
- Optimize for deep zoom plus performance together, with balanced tradeoffs.
- Android physical device is the success platform.
- Target extreme exploration, beyond `1e15`, with slower refinement when required.
- Keep interaction smooth during pinch/pan.
- Use an automatic-first UI with a small precision status chip and override entry point.
- First cycle scope: all 2D escape-time fractals, not just Mandelbrot.

## Scope

### In Scope

- 2D escape-time fractal viewer precision behavior
- Deep-zoom tier selection and renderer handoff behavior
- Canonical viewport math for deep zoom
- Viewer HUD precision state and override control
- Unit, widget, integration, and Maestro regression coverage for the deep-zoom flow

### Out Of Scope

- 3D fractals
- Catalog redesign
- General non-escape-time fractal correctness
- Broad UI refactors unrelated to precision control and status

## Design Overview

The viewer will stop treating deep zoom as a binary `GPU vs CPU` switch and instead move to a precision ladder with explicit modes.

### Precision Tiers

1. `realtime_gpu`
   Standard fast GPU rendering for shallow zoom.

2. `extended_gpu`
   Deep-zoom GPU preview path using the best supported module-specific strategy:
   - float32 when sufficient
   - double-float where available
   - perturbation preview where available

3. `precision_refine`
   Exact or exact-intended high-precision refine pass after interaction settles.

4. `precision_locked`
   Manual override that keeps the viewer on the precise path until the user unlocks it.

The renderer should always know both:

- what path to use for live preview
- what path to use for post-gesture refinement

## Architecture

### 1. Canonical Deep-Zoom Viewport

Add a canonical viewport model for 2D escape-time fractals that owns:

- exact center coordinates
- canonical zoom value
- conversion helpers for preview renderers
- formatting helpers for stable zoom display

This model becomes the single source of truth for deep zoom. Existing `FractalViewState` remains useful for ordinary rendering and serialization, but deep-zoom decisions must no longer depend on separate clamp logic in gesture handling, controller updates, and renderer policy.

### 2. Precision Coordinator

Add one precision coordinator that decides the active tier from:

- module identity and capability metadata
- zoom depth
- whether the user is actively interacting
- whether precision is manually locked
- device-performance constraints
- availability of exact refine support

The coordinator outputs a single decision object containing:

- preview tier
- refine tier
- user-visible label
- whether refinement should start now
- whether refinement is exact for the current module
- whether the current operation should remain in preview-only mode

This replaces threshold decisions currently spread across:

- `lib/features/renderer/deep_zoom_precision_policy.dart`
- `lib/features/renderer/fractal_renderer.dart`
- `lib/features/viewer/viewer_gpu_health.dart`
- portions of viewer HUD state

### 3. Escape-Time Capability Metadata

Precision support must be metadata-driven for the 2D escape-time family.

Each supported module should expose capability data such as:

- preview strategy kind
- refine strategy kind
- exact-refine support flag
- safe threshold boundaries
- recurrence family identifier

This avoids hardcoded behavior lists scattered across the renderer and creates a clean path for broadening exact support.

### 4. Two-Phase Render Pipeline

The active pipeline should be:

- preview frame while interacting
- cancellable refine frame after interaction settles

Rules:

- Preview always wins during active gestures.
- Refine starts after a short idle window, around `180-250ms`.
- Refine is cancelled immediately by new interaction.
- The last preview frame remains visible until refine output is ready.
- Handoff between preview and refine must not shift the world point under the chosen center/focal anchor.

### 5. Exactness Boundary

Precision state must be honest.

If a 2D escape-time module does not yet have a true recurrence-based refine path, the viewer must not claim exact deep precision. In that case, the viewer remains in preview mode with explicit messaging that exact refinement is unavailable for that module.

The first implementation cycle must expand exact refine support far enough that the declared scope, all supported 2D escape-time fractals, is true for the chosen set. Proxy iterators are not acceptable as the mathematical truth path for deep-zoom refinement.

## Interaction Contract

### During Active Pinch/Pan

- Stay on the fastest valid preview tier.
- Never block gesture updates on a refine pass.
- Keep focal-point math stable even when the preview renderer tier changes.
- Prefer a perceptually smooth preview target on Android over immediate exact refinement.

### After Interaction Ends

- Wait for a short idle window.
- Start refine automatically when needed.
- Show a subtle non-blocking refining state if the refine pass becomes noticeable.
- Cancel refine immediately on renewed interaction.

### Manual Control

The default mode is automatic.

The viewer shows a small status chip, not a large persistent control panel. The chip should expose states such as:

- `GPU`
- `Deep GPU`
- `Precision`
- `Precision Locked`

Tapping the chip opens a compact menu with:

- `Automatic`
- `Lock precision`
- `Prefer speed`

This keeps the viewer clean while making the active precision state discoverable and controllable.

## UI Placement

Reuse the existing viewer HUD instead of adding a parallel precision surface.

- Extend the existing status-chip pattern rather than inventing a new floating widget family.
- Keep the precision chip visible enough to communicate mode, but compact enough that it does not clutter the viewport.
- Preserve semantics labels and tooltip surface so black-box tests can drive the control reliably.

## Performance Model

The performance target is not “CPU all the time.” The target is:

- smooth preview during active deep-zoom interaction on Android
- exact refinement after interaction settles

The design therefore depends on keeping preview and refinement separate. For supported modules:

- use shallow GPU at ordinary zoom
- use extended GPU preview deeper in the ladder
- refine only after idle or on manual lock

## Testing Strategy

Testing is part of the design, not a follow-up task.

### Unit Tests

- canonical viewport math
- precision-tier selection
- threshold and hysteresis behavior
- refine cancellation and restart rules
- manual override behavior

### Widget Tests

- precision chip labels and semantics
- precision menu behavior
- viewer status changes across zoom tiers
- no visual-state jump when switching from preview to refine
- dock-driven zoom and reset flows

### Integration Tests

- Android-oriented deep-zoom settle/refine behavior
- smooth preview followed by refine activation
- exactness assertions for supported escape-time modules
- frame-time smoke checks on the changed renderer path

### Maestro Regression Flows

Current Maestro documentation clearly supports resilient commands such as:

- `tapOn`
- `swipe`
- `scrollUntilVisible`
- `assertVisible`
- `takeScreenshot`
- `runFlow`
- `repeat`
- folder-based suite execution via `maestro test <folder>/`

I did not find a documented direct pinch primitive in the current Maestro docs, so the Android regression suite should not depend on synthetic multi-touch.

Instead, Maestro should drive deterministic deep-zoom regressions through the existing viewer controls:

- open a target fractal
- zoom in repeatedly using the viewer navigation dock
- verify precision chip state transitions
- open the precision menu
- lock precision
- pan via swipe
- confirm refine status and stable renderer state
- reset view
- return to catalog

This produces repeatable Android black-box coverage without depending on flaky multi-touch emulation.

## Rollout Gates

The subsystem is only considered fixed when all of these are true:

1. The same canonical viewport produces consistent center/zoom across preview and refine tiers.
2. Precision UI never overstates exactness.
3. Android preview interaction remains smooth enough for deep zoom exploration.
4. Precision refine starts after idle and cancels cleanly on new interaction.
5. The new Flutter test coverage passes.
6. The Android integration checks pass.
7. The Maestro flow suite passes on the ADB-connected physical device.

## Implementation Shape

The implementation plan should be split into phases inside one subsystem project:

1. Canonical viewport and precision coordinator
2. Renderer pipeline handoff and UI state wiring
3. Exact refine support expansion across 2D escape-time modules
4. Android integration and Maestro regression hardening

## Risks

- Broad exact-refine support for all 2D escape-time fractals is larger than the existing code currently proves.
- Existing preview paths are uneven: some modules have specialized GPU support, some do not.
- Any mismatch between viewport math and renderer tier conversions will show up as image jumps at handoff time.
- Android performance can regress if refine work is allowed to compete with active gesture updates.

## Decisions Locked In

- Architecture direction: evolve the existing renderer into a coherent precision ladder.
- Product mode: automatic first, with a compact override entry point.
- Platform target: Android physical device.
- Performance tradeoff: balanced, with smooth preview prioritized during interaction and precise refinement after idle.
- Test strategy: deterministic Maestro flows through stable viewer controls rather than undocumented multi-touch gestures.
