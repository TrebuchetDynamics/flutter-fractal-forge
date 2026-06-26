import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';

/// A wrapper widget that provides accessibility features.
///
/// Wraps child widgets with appropriate [Semantics] to make them
/// accessible to screen readers (TalkBack/VoiceOver).
///
/// {@category Accessibility}
class AccessibleWrapper extends StatelessWidget {
  /// The child widget to wrap.
  final Widget child;

  /// The semantic label for screen readers.
  final String? label;

  /// A hint about what happens when the element is activated.
  final String? hint;

  /// Whether this element is a button.
  final bool isButton;

  /// Whether this element is a header.
  final bool isHeader;

  /// Whether this element is focusable.
  final bool isFocusable;

  /// Whether this element is currently selected.
  final bool? isSelected;

  /// Whether this element is enabled.
  final bool isEnabled;

  /// Callback when the element is activated.
  final VoidCallback? onTap;

  /// Callback when the element receives long press.
  final VoidCallback? onLongPress;

  /// Creates an accessible wrapper.
  const AccessibleWrapper({
    Key? key,
    required this.child,
    this.label,
    this.hint,
    this.isButton = false,
    this.isHeader = false,
    this.isFocusable = true,
    this.isSelected,
    this.isEnabled = true,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      button: isButton,
      header: isHeader,
      focusable: isFocusable,
      selected: isSelected,
      enabled: isEnabled,
      onTap: onTap,
      onLongPress: onLongPress,
      child: child,
    );
  }
}

/// A button with accessibility features built in.
///
/// Automatically handles focus indicators, minimum touch target sizes,
/// and semantic labels for screen readers.
class AccessibleButton extends StatefulWidget {
  /// The button's child widget.
  final Widget child;

  /// Callback when button is pressed.
  final VoidCallback? onPressed;

  /// Semantic label for screen readers.
  final String semanticLabel;

  /// Optional hint about what happens on activation.
  final String? semanticHint;

  /// Minimum size for touch target (default 48x48).
  final double minTouchTarget;

  /// Whether to show focus indicator.
  final bool showFocusIndicator;

  /// Optional tooltip text.
  final String? tooltip;

  /// Creates an accessible button.
  const AccessibleButton({
    Key? key,
    required this.child,
    required this.onPressed,
    required this.semanticLabel,
    this.semanticHint,
    this.minTouchTarget = AccessibleSizing.minTouchTarget,
    this.showFocusIndicator = true,
    this.tooltip,
  }) : super(key: key);

  @override
  State<AccessibleButton> createState() => _AccessibleButtonState();
}

