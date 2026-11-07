import 'dart:convert';
import 'dart:io';

// Reuse the locked hashing dependency and inventory's deterministic JSON writer.
// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart' show sha256;
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/models/history/history_entry.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/renderer/cpu/formulas/cpu_formulas.dart';
import 'package:flutter_fractals/features/renderer/policy/precision_ladder_policy.dart';
import 'package:vector_math/vector_math_64.dart';

import 'baseline_inventory.dart' show canonicalJson;

export 'baseline_inventory.dart' show canonicalJson;

const replayOutput = String.fromEnvironment('MIGRATION_REPLAY_OUT');
const replayNames = ['state-replay', 'precision-replay'];
final _epoch = DateTime.utc(2026);

/// Tags are input operands only; snapshots use the production serializers.
Object? decodeReplayOperand(Object? value) {
  if (value is Map) {
    if (value.length == 1 && value.containsKey('nonfinite')) {
      return switch (value['nonfinite']) {
        'nan' => double.nan,
        '+infinity' => double.infinity,
        '-infinity' => double.negativeInfinity,
        _ => throw FormatException('Unknown nonfinite operand: $value'),
      };
    }
    return value.map(
        (key, value) => MapEntry(key as String, decodeReplayOperand(value)));
  }
  if (value is List) return value.map(decodeReplayOperand).toList();
  return value;
}

Map<String, Object> _params(Object? value) =>
    Map<String, Object>.from(value as Map? ?? {});

FractalViewState _view(Object? value) => HistoryEntry.fromJson({
      'id': 'replay',
      'moduleId': 'mandelbrot',
      'visitedAt': _epoch.toIso8601String(),
      'view': value ?? {},
    }).view;

HistoryEntry _history(FractalController controller) => HistoryEntry(
      id: 'replay',
      moduleId: controller.module.id,
      params: controller.params,
      view: controller.view,
      visitedAt: _epoch,
    );

Map<String, Object?> _snapshot(FractalController controller) => {
      'history': _history(controller).toJson(),
      'transparentBackground': controller.transparentBackground,
      'numberWall': {
        'pending': controller.numberWallPending,
        'status': controller.numberWallStatus?.name,
        'prime': controller.numberWallGrid?.prime.toString(),
        'firstCell': controller.numberWallGrid?.values.first.first.toString(),
      },
    };

/// Execute stored, ordered public API events. No timers, randomization or gestures.
Future<List<Map<String, Object?>>> replayState(List<dynamic> inputs) async {
  final controller = FractalController(ModuleRegistry());
  final saved = <String, Map<String, Object?>>{};
  final pending = <String, Future<bool>>{};
  final outputs = <Map<String, Object?>>[];
  try {
    for (final raw in inputs) {
      final event = decodeReplayOperand(raw) as Map;
      Object? result;
      Future<bool> load() => controller.loadState(
            moduleId: event['moduleId'] as String?,
            params: _params(event['params']),
            view: _view(event['view']),
            transparentBackground: event['transparentBackground'] == true,
          );
      switch (event['op']) {
        case 'snapshot':
          break;
        case 'zoom':
          controller.updateZoom((event['value'] as num).toDouble());
        case 'pan':
          final values = (event['value'] as List).cast<num>();
          controller
              .updatePan(Vector2(values[0].toDouble(), values[1].toDouble()));
        case 'rotation':
          final values = (event['value'] as List).cast<num>();
          controller.updateRotation(Vector3(values[0].toDouble(),
              values[1].toDouble(), values[2].toDouble()));
        case 'view':
          controller.updateView(_view(event['value']),
              adaptIterationsForZoom: event['adaptive'] == true);
        case 'param':
          controller.updateParam(
              event['id'] as String, event['value'] as Object);
        case 'module':
          controller.selectModule(
              controller.registry.byId(event['moduleId'] as String),
              animate: false,
              resetView: event['resetView'] == true);
        case 'transparent':
          controller.setTransparentBackground(event['value'] as bool);
        case 'preset':
          final preset = FractalPreset(
            id: 'replay',
            moduleId: event['moduleId'] as String? ?? controller.module.id,
            name: 'Replay',
            params: _params(event['params']),
            view: _view(event['view']),
            createdAt: _epoch,
          );
          // Only finite ingress is serialized; invalid camera operands stay tags.
          if (event['roundTrip'] == true) {
            final json =
                jsonDecode(jsonEncode(preset.toJson())) as Map<String, dynamic>;
            result = json;
            await controller.applyPreset(FractalPreset.fromJson(json));
          } else {
            await controller.applyPreset(preset);
          }
        case 'saveHistory':
          saved[event['key'] as String] =
              jsonDecode(jsonEncode(_history(controller).toJson()))
                  as Map<String, dynamic>;
          result = saved[event['key']];
        case 'restoreHistory':
          final entry = HistoryEntry.fromJson(saved[event['key']]!);
          result = await controller.loadState(
              moduleId: entry.moduleId, params: entry.params, view: entry.view);
        case 'load':
          result = await load();
        case 'startLoad':
          pending[event['key'] as String] = load();
        case 'awaitLoad':
          result = await pending.remove(event['key'])!;
        case 'prime':
          result =
              (await controller.applyNumberWallPrime(event['value'] as String))
                  .name;
        case 'resetParams':
          controller.resetParams();
        case 'resetView':
          controller.resetView();
        case 'resetSession':
          controller.resetSession();
        default:
          throw FormatException('Unknown state event: $event');
      }
      outputs.add({'result': result, ..._snapshot(controller)});
    }
    if (pending.isNotEmpty || controller.numberWallPending) {
      throw StateError('Replay must await actual candidate completion');
    }
    return outputs;
  } finally {
    controller.cancelNumberWallRequest();
    await Future.wait(pending.values);
    controller.dispose();
  }
}

