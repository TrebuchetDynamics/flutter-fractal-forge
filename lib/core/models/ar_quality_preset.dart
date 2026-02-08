import 'package:flutter_fractals/l10n/app_localizations.dart';

/// Quality presets for AR (Augmented Reality) camera overlay mode.
///
/// These presets balance visual quality against performance to maintain
/// smooth frame rates during real-time camera overlay rendering.
///
/// {@category Models}
enum ArQualityPreset {
  /// Low quality for maximum performance.
  ///
  /// Uses reduced iterations and steps. Best for older devices
  /// or when smooth camera feed is prioritized.
  low,

  /// Balanced quality and performance.
  ///
  /// Provides good visual detail while maintaining acceptable
  /// frame rates on most devices. Default choice.
  medium,

  /// Maximum visual quality.
  ///
  /// Uses higher iteration counts for more detail. May reduce
  /// frame rate on lower-end devices.
  high,
}

/// Extension providing localized labels for [ArQualityPreset].
extension ArQualityPresetLabels on ArQualityPreset {
  /// Returns the localized display label for this preset.
  ///
  /// Uses the provided [l10n] instance to fetch the appropriate
  /// translated string.
  String label(AppLocalizations l10n) {
    switch (this) {
      case ArQualityPreset.low:
        return l10n.arQualityLow;
      case ArQualityPreset.medium:
        return l10n.arQualityMedium;
      case ArQualityPreset.high:
        return l10n.arQualityHigh;
    }
  }
}

/// Returns parameter overrides for the given [preset] and [moduleId].
///
/// Each fractal module may define different parameters to adjust based
/// on quality level. This function maps quality presets to specific
/// parameter values.
///
/// Returns an empty map if no overrides are defined for the module.
///
/// Example:
/// ```dart
/// final overrides = arQualityParamsForModule(
///   ArQualityPreset.low,
///   'mandelbrot',
/// );
/// // Returns {'iterations': 80}
/// ```
Map<String, Object> arQualityParamsForModule(ArQualityPreset preset, String moduleId) {
  switch (moduleId) {
    case 'mandelbrot':
      return {
        'iterations': _qualityValue(preset, low: 80, medium: 140, high: 220),
      };
    case 'mandelbulb':
      return {
        'iterations': _qualityValue(preset, low: 30, medium: 50, high: 80),
        'steps': _qualityValue(preset, low: 80, medium: 120, high: 160),
      };
    default:
      return const {};
  }
}

/// Helper to select a value based on quality preset.
int _qualityValue(ArQualityPreset preset,
    {required int low, required int medium, required int high}) {
  switch (preset) {
    case ArQualityPreset.low:
      return low;
    case ArQualityPreset.medium:
      return medium;
    case ArQualityPreset.high:
      return high;
  }
}
