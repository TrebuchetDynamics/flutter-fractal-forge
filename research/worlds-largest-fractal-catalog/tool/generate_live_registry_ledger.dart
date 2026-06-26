import 'dart:convert';
import 'dart:io';

import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/catalog/catalog_repository.dart';
import 'package:flutter_fractals/features/catalog/catalog_thumbnail_plan.dart';

const outputPath =
    'research/worlds-largest-fractal-catalog/curated-entry-ledger.live-registry.json';
const thumbnailWorklistPath =
    'research/worlds-largest-fractal-catalog/thumbnail-worklist.live-registry.json';
const thumbnailBatchSize = 25;

const categoryToTargetFamily = {
  'Escape-Time': 'escape_time_polynomial_complex',
  'Escape-Time (Complex Plane)': 'escape_time_polynomial_complex',
  'Convergent/Root-Finding': 'root_finding_polynomiography',
  'Convergent & Root-Finding': 'root_finding_polynomiography',
  'Strange Attractors': 'strange_attractors_maps',
  'IFS & Geometric Construction': 'ifs_geometric',
  'IFS / Geometric Fractals': 'ifs_geometric',
  'Kaleidoscopes': 'ifs_geometric',
  'L-Systems & Space-Filling Curves': 'l_systems_plants_curves',
  '3D Raymarching & Hypercomplex': 'distance_estimated_3d_raymarch',
  '3D Fractals': 'distance_estimated_3d_raymarch',
  'Trigonometric & Transcendental': 'rational_transcendental_maps',
  'Advanced Rational & Polynomial': 'rational_transcendental_maps',
  'Lyapunov & Stability': 'number_theory_special_functions',
  'Deep Chaos & Flows': 'strange_attractors_maps',
  'High-Dimensional Algebra': 'number_theory_special_functions',
  'Tiling & Graph Fractals': 'tilings_substitution_graphs',
  'Cellular & Stochastic': 'cellular_automata',
  'Cellular & Stochastic Growth': 'cellular_automata',
  'Number-Theory Fractals': 'number_theory_special_functions',
  'Other': 'escape_time_polynomial_complex',
};

const categoryToIdentityType = {
  'IFS & Geometric Construction': 'transform_system',
  'IFS / Geometric Fractals': 'transform_system',
  'Kaleidoscopes': 'transform_system',
  'L-Systems & Space-Filling Curves': 'grammar',
  'Tiling & Graph Fractals': 'rule',
  'Cellular & Stochastic': 'rule',
  'Cellular & Stochastic Growth': 'rule',
  'Strange Attractors': 'map',
  'Deep Chaos & Flows': 'map',
  'Lyapunov & Stability': 'map',
};

bool isDiagnosticModule(String id, String shaderAsset) {
  return id.startsWith('test_') ||
      id == 'gpu_gradient' ||
      id == 'gpu_sampler_diag' ||
      shaderAsset.startsWith('shaders/diagnostic/');
}

String identityTypeFor(String category) {
  return categoryToIdentityType[category] ?? 'named_stable_variant';
}

Map<String, String> parameterSchema(Iterable<dynamic> parameters) {
  return {
    for (final parameter in parameters)
      parameter.id as String: parameter.type.toString().split('.').last,
  };
}

