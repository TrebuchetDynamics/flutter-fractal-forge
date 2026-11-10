import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_fractals/core/modules/escape_time_perturb_module.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/renderer/cpu/formulas/cpu_formulas.dart';
import 'package:flutter_fractals/features/renderer/policy/precision_ladder_policy.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/replay_codec.dart';

const _output = String.fromEnvironment('RUST_PRECISION_OUT');
const _seed = 0x50726563;
const _seededCases = 1024;

// Adjacent binary64 values, not decimal epsilon approximations to power == 2.
double _neighbor(double value, int delta) {
  final bytes = ByteData(8)..setFloat64(0, value);
  bytes.setUint64(0, bytes.getUint64(0) + delta);
  return bytes.getFloat64(0);
}

List<dynamic> _inputs(List<dynamic> recorded, List<String> ids) {
  final inputs = <dynamic>[...recorded];
  void add(String label, String id, Object zoom, {Object power = 2}) {
    inputs.add({
      'label': label,
      'op': 'decide',
      'moduleId': id,
      'dimension': 'twoD',
      'zoom': zoom,
      'power': power,
    });
  }

  for (final power in [
    _neighbor(2, -1),
    2,
    _neighbor(2, 1),
    3,
    {'nonfinite': 'nan'},
    {'nonfinite': '+infinity'},
    {'nonfinite': '-infinity'},
  ]) {
    add('Burning Ship exact quadratic restriction $power', 'burning_ship', 1e20,
        power: power);
  }
  for (final id in ['mandelbrot', 'julia', 'celtic', 'phoenix']) {
    add('policy zoom is not camera-clipped: $id', id, 1e20);
  }

  final random = math.Random(_seed);
  final specialZooms = <Object>[
    {'nonfinite': 'nan'},
    {'nonfinite': '+infinity'},
    {'nonfinite': '-infinity'},
    -1,
    0,
    1,
    1e5,
    5e6,
    1e7,
    1e9,
    1e12,
    1e20,
    1e30,
  ];
  for (var i = 0; i < _seededCases; i++) {
    if (i % 64 == 0) {
      inputs.add({'op': 'reset', 'label': 'seeded reset $i'});
    }
    inputs.add({
      'label': 'seeded $i',
      'op': random.nextBool() ? 'decide' : 'update',
      'moduleId': ids[random.nextInt(ids.length)],
      'dimension': random.nextInt(4) == 0 ? 'threeD' : 'twoD',
      'zoom': i.isEven
          ? specialZooms[random.nextInt(specialZooms.length)]
          : math.pow(10, random.nextDouble() * 44 - 4),
      'power': [2, 3, _neighbor(2, 1)][random.nextInt(3)],
      'cpuFallbackActive': random.nextBool(),
      'baseIterations': random.nextInt(2401) - 200,
    });
  }
  return inputs;
}

List<Object?> _helpers(
    List<dynamic> inputs, List<Map<String, Object?>> results) {
  const policy = PrecisionLadderPolicy();
  return List.generate(inputs.length, (i) {
    final event = decodeReplayOperand(inputs[i]) as Map;
    if (event['op'] == 'reset') return null;
    final decision = policy.decide(
      moduleId: event['moduleId'] as String,
      dimension: FractalDimension.values.byName(event['dimension'] as String),
      zoom: (event['zoom'] as num).toDouble(),
      power: (event['power'] as num? ?? 2).toDouble(),
      cpuFallbackActive: event['op'] == 'update'
          ? (results[i]['history'] as Map)['cpuActive'] as bool
          : event['cpuFallbackActive'] as bool? ?? true,
    );
    return {
      'usesCpuRenderer': decision.usesCpuRenderer,
      'usesDoubleFloatGpu': decision.usesDoubleFloatGpu,
      'usesPerturbationGpu': decision.usesPerturbationGpu,
      'usesExtendedGpu': decision.usesExtendedGpu,
      'showPrecisionIndicator': decision.showPrecisionIndicator,
      'statusLabel': decision.statusLabel,
      'debugRendererLabel': decision.debugRendererLabel,
    };
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('source-bound precision stream is deterministic and exports only opt-in',
      () {
    final frozen = File('migration/baseline/precision-replay.json');
    final before = frozen.readAsStringSync();
    final recorded = (jsonDecode(before) as Map)['inputs'] as List;
    final ids = <String>{
      ...ModuleRegistry().modules.map((module) => module.id),
      'unknown-replay-module',
    }.toList()
      ..sort();
    final inputs = _inputs(recorded, ids);
    final expected = replayPrecision(inputs);
    expect(inputs.length, greaterThanOrEqualTo(recorded.length + 1024));
    expect(replayPrecision(_inputs(recorded, ids)), expected);
    expect(inputs.take(recorded.length).toList(), recorded,
        reason: 'Preserve the complete original ordered stream');
    const policy = PrecisionLadderPolicy();
    final document = {
      'schema': 1,
      'kind': 'precision-parity',
      'seed': _seed,
      'seededCases': _seededCases,
      'source_bindings': replaySourceBindings(),
      'capabilities': {
        for (final id in ids)
          id: {
            'nativeCpu': hasNativeCpuFormula(id),
            'perturbation': kJuliaVariantSpecs.containsKey(id) ||
                kPerturbableEscapeTimeIds.contains(id),
          },
      },
      'gpuCeilings': {
        for (final id in ids) id: policy.gpuRenderableCeilingZoom(id),
      },
      'inputs': inputs,
      'expected': expected,
      'helpers': _helpers(inputs, expected),
    };
    final encoded = canonicalJson(document);
    expect(jsonDecode(encoded), document);
    expect(frozen.readAsStringSync(), before);
    if (_output.isEmpty) return;
    final file = File(_output);
    if (!file.isAbsolute) throw ArgumentError('Output must be absolute');
    file.parent.createSync(recursive: true);
    final parent = file.parent.resolveSymbolicLinksSync();
    final root = Directory.current.resolveSymbolicLinksSync();
    if (parent == root || parent.startsWith('$root/')) {
      throw ArgumentError('Output must be outside the checkout');
    }
    // Exclusive create also rejects existing symlinks; never promote a fixture.
    file.createSync(exclusive: true);
    file.writeAsStringSync(encoded);
  });
}
