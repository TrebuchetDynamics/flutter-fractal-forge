import 'dart:typed_data';

import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/features/renderer/backend_policy.dart';
import 'package:flutter_fractals/features/renderer/render_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RendererBackendPolicy', () {
    const policy = RendererBackendPolicy();

    test('prefers GPU on healthy target', () {
      final decision = policy.decide(
        const BackendPolicyInput(
          isAndroid: false,
          isWeb: false,
          isEmulator: false,
          userMode: RendererBackendMode.auto,
          gpuHealthFailed: false,
          deepZoomNeedsCpu: false,
          dimension: FractalDimension.twoD,
        ),
      );

      expect(decision.backend, RendererBackend.gpu);
      expect(decision.reasonCode, FallbackReasonCode.none);
    });

    test('uses GPU on healthy android emulator in auto mode', () {
      final decision = policy.decide(
        const BackendPolicyInput(
          isAndroid: true,
          isWeb: false,
          isEmulator: true,
          userMode: RendererBackendMode.auto,
          gpuHealthFailed: false,
          deepZoomNeedsCpu: false,
          dimension: FractalDimension.twoD,
        ),
      );

      expect(decision.backend, RendererBackend.gpu);
      expect(decision.reasonCode, FallbackReasonCode.none);
    });

    test('falls back to CPU on android emulator when GPU health fails', () {
      final decision = policy.decide(
        const BackendPolicyInput(
          isAndroid: true,
          isWeb: false,
          isEmulator: true,
          userMode: RendererBackendMode.auto,
          gpuHealthFailed: true,
          deepZoomNeedsCpu: false,
          dimension: FractalDimension.twoD,
        ),
      );

      expect(decision.backend, RendererBackend.cpu);
      expect(decision.reasonCode, FallbackReasonCode.gpuHealthCheckFailed);
      expect(decision.reasonToken, 'gpu_health_check_failed');
    });

    test('keeps 3D modules on GPU in auto mode', () {
      final decision = policy.decide(
        const BackendPolicyInput(
          isAndroid: true,
          isWeb: false,
          isEmulator: false,
          userMode: RendererBackendMode.auto,
          gpuHealthFailed: true,
          deepZoomNeedsCpu: false,
          dimension: FractalDimension.threeD,
        ),
      );

      expect(decision.backend, RendererBackend.gpu);
      expect(decision.reasonCode, FallbackReasonCode.none);
    });
  });

  group('Render validation', () {
    test('detects non-black histogram and progression', () {
      final frameA = Uint8List.fromList(List<int>.filled(16 * 4, 0));
      final frameB = Uint8List.fromList(List<int>.filled(16 * 4, 0));

      // center pixel (1,1) for a 4x4 image
      const center = (1 * 4 + 1) * 4;
      frameB[center] = 64;
      frameB[center + 1] = 96;
      frameB[center + 2] = 128;

      // add additional non-black + changed pixels
      for (int i = 0; i < frameB.length; i += 8) {
        frameB[i] = 32;
        frameB[i + 1] = 16;
        frameB[i + 2] = 48;
      }

      final result = validateRenderPair(
        frameA: frameA,
        frameB: frameB,
        width: 4,
        height: 4,
      );

      expect(result.centerNonBlack, isTrue);
      expect(result.histogramSane, isTrue);
      expect(result.frameProgressed, isTrue);
      expect(result.iterationDeltaVisible, isTrue);
    });
  });
}
