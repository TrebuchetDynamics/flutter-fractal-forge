import 'dart:io';
import 'dart:math';

// Reuse the locked hashing dependency and replay's source graph/JSON conventions.
// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart' show sha256;
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:vector_math/vector_math_64.dart';

import 'replay_codec.dart' show canonicalJson, replaySourceBindings;

export 'replay_codec.dart' show canonicalJson;

const randomizationOutput =
    String.fromEnvironment('MIGRATION_RANDOMIZATION_OUT');
const oracleSeeds = [0, 1, 42, 2147483647, -1, 2147483648];

/// Delegates each public call exactly once; internal RNG steps are not draws.
class RecordingRandom implements Random {
  RecordingRandom(int seed) : _delegate = Random(seed);
  final Random _delegate;
  final draws = <Map<String, Object?>>[];

  T _record<T extends Object>(String method, int? bound, T value) {
    draws.add({
      'order': draws.length,
      'method': method,
      'bound': bound,
      'value': value,
    });
    return value;
  }

  @override
  bool nextBool() => _record('nextBool', null, _delegate.nextBool());
  @override
  double nextDouble() => _record('nextDouble', null, _delegate.nextDouble());
  @override
  int nextInt(int max) => _record('nextInt', max, _delegate.nextInt(max));
}

FractalModule _synthetic(FractalModule base) {
  FractalParameter param(String id, FractalParamType type, Object value,
          {double min = -1,
          double max = 1,
          double step = 0.125,
          List<Object> options = const []}) =>
      FractalParameter(
        id: id,
        label: (_) => id,
        type: type,
        min: min,
        max: max,
        step: step,
        defaultValue: value,
        options: [
          for (final option in options)
            FractalParamOption(value: option, label: (_) => '$option'),
        ],
      );
  final parameters = [
    param('colorScheme', FractalParamType.integer, 0, min: 0, max: 63),
    param('fraction', FractalParamType.float, 0.0, min: -1.1, max: 2.3),
    param('integer', FractalParamType.integer, 0, min: -2.8, max: 2.8),
    param('colorCycleSpeed', FractalParamType.float, 0.0, min: 0, max: 2),
    param('juliaCReal', FractalParamType.float, 0.9),
    param('juliaCImag', FractalParamType.float, -0.9),
    param('enumInt', FractalParamType.enumeration, 7, options: [7, 11]),
    param('enumDouble', FractalParamType.enumeration, 1.25,
        options: [1.25, 2.5]),
    param('enumString', FractalParamType.enumeration, 'first',
        options: ['first', 'second']),
    param('enumBool', FractalParamType.enumeration, false,
        options: [false, true]),
    param('emptyEnum', FractalParamType.enumeration, 'unchanged'),
    param('decimal', FractalParamType.decimalInteger, '9007199254740993'),
    param('boolean', FractalParamType.boolean, false),
  ];
  return FractalModule(
    id: 'randomization_oracle_schema',
    displayName: (_) => 'Randomization oracle schema',
    dimension: base.dimension,
    shaderAsset: base.shaderAsset,
    parameters: parameters,
    defaultPreset: base.defaultPreset.copyWith(
      moduleId: 'randomization_oracle_schema',
      params: {for (final p in parameters) p.id: p.defaultValue},
    ),
    builtInPresets: const [],
    setUniforms: base.setUniforms,
  );
}

String _kind(Object value) => value is int
    ? 'int'
    : value is double
        ? 'double'
        : value is bool
            ? 'bool'
            : value is String
                ? 'String'
                : throw StateError('Unsupported oracle value: $value');

List<Map<String, Object?>> _schema(FractalModule module) => [
      for (final p in module.parameters)
        {
          'id': p.id,
          'type': p.type.name,
          'min': p.min,
          'max': p.max,
          'step': p.step,
          'default': p.defaultValue,
          'options': [
            for (final option in p.options)
              {'value': option.value, 'kind': _kind(option.value)},
          ],
        },
    ];

Map<String, Object?> _snapshot(FractalController controller) {
  final grid = controller.numberWallGrid;
  return {
    'module': controller.module.id,
    'params': Map<String, Object>.from(controller.params),
    'paramKinds': {
      for (final entry in controller.params.entries)
        entry.key: _kind(entry.value),
    },
    'view': {
      'zoom': controller.view.zoom,
      'pan': [controller.view.pan.x, controller.view.pan.y],
      'rotation': [
        controller.view.rotation.x,
        controller.view.rotation.y,
        controller.view.rotation.z
      ],
    },
    'transparentBackground': controller.transparentBackground,
    'pending': controller.numberWallPending,
    'status': controller.numberWallStatus?.name,
    'canUndo': controller.canUndoNumberWallRandomization,
    'grid': grid == null
        ? null
        : {
            'sequence': grid.sequence.name,
            'prime': grid.prime.toString(),
            'rows': grid.rowCount,
            'columns': grid.columnCount,
            'columnStart': grid.columnStart,
            'support': {'start': grid.support.start, 'end': grid.support.end},
            'cells': [
              for (final row in grid.values)
                [for (final cell in row) cell.toString()]
            ],
          },
  };
}

