import 'package:flutter_fractals/l10n/app_localizations.dart';

/// Display labels only. Legacy names remain the source of persisted built-in IDs.
/// Never change a palette's colours to fit a label.
class BuiltInPaletteNames {
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

  static String legacyName(int index) {
    if (index >= 5 && index < 50) return _proceduralPaletteNames[index - 5];
    final angle = (((index - 50) * 180) / 13).round();
    return 'Relief $angle° ${_reliefBasePaletteNames[(index - 50) % 4]}';
  }

  static String name(int index, {AppLocalizations? l10n}) {
    if (index < 5) {
      return switch (index) {
        0 => l10n?.colorFire ?? 'Fire',
        1 => l10n?.colorOcean ?? 'Ocean',
        2 => l10n?.colorPsychedelic ?? 'Psychedelic',
        3 => l10n?.colorGrayscale ?? 'Grayscale',
        _ => l10n?.colorPhoenix ?? 'Phoenix',
      };
    }
    // These historical labels implied accessibility/perceptual certification
    // that the app does not establish. Keep the IDs, not the unsupported claim.
    if (index == 7) return 'Cividis';
    if (index == 8) return l10n?.paletteRainbow ?? 'Rainbow';
    if (index == 12) {
      return '${_hueName(220, l10n)} / ${_hueName(30, l10n)} / ${_hueName(60, l10n)}';
    }
    if (index >= 13 && index < 50) {
      // The generated HSV ramp uses index*47 at stop .28 and hue+70 at
      // stop 1. Its old evocative names were unrelated to these actual hues.
      // Include the stable number since nearby ramps can share hue families.
      final hue = index * 47 % 360;
      return '${_hueName(hue, l10n)} / ${_hueName((hue + 70) % 360, l10n)} (${index + 1})';
    }
    return legacyName(index);
  }

  static String _hueName(int hue, AppLocalizations? l10n) => switch (hue) {
        < 15 => l10n?.paletteHueRed ?? 'Red',
        < 45 => l10n?.paletteHueOrange ?? 'Orange',
        < 70 => l10n?.paletteHueYellow ?? 'Yellow',
        < 100 => l10n?.paletteHueLime ?? 'Lime',
        < 155 => l10n?.paletteHueGreen ?? 'Green',
        < 175 => l10n?.paletteHueTeal ?? 'Teal',
        < 200 => l10n?.paletteHueCyan ?? 'Cyan',
        < 250 => l10n?.paletteHueBlue ?? 'Blue',
        < 280 => l10n?.paletteHueViolet ?? 'Violet',
        < 310 => l10n?.paletteHueMagenta ?? 'Magenta',
        < 340 => l10n?.paletteHuePink ?? 'Pink',
        _ => l10n?.paletteHueRed ?? 'Red',
      };
}
