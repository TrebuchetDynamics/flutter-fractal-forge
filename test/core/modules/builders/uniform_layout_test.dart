import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_fractals/core/modules/builders/uniform_layout.dart';

void main() {
  group('builder uniform layouts', () {
    test('escape-time slots expose the shader contract without gaps', () {
      expect(EscapeTimeUniformSlots.time, 0);
      expect(EscapeTimeUniformSlots.resolutionX, 1);
      expect(EscapeTimeUniformSlots.resolutionY, 2);
      expect(EscapeTimeUniformSlots.centerX, 3);
      expect(EscapeTimeUniformSlots.centerY, 4);
      expect(EscapeTimeUniformSlots.zoom, 5);
      expect(EscapeTimeUniformSlots.iterations, 6);
      expect(EscapeTimeUniformSlots.bailout, 7);
      expect(EscapeTimeUniformSlots.colorScheme, 8);
      expect(EscapeTimeUniformSlots.transparentBackground, 9);
      expect(EscapeTimeUniformSlots.extraStart, 10);
    });

    test('raymarched 3D slots expose the shader contract without gaps', () {
      expect(Raymarched3DUniformSlots.time, 0);
      expect(Raymarched3DUniformSlots.resolutionX, 1);
      expect(Raymarched3DUniformSlots.resolutionY, 2);
      expect(Raymarched3DUniformSlots.mouseX, 3);
      expect(Raymarched3DUniformSlots.mouseY, 4);
      expect(Raymarched3DUniformSlots.zoom, 5);
      expect(Raymarched3DUniformSlots.rotationX, 6);
      expect(Raymarched3DUniformSlots.rotationY, 7);
      expect(Raymarched3DUniformSlots.rotationZ, 8);
      expect(Raymarched3DUniformSlots.power, 9);
      expect(Raymarched3DUniformSlots.iterations, 10);
      expect(Raymarched3DUniformSlots.steps, 11);
      expect(Raymarched3DUniformSlots.bailout, 12);
      expect(Raymarched3DUniformSlots.colorScheme, 13);
      expect(Raymarched3DUniformSlots.fractalType, 14);
      expect(Raymarched3DUniformSlots.transparentBackground, 15);
    });
  });
}
