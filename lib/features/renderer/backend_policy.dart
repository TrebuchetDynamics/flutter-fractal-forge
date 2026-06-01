import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/services/renderer_settings_service.dart';

const bool kForceCpuFallback =
    bool.fromEnvironment('FORCE_CPU_FALLBACK', defaultValue: false);
// Android emulator GPU is allowed in auto mode. Runtime health probes in
// FractalViewerScreen enforce fast fallback to CPU on invalid output.

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
        return 'Renderer preference applied';
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
  final RendererBackendMode userMode;
  final bool gpuHealthFailed;
  final bool deepZoomNeedsCpu;
  final FractalDimension dimension;

  const BackendPolicyInput({
    required this.isAndroid,
    required this.isWeb,
    required this.isEmulator,
    required this.userMode,
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

    if (input.dimension != FractalDimension.twoD) {
      // 3D modules (e.g. Mandelbulb/Mandelbox) currently rely on GPU shader
      // rendering. Forcing CPU here only produces a disabled placeholder pane.
      // Keep these modules on GPU by default.
      if (input.userMode == RendererBackendMode.cpuOnly) {
        return const BackendDecision(
          backend: RendererBackend.gpu,
          reasonCode: FallbackReasonCode.moduleUnsupported,
          detail: 'cpu_only_ignored_for_3d_gpu_required',
        );
      }
      return const BackendDecision(
        backend: RendererBackend.gpu,
        reasonCode: FallbackReasonCode.none,
        detail: '3d_gpu_path',
      );
    }

    if (input.userMode == RendererBackendMode.cpuOnly) {
      return const BackendDecision(
        backend: RendererBackend.cpu,
        reasonCode: FallbackReasonCode.manualToggle,
        detail: 'cpu_only',
      );
    }

    if (input.userMode == RendererBackendMode.gpuOnly) {
      return const BackendDecision(
        backend: RendererBackend.gpu,
        reasonCode: FallbackReasonCode.manualToggle,
        detail: 'gpu_only',
      );
    }

    // Emulator targets are handled like physical devices in auto mode.
    // Runtime GPU health checks own fallback decisions.

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

/// Replayable Android emulator signal snapshot.
///
/// Device probing is intentionally best-effort and IO-heavy; keeping the
/// signal classifier pure makes marker drift testable without touching
/// `/proc`, `getprop`, or `/system` in unit tests.
class AndroidEmulatorSignals {
  final String cpuInfo;
  final String hardware;
  final String buildCharacteristics;
  final String productModel;
  final String buildProp;

  const AndroidEmulatorSignals({
    this.cpuInfo = '',
    this.hardware = '',
    this.buildCharacteristics = '',
    this.productModel = '',
    this.buildProp = '',
  });

  bool get isEmulator =>
      _cpuInfoHasEmulatorMarker(cpuInfo) ||
      _hardwareHasEmulatorMarker(hardware) ||
      buildCharacteristics.toLowerCase().contains('emulator') ||
      productModel.toLowerCase().contains('sdk_gphone') ||
      _buildPropHasEmulatorMarker(buildProp);

  static bool _cpuInfoHasEmulatorMarker(String value) {
    final normalized = value.toLowerCase();
    return normalized.contains('ranchu') ||
        normalized.contains('goldfish') ||
        normalized.contains('qemu') ||
        normalized.contains('android virtual processor');
  }

  static bool _hardwareHasEmulatorMarker(String value) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'ranchu' || normalized == 'goldfish';
  }

  static bool _buildPropHasEmulatorMarker(String value) {
    final normalized = value.toLowerCase();
    return normalized.contains('ro.hardware=goldfish') ||
        normalized.contains('ro.hardware=ranchu') ||
        normalized.contains('sdk_gphone') ||
        normalized.contains('generic_x86');
  }
}

Future<bool> detectAndroidEmulator() async {
  if (kIsWeb || !Platform.isAndroid) return false;

  var signals = const AndroidEmulatorSignals();

  // 1. /proc/cpuinfo — check for emulator markers
  try {
    signals = AndroidEmulatorSignals(
      cpuInfo: await File('/proc/cpuinfo').readAsString(),
    );
    if (signals.isEmulator) return true;
  } catch (e) {
    if (kDebugMode) debugPrint('[FF] silent catch: $e');
  }

  // 2. getprop — most reliable on modern emulators
  try {
    final result = await Process.run('getprop', ['ro.hardware']);
    signals = AndroidEmulatorSignals(hardware: result.stdout as String);
    if (signals.isEmulator) return true;
  } catch (e) {
    if (kDebugMode) debugPrint('[FF] silent catch: $e');
  }

  try {
    final result = await Process.run('getprop', ['ro.build.characteristics']);
    signals = AndroidEmulatorSignals(
      buildCharacteristics: result.stdout as String,
    );
    if (signals.isEmulator) return true;
  } catch (e) {
    if (kDebugMode) debugPrint('[FF] silent catch: $e');
  }

  try {
    final result = await Process.run('getprop', ['ro.product.model']);
    signals = AndroidEmulatorSignals(productModel: result.stdout as String);
    if (signals.isEmulator) return true;
  } catch (e) {
    if (kDebugMode) debugPrint('[FF] silent catch: $e');
  }

  // 3. /system/build.prop — fallback file check
  try {
    signals = AndroidEmulatorSignals(
      buildProp: await File('/system/build.prop').readAsString(),
    );
    if (signals.isEmulator) return true;
  } catch (e) {
    if (kDebugMode) debugPrint('[FF] silent catch: $e');
  }

  return false;
}
