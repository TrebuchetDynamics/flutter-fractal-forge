import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';
import 'package:flutter_fractals/core/services/rendering/shader_service.dart';
import 'package:flutter_fractals/core/models/fractal_params.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('ShaderService', () {
    late ShaderService service;

    setUp(() {
      service = ShaderService();
    });

    test('starts uninitialized', () {
      expect(service.initialized, isFalse);
    });

    test('initialize sets initialized to true', () async {
      await service.initialize(null);
      expect(service.initialized, isTrue);
    });

    test('dispose sets initialized to false', () async {
      await service.initialize(null);
      service.dispose();
      expect(service.initialized, isFalse);
    });

    test('initialize then dispose cycle leaves service uninitialized', () async {
      await service.initialize(null);
      expect(service.initialized, isTrue);
      service.dispose();
      expect(service.initialized, isFalse);
    });

    test('useProgram does not throw', () async {
      await service.initialize(null);
      expect(() => service.useProgram(), returnsNormally);
    });

    test('setUniforms does not throw', () async {
      await service.initialize(null);
      final params = FractalParams(
        rotation: Vector3(0.0, 0.0, 0.0),
        mousePos: Vector2(0.0, 0.0),
      );
      const size = Size(100, 100);
      const time = 0.0;
      expect(() => service.setUniforms(params, size, time), returnsNormally);
    });
  });
}
