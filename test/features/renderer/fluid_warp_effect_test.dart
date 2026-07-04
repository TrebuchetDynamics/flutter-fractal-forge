import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fluid warp shader is a reusable ImageFilter shader', () {
    final shader = File('shaders/runtime/fluid_warp.frag').readAsStringSync();

    expect(shader, contains('uniform vec2 uSize;'));
    expect(shader, contains('uniform sampler2D uTexture;'));
    expect(shader, contains('texture(uTexture'));
    expect(shader, contains('stateless curl-noise warp'));
  });
}