Future<void> _loadWall(FractalController controller, bool optIn) async {
  final module = controller.registry.byId('number_wall');
  final committed = await controller.loadState(
    module: module,
    params: {
      ...module.defaultPreset.params,
      'prime': '97',
      'rows': 4,
      'columns': 16,
      'columnStart': 3,
      'randomizeModulus': optIn
    },
    view: module.defaultPreset.view,
  );
  if (!committed) throw StateError('Oracle wall setup was rejected');
}

/// Explanatory replay, NOT instrumentation: Number Walls owns its own Random.
/// Every derived field is checked against the public controller result below.
Map<String, Object?> _wallDraws(
    FractalController controller, int seed, bool optIn) {
  final materialized = seed & 0x7fffffff;
  final random = RecordingRandom(materialized);
  final sources =
      controller.module.parameters.firstWhere((p) => p.id == 'source').options;
  final derived = <String, Object>{
    'randomSeed': materialized,
    'source': sources[random.nextInt(sources.length)].value,
    'colorScheme': random.nextInt(64),
    'backgroundColor': random.nextInt(0x404040),
    'foregroundColor': random.nextInt(0x1000000),
    'zeroColor': 0x808080 | random.nextInt(0x1000000),
    'prime': optIn
        ? const ['2', '3', '5', '7', '11', '13'][random.nextInt(6)]
        : '97',
  };
  for (final entry in derived.entries) {
    if (controller.params[entry.key] != entry.value) {
      throw StateError('Derived Number Walls draw mismatch: ${entry.key}');
    }
  }
  return {
    'provenance': 'separately-derived-pinned-Dart-call-sites',
    'draws': random.draws,
    'derivedParams': derived
  };
}

Future<List<Map<String, Object?>>> _generalScenarios() async {
  final scenarios = <Map<String, Object?>>[];
  for (final moduleId in ['mandelbrot', 'julia', 'synthetic']) {
    for (final seed in oracleSeeds) {
      final controller = FractalController(ModuleRegistry());
      try {
        final module = moduleId == 'synthetic'
            ? _synthetic(controller.module)
            : controller.registry.byId(moduleId);
        final params = {
          ...module.defaultPreset.params,
          'colorScheme': 17,
          'colorCycleSpeed': 0.625
        };
        await controller.loadState(
            module: module, params: params, view: module.defaultPreset.view);
        final before = _snapshot(controller);
        final random = RecordingRandom(seed);
        controller.randomizeParams(animate: false, random: random);
        scenarios.add({
          'id': '$moduleId/$seed',
          'input': {
            'module': module.id,
            'seed': seed,
            'animate': false,
            'params': params
          },
          'expected': {
            'before': before,
            'after': _snapshot(controller),
            'drawProvenance': 'injected-delegating-Random',
            'draws': random.draws
          },
        });
      } finally {
        controller.dispose();
      }
    }
  }
  return scenarios;
}

Future<List<Map<String, Object?>>> _wallScenarios() async {
  final scenarios = <Map<String, Object?>>[];
  for (final optIn in [false, true]) {
    // The extra opt-in seeds reach the other three certified quick-pick primes.
    for (final seed in [
      ...oracleSeeds,
      if (optIn) ...[3, 8, 19]
    ]) {
      final controller = FractalController(ModuleRegistry());
      try {
        await _loadWall(controller, optIn);
        final before = _snapshot(controller);
        final committed = await controller.randomizeNumberWall(seed: seed);
        if (!committed) throw StateError('Seeded randomization rejected');
        final randomized = _snapshot(controller);
        final transcript = _wallDraws(controller, seed, optIn);
        controller.updateView(controller.view.copyWith(
            zoom: 3.0,
            pan: Vector2(0.25, -0.5),
            rotation: Vector3(0.1, 0.2, 0.3)));
        controller.setTransparentBackground(true);
        final edited = _snapshot(controller);
        final undone = controller.undoNumberWallRandomization();
        final afterUndo = _snapshot(controller);
        final secondUndo = controller.undoNumberWallRandomization();
        scenarios.add({
          'id': 'number_wall/$optIn/$seed',
          'input': {
            'seed': seed,
            'randomizeModulus': optIn,
            'module': 'number_wall',
            'initialParams': before['params'],
            'actions': [
              'randomizeNumberWall',
              {'updateView': edited['view']},
              {'transparentBackground': true},
              'undoNumberWallRandomization',
              'undoNumberWallRandomization'
            ]
          },
          'expected': {
            'before': before,
            'committed': committed,
            'randomized': randomized,
            'explanatoryTranscript': transcript,
            'edited': edited,
            'undone': undone,
            'afterUndo': afterUndo,
            'secondUndo': secondUndo,
            'afterSecondUndo': _snapshot(controller)
          },
        });
      } finally {
        controller.dispose();
      }
    }
  }
  return scenarios;
}

