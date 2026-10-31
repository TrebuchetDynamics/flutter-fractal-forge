import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';

/// Emphasis of a modal action: the filled primary CTA or an outlined partner.
enum AppActionEmphasis { primary, secondary }

/// Labeled icon action shared by modal footers and the controls panel.
///
/// Keeps the 48dp minimum target, the shared button geometry and the optional
/// haptic tap in one place. Callers still own semantics that carry extra hints
/// (for example the export sheet's save-location hint).
class AppActionButton extends StatelessWidget {
  final IconData? icon;
  final String label;
  final VoidCallback? onPressed;
  final AppActionEmphasis emphasis;
  final bool expand;

  /// Fires a medium haptic on tap. Off by default so dismiss/cancel actions
  /// stay silent.
  final bool haptic;
  final double minHeight;
  final EdgeInsetsGeometry? padding;

  const AppActionButton({
    super.key,
    this.icon,
    required this.label,
    this.onPressed,
    this.emphasis = AppActionEmphasis.primary,
    this.expand = false,
    this.haptic = false,
    this.minHeight = AccessibleSizing.minTouchTarget,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ??
        const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.sm);
    final style = emphasis == AppActionEmphasis.primary
        ? FilledButton.styleFrom(
            minimumSize: Size(0, minHeight),
            padding: effectivePadding,
          )
        : OutlinedButton.styleFrom(
            minimumSize: Size(0, minHeight),
            padding: effectivePadding,
          );
    final VoidCallback? handler = onPressed == null
        ? null
        : () {
            if (haptic) HapticFeedback.mediumImpact();
            onPressed!.call();
          };
    final child = Text(label, textAlign: TextAlign.center);
    final button = icon == null
        ? (emphasis == AppActionEmphasis.primary
            ? FilledButton(onPressed: handler, style: style, child: child)
            : OutlinedButton(onPressed: handler, style: style, child: child))
        : (emphasis == AppActionEmphasis.primary
            ? FilledButton.icon(
                onPressed: handler,
                style: style,
                icon: Icon(icon),
                label: child)
            : OutlinedButton.icon(
                onPressed: handler,
                style: style,
                icon: Icon(icon),
                label: child));
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Shared footer for a modal sheet.
///
/// One action stretches to the full width. Two actions sit side by side above
/// [stackBelow] logical pixels and stack in source order on phone widths.
/// [extra] always takes its own full-width row, so a secondary destination such
/// as "Set as wallpaper" does not compete with the primary save actions.
/// [pinned] paints the surface and a top border for a footer that stays outside
/// the scrolling body.
class AppSheetActions extends StatelessWidget {
  final List<Widget> actions;
  final Widget? extra;
  final bool pinned;
  final EdgeInsetsGeometry padding;
  final double stackBelow;

  const AppSheetActions({
    super.key,
    required this.actions,
    this.extra,
    this.pinned = false,
    this.padding = const EdgeInsets.fromLTRB(
        AppSpacing.md, AppSpacing.xs, AppSpacing.md, AppSpacing.md),
    this.stackBelow = 420,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = <Widget>[];
    if (actions.length == 1) {
      rows.add(SizedBox(width: double.infinity, child: actions.single));
    } else if (actions.length == 2) {
      rows.add(LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth < stackBelow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              actions.first,
              const SizedBox(height: AppSpacing.sm),
              actions.last,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: actions.first),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: actions.last),
          ],
        );
      }));
    } else {
      rows.add(Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.sm),
            actions[i],
          ],
        ],
      ));
    }
    if (extra != null) {
      rows.add(const SizedBox(height: AppSpacing.sm));
      rows.add(SizedBox(width: double.infinity, child: extra!));
    }
    return Container(
      padding: padding,
      decoration: pinned
          ? BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.12)),
              ),
            )
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rows,
      ),
    );
  }
}
