import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fluid warp shader is a reusable ImageFilter shader', () {
    final shader = File('shaders/runtime/fluid_warp.frag').readAsStringSync();

    expect(shader, contains('uniform vec2 uSize;'));
    expect(shader, contains('uniform sampler2D uTexture;'));
    expect(shader, contains('uniform float uTouchEnergy;'));
    expect(shader, contains('uniform float uTouchVelocityX;'));
    expect(shader, contains('uniform float uTouchVelocityY;'));
    expect(shader, contains('uniform float uSecondaryTouchX;'));
    expect(shader, contains('uniform float uSecondaryTouchY;'));
    expect(shader, contains('texture(uTexture'));
    expect(shader, contains('velocity-aware splat'));
    expect(shader, contains('liquid glass'));
    expect(shader, contains('feedback-like echo'));
    expect(shader, contains('another live layer/source'));
    expect(shader, contains('Fraksl-style filter treatment'));
    expect(shader, contains('float filterAmount'));
  });
}