Map<String, Object> buildLiveRegistryLedger() {
  final registry = ModuleRegistry();
  final catalog = CatalogRepository.fromRegistry(registry);
  final entries = <Map<String, Object>>[];
  final missingThumbnails = <Map<String, Object>>[];
  var skippedMissingThumbnail = 0;
  var skippedDiagnostic = 0;
  var skippedUnknownFamily = 0;
  final unknownFamilies = <Map<String, Object>>[];

  for (final entry in catalog.entries) {
    final module = entry.module;
    if (isDiagnosticModule(module.id, module.shaderAsset)) {
      skippedDiagnostic++;
      continue;
    }
    final thumbnail =
        CatalogThumbnailPlan.fromCatalogId(entry.catalogId).assetPath;
    if (!File(module.shaderAsset).existsSync()) {
      throw StateError(
          'Live registry shader missing for ${module.id}: ${module.shaderAsset}');
    }
    if (!File(thumbnail).existsSync()) {
      skippedMissingThumbnail++;
      missingThumbnails.add({
        'moduleId': module.id,
        'catalogId': entry.catalogId,
        'category': entry.category,
        'shaderAsset': module.shaderAsset,
        'thumbnailAsset': thumbnail,
      });
      continue;
    }
    final targetFamily = categoryToTargetFamily[entry.category];
    if (targetFamily == null) {
      skippedUnknownFamily++;
      unknownFamilies.add({
        'moduleId': module.id,
        'catalogId': entry.catalogId,
        'category': entry.category,
        'shaderAsset': module.shaderAsset,
        'thumbnailAsset': thumbnail,
      });
      continue;
    }

    entries.add({
      'stable_id': module.id,
      'display_name': module.id.replaceAll('_', ' '),
      'family': targetFamily,
      'mathematical_identity_type': identityTypeFor(entry.category),
      'formula_or_rule':
          'Live app FractalModule identity: ${module.id}; catalog category: ${entry.category}; shader asset: ${module.shaderAsset}. Counts the module formula/rule identity only, not presets, palettes, or camera views.',
      'renderer_path': module.shaderAsset,
      'parameter_schema': parameterSchema(module.parameters),
      'provenance': {
        'source_type': 'live_module_registry',
        'source': 'lib/core/modules/module_registry.dart',
        'reuse_decision':
            'local app module identity; count only the stable module formula/rule identity, not built-in presets or random seeds',
      },
      'license_context':
          'local app module and shader artifact; no upstream source copied by this ledger',
      'thumbnail_plan': thumbnail,
      'validation': {
        'status': 'validated',
        'signals': [
          'ModuleRegistry entry exists',
          'CatalogRepository entry exists',
          'shader asset exists',
          'thumbnail asset exists',
          'presets ignored for counted-entry total',
        ],
      },
      'accessibility_label': '${module.id.replaceAll('_', ' ')} fractal',
      'counted_entry': true,
      'ingest_status': 'promoted',
      'notes':
          'Generated from live registry. Formula detail should be enriched before educational copy, but this is a renderable stable module identity.',
    });
  }

  return {
    'generated_at': DateTime.now().toUtc().toIso8601String(),
    'purpose':
        'Promoted ledger from live production ModuleRegistry entries that have shader and thumbnail assets.',
    'counting_rule':
        'Counts stable live module formula/rule identities only; built-in presets, random seeds, palettes, and camera views are ignored.',
    'skipped': {
      'diagnostic': skippedDiagnostic,
      'missingThumbnail': skippedMissingThumbnail,
      'unknownFamily': skippedUnknownFamily,
    },
    'missingThumbnails': missingThumbnails,
    'unknownFamilies': unknownFamilies,
    'entries': entries,
  };
}

List<Map<String, Object>> thumbnailBatches(List<Map<String, Object>> missing) {
  final batches = <Map<String, Object>>[];
  for (var offset = 0; offset < missing.length; offset += thumbnailBatchSize) {
    final chunk = missing.skip(offset).take(thumbnailBatchSize).toList();
    final ids = chunk.map((item) => item['moduleId']! as String).toList();
    batches.add({
      'offset': offset,
      'limit': chunk.length,
      'moduleIds': ids,
      'command':
          'CATALOG_THUMB_ONLY=${ids.join(',')} flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux',
    });
  }
  return batches;
}

void writeLiveRegistryLedger(Map<String, Object> ledger) {
  const encoder = JsonEncoder.withIndent('  ');
  File(outputPath).writeAsStringSync('${encoder.convert(ledger)}\n');
  final missing =
      (ledger['missingThumbnails']! as List).cast<Map<String, Object>>();
  final worklist = {
    'generated_at': ledger['generated_at'],
    'purpose':
        'Live registry modules that are shader-backed but cannot be promoted because bundled thumbnails are missing.',
    'thumbnailStandard': 'Launch Thumbnail Standard: 320x320 bundled assets',
    'missingCount': missing.length,
    'batchSize': thumbnailBatchSize,
    'batches': thumbnailBatches(missing),
    'missingThumbnails': missing,
  };
  File(thumbnailWorklistPath)
      .writeAsStringSync('${encoder.convert(worklist)}\n');
}

void main() {
  final ledger = buildLiveRegistryLedger();
  writeLiveRegistryLedger(ledger);
  final skipped = ledger['skipped']! as Map<String, Object>;
  const encoder = JsonEncoder.withIndent('  ');
  print(encoder.convert({
    'wrote': outputPath,
    'thumbnailWorklist': thumbnailWorklistPath,
    'entries': (ledger['entries']! as List).length,
    'skippedDiagnostic': skipped['diagnostic'],
    'skippedMissingThumbnail': skipped['missingThumbnail'],
    'skippedUnknownFamily': skipped['unknownFamily'],
  }));
}
