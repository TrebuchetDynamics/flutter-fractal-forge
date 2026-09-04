import 'dart:ui' as ui;

import 'package:flutter_fractals/core/models/fractal_palette.dart';
import 'package:flutter_fractals/core/services/rendering/palette/palette_texture_cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final palettesWithNarrowHighlight = [
    FractalPalette(
      id: 'highlight',
      name: 'Highlight',
      stops: const [
        FractalColorStop(position: 0, colorArgb: 0xFF000000),
        FractalColorStop(position: 0.22, colorArgb: 0xFF000000),
        FractalColorStop(position: 0.25, colorArgb: 0xFFFFFFFF),
        FractalColorStop(position: 0.28, colorArgb: 0xFF000000),
        FractalColorStop(position: 1, colorArgb: 0xFF000000),
      ],
    ),
    FractalPalette(
      id: 'black',
      name: 'Black',
      stops: const [
        FractalColorStop(position: 0, colorArgb: 0xFF000000),
        FractalColorStop(position: 1, colorArgb: 0xFF000000),
      ],
    ),
  ];

  test('blending preserves narrow highlights at every texture pixel', () async {
    final cache = PaletteTextureCache();
    addTearDown(cache.clear);
    final source = cache.paletteTexture(palettesWithNarrowHighlight.first);
    final sourceBytes =
        (await source.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    for (final mix in [0.25, 0.5, 0.75]) {
      final blend = cache.paletteTextureForIndex(
        mix,
        (i) => palettesWithNarrowHighlight[i],
      );
      final bytes =
          (await blend.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      for (var x = 0; x < source.width; x++) {
        for (var channel = 0; channel < 3; channel++) {
          final offset = x * 4 + channel;
          expect(bytes.getUint8(offset),
              closeTo(sourceBytes.getUint8(offset) * (1 - mix), 1),
              reason: 'mix=$mix, pixel=$x, channel=$channel');
        }
        expect(bytes.getUint8(x * 4 + 3), 255);
      }
    }
  });

  test('rounded transition endpoint reuses the destination texture', () {
    final cache = PaletteTextureCache();
    addTearDown(cache.clear);
    for (final count in [2, 64]) {
      final destination = cache.paletteTexture(
        palettesWithNarrowHighlight[1],
        colorCount: count,
      );
      final endpoint = cache.paletteTextureForIndex(
        0.999,
        (i) => palettesWithNarrowHighlight[i],
        colorCount: count,
      );
      expect(identical(endpoint, destination), isTrue);
    }
  });

  test('caches blended palette textures by quantized fractional index', () {
    final cache = PaletteTextureCache();
    addTearDown(cache.clear);
    final palettes = [
      FractalPalette(
        id: 'a',
        name: 'A',
        stops: const [
          FractalColorStop(position: 0, colorArgb: 0xFF000000),
          FractalColorStop(position: 1, colorArgb: 0xFFFFFFFF),
        ],
      ),
      FractalPalette(
        id: 'b',
        name: 'B',
        stops: const [
          FractalColorStop(position: 0, colorArgb: 0xFFFF0000),
          FractalColorStop(position: 1, colorArgb: 0xFF0000FF),
        ],
      ),
    ];

    final first = cache.paletteTextureForIndex(0, (i) => palettes[i]);
    final twoColor = cache.paletteTextureForIndex(
      0,
      (i) => palettes[i],
      colorCount: 2,
    );
    final blend = cache.paletteTextureForIndex(0.5, (i) => palettes[i]);
    final sameBlendBucket =
        cache.paletteTextureForIndex(0.501, (i) => palettes[i]);

    expect(first.width, PaletteTextureCache.textureWidth);
    expect(blend.height, 1);
    expect(identical(first, twoColor), isFalse);
    expect(identical(first, blend), isFalse);
    expect(identical(blend, sameBlendBucket), isTrue);
  });
}
