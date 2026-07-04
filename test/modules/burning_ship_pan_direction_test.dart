import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

void main() {
  const assets = [
    'shaders/escape_time_family/families/burning_ship/parameter_plane/burning_ship_gpu.frag',
    'shaders/escape_time_family/families/burning_ship/parameter_plane/burning_ship_cubic_gpu.frag',
  ];

  test('upright Burning Ship shaders keep vertical pan direction consistent',
      () {
    for (final asset in assets) {
      final shader = File(asset).readAsStringSync();

      expect(shader, contains('vec2(uv.x, -uv.y)'));
      expect(shader, contains('vec2(uCenter.x, -uCenter.y)'));
      expect(
          shader,
          isNot(
              contains('vec2(uv.x, -uv.y) / max(0.000001, uZoom) + uCenter')));
    }
  });

  test('upright Burning Ship shaders compile after pan fix', () async {
    for (final asset in assets) {
      expect(await ui.FragmentProgram.fromAsset(asset), isNotNull);
    }
  }, timeout: const Timeout(Duration(seconds: 60)));
}
