import 'dart:convert';
import 'dart:io';

// Reuse the locked test hashing dependency, as in iteration_buffer_golden_test.
// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart' show sha256;
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/modules/builders/uniform_layout.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_repository.dart';
import 'package:flutter_fractals/features/renderer/cpu/formulas/cpu_formulas.dart';
import 'package:flutter_fractals/features/renderer/policy/precision_ladder_policy.dart';
import 'package:flutter_fractals/features/renderer/policy/render_plan.dart';
import 'package:yaml/yaml.dart';
import 'package:flutter_fractals/l10n/app_localizations_en.dart';

const baselineOutput = String.fromEnvironment('MIGRATION_BASELINE_OUT');
const baselineNames = [
  'modules',
  'parameters',
  'presets',
  'capabilities',
  'shader-contracts',
];

/// Sort object keys, not arrays: array order and explicit order fields are data.
String canonicalJson(Object? value) {
  Object? sorted(Object? value) {
    if (value is Map) {
      final keys = value.keys.cast<String>().toList()..sort();
      return {for (final key in keys) key: sorted(value[key])};
    }
    if (value is Iterable) return value.map(sorted).toList();
    return value;
  }

  return '${const JsonEncoder.withIndent('  ').convert(sorted(value))}\n';
}

String _hash(List<int> bytes) => sha256.convert(bytes).toString();

/// JSON-compatible records only. No renderer, storage service or shader executes.
Map<String, Map<String, Object?>> buildBaselineInventory({
  List<FractalModule>? modules,
  CatalogRepository? repository,
  String Function(String path)? readSource,
}) {
  final registry = ModuleRegistry();
  modules ??= registry.modules;
  repository ??= CatalogRepository.fromRegistry(registry);
  readSource ??= (path) => File(path).readAsStringSync();
  final catalog = repository.entries;
  final exploreIds = repository.exploreEntries.map((e) => e.catalogId).toSet();
  final registryOrder = {
    for (var i = 0; i < modules.length; i++) modules[i].id: i
  };
  final allModules = {for (final module in modules) module.id: module};
  for (final entry in catalog) {
    allModules.putIfAbsent(entry.module.id, () => entry.module);
  }
  final ids = allModules.keys.toList()..sort();
  final records = <String, List<Object?>>{
    for (final name in baselineNames) name: [],
  };
  final l10n = AppLocalizationsEn();
  const precision = PrecisionLadderPolicy();
  for (final id in ids) {
    final module = allModules[id]!;
    final entries = catalog.where((e) => e.module.id == id).toList();
    records['modules']!.add({
      'id': id,
      'registry_order': registryOrder[id],
      'display_name_en': module.displayName(l10n),
      'dimension': module.dimension.name,
      'shader_asset': module.shaderAsset,
      'horizontal_orbit_sign': module.horizontalOrbitSign,
      'animation': module.animationCapability.name,
      'hides_effect_controls': module.hidesEffectControls,
      'diagnostic': module.shaderAsset.startsWith('shaders/diagnostic/'),
      'catalog': [
        for (final entry in entries)
          {
            'id': entry.catalogId,
            'order': catalog.indexOf(entry),
            'family': entry.family.name,
            'category': entry.category,
            'aliases': entry.aliases,
            'hidden_from_explore': !exploreIds.contains(entry.catalogId),
          }
      ],
    });
    records['parameters']!.add({
      'module_id': id,
      'parameters': [
        for (var i = 0; i < module.parameters.length; i++)
          {
            'id': module.parameters[i].id,
            'order': i,
            'label_en': module.parameters[i].label(l10n),
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
                  'value': option.value,
                  'label_en': option.label(l10n),
                }
            ],
          }
      ],
    });
    records['presets']!.add({
      'module_id': id,
      'default': _preset(module.defaultPreset),
      'built_in': [
        for (var i = 0; i < module.builtInPresets.length; i++)
          {
            'order': i,
            ..._preset(module.builtInPresets[i]),
          }
      ],
    });
    final math = entries.isEmpty ? null : entries.first.mathematics;
    final power = module.defaultPreset.params['power'];
    records['capabilities']!.add({
      'module_id': id,
      'native_cpu': hasNativeCpuFormula(id),
      'curated_cpu': hasCuratedCpuFormula(id),
      'gpu_ceiling_zoom': precision.gpuRenderableCeilingZoom(id),
      // Samples describe current policy, not mathematical certification or a
      // promise that a dimension/parameter variant has an executable backend.
      'precision_default_power': power is num ? power : 2,
      'precision_samples': [
        for (final zoom in [1.0, 1e5, 5e6, 1e7, 1e9, 1e12, 1e30])
          _precisionRecord(
              module,
              precision.decide(
                moduleId: id,
                dimension: module.dimension,
                zoom: zoom,
                power: power is num ? power.toDouble() : 2,
              )),
      ],
      'mathematics': math == null
          ? null
          : {
              'family': math.family,
              'algebra': math.algebra,
              'view': math.view,
              'method': math.method,
              'qualification': math.qualification,
              'group_id': math.groupId,
              'relationship': math.relationship,
              'default_formula': math.formula(module.defaultPreset.params),
            },
    });
  }

  final pubspec = loadYaml(readSource('pubspec.yaml')) as YamlMap;
  final assets = <String>{
    ...(pubspec['flutter']['shaders'] as YamlList).cast<String>(),
    for (final module in allModules.values) module.shaderAsset,
  }.toList()
    ..sort();
  final shaderHashes = <String, String>{};
  final sdk = _flutterRoot();
  String shaderSource(String path) {
    final source = path.startsWith('flutter/')
        ? File('$sdk/engine/src/flutter/impeller/compiler/shader_lib/$path')
            .readAsStringSync()
        : readSource!(path);
    shaderHashes[path] = _hash(utf8.encode(source));
    return source;
  }

  for (final asset in assets) {
    final contract = shaderDeclarations(asset, shaderSource);
    records['shader-contracts']!.add({
      'asset': asset,
      'declared_in_pubspec':
          (pubspec['flutter']['shaders'] as YamlList).contains(asset),
      'module_ids':
          ids.where((id) => allModules[id]!.shaderAsset == asset).toList(),
      ...contract,
      'dart_setter_abi': {
        'status': 'unresolved',
        'source_path': 'lib/core/modules/module_registry.dart',
        'shader_source_path': asset,
        'reason':
            'Opaque UniformSetter closures are not introspected; declarations do not certify setter compatibility or a wgpu ABI.',
      },
    });
  }
  final layoutPath = 'lib/core/modules/builders/uniform_layout.dart';
  final layout = readSource(layoutPath);
  final families = <String, Object?>{};
  for (final match in RegExp(
    r'abstract final class (\w+UniformSlots)\s*\{([^}]+)\}',
  ).allMatches(layout)) {
    families[match[1]!] = {
      for (final slot
          in RegExp(r'static const int (\w+) = (\d+);').allMatches(match[2]!))
        slot[1]!: int.parse(slot[2]!),
    };
  }
  // Read the real constants too, so unsupported source parsing fails closed.
  if ((families['EscapeTimeUniformSlots'] as Map)['extraStart'] !=
          EscapeTimeUniformSlots.extraStart ||
      (families['Raymarched3DUniformSlots'] as Map)['extraStart'] !=
          Raymarched3DUniformSlots.extraStart) {
    throw StateError('Unresolved uniform family constants: $layoutPath');
  }
  final sources = _sourceHashes(readSource)..addAll(shaderHashes);
  final provenance = {
    'hash_algorithm': 'sha256',
    'sources': sources,
    'source_set_sha256': _hash(utf8.encode(canonicalJson(sources))),
    'flutter_version': File('fdroid/flutter.version').readAsStringSync().trim(),
    'registry_mode': 'Flutter test/debug (includes diagnostics)',
  };
  return {
    for (final name in baselineNames)
      name: {
        'schema': 1,
        'kind': name,
        'payload': {
          'records': records[name],
          if (name == 'shader-contracts') 'family_float_slots': families,
        },
        'provenance': provenance,
      }
  };
}

