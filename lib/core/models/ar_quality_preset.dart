import 'package:flutter_fractals/l10n/app_localizations.dart';

enum ArQualityPreset {
  low,
  medium,
  high,
}

extension ArQualityPresetLabels on ArQualityPreset {
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
