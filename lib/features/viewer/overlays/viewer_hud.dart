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
  FractalController controller, {
  bool compact = false,
}) {
  final l10n = AppLocalizations.of(context)!;
  final colors = Theme.of(context).colorScheme;
  final maxWidth =
      math.max(0.0, math.min(360.0, MediaQuery.sizeOf(context).width - 96));
  return ClipRRect(
    key: const Key('viewerTitleChip'),
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, minHeight: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.module.displayName(l10n),
              key: const Key('viewerTitleChipText'),
              maxLines: compact ? 1 : 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelMedium.copyWith(
                color: colors.onSurface,
                fontSize: 14,
                height: 1.25,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _viewerBuildChromeHeader(
  BuildContext context,
  FractalController controller, {
  required bool showTitle,
  required bool compact,
  required bool showBack,
  required VoidCallback? onBack,
  Widget? extra,
}) {
  return Row(
    children: [
      if (showBack) _viewerBuildBackButton(context, onPressed: onBack),
      if (showBack && showTitle) const SizedBox(width: 12),
      if (showTitle)
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _viewerBuildViewerTitleChip(context, controller,
                  compact: compact),
              if (extra != null) ...[
                const SizedBox(height: 8),
                extra,
              ],
            ],
          ),
        ),
    ],
  );
}

Widget _viewerBuildBackButton(BuildContext context, {VoidCallback? onPressed}) {
  final l10n = AppLocalizations.of(context)!;
  final colors = Theme.of(context).colorScheme;
  final largeTargets =
      context.watch<AccessibilityService?>()?.largeTargetsEnabled == true;
  return IconButton(
    key: const Key('viewerBackToCatalogButton'),
    tooltip: l10n.viewerBackToCatalog,
    style: IconButton.styleFrom(
      visualDensity: VisualDensity.standard,
      foregroundColor: colors.onSurface,
      backgroundColor: Colors.transparent,
      shape: const CircleBorder(),
      padding: EdgeInsets.zero,
      fixedSize: Size.square(largeTargets ? 56 : 48),
    ),
    onPressed: onPressed,
    icon: Center(
      child: Container(
        width: largeTargets ? 40 : 36,
        height: largeTargets ? 40 : 36,
        decoration: BoxDecoration(
          color: colors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Icon(
          Icons.arrow_back_rounded,
          size: largeTargets ? 24 : 20,
          semanticLabel: l10n.viewerBackToCatalog,
        ),
      ),
    ),
  );
}
