import 'package:flutter/foundation.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

/// A function that returns a localized string for the current locale.
///
/// Used for parameter labels and option descriptions.
typedef LocalizedText = String Function(AppLocalizations l10n);

/// The data type of a fractal parameter.
///
/// Determines how the parameter is rendered in the UI and how its
/// value is validated and stored.
enum FractalParamType {
  /// A floating-point number parameter.
  ///
  /// Rendered as a slider with continuous values.
  /// Value type: [double]
  float,

  /// An integer parameter.
  ///
  /// Rendered as a slider with discrete steps.
  /// Value type: [int]
  integer,

  /// A selection from a fixed set of options.
  ///
  /// Rendered as a dropdown or segmented control.
  /// Value type: depends on [FractalParamOption.value]
  enumeration,

  /// A boolean on/off parameter.
  ///
  /// Rendered as a switch or checkbox.
  /// Value type: [bool]
  boolean,
}

/// An option for an enumeration-type parameter.
///
/// Defines a single selectable value with its display label.
///
/// Example:
/// ```dart
/// FractalParamOption(
///   value: 0,
///   label: (l10n) => l10n.colorFire,
/// )
/// ```
class FractalParamOption {
  /// The underlying value for this option.
  ///
  /// This is what gets stored in the parameter map and passed to shaders.
  final Object value;

  /// Returns the localized display label for this option.
  final LocalizedText label;

  /// Creates a new parameter option.
  const FractalParamOption({
    required this.value,
    required this.label,
  });
}

/// Defines the schema for a configurable fractal parameter.
///
/// A [FractalParameter] describes how a single adjustable value should
/// behave: its valid range, step increment, default value, and UI
/// representation.
///
/// Parameters are defined per [FractalModule] and used to:
/// - Generate the controls UI automatically
/// - Validate user input
/// - Clamp values to valid ranges
/// - Store and restore presets
///
/// {@category Models}
///
/// Example:
/// ```dart
/// FractalParameter(
///   id: 'iterations',
///   label: (l10n) => l10n.paramIterations,
///   type: FractalParamType.integer,
///   min: 10,
///   max: 500,
///   step: 1,
///   defaultValue: 100,
/// )
/// ```
@immutable
class FractalParameter {
  /// Unique identifier for this parameter.
  ///
  /// Used as the key in parameter maps and for preset serialization.
  /// Should be a lowercase, camelCase string (e.g., 'iterations', 'colorScheme').
  final String id;

  /// Returns the localized display label for this parameter.
  ///
  /// Shown in the controls UI next to the input widget.
  final LocalizedText label;

  /// The data type of this parameter.
  ///
  /// Determines the UI widget and value handling.
  final FractalParamType type;

  /// The minimum allowed value (for numeric types).
  ///
  /// For [FractalParamType.enumeration] and [FractalParamType.boolean],
  /// this is typically 0.
  final double min;

  /// The maximum allowed value (for numeric types).
  ///
  /// For [FractalParamType.enumeration], this should match `options.length - 1`.
  final double max;

  /// The step increment for slider-based inputs.
  ///
  /// For integers, use 1.0. For floats, use an appropriate precision
  /// (e.g., 0.1 or 0.01).
  final double step;

  /// The initial value when no preset is applied.
  ///
  /// Must be within the [min]/[max] range and compatible with [type].
  final Object defaultValue;

  /// Available options for enumeration-type parameters.
  ///
  /// Only used when [type] is [FractalParamType.enumeration].
  /// Empty for other types.
  final List<FractalParamOption> options;

  /// Creates a new [FractalParameter] with the specified schema.
  ///
  /// For enumeration types, ensure [options] is populated with
  /// all valid choices.
  const FractalParameter({
    required this.id,
    required this.label,
    required this.type,
    required this.min,
    required this.max,
    required this.step,
    required this.defaultValue,
    this.options = const [],
  });
}
