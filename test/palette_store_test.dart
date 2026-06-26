import 'dart:convert';

import 'package:flutter_fractals/core/models/fractal_palette.dart';
import 'package:flutter_fractals/core/services/storage/palette_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  group('PaletteStore', () {
    test('loadPalettes returns empty list when no data', () async {
      final store = await PaletteStore.create();
      final palettes = store.loadPalettes();
      expect(palettes, isEmpty);
    });

    test('savePalettes and loadPalettes round-trip', () async {
      final store = await PaletteStore.create();

      final palettes = [
        FractalPalette(
          id: 'pal-1',
          name: 'Fire',
          stops: [
            FractalColorStop(position: 0.0, colorArgb: 0xFFFF0000),
            FractalColorStop(position: 1.0, colorArgb: 0xFFFFFF00),
          ],
        ),
        FractalPalette(
          id: 'pal-2',
          name: 'Ocean',
          stops: [
            FractalColorStop(position: 0.0, colorArgb: 0xFF0000FF),
            FractalColorStop(position: 1.0, colorArgb: 0xFF00FFFF),
          ],
        ),
      ];

      await store.savePalettes(palettes);
      final loaded = store.loadPalettes();

      expect(loaded.length, 2);
      expect(loaded[0].id, 'pal-1');
      expect(loaded[0].name, 'Fire');
      expect(loaded[0].stops.length, 2);
      expect(loaded[0].stops[0].colorArgb, 0xFFFF0000);
      expect(loaded[0].stops[1].colorArgb, 0xFFFFFF00);

      expect(loaded[1].id, 'pal-2');
      expect(loaded[1].name, 'Ocean');
      expect(loaded[1].stops[0].colorArgb, 0xFF0000FF);
    });

    test('savePalettes and loadPalettes preserves stop positions', () async {
      final store = await PaletteStore.create();

      final palette = FractalPalette(
        id: 'gradient',
        name: 'Gradient',
        stops: [
          FractalColorStop(position: 0.0, colorArgb: 0xFFFFFFFF),
          FractalColorStop(position: 0.5, colorArgb: 0xFF888888),
          FractalColorStop(position: 1.0, colorArgb: 0xFF000000),
        ],
      );

      await store.savePalettes([palette]);
      final loaded = store.loadPalettes();

      expect(loaded.length, 1);
      expect(loaded[0].stops[1].position, closeTo(0.5, 1e-9));
    });

    test('loadPalettes skips corrupted string-list entries', () async {
      final goodEntry = FractalPalette(
        id: 'ok',
        name: 'Good',
        stops: [FractalColorStop(position: 0.0, colorArgb: 0xFFFFFFFF)],
      ).toJsonString(pretty: false);

      SharedPreferences.setMockInitialValues({
        'user_palettes_v1': <String>['not valid json {{{{', goodEntry],
      });

      final store = await PaletteStore.create();
      final palettes = store.loadPalettes();

      expect(palettes, hasLength(1));
      expect(palettes.single.id, 'ok');
    });

    test('loadPalettes loads legacy JSON array payloads', () async {
      SharedPreferences.setMockInitialValues({
        'user_palettes_v1': jsonEncode([
          FractalPalette(
            id: 'legacy',
            name: 'Legacy',
            stops: [FractalColorStop(position: 0.0, colorArgb: 0xFFFFFFFF)],
          ).toJson(),
        ]),
      });

      final store = await PaletteStore.create();
      final palettes = store.loadPalettes();

      expect(palettes, hasLength(1));
      expect(palettes.single.id, 'legacy');
      expect(palettes.single.name, 'Legacy');
    });

    test('loadPalettes skips palettes with empty id', () async {
      // Use the List<String> primary path: two serialised palette JSON strings,
      // one with an empty id (should be filtered) and one with a valid id.
      final badEntry = FractalPalette(
        id: '',
        name: 'Bad',
        stops: [],
      ).toJsonString(pretty: false);
      final goodEntry = FractalPalette(
        id: 'ok',
        name: 'Good',
        stops: [],
      ).toJsonString(pretty: false);

      SharedPreferences.setMockInitialValues({
        'user_palettes_v1': <String>[badEntry, goodEntry],
      });

      final store = await PaletteStore.create();
      final palettes = store.loadPalettes();
      expect(palettes.length, 1);
      expect(palettes.first.id, 'ok');
    });

    test('savePalettes overwrites previous save', () async {
      final store = await PaletteStore.create();

      final first = [
        FractalPalette(
          id: 'first',
          name: 'First',
          stops: [FractalColorStop(position: 0.0, colorArgb: 0xFFFF0000)],
        ),
      ];
      final second = [
        FractalPalette(
          id: 'second',
          name: 'Second',
          stops: [FractalColorStop(position: 0.0, colorArgb: 0xFF00FF00)],
        ),
      ];

      await store.savePalettes(first);
      await store.savePalettes(second);
      final loaded = store.loadPalettes();

      expect(loaded.length, 1);
      expect(loaded.first.id, 'second');
    });

    test('savePalettes with empty list clears palettes', () async {
      final store = await PaletteStore.create();

      final palettes = [
        FractalPalette(
          id: 'p1',
          name: 'P1',
          stops: [FractalColorStop(position: 0.0, colorArgb: 0xFFFFFFFF)],
        ),
      ];
      await store.savePalettes(palettes);
      await store.savePalettes([]);
      final loaded = store.loadPalettes();

      expect(loaded, isEmpty);
    });
  });
}
