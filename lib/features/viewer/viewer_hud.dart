part of 'fractal_viewer_screen.dart';

Widget _viewerBuildTopFab({
  required String heroTag,
  required IconData icon,
  required String tooltip,
  required VoidCallback? onPressed,
}) {
  return Semantics(
    label: tooltip,
    button: true,
    child: Tooltip(
      message: tooltip,
      child: FloatingActionButton.small(
        heroTag: heroTag,
        onPressed: onPressed,
        elevation: 4,
        backgroundColor: AppColors.surface.withValues(alpha: 0.9),
        foregroundColor: AppColors.textPrimary,
        child: Icon(icon),
      ),
    ),
  );
}

Widget _viewerBuildViewerTitleChip(
  BuildContext context,
  FractalController controller,
) {
  final l10n = AppLocalizations.of(context)!;
  return Container(
    key: const Key('viewerTitleChip'),
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.58),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.white24),
    ),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 200),
      child: Text(
        controller.module.displayName(l10n),
        key: const Key('viewerTitleChipText'),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}

String _viewerFormatZoomLabel(double zoom) {
  if (zoom == 0) return '0';
  if (zoom >= 1000 || zoom < 0.01) {
    return zoom.toStringAsExponential(2);
  }
  return zoom.toStringAsFixed(2);
}

Widget _viewerBuildViewerStatusChip(
  _FractalViewerScreenState state,
  BuildContext context,
  FractalController controller,
) {
  final backendLabel =
      state._backendDecision.backend == RendererBackend.cpu ? 'CPU' : 'GPU';
  final zoomLabel = state._formatZoomLabel(controller.view.zoom);
  final iterations = (controller.params['iterations'] as num?)?.toInt() ?? 0;
  final moduleId = controller.module.id;
  final shaderId = controller.module.shaderAsset;
  final presetId = controller.module.defaultPreset.id;

  final semanticsLabel =
      'Render status. Backend $backendLabel. Module $moduleId. Zoom $zoomLabel. Iterations $iterations. Shader $shaderId. Preset $presetId.';

  return Semantics(
    container: true,
    liveRegion: true,
    label: semanticsLabel,
    child: Container(
      key: const Key('viewerStatusChip'),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        '$backendLabel · z=$zoomLabel · it=$iterations',
        key: const Key('viewerStatusChipText'),
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}
