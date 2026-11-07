import 'dart:convert';
import 'dart:io';
import 'dart:math';

// Reuse the locked hashing dependency and replay source graph/JSON conventions.
// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart' show sha256;
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/replay_codec.dart' show canonicalJson, replaySourceBindings;

const _output = String.fromEnvironment('MIGRATION_INTERPOLATION_OUT');
const _tick = Duration(milliseconds: 16);
const _testPath = 'test/migration/param_interpolation_oracle_test.dart';

FractalParameter _param(String id, FractalParamType type, Object value,
        {double min = -10, double max = 10, List<Object> options = const []}) =>
    FractalParameter(
      id: id,
      label: (_) => id,
      type: type,
      min: min,
      max: max,
      step: 0.125,
      defaultValue: value,
      options: [
        for (final option in options)
          FractalParamOption(value: option, label: (_) => '$option'),
      ],
    );

FractalModule _synthetic(FractalModule base) {
  final parameters = [
    _param('fraction', FractalParamType.float, -1.125),
    _param('positive', FractalParamType.integer, 1, min: 0, max: 5),
    _param('negative', FractalParamType.integer, -1, min: -5, max: 0),
    _param('boolean', FractalParamType.boolean, false),
    _param('enumNumber', FractalParamType.enumeration, 1, options: [1, 2.5]),
    _param('enumText', FractalParamType.enumeration, 'first',
        options: ['first', 'second']),
    _param('decimal', FractalParamType.decimalInteger,
        '900719925474099312345678901234567890'),
    _param('colorScheme', FractalParamType.integer, 0, min: 0, max: 63),
    _param('colorCycleSpeed', FractalParamType.float, 0.0, min: 0, max: 2),
  ];
  return FractalModule(
    id: 'interpolation_oracle_schema',
    displayName: (_) => 'Interpolation oracle schema',
    dimension: base.dimension,
    shaderAsset: base.shaderAsset,
    parameters: parameters,
    defaultPreset: base.defaultPreset.copyWith(
      moduleId: 'interpolation_oracle_schema',
      params: {for (final p in parameters) p.id: p.defaultValue},
    ),
    builtInPresets: const [],
    setUniforms: base.setUniforms,
  );
}

List<Map<String, Object?>> _schema(FractalModule module) => [
      for (var i = 0; i < module.parameters.length; i++)
        {
          'id': module.parameters[i].id,
          'order': i,
          'label_en': module.parameters[i].label(AppLocalizationsEn()),
          'type': module.parameters[i].type.name,
          'control': module.parameters[i].control?.name,
          'resolved_control': module.parameters[i].resolvedControl.name,
          'min': module.parameters[i].min,
          'max': module.parameters[i].max,
          'step': module.parameters[i].step,
          'default': module.parameters[i].defaultValue,
          'options': [
            for (final option in module.parameters[i].options)
              {
                'label_en': option.label(AppLocalizationsEn()),
                'value': option.value,
              },
          ],
        },
    ];

Future<List<Map<String, Object>>> _ticks(
    WidgetTester tester, FractalController controller) async {
  final outputs = <Map<String, Object>>[
    {'step': 0, 'params': controller.params}
  ];
  for (var step = 1; step <= 36; step++) {
    await tester.pump(_tick);
    outputs.add({'step': step, 'params': controller.params});
  }
  return outputs;
}

