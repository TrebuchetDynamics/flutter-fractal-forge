import 'dart:ui' as ui;

import 'package:flutter_fractals/core/models/fractal_palette.dart';
import 'package:flutter_fractals/core/services/rendering/palette/palette_texture_cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('long palette exploration retains at most 256 textures', () {
    final cache = PaletteTextureCache();
    addTearDown(cache.clear);
    final images = <ui.Image>[];
    for (var i = 0; i < 1024; i++) {
      images.add(cache.paletteTexture(FractalPalette(
        id: 'stress-$i',
        name: 'Stress',
        stops: const [
          FractalColorStop(position: 0, colorArgb: 0xFF000000),
          FractalColorStop(position: 1, colorArgb: 0xFFFFFFFF),
        ],
      )));
    }
    expect(images.where((image) => !image.debugDisposed), hasLength(256));
    cache.clear();
    expect(images.every((image) => image.debugDisposed), isTrue);
    cache.clear();
  });

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

  test('eviction respects recent use and preserves bound shader pixels',
      () async {
    final cache = PaletteTextureCache();
    addTearDown(cache.clear);
    final sourcePalette = palettesWithNarrowHighlight.first;
    final source = cache.paletteTexture(sourcePalette);
    final sourceBytes = (await source.toByteData())!.buffer.asUint8List();
    final program = await ui.FragmentProgram.fromAsset(
      'shaders/diagnostic/diag_sampler.frag',
    );
    final shader = program.fragmentShader()
      ..setFloat(0, 16)
      ..setFloat(1, 16)
      ..setImageSampler(0, source);
    addTearDown(shader.dispose);

    Future<List<int>> render() async {
      final recorder = ui.PictureRecorder();
      ui.Canvas(recorder).drawRect(
        const ui.Rect.fromLTWH(0, 0, 16, 16),
        ui.Paint()..shader = shader,
      );
      final picture = recorder.endRecording();
      try {
        final image = await picture.toImage(16, 16);
        try {
          return (await image.toByteData())!.buffer.asUint8List();
        } finally {
          image.dispose();
        }
      } finally {
        picture.dispose();
      }
    }

    final before = await render();
    final blends = <ui.Image>[];
    for (var i = 1; i < 256; i++) {
      blends.add(cache.paletteTextureForIndex(
        i / 256,
        (i) => palettesWithNarrowHighlight[i],
      ));
    }
    expect(source.debugDisposed, isFalse);
    // Touch the oldest base entry; the oldest blend must now be evicted.
    expect(cache.paletteTexture(sourcePalette), same(source));
    cache.paletteTexture(palettesWithNarrowHighlight.last);
    expect(blends.first.debugDisposed, isTrue);
    expect(source.debugDisposed, isFalse);
    // Refresh a blend too, then fill enough entries to evict the bound source.
    final recent = cache.paletteTextureForIndex(
      2 / 256,
      (i) => palettesWithNarrowHighlight[i],
    );
    expect(recent, same(blends[1]));
    for (var i = 1; i < 256; i++) {
      cache.paletteTextureForIndex(
        i / 256,
        (i) => palettesWithNarrowHighlight[i],
        colorCount: 2,
      );
    }
    expect(source.debugDisposed, isTrue);
    expect(recent.debugDisposed, isFalse);
    expect(await render(), orderedEquals(before));
    final recreated = cache.paletteTexture(sourcePalette);
    expect(recreated, isNot(same(source)));
    expect((await recreated.toByteData())!.buffer.asUint8List(),
        orderedEquals(sourceBytes));
    cache.clear();
    expect(recreated.debugDisposed, isTrue);
    expect(await render(), orderedEquals(before));
  });

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
