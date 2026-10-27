import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/platform/haptic_service.dart';
import 'package:flutter_fractals/core/widgets/animated_widgets.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/shared/widgets/circular_tool_surface.dart';

/// Circular tool input shared by viewer actions and sheet close buttons.
class AppToolButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final String? semanticHint;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final bool isPrimary;
  final bool? selected;
  final Duration delay;
  final double? sortOrder;

  const AppToolButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.semanticHint,
    this.onPressed,
    this.onLongPress,
    this.isPrimary = false,
    this.selected,
    this.delay = Duration.zero,
    this.sortOrder,
  });

  @override
  State<AppToolButton> createState() => _AppToolButtonState();
}

class _SecondaryToolIntent extends Intent {
  const _SecondaryToolIntent();
}

class _AppToolButtonState extends State<AppToolButton> {
  bool _pressed = false;
  bool _focused = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations ||
        (context.watch<AccessibilityService?>()?.reducedMotionEnabled ?? false);
    final disabled = widget.onPressed == null && widget.onLongPress == null;
    final hint = widget.semanticHint ??
        (widget.onLongPress == null
            ? null
            : AppLocalizations.of(context)?.viewerSecondaryActionHint ??
                'Long press or Shift+Enter opens the secondary action.');
    final surface = CircularToolSurface(
      icon: widget.icon,
      selected: widget.isPrimary || widget.selected == true,
      pressed: _pressed,
      focused: _focused,
      hovered: _hovered,
    );
    final content = MergeSemantics(
      child: Semantics(
        excludeSemantics: true,
        label: widget.tooltip,
        hint: hint,
        sortKey:
            widget.sortOrder == null ? null : OrdinalSortKey(widget.sortOrder!),
        button: true,
        selected: widget.selected,
        enabled: !disabled,
        onTap: widget.onPressed,
        onLongPress: widget.onLongPress,
        child: Tooltip(
          message: widget.tooltip,
          child: FocusableActionDetector(
            enabled: !disabled,
            onShowFocusHighlight: (value) => setState(() => _focused = value),
            mouseCursor:
                disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
            shortcuts: const {
              SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
              SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
              SingleActivator(LogicalKeyboardKey.enter, shift: true):
                  _SecondaryToolIntent(),
            },
            actions: {
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (_) {
                  widget.onPressed?.call();
                  return null;
                },
              ),
              _SecondaryToolIntent: CallbackAction<_SecondaryToolIntent>(
                onInvoke: (_) {
                  widget.onLongPress?.call();
                  return null;
                },
              ),
            },
            child: MouseRegion(
              onEnter: disabled ? null : (_) => setState(() => _hovered = true),
              onExit: (_) => setState(() => _hovered = false),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: widget.onPressed == null
                    ? null
                    : (_) {
                        HapticService.medium();
                        setState(() => _pressed = true);
                      },
                onTapUp: widget.onPressed == null
                    ? null
                    : (_) => setState(() => _pressed = false),
                onTapCancel: widget.onPressed == null
                    ? null
                    : () => setState(() => _pressed = false),
                onTap: widget.onPressed,
                onLongPress: widget.onLongPress,
                child:
                    disabled ? Opacity(opacity: 0.38, child: surface) : surface,
              ),
            ),
          ),
        ),
      ),
    );
    final button =
        reduceMotion ? content : FadeIn(delay: widget.delay, child: content);
    return widget.sortOrder == null
        ? button
        : FocusTraversalOrder(
            order: NumericFocusOrder(widget.sortOrder!), child: button);
  }
}