Future<Map<String, Object?>> _buildOracle(WidgetTester tester) async {
  final registry = ModuleRegistry();
  final cases = <Map<String, Object?>>[];
  for (final id in ['mandelbrot', 'synthetic']) {
    final controller = FractalController(registry);
    final reference = FractalController(registry);
    final module =
        id == 'synthetic' ? _synthetic(controller.module) : registry.byId(id);
    final initial = <String, Object>{
      'colorScheme': 17,
      'colorCycleSpeed': 0.625,
      if (id == 'synthetic') ...{
        'decimal': '9007199254740993',
        'boolean': true,
        'enumText': 'second',
      },
    };
    // selectModule is a no-op for the current module; update its initial values
    // through the same public seam instead.
    for (final c in [controller, reference]) {
      c.selectModule(module, animate: false, initialParams: initial);
      for (final entry in initial.entries) {
        c.updateParam(entry.key, entry.value);
      }
    }
    final from = controller.params;
    expect(reference.params, from);
    if (id == 'synthetic') {
      // A test-only mutable schema exposes absent inputs without private access.
      module.parameters
          .add(_param('missingFrom', FractalParamType.float, 2.25));
    }
    reference.randomizeParams(animate: false, random: Random(1));
    final target = reference.params;
    controller.randomizeParams(random: Random(1));
    if (id == 'synthetic') {
      // Absent in both captured maps; interim defaults disappear at tick 36.
      module.parameters
          .add(_param('missingBoth', FractalParamType.float, 3.125));
    }
    final expected = await _ticks(tester, controller);
    expect(expected.last['params'], target);
    for (final output in expected.skip(1).take(35)) {
      final params = output['params'] as Map;
      for (final p in module.parameters) {
        if (p.id == 'colorScheme' ||
            p.id == 'colorCycleSpeed' ||
            p.type == FractalParamType.boolean ||
            p.type == FractalParamType.enumeration ||
            p.type == FractalParamType.decimalInteger) {
          expect(params[p.id], from[p.id] ?? p.defaultValue);
        }
      }
      if (id == 'synthetic') expect(params['missingBoth'], 3.125);
    }
    cases.add({
      'id': id,
      'seed': 1,
      'schema': _schema(module),
      'from': from,
      'target': target,
      'expected': expected,
    });
    controller.dispose();
    reference.dispose();
  }

  final cancellations = <Map<String, Object?>>[];
  for (final action in [
    'replace',
    'immediate',
    'module',
    'resetParams',
    'resetSession',
    'dispose'
  ]) {
    final controller = FractalController(registry);
    controller.randomizeParams(random: Random(1));
    for (var i = 0; i < 5; i++) {
      await tester.pump(_tick);
    }
    final from = controller.params;
    final schema = _schema(controller.module);
    var notifications = 0;
    controller.addListener(() => notifications++);
    Map<String, Object>? target;
    switch (action) {
      case 'replace':
      case 'immediate':
        final reference = FractalController(registry);
        for (final entry in from.entries) {
          reference.updateParam(entry.key, entry.value);
        }
        reference.randomizeParams(animate: false, random: Random(42));
        target = reference.params;
        reference.dispose();
        controller.randomizeParams(
            animate: action == 'replace', random: Random(42));
      case 'module':
        controller.selectModule(registry.byId('julia'), animate: false);
      case 'resetParams':
        controller.resetParams();
      case 'resetSession':
        controller.resetSession();
      case 'dispose':
        controller.dispose();
    }
    final afterAction = controller.params;
    notifications = 0;
    final outputs = await _ticks(tester, controller);
    if (action == 'replace') {
      expect(outputs.first['params'], from);
      expect(outputs[1]['params'], isNot(from));
      expect(outputs.last['params'], target);
      expect(notifications, 36,
          reason: 'Only the replacement timer may notify');
    } else {
      for (final output in outputs) {
        expect(output['params'], afterAction,
            reason: '$action cancels the old timer');
      }
      expect(notifications, 0);
      if (target != null) expect(afterAction, target);
    }
    cancellations.add({
      'action': action,
      'afterStep': 5,
      'schema': schema,
      'from': from,
      'target': target,
      'afterAction': afterAction,
      'notificationsAfterAction': notifications,
      'expected': [
        for (final step in [0, 1, 18, 35, 36]) outputs[step]
      ],
    });
    if (action != 'dispose') controller.dispose();
  }
  final sources = replaySourceBindings();
  sources[_testPath] =
      sha256.convert(File(_testPath).readAsBytesSync()).toString();
  final flutterRoot = Platform.environment['FLUTTER_ROOT']!;
  for (final path in [
    'lib/math/random.dart',
    'lib/_internal/vm/lib/math_patch.dart'
  ]) {
    sources['dart-sdk/$path'] = sha256
        .convert(
            File('$flutterRoot/bin/cache/dart-sdk/$path').readAsBytesSync())
        .toString();
  }
  return {
    'schema': 1,
    'kind': 'public-controller-fake-time-parameter-interpolation',
    'runtime': {
      'dart': Platform.version.split(' ').first,
      'flutter': File('fdroid/flutter.version').readAsStringSync().trim(),
    },
    'steps': 36,
    'scheduledTickMilliseconds': 16,
    'source_bindings': sources,
    'cases': cases,
    'cancellations': cancellations,
  };
}

void main() {
  testWidgets(
      'public fake-time interpolation is exact, source-bound and immutable',
      (tester) async {
    final file = File('migration/oracles/param-interpolation.json');
    final before = file.existsSync() ? file.readAsStringSync() : null;
    final actual = await _buildOracle(tester);
    expect(await _buildOracle(tester), actual);
    expect((actual['runtime'] as Map)['dart'], '3.13.7');
    expect((actual['runtime'] as Map)['flutter'], '3.47.9');
    expect(jsonDecode(canonicalJson(actual)), actual);
    void compare(Object? expected) => expect(actual, expected);
    if (_output.isEmpty) {
      compare(jsonDecode(file.readAsStringSync()));
      expect(before, canonicalJson(actual));
    }
    final changed = jsonDecode(canonicalJson(actual)) as Map;
    changed['cases'][0]['expected'][18]['params']['iterations'] = -999;
    expect(() => compare(changed), throwsA(isA<TestFailure>()),
        reason: 'A nested changed expectation must fail');
    final changedSource = jsonDecode(canonicalJson(actual)) as Map;
    changedSource['source_bindings']
        ['lib/core/controllers/fractal_controller.dart'] = 'changed';
    expect(() => compare(changedSource), throwsA(isA<TestFailure>()));
    expect(file.existsSync() ? file.readAsStringSync() : null, before);
    if (_output.isNotEmpty) {
      final directory = Directory(_output);
      if (!directory.isAbsolute) throw ArgumentError('Output must be absolute');
      directory.createSync(recursive: true);
      final resolved = directory.resolveSymbolicLinksSync();
      final root = Directory.current.resolveSymbolicLinksSync();
      if (resolved == root || resolved.startsWith('$root/')) {
        throw ArgumentError('Output must be outside the checkout');
      }
      if (directory.listSync().isNotEmpty)
        throw StateError('Output must be empty');
      File('$resolved/param-interpolation.json')
          .writeAsStringSync(canonicalJson(actual));
    }
  });
}
