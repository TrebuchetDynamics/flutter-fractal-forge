import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/features/renderer/widgets/effects/fluid_warp_effect.dart';

void main() {
  testWidgets('disabled fluid effect preserves its child', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: FluidWarpEffect(
          enabled: false,
          time: 0,
          touchPosition: Offset.zero,
          touchActive: false,
          child: ColoredBox(
            key: Key('fluid-child'),
            color: Colors.black,
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('fluid-child')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fluid effect accepts velocity and two touch sources',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox(
          width: 240,
          height: 240,
          child: FluidWarpEffect(
            enabled: true,
            strength: 1.5,
            time: 100,
            touchPosition: Offset(60, 120),
            touchVelocity: Offset(12, -4),
            secondaryTouchPosition: Offset(180, 120),
            secondaryTouchActive: true,
            touchActive: true,
            child: ColoredBox(color: Colors.black),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

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
