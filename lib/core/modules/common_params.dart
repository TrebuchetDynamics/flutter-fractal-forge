import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

/// Common parameter builders shared across many 2D modules.
///
/// Keep these helpers small and stable; they are used in tests and codegen later.
class CommonFractalParams {
  static const int paletteCount = 64;

  static const List<String> _proceduralPaletteNames = [
    'Viridis Depth',
    'Magma Core',
    'Cividis Safe',
    'Perceptual Rainbow',
    'Warm Cool Relief',
    'Blue Yellow Opponent',
    'High Contrast Mono',
    'Colorblind Safe Fire',
    'Glacier Mint',
    'Solar Flare',
    'Ultraviolet',
    'Cyan Furnace',
    'Amber Circuit',
    'Plasma Wave',
    'Forest Lumen',
    'Ruby Ice',
    'Electric Dusk',
    'Golden Orbit',
    'Teal Comet',
    'Crimson Tide',
    'Lime Halo',
    'Indigo Ember',
    'Tangerine Sky',
    'Arctic Fire',
    'Magenta Bloom',
    'Blue Steel',
    'Opal Pulse',
    'Saffron Smoke',
    'Jade Signal',
    'Coral Eclipse',
    'Sonic Violet',
    'Bronze Aurora',
    'Cerulean Ash',
    'Pink Lightning',
    'Green Inferno',
    'Royal Plasma',
    'Desert Neon',
    'Ice Sapphire',
    'Infrared Moss',
    'Pearl Shadow',
    'Signal Orange',
    'Deep Orchid',
    'Aqua Gold',
    'Volcanic Glass',
    'Starlight Candy',
  ];

  static const List<String> _reliefBasePaletteNames = [
    'Fire',
    'Ocean',
    'Psychedelic',
    'Grayscale',
  ];

  static FractalParameter iterations({
    required num defaultValue,
    num min = 20,
    num max = 5000,
  }) {
    return FractalParameter(
      id: 'iterations',
      label: (l10n) => l10n.paramIterations,
      type: FractalParamType.integer,
      min: min.toDouble(),
      max: max.toDouble(),
      step: 1,
      defaultValue: defaultValue,
    );
  }

  static FractalParameter bailout({
    required double defaultValue,
    double min = 2.0,
    double max = 8.0,
  }) {
    return FractalParameter(
      id: 'bailout',
      label: (l10n) => l10n.paramBailout,
      type: FractalParamType.float,
      min: min,
      max: max,
      step: 0.1,
      defaultValue: defaultValue,
    );
  }

  static FractalParameter colorScheme4({Object defaultValue = 0, num max = 3}) {
    return FractalParameter(
      id: 'colorScheme',
      label: (l10n) => l10n.paramColorScheme,
      type: FractalParamType.enumeration,
      min: 0,
      max: max.toDouble(),
      step: 1,
      defaultValue: defaultValue,
      options: [
        FractalParamOption(value: 0, label: (l10n) => l10n.colorFire),
        FractalParamOption(value: 1, label: (l10n) => l10n.colorOcean),
        FractalParamOption(value: 2, label: (l10n) => l10n.colorPsychedelic),
        FractalParamOption(value: 3, label: (l10n) => l10n.colorGrayscale),
      ],
    );
  }

  static FractalParameter colorCount({int defaultValue = 64}) {
    return FractalParameter(
      id: 'colorCount',
      label: (l10n) => 'Color count',
      type: FractalParamType.integer,
      min: 2,
      max: 64,
      step: 1,
      defaultValue: defaultValue,
    );
  }

  /// Color cycle speed for palette-texture shaders (G15).
  ///
  /// A value of 0.0 = static (no cycling); 0.1 = ~1 full cycle every 10 s.
  /// Only meaningful at deep zoom where the perturbation shader is active
  /// (zoom >= 5e6). The controls panel shows this slider for all modules that
  /// include it, but it only has visible effect in the perturbation path.
  static FractalParameter colorCycleSpeed() {
    return FractalParameter(
      id: 'colorCycleSpeed',
      label: (l10n) => 'Color speed',
      type: FractalParamType.float,
      min: 0.0,
      max: 0.2,
      step: 0.001,
      defaultValue: 0.0,
    );
  }

  static FractalParameter colorScheme64({int defaultValue = 0}) {
    // Keep the first 4 as named palettes for continuity.
    final options = <FractalParamOption>[
      FractalParamOption(value: 0, label: (l10n) => l10n.colorFire),
      FractalParamOption(value: 1, label: (l10n) => l10n.colorOcean),
      FractalParamOption(value: 2, label: (l10n) => l10n.colorPsychedelic),
      FractalParamOption(value: 3, label: (l10n) => l10n.colorGrayscale),
      FractalParamOption(value: 4, label: (l10n) => l10n.colorPhoenix),
      for (int i = 5; i < paletteCount; i++)
        FractalParamOption(
          value: i,
          label: (AppLocalizations l10n) => _paletteName(i),
        ),
    ];

    return FractalParameter(
      id: 'colorScheme',
      label: (l10n) => l10n.paramColorScheme,
      type: FractalParamType.enumeration,
      min: 0,
      max: paletteCount - 1,
      step: 1,
      defaultValue: defaultValue,
      options: options,
    );
  }

  static String _paletteName(int index) {
    if (index >= 5 && index < 50) {
      return _proceduralPaletteNames[index - 5];
    }
    if (index >= 50 && index < paletteCount) {
      final angle = (((index - 50) * 180) / 13).round();
      final baseName = _reliefBasePaletteNames[(index - 50) % 4];
      return 'Relief $angle° $baseName';
    }
    return 'Palette ${index + 1}';
  }
}
