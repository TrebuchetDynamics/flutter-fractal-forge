import 'package:flutter/widgets.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/test_logger.dart';
import 'package:flutter_fractals/core/services/test_screenshot_service.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:path_provider/path_provider.dart';

enum DebugRunState { idle, running, completed, error }

class DebugRunnerService extends ChangeNotifier {
  final FractalController controller;
  final ModuleRegistry registry;
  final TestLogger _logger = TestLogger();
  late TestScreenshotService _screenshotService;

  DebugRunState _state = DebugRunState.idle;
  int _currentStep = 0;
  int _totalSteps = 0;
  String _statusMessage = '';
  String? _errorMessage;

  DebugRunnerService({
    required this.controller,
    required this.registry,
    String? screenshotDir,
  }) {
    // screenshotDir will be set during run() if not provided
    _screenshotService = TestScreenshotService(
      outputDir: screenshotDir ?? '', // will be overwritten in run()
    );
  }

  DebugRunState get state => _state;
  int get currentStep => _currentStep;
  int get totalSteps => _totalSteps;
  String get statusMessage => _statusMessage;
  String? get errorMessage => _errorMessage;

  Future<void> run(GlobalKey boundaryKey) async {
    if (_state == DebugRunState.running) return;

    try {
      // Initialize logger
      await _logger.init();

      // Set up screenshot dir
      final docDir = await getApplicationDocumentsDirectory();
      final screenshotDir = '${docDir.path}/debug_screenshots';
      _screenshotService = TestScreenshotService(outputDir: screenshotDir);

      final modules = registry.modules;
      // Each module: select + screenshot_default + randomize + screenshot_randomized + reset = 5 steps
      _totalSteps = modules.length * 5;
      _currentStep = 0;
      _state = DebugRunState.running;
      _errorMessage = null;
      notifyListeners();

      _logger.logAction('debugRunner', 'Debug run started', metadata: {'moduleCount': modules.length});

      for (final module in modules) {
        // Step 1: Select module
        _updateStatus('Selecting ${module.id}...');
        controller.selectModule(module);
        await _settle();
        _advanceStep();

        // Step 2: Screenshot default state
        _updateStatus('Capturing ${module.id} default...');
        await _screenshotService.capture(boundaryKey, '${module.id}_default');
        await _settle();
        _advanceStep();

        // Step 3: Randomize params
        _updateStatus('Randomizing ${module.id}...');
        controller.randomizeParams();
        await _settle();
        _advanceStep();

        // Step 4: Screenshot randomized state
        _updateStatus('Capturing ${module.id} randomized...');
        await _screenshotService.capture(boundaryKey, '${module.id}_randomized');
        await _settle();
        _advanceStep();

        // Step 5: Reset
        _updateStatus('Resetting ${module.id}...');
        controller.resetSession();
        await _settle();
        _advanceStep();
      }

      _state = DebugRunState.completed;
      _statusMessage = 'Completed! ${modules.length} modules tested.';
      _logger.logAction('debugRunner', 'Debug run completed');
      notifyListeners();
    } catch (e) {
      _state = DebugRunState.error;
      _errorMessage = e.toString();
      _statusMessage = 'Error: $e';
      _logger.logAction('debugRunner', 'Debug run failed: $e');
      notifyListeners();
    }
  }

  void _updateStatus(String message) {
    _statusMessage = message;
    _logger.logAction('debugRunner', message);
    notifyListeners();
  }

  void _advanceStep() {
    _currentStep++;
    notifyListeners();
  }

  /// 500ms settle delay for shader render time
  Future<void> _settle() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