Map<String, Object?> _decision(PrecisionLadderDecision decision) => {
      'renderPath': decision.renderPath.name,
      'tier': decision.tier.name,
      'exactness': decision.exactness.name,
      'cpuFallbackPending': decision.cpuFallbackPending,
    };

List<Map<String, Object?>> replayPrecision(List<dynamic> inputs) {
  const policy = PrecisionLadderPolicy();
  final hysteresis = PrecisionLadderHysteresis();
  return inputs.map((raw) {
    final event = decodeReplayOperand(raw) as Map;
    if (event['op'] == 'reset') {
      hysteresis.reset();
      return <String, Object?>{'reset': true};
    }
    final moduleId = event['moduleId'] as String;
    final dimension =
        FractalDimension.values.byName(event['dimension'] as String);
    final zoom = (event['zoom'] as num).toDouble();
    final power = (event['power'] as num? ?? 2).toDouble();
    final decision = event['op'] == 'decide'
        ? policy.decide(
            moduleId: moduleId,
            dimension: dimension,
            zoom: zoom,
            power: power,
            cpuFallbackActive: event['cpuFallbackActive'] as bool? ?? true)
        : event['op'] == 'update'
            ? hysteresis.update(
                moduleId: moduleId,
                dimension: dimension,
                zoom: zoom,
                power: power)
            : throw FormatException('Unknown precision event: $event');
    return <String, Object?>{
      ..._decision(decision),
      'nativeCpu': hasNativeCpuFormula(moduleId),
      'scaledGpuIterations': policy.scaledGpuIterations(
          baseIterations: event['baseIterations'] as int? ?? 200, zoom: zoom),
      if (event['op'] == 'update')
        'history': {
          'moduleId': hysteresis.state.moduleId,
          'aboveThresholdCount': hysteresis.state.aboveThresholdCount,
          'cpuActive': hysteresis.state.cpuActive,
        },
    };
  }).toList();
}

/// Bind the local semantic import graph, not a machine path or capture timestamp.
Map<String, String> replaySourceBindings() {
  final hashes = <String, String>{};
  void visit(String path) {
    if (hashes.containsKey(path)) return;
    final source = File(path).readAsStringSync();
    hashes[path] = sha256.convert(utf8.encode(source)).toString();
    for (final match in RegExp(
      r'''(?:import|export|part)\s+['"]([^'"]+)['"]''',
    ).allMatches(source.replaceAll(RegExp(r'/\*[\s\S]*?\*/|//[^\n]*'), ''))) {
      final uri = match[1]!;
      if (uri.startsWith('package:flutter_fractals/')) {
        visit(uri.replaceFirst('package:flutter_fractals/', 'lib/'));
      } else if (!uri.contains(':')) {
        visit(File.fromUri(File(path).uri.resolve(uri)).path);
      }
    }
  }

  for (final path in [
    'lib/core/controllers/fractal_controller.dart',
    'lib/core/models/history/history_entry.dart',
    'lib/features/renderer/policy/precision_ladder_policy.dart',
    'test/migration/support/replay_codec.dart',
    'test/migration/state_replay_test.dart',
    'pubspec.lock',
    'fdroid/flutter.version',
  ]) {
    visit(path);
  }
  return hashes;
}

/// Recording is explicit and scratch-only. Tests never overwrite baselines.
void exportReplays(Map<String, Map<String, Object?>> documents) {
  if (replayOutput.isEmpty) return;
  final directory = Directory(replayOutput);
  final root = Directory.current.resolveSymbolicLinksSync();
  if (!directory.isAbsolute)
    throw ArgumentError('Replay output must be absolute');
  directory.createSync(recursive: true);
  final resolved = directory.resolveSymbolicLinksSync();
  if (resolved == root || resolved.startsWith('$root/')) {
    throw ArgumentError('Replay output must be outside the checkout');
  }
  if (directory.listSync().isNotEmpty)
    throw StateError('Replay output must be empty');
  for (final entry in documents.entries) {
    File('$resolved/${entry.key}.json')
        .writeAsStringSync(canonicalJson(entry.value));
  }
}