Map<String, Object?> _preset(FractalPreset preset) {
  final json = preset.toJson();
  // Builders use DateTime.now(); it is not built-in preset semantics.
  json.remove('createdAt');
  return json;
}

Map<String, Object?> _precisionRecord(
        FractalModule module, PrecisionLadderDecision decision) =>
    {
      'zoom': decision.zoom,
      'path': decision.renderPath.name,
      'shader_asset': decision.usesCpuRenderer
          ? null
          : RendererPlanModuleResolver()
              .resolve(
                plan: RendererPlan.gpu(decision),
                module: module,
              )
              .shaderAsset,
      'tier': decision.tier.name,
      'exactness': decision.exactness.name,
      'cpu_fallback_pending': decision.cpuFallbackPending,
    };

/// A conservative declaration reader, not a GLSL compiler. Unsupported syntax
/// retains its source path and prevents any claim of a resolved slot layout.
Map<String, Object?> shaderDeclarations(
  String asset,
  String Function(String) readSource,
) {
  final floats = <Object?>[];
  final samplers = <Object?>[];
  final includes = <String>[];
  final unresolved = <String>[];
  var floatSlot = 0;
  var sampler = 0;
  final stack = <String>{};
  String expand(String path) {
    if (!stack.add(path)) {
      unresolved.add('$path: cyclic include');
      return '';
    }
    String source;
    try {
      source = readSource(path);
    } on FileSystemException {
      unresolved.add('$path: missing source');
      stack.remove(path);
      return '';
    }
    source = source.replaceAll(RegExp(r'/\*[\s\S]*?\*/|//[^\n]*'), '');
    if (!path.startsWith('flutter/') &&
        RegExp(r'^\s*#\s*(if|ifdef|ifndef|define)\b', multiLine: true)
            .hasMatch(source)) {
      unresolved.add('$path: preprocessor requires compiler introspection');
    }
    source = source.replaceAllMapped(
      RegExp(r'^\s*#include\s+[<"]([^>"]+)[>"]', multiLine: true),
      (match) {
        final target = match[1]!;
        final resolved = target.startsWith('flutter/')
            ? target
            : File.fromUri(File(path).uri.resolve(target)).path;
        includes.add(resolved);
        return expand(resolved);
      },
    );
    stack.remove(path);
    return source;
  }

  final source = expand(asset);
  const widths = {'float': 1, 'vec2': 2, 'vec3': 3, 'vec4': 4};
  for (final match in RegExp(r'\buniform\s+([^;]+);').allMatches(source)) {
    final declaration = match[1]!.trim();
    final parts = RegExp(r'^(\w+)\s+(\w+)$').firstMatch(declaration);
    if (parts == null) {
      unresolved.add('$asset: unsupported uniform $declaration');
      continue;
    }
    final type = parts[1]!;
    final name = parts[2]!;
    if (type == 'sampler2D') {
      samplers.add(
          <String, Object?>{'name': name, 'type': type, 'binding': sampler++});
    } else if (widths.containsKey(type)) {
      floats.add({
        'name': name,
        'type': type,
        'slot': floatSlot,
        'width': widths[type]
      });
      floatSlot += widths[type]!;
    } else {
      unresolved.add('$asset: unsupported uniform type $type');
    }
  }
  // Backend guards in Flutter's builtin contain no uniform declarations.
  // shortcut: unsupported declarations need a compiler-backed reader.
  if (unresolved.isNotEmpty) {
    for (final record in floats.cast<Map<String, Object?>>()) {
      record['slot'] = null;
    }
    for (final record in samplers.cast<Map<String, Object?>>()) {
      record['binding'] = null;
    }
  }
  return {
    'status': unresolved.isEmpty ? 'declarations_resolved' : 'unresolved',
    'includes': includes,
    'float_slots': floats,
    'float_slot_count': unresolved.isEmpty ? floatSlot : null,
    'samplers': samplers,
    'sampler_count': unresolved.isEmpty ? sampler : null,
    'unresolved': unresolved,
  };
}

