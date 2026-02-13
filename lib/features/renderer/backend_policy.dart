import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';

const bool kForceCpuFallback =
    bool.fromEnvironment('FORCE_CPU_FALLBACK', defaultValue: false);
const bool _kSkipEmulatorGuard =
    bool.fromEnvironment('SKIP_EMULATOR_GUARD', defaultValue: false);

enum RendererBackend { gpu, cpu }

enum FallbackReasonCode {
  none,
  forcedByFlag,
  androidEmulator,
  gpuHealthCheckFailed,
  deepZoomPrecision,
  manualToggle,
  moduleUnsupported,
}

class BackendDecision {
  final RendererBackend backend;
  final FallbackReasonCode reasonCode;
  final String detail;

  const BackendDecision({
    required this.backend,
    required this.reasonCode,
    required this.detail,
  });

  bool get isFallback => backend == RendererBackend.cpu;

  String get reasonToken {
    switch (reasonCode) {
      case FallbackReasonCode.none:
        return 'none';
      case FallbackReasonCode.forcedByFlag:
        return 'forced_by_flag';
      case FallbackReasonCode.androidEmulator:
        return 'android_emulator';
      case FallbackReasonCode.gpuHealthCheckFailed:
        return 'gpu_health_check_failed';
      case FallbackReasonCode.deepZoomPrecision:
        return 'deep_zoom_precision';
      case FallbackReasonCode.manualToggle:
        return 'manual_toggle';
      case FallbackReasonCode.moduleUnsupported:
        return 'module_unsupported';
    }
  }

  String toLogLine({required String moduleId}) {
    return '[renderer] backend_decision backend=${backend.name} reason=$reasonToken module=$moduleId detail=$detail';
  }

  String toUserStatusText() {
    if (!isFallback) return 'Renderer: GPU';
    switch (reasonCode) {
      case FallbackReasonCode.androidEmulator:
        return 'Using stable renderer for this Android emulator';
      case FallbackReasonCode.gpuHealthCheckFailed:
        return 'GPU output unavailable, using stable renderer';
      case FallbackReasonCode.deepZoomPrecision:
        return 'Deep zoom precision mode enabled';
      case FallbackReasonCode.manualToggle:
        return 'Stable renderer enabled';
      case FallbackReasonCode.moduleUnsupported:
        return 'Stable renderer enabled for this fractal mode';
      case FallbackReasonCode.forcedByFlag:
        return 'Stable renderer forced by launch flag';
      case FallbackReasonCode.none:
        return 'Renderer: CPU';
    }
  }
}

class BackendPolicyInput {
  final bool isAndroid;
  final bool isWeb;
  final bool isEmulator;
  final bool manualCpuRequested;
  final bool gpuHealthFailed;
  final bool deepZoomNeedsCpu;
  final FractalDimension dimension;

  const BackendPolicyInput({
    required this.isAndroid,
    required this.isWeb,
    required this.isEmulator,
    required this.manualCpuRequested,
    required this.gpuHealthFailed,
    required this.deepZoomNeedsCpu,
    required this.dimension,
  });
}

class RendererBackendPolicy {
  const RendererBackendPolicy();

  BackendDecision decide(BackendPolicyInput input) {
    if (kForceCpuFallback) {
      return const BackendDecision(
        backend: RendererBackend.cpu,
        reasonCode: FallbackReasonCode.forcedByFlag,
        detail: 'FORCE_CPU_FALLBACK=true',
      );
    }

    if (input.manualCpuRequested) {
      return const BackendDecision(
        backend: RendererBackend.cpu,
        reasonCode: FallbackReasonCode.manualToggle,
        detail: 'manual_cpu_toggle',
      );
    }

    if (input.dimension != FractalDimension.twoD) {
      return const BackendDecision(
        backend: RendererBackend.cpu,
        reasonCode: FallbackReasonCode.moduleUnsupported,
        detail: 'cpu_path_only_for_unsupported_gpu_module',
      );
    }

    if (input.isAndroid && input.isEmulator && !_kSkipEmulatorGuard) {
      return const BackendDecision(
        backend: RendererBackend.cpu,
        reasonCode: FallbackReasonCode.androidEmulator,
        detail: 'ranchu/goldfish emulator guard',
      );
    }

    if (input.gpuHealthFailed) {
      return const BackendDecision(
        backend: RendererBackend.cpu,
        reasonCode: FallbackReasonCode.gpuHealthCheckFailed,
        detail: 'frame_probe_detected_invalid_gpu_output',
      );
    }

    if (input.deepZoomNeedsCpu) {
      return const BackendDecision(
        backend: RendererBackend.cpu,
        reasonCode: FallbackReasonCode.deepZoomPrecision,
        detail: 'deep_zoom_precision_policy',
      );
    }

    return const BackendDecision(
      backend: RendererBackend.gpu,
      reasonCode: FallbackReasonCode.none,
      detail: 'healthy_gpu_target',
    );
  }
}

Future<bool> detectAndroidEmulator() async {
  if (kIsWeb || !Platform.isAndroid) return false;

  try {
    final cpuInfo = await File('/proc/cpuinfo').readAsString();
    final c = cpuInfo.toLowerCase();
    if (c.contains('ranchu') || c.contains('goldfish') || c.contains('qemu')) {
      return true;
    }
  } catch (_) {}

  try {
    final buildProp = await File('/system/build.prop').readAsString();
    final b = buildProp.toLowerCase();
    if (b.contains('ro.hardware=goldfish') ||
        b.contains('ro.hardware=ranchu') ||
        b.contains('sdk_gphone') ||
        b.contains('generic_x86')) {
      return true;
    }
  } catch (_) {}

  return false;
}
