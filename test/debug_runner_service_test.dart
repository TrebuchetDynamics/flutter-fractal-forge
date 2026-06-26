import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/diagnostics/debug_runner_service.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Helper factories to avoid repeating boilerplate.
  ModuleRegistry makeRegistry() => ModuleRegistry();

  FractalController makeController(ModuleRegistry registry) =>
      FractalController(registry);

  DebugRunnerService makeService({String? screenshotDir}) {
    final registry = makeRegistry();
    final controller = makeController(registry);
    return DebugRunnerService(
      controller: controller,
      registry: registry,
      screenshotDir: screenshotDir,
    );
  }

  // ---------------------------------------------------------------------------
  // Pure debug-run planning helpers
  // ---------------------------------------------------------------------------

  group('DebugRunnerRunGate', () {
    test('rejects a new run only while one is already running', () {
      expect(DebugRunnerRunGate.shouldStart(DebugRunState.idle), isTrue);
      expect(DebugRunnerRunGate.shouldStart(DebugRunState.completed), isTrue);
      expect(DebugRunnerRunGate.shouldStart(DebugRunState.error), isTrue);
      expect(DebugRunnerRunGate.shouldStart(DebugRunState.running), isFalse);
    });
  });

  group('DebugRunnerOutputPlan', () {
    test('uses provided screenshot directory instead of document fallback', () {
      final plan = DebugRunnerOutputPlan.fromDocumentsDirectory(
        documentsPath: 'app_docs',
        requestedScreenshotDir: 'custom_shots',
      );

      expect(plan.screenshotDir, 'custom_shots');
    });

    test('falls back to documents debug directory when no override exists', () {
      final plan = DebugRunnerOutputPlan.fromDocumentsDirectory(
        documentsPath: 'app_docs',
      );

      expect(plan.screenshotDir, 'app_docs/debug_screenshots');
    });

    test('treats blank screenshot directory override as missing', () {
      final plan = DebugRunnerOutputPlan.fromDocumentsDirectory(
        documentsPath: 'app_docs',
        requestedScreenshotDir: '   ',
      );

      expect(plan.screenshotDir, 'app_docs/debug_screenshots');
    });
  });

  group('DebugRunnerStepPlan', () {
    test('keeps per-module step count explicit', () {
      const plan = DebugRunnerStepPlan(moduleCount: 3);

      expect(DebugRunnerStepPlan.stepsPerModule, 5);
      expect(plan.totalSteps, 15);
    });
  });

  // ---------------------------------------------------------------------------
  // Construction / initial state
  // ---------------------------------------------------------------------------

  group('DebugRunnerService – construction', () {
    test('initialises with idle state', () {
      final service = makeService();

      expect(service.state, DebugRunState.idle);
    });

    test('initialises currentStep to 0', () {
      final service = makeService();

      expect(service.currentStep, 0);
    });

    test('initialises totalSteps to 0', () {
      final service = makeService();

      expect(service.totalSteps, 0);
    });

    test('initialises statusMessage to empty string', () {
      final service = makeService();

      expect(service.statusMessage, '');
    });

    test('initialises errorMessage to null', () {
      final service = makeService();

      expect(service.errorMessage, isNull);
    });

    test('accepts optional screenshotDir without throwing', () {
      expect(
        () => makeService(screenshotDir: 'custom_shots'),
        returnsNormally,
      );
    });

    test('exposes controller and registry passed at construction', () {
      final registry = makeRegistry();
      final controller = makeController(registry);
      final service = DebugRunnerService(
        controller: controller,
        registry: registry,
      );

      expect(service.controller, same(controller));
      expect(service.registry, same(registry));
    });
  });

  // ---------------------------------------------------------------------------
  // DebugRunState enum
  // ---------------------------------------------------------------------------

  group('DebugRunState enum', () {
    test('has exactly four values', () {
      expect(DebugRunState.values.length, 4);
    });

    test('values are idle, running, completed, error', () {
      expect(DebugRunState.values, contains(DebugRunState.idle));
      expect(DebugRunState.values, contains(DebugRunState.running));
      expect(DebugRunState.values, contains(DebugRunState.completed));
      expect(DebugRunState.values, contains(DebugRunState.error));
    });
  });

  // ---------------------------------------------------------------------------
  // ChangeNotifier – listener registration
  // ---------------------------------------------------------------------------

  group('DebugRunnerService – ChangeNotifier', () {
    test('addListener and removeListener work without errors', () {
      final service = makeService();
      void listener() {}

      service.addListener(listener);
      service.removeListener(listener);

      service.dispose();
    });

    test('dispose does not throw', () {
      final service = makeService();

      expect(() => service.dispose(), returnsNormally);
    });
  });

  // ---------------------------------------------------------------------------
  // FractalController integration (used by DebugRunnerService internally)
  // ---------------------------------------------------------------------------

  group('FractalController – module registry sanity', () {
    test('registry has at least one module', () {
      final registry = makeRegistry();

      expect(registry.modules, isNotEmpty);
    });

    test('first module can be selected on the controller', () {
      final registry = makeRegistry();
      final controller = makeController(registry);

      expect(controller.module, registry.modules.first);
    });

    test('controller can select second module without throwing', () {
      final registry = makeRegistry();
      final controller = makeController(registry);

      if (registry.modules.length >= 2) {
        expect(
          () => controller.selectModule(registry.modules[1]),
          returnsNormally,
        );
      }
    });

    test('controller.randomizeParams does not throw', () {
      final registry = makeRegistry();
      final controller = makeController(registry);

      expect(() => controller.randomizeParams(), returnsNormally);
    });

    test('controller.resetSession does not throw', () {
      final registry = makeRegistry();
      final controller = makeController(registry);

      expect(() => controller.resetSession(), returnsNormally);
    });
  });

  // ---------------------------------------------------------------------------
  // totalSteps formula
  // ---------------------------------------------------------------------------

  group('DebugRunnerService – totalSteps formula', () {
    test('totalSteps should equal modules.length * stepsPerModule', () {
      final registry = makeRegistry();
      final plan = DebugRunnerStepPlan(moduleCount: registry.modules.length);

      expect(plan.totalSteps, registry.modules.length * 5);
      expect(plan.totalSteps, greaterThan(0));
    });
  });
}
