import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_fractals/l10n/app_localizations_es.dart';

import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/core/services/rendering/palette/palette_service.dart';
import 'package:flutter_fractals/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PaletteService service;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    service = await PaletteService.create();
  });
  tearDown(() => service.dispose());

  test(
      'every built-in index retains its original persisted ID and render stops',
      () {
    final original = jsonDecode(
        File('test/palette/fixtures/builtin_palette_compatibility.json')
            .readAsStringSync()) as List;
    expect(service.builtInCount, original.length);
    for (final entry in original) {
      final index = entry['index'] as int;
      final palette = service.paletteAtIndex(index);
      expect(palette.id, entry['id'], reason: 'persisted ID at $index');
      expect([
        for (final stop in palette.stops)
          {'position': stop.position, 'argb': stop.colorArgb}
      ], entry['stops'], reason: 'saved-view colours at $index');
    }
  });

  test(
      'all generated names describe actual dominant and end hues, not legacy branding',
      () {
    const pairs = [
      'Violet / Pink',
      'Magenta / Red',
      'Red / Yellow',
      'Orange / Green',
      'Lime / Green',
      'Green / Cyan',
      'Teal / Blue',
      'Blue / Magenta',
      'Violet / Pink',
      'Pink / Orange',
      'Red / Lime',
      'Yellow / Green',
      'Lime / Teal',
      'Green / Blue',
      'Cyan / Violet',
      'Blue / Magenta',
      'Magenta / Red',
      'Pink / Orange',
      'Orange / Lime',
      'Yellow / Green',
      'Green / Cyan',
      'Teal / Blue',
      'Blue / Violet',
      'Violet / Pink',
      'Magenta / Red',
      'Red / Yellow',
      'Orange / Green',
      'Lime / Green',
      'Green / Cyan',
      'Teal / Blue',
      'Blue / Magenta',
      'Violet / Pink',
      'Pink / Orange',
      'Red / Lime',
      'Yellow / Green',
      'Lime / Teal',
      'Green / Blue',
    ];
    for (var i = 13; i < 50; i++) {
      final palette = service.paletteAtIndex(i);
      final baseHue = HSVColor.fromColor(Color(palette.stops[1].colorArgb)).hue;
      final endHue =
          HSVColor.fromColor(Color(palette.stops.last.colorArgb)).hue;
      expect(baseHue, closeTo(i * 47 % 360, 1),
          reason: 'actual dominant hue at $i');
      expect(endHue, closeTo((i * 47 + 70) % 360, 1),
          reason: 'actual end hue at $i');
      expect(service.paletteAtIndex(i).name, '${pairs[i - 13]} (${i + 1})',
          reason: 'hue pair at $i');
    }
    const spanishHues = {
      'Red': 'Rojo',
      'Orange': 'Naranja',
      'Yellow': 'Amarillo',
      'Lime': 'Lima',
      'Green': 'Verde',
      'Teal': 'Verde azulado',
      'Cyan': 'Cian',
      'Blue': 'Azul',
      'Violet': 'Violeta',
      'Magenta': 'Magenta',
      'Pink': 'Rosa'
    };
    final options = CommonFractalParams.colorScheme64().options;
    for (var i = 13; i < 50; i++) {
      final translated = pairs[i - 13]
          .split(' / ')
          .map((hue) => spanishHues[hue]!)
          .join(' / ');
      expect(options[i].label(AppLocalizationsEs()), '$translated (${i + 1})');
    }
    expect(options[8].label(AppLocalizationsEs()), 'Arcoíris');
    expect(
        options[12].label(AppLocalizationsEs()), 'Azul / Naranja / Amarillo');
    expect(service.paletteAtIndex(7).name, 'Cividis');
    expect(service.paletteAtIndex(8).name, 'Rainbow');
    expect(service.paletteAtIndex(12).name, 'Blue / Orange / Yellow');
  });

  test('all 64 parameter labels use service names; custom names stay separate',
      () async {
    final options = CommonFractalParams.colorScheme64().options;
    for (var i = 0; i < 64; i++) {
      expect(options[i].value, i);
      expect(options[i].label(AppLocalizationsEn()),
          service.paletteAtIndex(i).name);
    }
    await service.addPalette(service.createEmptyPalette(name: 'Glacier Mint'));
    expect(service.paletteAtIndex(64).name, 'Glacier Mint');
    expect(options.length, 64);
  });
}