Future<Map<String, Object?>> _unsuccessfulScenario() async {
  final controller = FractalController(ModuleRegistry());
  final events = <Map<String, Object?>>[];
  void record(String op, Object? result, [Map<String, Object?>? input]) =>
      events.add({
        'op': op,
        'input': input ?? {},
        'result': result,
        'state': _snapshot(controller)
      });
  try {
    await _loadWall(controller, false);
    record('setup', true);
    record('undoNumberWallRandomization',
        controller.undoNumberWallRandomization());
    record('randomizeNumberWall',
        await controller.randomizeNumberWall(seed: 42), {'seed': 42});
    final cancelled = controller.randomizeNumberWall(seed: 1);
    if (!controller.numberWallPending) {
      throw StateError('Cancel must intercept an actually pending request');
    }
    record('startRandomizeNumberWall', null, {'seed': 1});
    controller.cancelNumberWallRequest();
    record('cancelNumberWallRequest', null);
    record('awaitRandomizeNumberWall', await cancelled);
    record(
        'loadState',
        await controller.loadState(
            params: {...controller.params, 'prime': '561'},
            view: controller.view),
        {'prime': '561'});
    var owned = true;
    final guarded = controller.loadState(
        params: {...controller.params, 'source': 'squares'},
        view: controller.view,
        shouldCommit: () => owned);
    if (!controller.numberWallPending) {
      throw StateError('Ownership guard must intercept a pending request');
    }
    record('startGuardedLoadState', null, {'source': 'squares', 'owned': true});
    owned = false;
    record('revokeOwnership', null, {'owned': false});
    record('awaitGuardedLoadState', await guarded);
    record('undoNumberWallRandomization',
        controller.undoNumberWallRandomization());
    record('undoNumberWallRandomization',
        controller.undoNumberWallRandomization());
    record('randomizeNumberWall', await controller.randomizeNumberWall(seed: 0),
        {'seed': 0});
    final abandoned = controller.randomizeNumberWall(seed: -1);
    if (!controller.numberWallPending) {
      throw StateError('Navigation must intercept a pending request');
    }
    record('startRandomizeNumberWall', null, {'seed': -1});
    controller.selectModule(controller.registry.byId('mandelbrot'),
        animate: false);
    record('selectModule', null, {'module': 'mandelbrot', 'animate': false});
    record('awaitRandomizeNumberWall', await abandoned);
    record('randomizeNumberWall',
        await controller.randomizeNumberWall(seed: 42), {'seed': 42});
    record('undoNumberWallRandomization',
        controller.undoNumberWallRandomization());
    return {
      'id': 'number_wall/unsuccessful-requests',
      'input': {
        'prime': '97',
        'rows': 4,
        'columns': 16,
        'columnStart': 3,
        'randomizeModulus': false
      },
      'expected': events
    };
  } finally {
    controller.dispose();
  }
}

Map<String, String> _sourceBindings() {
  final sources = replaySourceBindings();
  for (final path in [
    'test/migration/support/randomization_oracle.dart',
    'test/migration/randomization_oracle_test.dart',
  ]) {
    sources[path] = sha256.convert(File(path).readAsBytesSync()).toString();
  }
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot == null) throw StateError('Select the pinned FLUTTER_ROOT');
  for (final path in [
    'lib/math/random.dart',
    'lib/_internal/vm/lib/math_patch.dart'
  ]) {
    sources['dart-sdk/$path'] = sha256
        .convert(
            File('$flutterRoot/bin/cache/dart-sdk/$path').readAsBytesSync())
        .toString();
  }
  return sources;
}

Future<Map<String, Object?>> buildRandomizationOracle() async {
  final registry = ModuleRegistry();
  return {
    'schema': 1,
    'kind': 'seeded-Dart-randomization',
    'runtime': {
      'dart': Platform.version.split(' ').first,
      'flutter': File('fdroid/flutter.version').readAsStringSync().trim(),
      'target': 'Dart VM (not browser RNG equivalence)'
    },
    'source_bindings': _sourceBindings(),
    'schemas': {
      for (final module in [
        registry.byId('mandelbrot'),
        registry.byId('julia'),
        _synthetic(registry.byId('mandelbrot')),
        registry.byId('number_wall')
      ])
        module.id: _schema(module),
    },
    'general': await _generalScenarios(),
    'numberWalls': await _wallScenarios(),
    'unsuccessful': await _unsuccessfulScenario(),
  };
}

/// Explicit scratch export only; promotion always requires a separate review.
void exportRandomizationOracle(Map<String, Object?> document) {
  if (randomizationOutput.isEmpty) return;
  final directory = Directory(randomizationOutput);
  if (!directory.isAbsolute) throw ArgumentError('Output must be absolute');
  directory.createSync(recursive: true);
  final resolved = directory.resolveSymbolicLinksSync();
  final root = Directory.current.resolveSymbolicLinksSync();
  if (resolved == root || resolved.startsWith('$root/')) {
    throw ArgumentError('Output must be outside the checkout');
  }
  if (directory.listSync().isNotEmpty) throw StateError('Output must be empty');
  File('$resolved/randomization.json')
      .writeAsStringSync(canonicalJson(document));
}
