import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/models/fractal_palette.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FractalPalette', () {
    test('snapshots mutable stop lists supplied by callers', () {
      final stops = <FractalColorStop>[
        const FractalColorStop(position: 0.0, colorArgb: 0xFF000000),
        const FractalColorStop(position: 1.0, colorArgb: 0xFFFFFFFF),
      ];

      final palette = FractalPalette(
        id: 'mutable',
        name: 'Mutable',
        stops: stops,
      );

      stops[0] = const FractalColorStop(
        position: 0.5,
        colorArgb: 0xFFFF0000,
      );
      stops.add(
        const FractalColorStop(position: 0.75, colorArgb: 0xFF00FF00),
      );

      expect(palette.stops, hasLength(2));
      expect(palette.stops.first.position, 0.0);
      expect(palette.stops.first.colorArgb, 0xFF000000);
      expect(palette.stops.last.position, 1.0);
      expect(palette.stops.last.colorArgb, 0xFFFFFFFF);
    });

    test('exposes stops as an immutable snapshot', () {
      final palette = FractalPalette(
        id: 'immutable',
        name: 'Immutable',
        stops: const [
          FractalColorStop(position: 0.0, colorArgb: 0xFF000000),
          FractalColorStop(position: 1.0, colorArgb: 0xFFFFFFFF),
        ],
      );

      expect(
        () => palette.stops.add(
          const FractalColorStop(position: 0.5, colorArgb: 0xFFFF0000),
        ),
        throwsUnsupportedError,
      );
    });

    test('copyWith snapshots replacement stop lists', () {
      final original = FractalPalette(
        id: 'original',
        name: 'Original',
        stops: [
          FractalColorStop(position: 0.0, colorArgb: 0xFF000000),
          FractalColorStop(position: 1.0, colorArgb: 0xFFFFFFFF),
        ],
      );
      final replacementStops = <FractalColorStop>[
        const FractalColorStop(position: 0.25, colorArgb: 0xFF123456),
      ];

      final copy = original.copyWith(stops: replacementStops);
      replacementStops.add(
        const FractalColorStop(position: 0.75, colorArgb: 0xFF654321),
      );

      expect(copy.stops, hasLength(1));
      expect(copy.stops.single.position, 0.25);
      expect(copy.stops.single.colorArgb, 0xFF123456);
    });

    test('toLinearGradient normalizes malformed imported stops before display',
        () {
      final palette = FractalPalette(
        id: 'malformed',
        name: 'Malformed',
        stops: const [
          FractalColorStop(position: double.nan, colorArgb: 0xFF112233),
        ],
      );

      final gradient = palette.toLinearGradient();

      expect(gradient.colors, const [Color(0xFF000000), Color(0xFFFFFFFF)]);
      expect(gradient.stops, const [0.0, 1.0]);
    });
  });
}
