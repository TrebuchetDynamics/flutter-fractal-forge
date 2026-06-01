part of '../fractal_viewer_screen.dart';

KeyEventResult _viewerOnKeyEvent(
  _FractalViewerScreenState state,
  BuildContext context,
  KeyEvent event,
) {
  if (event is! KeyDownEvent) {
    return KeyEventResult.ignored;
  }

  final controller = state._activeController(context);
  const panStep = 0.08;

  if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
    final pan = controller.view.pan;
    controller.updatePan(Vector2(pan.x - panStep, pan.y));
    state._onAutoExploreUserCorrection();
    return KeyEventResult.handled;
  }
  if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
    final pan = controller.view.pan;
    controller.updatePan(Vector2(pan.x + panStep, pan.y));
    state._onAutoExploreUserCorrection();
    return KeyEventResult.handled;
  }
  if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
    final pan = controller.view.pan;
    controller.updatePan(Vector2(pan.x, pan.y - panStep));
    state._onAutoExploreUserCorrection();
    return KeyEventResult.handled;
  }
  if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
    final pan = controller.view.pan;
    controller.updatePan(Vector2(pan.x, pan.y + panStep));
    state._onAutoExploreUserCorrection();
    return KeyEventResult.handled;
  }
  if (event.logicalKey == LogicalKeyboardKey.minus ||
      event.logicalKey == LogicalKeyboardKey.numpadSubtract) {
    controller.updateZoom(controller.view.zoom / 1.2);
    state._onAutoExploreUserCorrection();
    return KeyEventResult.handled;
  }
  if (event.logicalKey == LogicalKeyboardKey.equal ||
      event.logicalKey == LogicalKeyboardKey.numpadAdd) {
    controller.updateZoom(controller.view.zoom * 1.2);
    state._onAutoExploreUserCorrection();
    return KeyEventResult.handled;
  }
  if (event.logicalKey == LogicalKeyboardKey.keyR) {
    controller.resetView();
    state._onAutoExploreUserCorrection();
    return KeyEventResult.handled;
  }

  return KeyEventResult.ignored;
}

void _viewerEnsureCompareController(
  _FractalViewerScreenState state,
  BuildContext context,
) {
  if (state._compareController != null) return;
  final registry = context.read<ModuleRegistry>();
  state._compareController = FractalController(registry);

  // Initialize B from A.
  final a = context.read<FractalController>();
  state._compareController!.selectModule(a.module, animate: false);
  for (final entry in a.params.entries) {
    state._compareController!.updateParam(entry.key, entry.value);
  }
  state._compareController!.updatePan(a.view.pan);
  state._compareController!.updateZoom(a.view.zoom);
  state._compareController!.updateRotation(a.view.rotation);
  state._compareController!.setTransparentBackground(a.transparentBackground);
}

void _viewerJumpToRandomFractal(
  _FractalViewerScreenState state,
  BuildContext context,
) {
  state._log.info('action', 'Random fractal');
  final registry = context.read<ModuleRegistry>();
  final controller = context.read<FractalController>();
  final currentId = controller.module.id;
  // Filter to real fractals (skip diagnostics)
  final candidates = registry.modules
      .where((m) =>
          m.id != currentId &&
          !m.id.contains('diag') &&
          !m.id.contains('gradient'))
      .toList();
  if (candidates.isEmpty) return;
  final rng = math.Random();
  final pick = candidates[rng.nextInt(candidates.length)];
  controller.selectModule(pick);
}

void _viewerOnRandomFractalFab(
  _FractalViewerScreenState state,
  BuildContext context,
) {
  // Random jump is an explicit user command; stop auto-zoom first so
  // navigation does not continue moving the view on the newly selected fractal.
  state._autoExploreService?.stop();

  state._jumpToRandomFractal(context);
  AccessibilityService.announce('Random fractal selected');
  HapticService.light();
}
