import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/services/renderer_settings_service.dart';
import 'package:flutter_fractals/features/renderer/backend_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const policy = RendererBackendPolicy();

  // Helper to build a standard 2D auto input with overrides.
  BackendPolicyInput buildInput({
    bool isAndroid = false,
    bool isWeb = false,
    bool isEmulator = false,
    RendererBackendMode userMode = RendererBackendMode.auto,
    bool gpuHealthFailed = false,
    bool deepZoomNeedsCpu = false,
    FractalDimension dimension = FractalDimension.twoD,
  }) {
    return BackendPolicyInput(
      isAndroid: isAndroid,
      isWeb: isWeb,
      isEmulator: isEmulator,
      userMode: userMode,
      gpuHealthFailed: gpuHealthFailed,
      deepZoomNeedsCpu: deepZoomNeedsCpu,
      dimension: dimension,
    );
  }

  group('cpuOnly user mode', () {
    test('cpuOnly always returns cpu backend for 2D', () {
      final decision =
          policy.decide(buildInput(userMode: RendererBackendMode.cpuOnly));
      expect(decision.backend, RendererBackend.cpu);
      expect(decision.reasonCode, FallbackReasonCode.manualToggle);
    });

    test('cpuOnly on non-emulator non-android still returns cpu', () {
      final decision = policy.decide(buildInput(
        isAndroid: false,
        isEmulator: false,
        userMode: RendererBackendMode.cpuOnly,
      ));
      expect(decision.backend, RendererBackend.cpu);
    });

    test('cpuOnly with gpuHealthFailed still returns cpu via manualToggle', () {
      // cpuOnly is evaluated before health-check; reason should be manualToggle
      final decision = policy.decide(buildInput(
        userMode: RendererBackendMode.cpuOnly,
        gpuHealthFailed: true,
      ));
      expect(decision.backend, RendererBackend.cpu);
      expect(decision.reasonCode, FallbackReasonCode.manualToggle);
    });

    test('cpuOnly is ignored for 3D module — GPU required', () {
      final decision = policy.decide(buildInput(
        userMode: RendererBackendMode.cpuOnly,
        dimension: FractalDimension.threeD,
      ));
      // 3D always uses GPU; cpuOnly is overridden
      expect(decision.backend, RendererBackend.gpu);
      expect(decision.reasonCode, FallbackReasonCode.moduleUnsupported);
    });
  });

  group('gpuOnly user mode', () {
    test('gpuOnly always returns gpu backend for 2D', () {
      final decision =
          policy.decide(buildInput(userMode: RendererBackendMode.gpuOnly));
      expect(decision.backend, RendererBackend.gpu);
      expect(decision.reasonCode, FallbackReasonCode.manualToggle);
    });

    test('gpuOnly bypasses deep-zoom CPU fallback', () {
      // gpuOnly is evaluated before deepZoomNeedsCpu check
      final decision = policy.decide(buildInput(
        userMode: RendererBackendMode.gpuOnly,
        deepZoomNeedsCpu: true,
      ));
      expect(decision.backend, RendererBackend.gpu);
      expect(decision.reasonCode, FallbackReasonCode.manualToggle);
    });

    test('gpuOnly bypasses GPU health check', () {
      final decision = policy.decide(buildInput(
        userMode: RendererBackendMode.gpuOnly,
        gpuHealthFailed: true,
      ));
      expect(decision.backend, RendererBackend.gpu);
      expect(decision.reasonCode, FallbackReasonCode.manualToggle);
    });
  });

  group('deep zoom CPU fallback', () {
    test('deepZoomNeedsCpu triggers cpu backend in auto mode', () {
      final decision = policy.decide(buildInput(deepZoomNeedsCpu: true));
      expect(decision.backend, RendererBackend.cpu);
      expect(decision.reasonCode, FallbackReasonCode.deepZoomPrecision);
    });

    test('deepZoomNeedsCpu reasonToken is deep_zoom_precision', () {
      final decision = policy.decide(buildInput(deepZoomNeedsCpu: true));
      expect(decision.reasonToken, 'deep_zoom_precision');
    });

    test('deepZoomNeedsCpu is evaluated after gpuHealthFailed', () {
      // gpuHealthFailed is checked first in the policy
      final decision = policy.decide(buildInput(
        gpuHealthFailed: true,
        deepZoomNeedsCpu: true,
      ));
      expect(decision.backend, RendererBackend.cpu);
      expect(decision.reasonCode, FallbackReasonCode.gpuHealthCheckFailed);
    });
  });

  group('GPU health failure', () {
    test('GPU health failure in auto mode returns cpu', () {
      final decision = policy.decide(buildInput(gpuHealthFailed: true));
      expect(decision.backend, RendererBackend.cpu);
      expect(decision.reasonCode, FallbackReasonCode.gpuHealthCheckFailed);
    });

    test('combined emulator + GPU health fail returns cpu', () {
      final decision = policy.decide(buildInput(
        isAndroid: true,
        isEmulator: true,
        gpuHealthFailed: true,
      ));
      expect(decision.backend, RendererBackend.cpu);
      expect(decision.reasonCode, FallbackReasonCode.gpuHealthCheckFailed);
    });

    test('isFallback is true when backend is cpu', () {
      final decision = policy.decide(buildInput(gpuHealthFailed: true));
      expect(decision.isFallback, isTrue);
    });
  });

  group('healthy GPU with auto mode', () {
    test('healthy GPU with auto mode returns gpu', () {
      final decision = policy.decide(buildInput());
      expect(decision.backend, RendererBackend.gpu);
      expect(decision.reasonCode, FallbackReasonCode.none);
    });

    test('isFallback is false for gpu decision', () {
      final decision = policy.decide(buildInput());
      expect(decision.isFallback, isFalse);
    });

    test('reasonToken is none for healthy GPU', () {
      final decision = policy.decide(buildInput());
      expect(decision.reasonToken, 'none');
    });

    test('toUserStatusText returns GPU label on healthy path', () {
      final decision = policy.decide(buildInput());
      expect(decision.toUserStatusText(), 'Renderer: GPU');
    });
  });

  group('3D module (unsupported GPU override)', () {
    test('3D module with auto mode uses GPU', () {
      final decision =
          policy.decide(buildInput(dimension: FractalDimension.threeD));
      expect(decision.backend, RendererBackend.gpu);
    });

    test('cpuOnly is ignored for 3D — moduleUnsupported reason', () {
      final decision = policy.decide(buildInput(
        userMode: RendererBackendMode.cpuOnly,
        dimension: FractalDimension.threeD,
      ));
      expect(decision.backend, RendererBackend.gpu);
      expect(decision.reasonCode, FallbackReasonCode.moduleUnsupported);
      expect(decision.reasonToken, 'module_unsupported');
    });

    test('3D module toUserStatusText returns GPU label (backend is gpu)', () {
      final decision = policy.decide(buildInput(
        userMode: RendererBackendMode.cpuOnly,
        dimension: FractalDimension.threeD,
      ));
      // backend == gpu so isFallback is false; toUserStatusText returns 'Renderer: GPU'
      // regardless of reasonCode because the !isFallback check fires first.
      expect(decision.backend, RendererBackend.gpu);
      expect(decision.isFallback, isFalse);
      expect(decision.toUserStatusText(), 'Renderer: GPU');
    });
  });

  group('AndroidEmulatorSignals', () {
    test('classifies each emulator marker without IO', () {
      const samples = [
        AndroidEmulatorSignals(cpuInfo: 'Hardware\t: ranchu'),
        AndroidEmulatorSignals(
            cpuInfo: 'Processor\t: Android Virtual Processor'),
        AndroidEmulatorSignals(cpuInfo: 'vendor_id\t: QEMU'),
        AndroidEmulatorSignals(hardware: ' goldfish\n'),
        AndroidEmulatorSignals(buildCharacteristics: 'nosdcard,emulator'),
        AndroidEmulatorSignals(productModel: 'sdk_gphone64_x86_64'),
        AndroidEmulatorSignals(buildProp: 'ro.hardware=ranchu\n'),
        AndroidEmulatorSignals(buildProp: 'ro.product.cpu.abi=generic_x86'),
      ];

      for (final sample in samples) {
        expect(sample.isEmulator, isTrue);
      }
    });

    test('does not classify physical-device-looking signals as emulator', () {
      const signals = AndroidEmulatorSignals(
        cpuInfo: 'Hardware\t: Qualcomm Technologies',
        hardware: 'qcom',
        buildCharacteristics: 'default',
        productModel: 'Pixel 8',
        buildProp: 'ro.hardware=qcom\nro.product.model=Pixel 8\n',
      );

      expect(signals.isEmulator, isFalse);
    });
  });

  group('BackendDecision helpers', () {
    test('toLogLine contains backend, reason, module, and detail', () {
      const decision = BackendDecision(
        backend: RendererBackend.cpu,
        reasonCode: FallbackReasonCode.deepZoomPrecision,
        detail: 'deep_zoom_precision_policy',
      );
      final line = decision.toLogLine(moduleId: 'mandelbrot');
      expect(line, contains('backend=cpu'));
      expect(line, contains('reason=deep_zoom_precision'));
      expect(line, contains('module=mandelbrot'));
      expect(line, contains('detail=deep_zoom_precision_policy'));
    });

    test('toUserStatusText for deep zoom precision', () {
      const decision = BackendDecision(
        backend: RendererBackend.cpu,
        reasonCode: FallbackReasonCode.deepZoomPrecision,
        detail: '',
      );
      expect(decision.toUserStatusText(), 'Deep zoom precision mode enabled');
    });

    test('toUserStatusText for manual toggle cpu', () {
      const decision = BackendDecision(
        backend: RendererBackend.cpu,
        reasonCode: FallbackReasonCode.manualToggle,
        detail: 'cpu_only',
      );
      expect(decision.toUserStatusText(), 'Renderer preference applied');
    });

    test('toUserStatusText for forced by flag', () {
      const decision = BackendDecision(
        backend: RendererBackend.cpu,
        reasonCode: FallbackReasonCode.forcedByFlag,
        detail: '',
      );
      expect(
          decision.toUserStatusText(), 'Stable renderer forced by launch flag');
    });
  });
}