class _AccessibleButtonState extends State<AccessibleButton> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    Widget button = Semantics(
      label: widget.semanticLabel,
      hint: widget.semanticHint,
      button: true,
      enabled: widget.onPressed != null,
      child: GestureDetector(
        onTap: widget.onPressed,
        behavior: HitTestBehavior.opaque,
        child: Focus(
          onFocusChange: (focused) {
            if (mounted) setState(() => _isFocused = focused);
          },
          child: Container(
            constraints: BoxConstraints(
              minWidth: widget.minTouchTarget,
              minHeight: widget.minTouchTarget,
            ),
            decoration: widget.showFocusIndicator && _isFocused
                ? BoxDecoration(
                    border: Border.all(
                      color: HighContrastColors.focusIndicator,
                      width: AccessibleSizing.focusIndicatorWidth,
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                  )
                : null,
            child: Center(child: widget.child),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(message: widget.tooltip!, child: button);
    }

    return button;
  }
}

/// A slider with full accessibility support.
///
/// Provides semantic labels with current value, min, max, and allows
/// adjustment via accessibility actions.
class AccessibleSlider extends StatelessWidget {
  /// Current value.
  final double value;

  /// Minimum value.
  final double min;

  /// Maximum value.
  final double max;

  /// Number of discrete divisions.
  final int? divisions;

  /// Label for the slider.
  final String label;

  /// Callback when value changes.
  final ValueChanged<double>? onChanged;

  /// Optional step increment for keyboard/a11y adjustments.
  final double? step;

  /// Creates an accessible slider.
  const AccessibleSlider({
    Key? key,
    required this.value,
    required this.min,
    required this.max,
    required this.label,
    this.divisions,
    this.onChanged,
    this.step,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentPercent = ((value - min) / (max - min) * 100).round();
    final semanticValue = value.toStringAsFixed(2);

    return Semantics(
      label: label,
      value: '$semanticValue ($currentPercent%)',
      slider: true,
      increasedValue: _getIncreasedValue(),
      decreasedValue: _getDecreasedValue(),
      onIncrease: onChanged != null ? () => _increase() : null,
      onDecrease: onChanged != null ? () => _decrease() : null,
      child: Slider(
        value: value.clamp(min, max),
        min: min,
        max: max,
        divisions: divisions,
        label: semanticValue,
        onChanged: onChanged,
      ),
    );
  }

  String _getIncreasedValue() {
    final increment = step ?? (max - min) / 10;
    final newValue = (value + increment).clamp(min, max);
    return newValue.toStringAsFixed(2);
  }

  String _getDecreasedValue() {
    final decrement = step ?? (max - min) / 10;
    final newValue = (value - decrement).clamp(min, max);
    return newValue.toStringAsFixed(2);
  }

  void _increase() {
    final increment = step ?? (max - min) / 10;
    final newValue = (value + increment).clamp(min, max);
    onChanged?.call(newValue);
  }

  void _decrease() {
    final decrement = step ?? (max - min) / 10;
    final newValue = (value - decrement).clamp(min, max);
    onChanged?.call(newValue);
  }
}

/// A toggle/switch with full accessibility support.
class AccessibleToggle extends StatelessWidget {
  /// Current value.
  final bool value;

  /// Label for the toggle.
  final String label;

  /// Callback when value changes.
  final ValueChanged<bool>? onChanged;

  /// Whether the toggle is enabled.
  final bool enabled;

  /// Creates an accessible toggle.
  const AccessibleToggle({
    Key? key,
    required this.value,
    required this.label,
    this.onChanged,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      toggled: value,
      enabled: enabled && onChanged != null,
      onTap: enabled && onChanged != null ? () => onChanged!(!value) : null,
      child: Switch(
        value: value,
        onChanged: enabled ? onChanged : null,
      ),
    );
  }
}

/// Extension for announcing messages to screen readers.
extension SemanticAnnouncer on BuildContext {
  /// Announces a message to screen readers.
  ///
  /// Use for important state changes that should be communicated
  /// to users of assistive technology.
  void announce(String message, {bool assertive = false}) {
    AccessibilityService.announce(
      message,
      politeness: assertive ? Assertiveness.assertive : Assertiveness.polite,
    );
  }
}

/// A widget that wraps another widget with a focus traversal group.
///
/// Helps organize keyboard/screen reader navigation in logical groups.
class AccessibleGroup extends StatelessWidget {
  /// The child widget.
  final Widget child;

  /// The semantic label for the group.
  final String? label;

  /// Whether this group should be a focus scope.
  final bool isFocusScope;

  /// Creates an accessible group.
  const AccessibleGroup({
    Key? key,
    required this.child,
    this.label,
    this.isFocusScope = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget result = child;

    if (label != null) {
      result = Semantics(
        container: true,
        label: label,
        child: result,
      );
    }

    if (isFocusScope) {
      result = FocusScope(child: result);
    }

    return FocusTraversalGroup(child: result);
  }
}

/// A widget that provides a live region for screen reader announcements.
///
/// When the [message] changes, screen readers will announce the new value.
class LiveRegion extends StatelessWidget {
  /// The message to display and announce.
  final String message;

  /// The child widget to display.
  final Widget? child;

  /// Whether announcements should be polite (default) or assertive.
  final bool assertive;

  /// Creates a live region.
  const LiveRegion({
    Key? key,
    required this.message,
    this.child,
    this.assertive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: message,
      child: child ??
          Text(
            message,
            style: const TextStyle(fontSize: 0, height: 0),
          ),
    );
  }
}

/// A widget that excludes its subtree from semantics.
///
/// Use sparingly - only for purely decorative elements that would
/// clutter the accessibility tree.
/// 
/// Note: Named differently from Flutter's built-in ExcludeSemantics
/// to avoid import conflicts.
class FractalExcludeSemantics extends StatelessWidget {
  /// The child widget to exclude.
  final Widget child;

  /// Creates an exclude semantics widget.
  const FractalExcludeSemantics({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      excludeSemantics: true,
      child: child,
    );
  }
}

/// Minimum touch target wrapper that ensures WCAG compliance.
///
/// Ensures interactive elements meet the minimum 48x48 logical pixel
/// touch target size requirement.
class MinTouchTarget extends StatelessWidget {
  /// The child widget.
  final Widget child;

  /// The minimum size (default 48).
  final double minSize;

  /// Creates a min touch target wrapper.
  const MinTouchTarget({
    Key? key,
    required this.child,
    this.minSize = AccessibleSizing.minTouchTarget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minSize,
        minHeight: minSize,
      ),
      child: Center(child: child),
    );
  }
}
