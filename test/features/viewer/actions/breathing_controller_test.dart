import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/viewer/actions/breathing_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ModuleRegistry registry;
  late FractalController fractal;
  late BreathingController breathing;
  var motionAllowed = true;

  setUp(() {
    registry = ModuleRegistry();
    fractal = FractalController(registry)
      ..selectModule(registry.byId('julia'), animate: false);
    motionAllowed = true;
    breathing = BreathingController(
      controller: fractal,
      canAnimate: () => motionAllowed,
    );
  });

  tearDown(() {
    breathing.dispose();
    fractal.dispose();
  });

  testWidgets(
      'one slow cycle returns to its starting values without camera motion',
      (tester) async {
    final initial = Map.of(fractal.params);
    final view = fractal.view;
    expect(breathing.isPlaying, isFalse);
    breathing.play();
    expect(fractal.params, initial);
    await tester.pump(const Duration(seconds: 2));
    expect(fractal.params['juliaCReal'], closeTo(-0.68, 0.001));
    expect(fractal.params['juliaCImag'], closeTo(0.276, 0.001));
    expect(fractal.params['iterations'], 160);
    expect(fractal.params['colorScheme'], 0);
    expect(fractal.view.pan, view.pan);
    expect(fractal.view.zoom, view.zoom);
    expect(fractal.view.rotation, view.rotation);
    await tester.pump(const Duration(seconds: 6));
    expect(fractal.params['juliaCReal'], closeTo(-0.8, 0.002));
    expect(fractal.params['juliaCImag'], closeTo(0.156, 0.002));
    breathing.pause();
  });

  testWidgets('parameters at both bounds keep moving inside the schema',
      (tester) async {
    fractal.updateParam('juliaCReal', 1.5);
    fractal.updateParam('juliaCImag', -1.5);
    breathing.play();
    var changed = false;
    for (var frame = 0; frame < 250; frame++) {
      await tester.pump(const Duration(milliseconds: 33));
      for (final parameter in fractal.module.parameters) {
        if (parameter.type != FractalParamType.float) continue;
        final value = (fractal.params[parameter.id] as num).toDouble();
        expect(value.isFinite, isTrue);
        expect(value, inInclusiveRange(parameter.min, parameter.max));
      }
      changed |= (fractal.params['juliaCReal'] as num) < 1.49 &&
          (fractal.params['juliaCImag'] as num) > -1.49;
    }
    expect(changed, isTrue);
    expect(breathing.isPlaying, isTrue);
    breathing.pause();
  });

  testWidgets('pause freezes the shape and resume continues without a jump',
      (tester) async {
    breathing.play();
    await tester.pump(const Duration(seconds: 1));
    breathing.pause();
    final paused = Map.of(fractal.params);
    await tester.pump(const Duration(seconds: 30));
    expect(fractal.params, paused);
    breathing.play();
    expect(fractal.params, paused);
    await tester.pump(const Duration(milliseconds: 33));
    expect(
        (fractal.params['juliaCReal'] as num) - (paused['juliaCReal'] as num),
        inInclusiveRange(0, 0.004));
    breathing.pause();
  });

  testWidgets('manual edits and module changes cancel the old loop',
      (tester) async {
    breathing.play();
    await tester.pump(const Duration(seconds: 1));
    fractal.updateParam('juliaCReal', 0.25);
    expect(breathing.isPlaying, isFalse);
    await tester.pump(const Duration(seconds: 1));
    expect(fractal.params['juliaCReal'], 0.25);
    breathing.play();
    expect(fractal.params['juliaCReal'], 0.25);
    fractal.selectModule(registry.byId('mandelbulb'), animate: false);
    final next = Map.of(fractal.params);
    expect(breathing.isPlaying, isFalse);
    await tester.pump(const Duration(seconds: 1));
    expect(fractal.params, next);
  });

  testWidgets('losing motion permission pauses and never auto-resumes',
      (tester) async {
    motionAllowed = false;
    breathing.play();
    expect(breathing.isPlaying, isFalse);
    motionAllowed = true;
    breathing.play();
    await tester.pump(const Duration(milliseconds: 330));
    motionAllowed = false;
    final paused = Map.of(fractal.params);
    await tester.pump(const Duration(seconds: 1));
    expect(breathing.isPlaying, isFalse);
    expect(fractal.params, paused);
    motionAllowed = true;
    await tester.pump(const Duration(seconds: 1));
    expect(breathing.isPlaying, isFalse);
    expect(fractal.params, paused);
  });

  testWidgets('whole-step float controls never enter the continuous loop',
      (tester) async {
    for (final module in registry.modules.where((module) => module.parameters
        .any((parameter) =>
            parameter.type == FractalParamType.float && parameter.step >= 1))) {
      fractal.selectModule(module, animate: false);
      final discrete = {
        for (final parameter in module.parameters)
          if (parameter.type == FractalParamType.float && parameter.step >= 1)
            parameter.id: fractal.params[parameter.id],
      };
      breathing.play();
      await tester.pump(const Duration(milliseconds: 330));
      breathing.pause();
      for (final entry in discrete.entries) {
        expect(fractal.params[entry.key], entry.value,
            reason: '${module.id}.${entry.key} is a whole-step control');
      }
    }
  });

  testWidgets(
      'fractional bailout sliders that encode discrete shader orders stay fixed',
      (tester) async {
    for (final id in [
      'mandelbrot_stripe_avg',
      'chebyshev',
      'legendre',
      'laguerre',
      'hermite'
    ]) {
      fractal.selectModule(registry.byId(id), animate: false);
      final bailout = fractal.params['bailout'];
      breathing.play();
      await tester.pump(const Duration(seconds: 6));
      breathing.pause();
      expect(fractal.params['bailout'], bailout, reason: id);
    }
  });

  testWidgets('step size and discrete parameters are not animated',
      (tester) async {
    fractal.selectModule(registry.byId('henon_heiles_escape_basin'),
        animate: false);
    final initial = Map.of(fractal.params);
    breathing.play();
    await tester.pump(const Duration(seconds: 2));
    expect(fractal.params['stepSize'], initial['stepSize']);
    for (final parameter in fractal.module.parameters) {
      if (parameter.type != FractalParamType.float) {
        expect(fractal.params[parameter.id], initial[parameter.id]);
      }
    }
    breathing.pause();
  });
}
