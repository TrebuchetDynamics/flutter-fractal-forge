import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/shared/widgets/app_feedback_snack_bar.dart';
import 'package:flutter_fractals/shared/widgets/app_tool_button.dart';

/// Opens a shared sheet without a second Material drag handle.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  BoxConstraints? constraints,
}) =>
    showModalBottomSheet<T>(
      context: context,
      useSafeArea: true,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      showDragHandle: false,
      constraints: constraints,
      builder: builder,
    );

/// Scrollable tool-panel frame shared by quick options and feature settings.
class AppOptionsSheet extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final double maxHeightFactor;
  final Widget child;

  const AppOptionsSheet({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.maxHeightFactor = 0.78,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => AppBottomSheet(
        maxHeightFactor: maxHeightFactor,
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppBottomSheetHeader(
                    icon: icon,
                    title: title,
                    subtitle: subtitle,
                    onClose: () => Navigator.of(context).pop(),
                  ),
                  Divider(
                      height: 1,
                      color: Theme.of(context).colorScheme.outlineVariant),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg,
                        AppSpacing.md, AppSpacing.lg, AppSpacing.xxxl),
                    child: Material(color: Colors.transparent, child: child),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
}

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
    // Inset content above either form of Android navigation. Edge-to-edge
    // devices may report only systemGestureInsets while classic navigation
    // buttons are exposed through viewPadding.
    // The surface still extends to the screen edge — only the content is
    // padded — and the extra inset is added to the height budget so the
    // visible content area is unchanged.
    final systemBottomInset = math.max(
      mq.viewPadding.bottom,
      mq.systemGestureInsets.bottom,
    );
    final bottomInset = math.max(systemBottomInset, AppSpacing.xl);
    // Navigation is already covered by a visible keyboard; reserve the larger
    // inset, rather than adding both and starving short viewports.
    return Padding(
      padding: EdgeInsets.only(
        bottom: math.max(0, mq.viewInsets.bottom - bottomInset),
      ),
      child: LayoutBuilder(
          builder: (context, constraints) => Container(
                constraints: BoxConstraints(
                  maxHeight: math.min(
                    constraints.maxHeight,
                    mq.size.height * effectiveFactor + bottomInset,
                  ),
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(28)),
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
              )),
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
    return Center(
      child: SheetDragHandle(
        margin: EdgeInsets.only(top: AppSpacing.md),
        color: Theme.of(context).colorScheme.outline,
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
    final systemBottomInset = math.max(
      mq.viewPadding.bottom,
      mq.systemGestureInsets.bottom,
    );
    final bottomInset = math.max(systemBottomInset, AppSpacing.xl);

    return Padding(
      padding: EdgeInsets.only(
        bottom: math.max(0, mq.viewInsets.bottom - bottomInset),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: initialChildSize,
        minChildSize: minChildSize,
        maxChildSize: maxChildSize,
        expand: expand,
        builder: (context, scrollController) {
          return Material(
            color: Theme.of(context).colorScheme.surface,
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
      ),
    );
  }
}

/// Standard header row for an [AppBottomSheet].
///
/// Renders a theme-aware icon badge on the left, a [title] + optional [subtitle]
/// column in the middle, and a close [IconButton] on the right.
class AppBottomSheetHeader extends StatelessWidget {
  final IconData icon;

  /// Optional gradient override for the theme-aware icon badge.
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
          _buildAppHeaderTitle(context, icon, iconGradient, title, subtitle),
          if (onClose != null)
            AppToolButton(
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              onPressed: onClose,
              icon: Icons.close_rounded,
            ),
        ],
      ),
    );
  }
}

/// Standard app dialog with the same icon badge and surface treatment as sheets.
///
/// Pass [actions] for a bespoke footer, or the [cancelLabel]/[confirmLabel]
/// pair for the usual dismiss/confirm row. The pair keeps button order,
/// emphasis and destructive styling identical in every dialog.
class AppDialog extends StatelessWidget {
  final IconData icon;
  final Gradient? iconGradient;
  final String title;
  final String? subtitle;
  final Widget? content;
  final List<Widget> actions;

  /// Dismiss action label. Built as a text button before the confirm action.
  final String? cancelLabel;
  final VoidCallback? onCancel;

  /// Confirmation action label. Built as a filled button after the cancel
  /// action.
  final String? confirmLabel;
  final VoidCallback? onConfirm;

  /// Uses the error fill for the confirmation button.
  final bool destructiveConfirm;
  final IconData? confirmIcon;

  const AppDialog({
    super.key,
    required this.icon,
    this.iconGradient,
    required this.title,
    this.subtitle,
    this.content,
    this.actions = const [],
    this.cancelLabel,
    this.onCancel,
    this.confirmLabel,
    this.onConfirm,
    this.destructiveConfirm = false,
    this.confirmIcon,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      scrollable: true,
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
          _buildAppHeaderTitle(context, icon, iconGradient, title, subtitle),
        ],
      ),
      content: content == null
          ? null
          : DefaultTextStyle(
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              child: content!,
            ),
      actions: _resolvedActions(context),
    );
  }

  /// Custom [actions] win; otherwise build the shared cancel/confirm pair.
  List<Widget> _resolvedActions(BuildContext context) {
    if (actions.isNotEmpty) return actions;
    return [
      if (cancelLabel != null)
        TextButton(
          onPressed: onCancel ?? () => Navigator.of(context).maybePop(),
          child: Text(cancelLabel!),
        ),
      if (confirmLabel != null)
        confirmIcon == null
            ? FilledButton(
                onPressed: onConfirm,
                style:
                    destructiveConfirm ? destructiveFilledButtonStyle() : null,
                child: Text(confirmLabel!),
              )
            : FilledButton.icon(
                onPressed: onConfirm,
                style:
                    destructiveConfirm ? destructiveFilledButtonStyle() : null,
                icon: Icon(confirmIcon),
                label: Text(confirmLabel!),
              ),
    ];
  }
}

Widget _buildAppHeaderTitle(
  BuildContext context,
  IconData icon,
  Gradient? iconGradient,
  String title,
  String? subtitle,
) {
  return Expanded(
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: iconGradient,
            color: iconGradient == null
                ? Theme.of(context).colorScheme.primary.withValues(alpha: .12)
                : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon,
              color: iconGradient == null
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white,
              size: 20),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Keep sheet titles bounded so large text scales leave room for
              // body content.
              Text(title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium),
              if (subtitle != null)
                Text(subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        )),
            ],
          ),
        ),
      ],
    ),
  );
}