Map<String, String> _sourceHashes(String Function(String) readSource) {
  final hashes = <String, String>{};
  void visit(String path) {
    if (hashes.containsKey(path)) return;
    final source = readSource(path);
    hashes[path] = _hash(utf8.encode(source));
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
    'lib/core/modules/module_registry.dart',
    'lib/features/catalog/data/catalog_repository.dart',
    'lib/features/renderer/cpu/formulas/cpu_formulas.dart',
    'lib/features/renderer/policy/precision_ladder_policy.dart',
    'lib/core/modules/builders/uniform_layout.dart',
    'test/migration/support/baseline_inventory.dart',
    'pubspec.yaml',
    'pubspec.lock',
    'fdroid/flutter.version',
  ]) {
    visit(path);
  }
  return hashes;
}

String _flutterRoot() {
  final configured = Platform.environment['FLUTTER_ROOT'];
  if (configured != null) return configured;
  var parent = File(Platform.resolvedExecutable).parent;
  while (parent.path != parent.parent.path) {
    if (File('${parent.path}/bin/flutter').existsSync()) return parent.path;
    parent = parent.parent;
  }
  throw StateError('Cannot resolve Flutter SDK; set FLUTTER_ROOT');
}

/// Explicit scratch export only; fixture promotion is a separate reviewed copy.
void exportBaseline(Map<String, Map<String, Object?>> inventory) {
  if (baselineOutput.isEmpty) return;
  final directory = Directory(baselineOutput);
  final root = Directory.current.resolveSymbolicLinksSync();
  if (!directory.isAbsolute ||
      directory.absolute.path == root ||
      directory.absolute.path.startsWith('$root/')) {
    throw ArgumentError(
        'MIGRATION_BASELINE_OUT must be an absolute scratch path outside the checkout');
  }
  directory.createSync(recursive: true);
  final resolved = directory.resolveSymbolicLinksSync();
  if (resolved == root || resolved.startsWith('$root/')) {
    throw ArgumentError('MIGRATION_BASELINE_OUT resolves inside the checkout');
  }
  if (directory.listSync().isNotEmpty) {
    throw StateError('MIGRATION_BASELINE_OUT must be empty');
  }
  for (final name in baselineNames) {
    File('${directory.path}/$name.json')
        .writeAsStringSync(canonicalJson(inventory[name]));
  }
}
