part of '../fractal_viewer_screen.dart';

Widget _viewerBuildTopFab({
  required IconData icon,
  required String tooltip,
  required VoidCallback? onPressed,
}) {
  // Reuse the custom FloatingActionButtonWidget so the top control matches the
  // press animation, sizing, and accessibility behavior of the bottom FAB
  // column instead of being a stock Material FAB.
  return FloatingActionButtonWidget(
    icon: icon,
    tooltip: tooltip,
    onPressed: onPressed,
    isCompact: true,
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
