import 'dart:typed_data';

import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/features/renderer/backend_policy.dart';
import 'package:flutter_fractals/features/viewer/diagnostics/gpu_health_probe.dart';
import 'package:flutter_test/flutter_test.dart';

// RGBA frame helpers — blackThreshold=8, so R>8 || G>8 || B>8 = non-black.

Uint8List _makeFrame(int width, int height, {int r = 0, int g = 0, int b = 0}) {
  final bytes = Uint8List(width * height * 4);
  for (var i = 0; i < bytes.length; i += 4) {
    bytes[i] = r;
    bytes[i + 1] = g;
    bytes[i + 2] = b;
    bytes[i + 3] = 255;
  }
  return bytes;
}

// 4x4 all-black → centerNonBlack=false, histogramSane=false
final Uint8List _blackFrame = _makeFrame(4, 4);

// 4x4 colorful → centerNonBlack=true, histogramSane=true
final Uint8List _healthyFrame = _makeFrame(4, 4, r: 128, g: 100, b: 150);

void main() {
  group('GpuHealthProbe.evaluateFrame', () {
    test('healthy frame keeps streak at 0 and healthFailed=false', () {
      final probe = GpuHealthProbe();
      probe.beginProbe();
      final result = probe.evaluateFrame(
        frameData: _healthyFrame,
        width: 4,
        height: 4,
      );
      probe.endProbe();

      expect(result.probeFailed, isFalse);
      expect(result.failureStreak, 0);
      expect(result.healthFailed, isFalse);
      expect(probe.gpuHealthFailed, isFalse);
      expect(probe.lastGpuNonBlackRatio, 1.0);
      expect(probe.lastGpuCenterNonBlack, isTrue);
      expect(probe.lastGpuHistogramSane, isTrue);
      expect(probe.lastGpuSampleCount, 16);
    });

    test('single black frame: streak=1, healthFailed=false (needs 2)', () {
      final probe = GpuHealthProbe();
      probe.beginProbe();
      final result = probe.evaluateFrame(
        frameData: _blackFrame,
        width: 4,
        height: 4,
      );
      probe.endProbe();

      expect(result.probeFailed, isTrue);
      expect(result.failureStreak, 1);
      expect(result.healthFailed, isFalse);
      expect(probe.gpuHealthFailed, isFalse);
    });

    test('two consecutive black frames: streak=2, healthFailed=true', () {
      final probe = GpuHealthProbe();

      probe.beginProbe();
      probe.evaluateFrame(frameData: _blackFrame, width: 4, height: 4);
      probe.endProbe();

      probe.beginProbe();
      final result =
          probe.evaluateFrame(frameData: _blackFrame, width: 4, height: 4);
      probe.endProbe();

      expect(result.failureStreak, 2);
      expect(result.healthFailed, isTrue);
      expect(probe.gpuHealthFailed, isTrue);
    });

    test('healthy frame after two failures resets streak to 0', () {
      final probe = GpuHealthProbe();

      probe.beginProbe();
      probe.evaluateFrame(frameData: _blackFrame, width: 4, height: 4);
      probe.endProbe();
      probe.beginProbe();
      probe.evaluateFrame(frameData: _blackFrame, width: 4, height: 4);
      probe.endProbe();

      // Probe is now failed. A healthy frame recovers it.
      probe.beginProbe();
      final result =
          probe.evaluateFrame(frameData: _healthyFrame, width: 4, height: 4);
      probe.endProbe();

      expect(result.probeFailed, isFalse);
      expect(result.failureStreak, 0);
      expect(result.healthFailed, isFalse);
      expect(probe.gpuHealthFailed, isFalse);
    });

    test('forceProbeFailure=true: single frame triggers healthFailed', () {
      final probe = GpuHealthProbe(forceProbeFailure: true);
      probe.beginProbe();
      final result = probe.evaluateFrame(
        frameData: _healthyFrame, // healthy pixels, but forced to fail
        width: 4,
        height: 4,
      );
      probe.endProbe();

      expect(result.probeFailed, isTrue);
      expect(result.failureStreak, 1);
      expect(result.healthFailed, isTrue); // required=1 in forced mode
      expect(probe.gpuHealthFailed, isTrue);
    });
  });

  group('GpuHealthProbe.resetHealth', () {
    test('clears gpuHealthFailed and failureStreak', () {
      final probe = GpuHealthProbe();

      // Drive to failed state.
      probe.beginProbe();
      probe.evaluateFrame(frameData: _blackFrame, width: 4, height: 4);
      probe.endProbe();
      probe.beginProbe();
      probe.evaluateFrame(frameData: _blackFrame, width: 4, height: 4);
      probe.endProbe();

      expect(probe.gpuHealthFailed, isTrue);

      probe.resetHealth();

      expect(probe.gpuHealthFailed, isFalse);

      // Confirm next single failure no longer trips healthFailed (streak reset).
      probe.beginProbe();
      final result =
          probe.evaluateFrame(frameData: _blackFrame, width: 4, height: 4);
      probe.endProbe();

      expect(result.failureStreak, 1);
      expect(result.healthFailed, isFalse);
    });
  });

  group('GpuHealthProbe.recordProbeError', () {
    test('stores the error in lastGpuHealthError', () {
      final probe = GpuHealthProbe();
      expect(probe.lastGpuHealthError, isNull);

      final err = Exception('simulated capture timeout');
      probe.recordProbeError(err);

      expect(probe.lastGpuHealthError, err);
    });
  });

  group('GpuHealthProbe.beginProbe / endProbe', () {
    test('beginProbe resets gpuProbeBackendSwitches counter', () {
      final probe = GpuHealthProbe();

      // First probe cycle.
      probe.beginProbe();
      expect(probe.gpuProbeBackendSwitches, 0);
      probe.endProbe();

      // Second probe cycle resets even if first left a count > 0 somehow.
      probe.beginProbe();
      expect(probe.gpuProbeBackendSwitches, 0);
      probe.endProbe();
    });
  });

  group('GpuHealthProbe.decide', () {
    late FractalController controller;

    setUp(() {
      controller = FractalController(ModuleRegistry());
    });

    tearDown(() {
      controller.dispose();
    });

    test('no backend change returns GpuBackendUpdate.none', () {
      final probe = GpuHealthProbe();

      final update = probe.decide(
        mode: RendererBackendMode.auto,
        moduleId: controller.module.id,
        isAndroid: false,
        isWeb: false,
        controller: controller,
      );

      expect(update.captureSnapshot, isFalse);
      expect(probe.backendDecision.backend, RendererBackend.gpu);
    });

    test('GPU→CPU transition after health failure: captureSnapshot=true', () {
      final probe = GpuHealthProbe();

      // Force health failure.
      probe.beginProbe();
      probe.evaluateFrame(frameData: _blackFrame, width: 4, height: 4);
      probe.endProbe();
      probe.beginProbe();
      probe.evaluateFrame(frameData: _blackFrame, width: 4, height: 4);
      probe.endProbe();

      expect(probe.gpuHealthFailed, isTrue);

      final update = probe.decide(
        mode: RendererBackendMode.auto,
        moduleId: controller.module.id,
        isAndroid: false,
        isWeb: false,
        controller: controller,
      );

      expect(update.captureSnapshot, isTrue);
      expect(
          probe.backendDecision.backend, RendererBackend.cpu);
      expect(probe.backendDecision.reasonCode,
          FallbackReasonCode.gpuHealthCheckFailed);
    });

    test('resetHealth after failure allows GPU on next decide', () {
      final probe = GpuHealthProbe();

      // Drive to failed state and commit the CPU switch.
      probe.beginProbe();
      probe.evaluateFrame(frameData: _blackFrame, width: 4, height: 4);
      probe.endProbe();
      probe.beginProbe();
      probe.evaluateFrame(frameData: _blackFrame, width: 4, height: 4);
      probe.endProbe();
      probe.decide(
        mode: RendererBackendMode.auto,
        moduleId: controller.module.id,
        isAndroid: false,
        isWeb: false,
        controller: controller,
      );
      expect(probe.backendDecision.backend, RendererBackend.cpu);

      // User resets health and switches to a new module (bypasses hysteresis).
      probe.resetHealth();
      const newModuleId = 'julia';

      final update = probe.decide(
        mode: RendererBackendMode.auto,
        moduleId: newModuleId,
        isAndroid: false,
        isWeb: false,
        controller: controller,
      );

      expect(update.captureSnapshot, isFalse);
      expect(probe.backendDecision.backend, RendererBackend.gpu);
    });
  });
}
