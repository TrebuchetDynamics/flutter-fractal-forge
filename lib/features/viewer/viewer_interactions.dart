part of 'fractal_viewer_screen.dart';

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

bool _viewerShouldUseTransparentBackgroundInAr(FractalModule module) {
  if (module.dimension != FractalDimension.twoD) {
    return false;
  }
  final paramIds = module.parameters.map((p) => p.id).toSet();
  return paramIds.contains('iterations') && paramIds.contains('bailout');
}

Future<void> _viewerOpenArOverlay(
  _FractalViewerScreenState state,
  BuildContext context,
) async {
  final controller = context.read<FractalController>();

  Future<void> openOverlayFallback({String? notice}) async {
    if (!state.mounted) return;
    if (notice != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(notice)),
      );
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: controller,
          child: const ArOverlayScreen(),
        ),
      ),
    );
  }

  if (!Platform.isAndroid) {
    await openOverlayFallback();
    return;
  }

  // Gate ARCore launch to avoid plugin installer crashes on profiles without
  // a Play Store handler (common on emulators and some custom ROMs).
  final supported = await ArCoreAnchorScreen.isSupportedOnDevice();
  if (!supported) {
    state._log.warn(
      'ar',
      'ARCore compatibility check reported unsupported; using overlay fallback',
    );
    await openOverlayFallback(
      notice: 'AR surface detection is unavailable. Using AR overlay.',
    );
    return;
  }

  final installed = await ArCoreAnchorScreen.isInstalledOnDevice();
  if (!installed) {
    state._log.warn(
      'ar',
      'ARCore services unavailable; using overlay fallback',
    );
    await openOverlayFallback(
      notice: 'ARCore services are unavailable. Using AR overlay.',
    );
    return;
  }

  final shouldTransparent =
      state._shouldUseTransparentBackgroundInAr(controller.module);
  final previousTransparency = controller.transparentBackground;
  final appliedTemporaryTransparency =
      shouldTransparent && !previousTransparency;

  Uint8List textureBytes;
  try {
    if (appliedTemporaryTransparency) {
      controller.setTransparentBackground(true);
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 16));
    }

    textureBytes = await state._exportService.capturePng(
      state._activeBoundaryKey(),
      pixelRatio: 1.5,
    );
  } catch (e) {
    state._log.warn(
      'ar',
      'ARCore texture capture failed; using overlay fallback',
      data: {'error': e.toString()},
    );
    await openOverlayFallback(
      notice: 'Could not capture fractal texture, using AR overlay',
    );
    return;
  } finally {
    if (appliedTemporaryTransparency) {
      try {
        controller.setTransparentBackground(previousTransparency);
      } catch (e) {
        state._log.warn(
          'ar',
          'Failed to restore transparency after AR capture',
          data: {'error': e.toString()},
        );
      }
    }
  }

  if (!state.mounted) return;

  try {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: controller,
          child: ArCoreAnchorScreen(
            fractalTextureBytes: textureBytes,
            fractalName: controller.module.id,
          ),
        ),
      ),
    );
  } catch (e) {
    state._log.warn(
      'ar',
      'ARCore route failed; using overlay fallback',
      data: {'error': e.toString()},
    );
    await openOverlayFallback(
      notice: 'ARCore session failed, using AR overlay',
    );
  }
}
