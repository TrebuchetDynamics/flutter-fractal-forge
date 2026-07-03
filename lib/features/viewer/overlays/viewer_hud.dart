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
  final maxWidth = (MediaQuery.sizeOf(context).width - 96).clamp(120.0, 260.0);
  return ClipRRect(
    key: const Key('viewerTitleChip'),
    borderRadius: BorderRadius.circular(16),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.68),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Text(
            controller.module.displayName(l10n),
            key: const Key('viewerTitleChipText'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ),
    ),
  );
}
