import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';

/// Standard bottom sheet container with drag handle and rounded top corners.
///
/// Eliminates the repeated [Container] + drag-handle + decoration boilerplate
/// found in every modal bottom sheet. Pass [children] (header, divider,
/// [Flexible] content, etc.) and they are placed in a [Column] below the handle.
class AppBottomSheet extends StatelessWidget {
  /// Fraction of screen height available for this sheet (default: 0.68).
  final double maxHeightFactor;

  /// Widgets placed after the drag handle (typically an [AppBottomSheetHeader],
  /// a [Divider], and a [Flexible] scrollable body).
  final List<Widget> children;

  const AppBottomSheet({
    super.key,
    this.maxHeightFactor = 0.68,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    // In landscape the screen height is much shorter (~360 px on phones), so
    // allow the sheet to expand further so controls remain usable.
    final isLandscape = mq.orientation == Orientation.landscape;
    final effectiveFactor =
        isLandscape ? maxHeightFactor.clamp(0.85, 0.92) : maxHeightFactor;
    // Inset content above the system navigation bar / gesture area so the
    // bottom of the sheet never merges with the phone's on-screen buttons.
    // The surface still extends to the screen edge — only the content is
    // padded — and the extra inset is added to the height budget so the
    // visible content area is unchanged.
    final bottomInset =
        math.max(mq.viewPadding.bottom, AppSpacing.xl) + mq.viewInsets.bottom;
    return Container(
      constraints: BoxConstraints(
        maxHeight:
            math.max(mq.size.height * effectiveFactor, 280) + bottomInset,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _DragHandle(),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// The small rounded grabber bar shown at the top of a modal bottom sheet.
///
/// Standardizes the `40×4`, radius-2 pill shared by every sheet. [color] and
/// [margin] vary per sheet, so they are parameters rather than baked in.
class SheetDragHandle extends StatelessWidget {
  final Color color;
  final EdgeInsetsGeometry? margin;

  const SheetDragHandle({super.key, required this.color, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SheetDragHandle(
        margin: EdgeInsets.only(top: AppSpacing.md),
        color: AppColors.border,
      ),
    );
  }
}

/// Standard shell for draggable modal sheets.
class AppDraggableBottomSheet extends StatelessWidget {
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;
  final bool expand;
  final List<Widget> Function(BuildContext context, ScrollController controller)
      childrenBuilder;

  const AppDraggableBottomSheet({
    super.key,
    required this.childrenBuilder,
    this.initialChildSize = 0.68,
    this.minChildSize = 0.35,
    this.maxChildSize = 0.92,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final bottomInset =
        math.max(mq.viewPadding.bottom, AppSpacing.xl) + mq.viewInsets.bottom;

    return DraggableScrollableSheet(
      initialChildSize: initialChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      expand: expand,
      builder: (context, scrollController) {
        return Material(
          color: AppColors.surface,
          elevation: 18,
          shadowColor: Colors.black.withValues(alpha: 0.35),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: Column(
              children: [
                const _DragHandle(),
                ...childrenBuilder(context, scrollController),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Standard header row for an [AppBottomSheet].
///
/// Renders a gradient icon badge on the left, a [title] + optional [subtitle]
/// column in the middle, and a close [IconButton] on the right.
class AppBottomSheetHeader extends StatelessWidget {
  final IconData icon;

  /// Gradient for the icon badge. Defaults to [AppColors.primaryGradient].
  final Gradient? iconGradient;

  final String title;
  final String? subtitle;
  final VoidCallback? onClose;

  const AppBottomSheetHeader({
    super.key,
    required this.icon,
    this.iconGradient,
    required this.title,
    this.subtitle,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: iconGradient ?? AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.titleMedium),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
              ],
            ),
          ),
          if (onClose != null)
            IconButton(
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              onPressed: onClose,
              icon: Icon(Icons.close_rounded, color: AppColors.textMuted),
            ),
        ],
      ),
    );
  }
}

/// Standard app dialog with the same icon badge and surface treatment as sheets.
class AppDialog extends StatelessWidget {
  final IconData icon;
  final Gradient? iconGradient;
  final String title;
  final String? subtitle;
  final Widget? content;
  final List<Widget> actions;

  const AppDialog({
    super.key,
    required this.icon,
    this.iconGradient,
    required this.title,
    this.subtitle,
    this.content,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titlePadding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      contentPadding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: iconGradient ?? AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.titleMedium),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      content: content == null
          ? null
          : DefaultTextStyle(
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              child: content!,
            ),
      actions: actions,
    );
  }
}
