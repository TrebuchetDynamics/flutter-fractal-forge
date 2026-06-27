import 'dart:async' show unawaited;

import 'package:flutter/widgets.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/diagnostics/test_logger.dart';
import 'package:flutter_fractals/core/services/diagnostics/test_screenshot_service.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:path_provider/path_provider.dart';

enum DebugRunState { idle, running, completed, error }

/// Replayable run-admission guard for debug runs.
class DebugRunnerRunGate {
  const DebugRunnerRunGate._();

  static bool shouldStart(DebugRunState state) =>
      state != DebugRunState.running;
}

/// Replayable output-path plan for a debug run.
///
/// The optional constructor `screenshotDir` is a caller override. When omitted
/// or blank, screenshots fall back to the app documents debug directory.
class DebugRunnerOutputPlan {
  final String screenshotDir;

  const DebugRunnerOutputPlan({required this.screenshotDir});

  factory DebugRunnerOutputPlan.fromDocumentsDirectory({
    required String documentsPath,
    String? requestedScreenshotDir,
  }) {
    final override = requestedScreenshotDir?.trim();
    return DebugRunnerOutputPlan(
      screenshotDir: override == null || override.isEmpty
          ? '$documentsPath/debug_screenshots'
          : override,
    );
  }
}

/// Replayable step-count contract for one debug run.
class DebugRunnerStepPlan {
  static const int stepsPerModule = 5;

  final int moduleCount;

  const DebugRunnerStepPlan({required this.moduleCount})
      : assert(moduleCount >= 0, 'moduleCount cannot be negative');

  int get totalSteps => moduleCount * stepsPerModule;
}

class DebugRunnerService extends ChangeNotifier {
  final FractalController controller;
  final ModuleRegistry registry;
  final String? _requestedScreenshotDir;
  final TestLogger _logger = TestLogger();
  late TestScreenshotService _screenshotService;

  DebugRunState _state = DebugRunState.idle;
  int _currentStep = 0;
  int _totalSteps = 0;
  String _statusMessage = '';
  String? _errorMessage;
  bool _disposed = false;

  void _notifyIfAlive() {
    if (!_disposed) notifyListeners();
  }

  DebugRunnerService({
    required this.controller,
    required this.registry,
    String? screenshotDir,
  }) : _requestedScreenshotDir = screenshotDir {
    // The default screenshot dir is resolved once documents storage is known in
    // run(); a provided override can be installed immediately.
    _screenshotService = TestScreenshotService(
      outputDir: screenshotDir ?? '',
    );
  }

  DebugRunState get state => _state;
  int get currentStep => _currentStep;
  int get totalSteps => _totalSteps;
  String get statusMessage => _statusMessage;
  String? get errorMessage => _errorMessage;

  Future<void> run(GlobalKey boundaryKey) async {
    if (!DebugRunnerRunGate.shouldStart(_state)) return;

    try {
      // Initialize logger
      await _logger.init();

      if (_disposed) return;

      // Set up screenshot dir.
      final docDir = await getApplicationDocumentsDirectory();
      final outputPlan = DebugRunnerOutputPlan.fromDocumentsDirectory(
        documentsPath: docDir.path,
        requestedScreenshotDir: _requestedScreenshotDir,
      );
      _screenshotService = TestScreenshotService(
        outputDir: outputPlan.screenshotDir,
      );

      final modules = registry.modules;
      final stepPlan = DebugRunnerStepPlan(moduleCount: modules.length);
      _totalSteps = stepPlan.totalSteps;
      _currentStep = 0;
      if (_disposed) return;

      _state = DebugRunState.running;
      _errorMessage = null;
      _notifyIfAlive();

      _logger.logAction(
        'debugRunner',
        'Debug run started',
        metadata: {'moduleCount': modules.length},
      );

      for (final module in modules) {
        // Step 1: Select module
        _updateStatus('Selecting ${module.id}...');
        controller.selectModule(module);
        await _settle();
        if (_disposed) return;
        _advanceStep();

        // Step 2: Screenshot default state
        _updateStatus('Capturing ${module.id} default...');
        await _screenshotService.capture(
          boundaryKey,
          '${module.id}_default',
        );
        await _settle();
        if (_disposed) return;
        _advanceStep();

        // Step 3: Randomize params
        _updateStatus('Randomizing ${module.id}...');
        controller.randomizeParams();
        await _settle();
        if (_disposed) return;
        _advanceStep();

        // Step 4: Screenshot randomized state
        _updateStatus('Capturing ${module.id} randomized...');
        await _screenshotService.capture(
          boundaryKey,
          '${module.id}_randomized',
        );
        await _settle();
        if (_disposed) return;
        _advanceStep();

        // Step 5: Reset
        _updateStatus('Resetting ${module.id}...');
        controller.resetSession();
        await _settle();
        if (_disposed) return;
        _advanceStep();
      }

      _state = DebugRunState.completed;
      _statusMessage = 'Completed! ${modules.length} modules tested.';
      _logger.logAction('debugRunner', 'Debug run completed');
      _notifyIfAlive();
    } catch (e) {
      _state = DebugRunState.error;
      _errorMessage = e.toString();
      _statusMessage = 'Error: $e';
      _logger.logAction('debugRunner', 'Debug run failed: $e');
      _notifyIfAlive();
    }
  }

  void _updateStatus(String message) {
    if (_disposed) return;
    _statusMessage = message;
    _logger.logAction('debugRunner', message);
    _notifyIfAlive();
  }

  void _advanceStep() {
    if (_disposed) return;
    _currentStep++;
    _notifyIfAlive();
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_logger.dispose());
    super.dispose();
  }

  /// 500ms settle delay for shader render time
  Future<void> _settle() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
