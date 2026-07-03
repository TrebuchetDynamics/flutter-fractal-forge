import 'dart:convert';
import 'dart:io';

import 'package:flutter_fractals/core/modules/builders/shared_catalogs/shared_legalize_fotd_catalog.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const shader =
      'shaders/escape_time_family/experimental_named/polynomial_variants/legalize_fotd_muth_gpu.frag';

  test('Legalize/XMission shared formulas are registered', () {
    final registry = ModuleRegistry();
    final pubspec = File('pubspec.yaml').readAsStringSync();

    for (final entry in sharedLegalizeFotdCatalogEntries) {
      final module = registry.byId(entry.id);
      expect(module.dimension, FractalDimension.twoD);
      expect(module.shaderAsset, shader);
      expect(File(module.shaderAsset).existsSync(), isTrue);
      expect(module.parameters.map((p) => p.id), contains('variant'));
    }

    expect(pubspec, contains('- $shader'));
  });

  test(
      'scraped Legalize/XMission manifests prove imported formulas are source-backed',
      () {
    final fotdManifest = jsonDecode(
      File('research/legalize-fractals/fotd-parameter-manifest.json')
          .readAsStringSync(),
    ) as Map<String, Object?>;
    final mainManifest = jsonDecode(
      File('research/legalize-fractals/main-site-parameter-manifest.json')
          .readAsStringSync(),
    ) as Map<String, Object?>;
    final crawlManifest = jsonDecode(
      File('research/legalize-fractals/main-site-crawl-manifest.json')
          .readAsStringSync(),
    ) as Map<String, Object?>;

    expect(fotdManifest['parameter_file_count'], 5098);
    expect(mainManifest['parsed_entry_count'],
        mainManifest['parameter_file_count']);
    expect(mainManifest['errors'], isEmpty);

    final fotdFormulaCounts =
        fotdManifest['formula_counts']! as Map<String, Object?>;
    final mainFormulaCounts =
        mainManifest['formula_counts']! as Map<String, Object?>;
    final fotdTypeCounts = fotdManifest['type_counts']! as Map<String, Object?>;
    final mainTypeCounts = mainManifest['type_counts']! as Map<String, Object?>;
    final sourceEntryNames = <String>{
      ..._entryIdentityNames(fotdManifest),
      ..._entryIdentityNames(mainManifest),
      ..._unmatchedImageIdentityNames(crawlManifest),
    };

    final represented = <String>{};
    for (final entry in sharedLegalizeFotdCatalogEntries) {
      final formula =
          entry.name.replaceFirst('FOTD ', '').replaceFirst('Legalize ', '');
      represented.add(formula);
      final sourceCount = (fotdFormulaCounts[formula] as num? ?? 0) +
          (mainFormulaCounts[formula] as num? ?? 0) +
          (fotdTypeCounts[formula] as num? ?? 0) +
          (mainTypeCounts[formula] as num? ?? 0) +
          (sourceEntryNames.contains(formula) ? 1 : 0);
      expect(sourceCount > 0, isTrue,
          reason:
              '$formula should be present in a scraped Legalize/XMission manifest');
    }

    final requiredSourceNames = <String>{
      ...fotdFormulaCounts.keys,
      ...mainFormulaCounts.keys,
      ...fotdTypeCounts.keys.where((type) => type != 'formula'),
      ...mainTypeCounts.keys.where((type) => type != 'formula'),
      ...sourceEntryNames,
    };
    expect(represented, containsAll(requiredSourceNames),
        reason:
            'Every scraped Legalize/XMission formula or non-formula Fractint type should have a catalog entry.');
  });
}

Set<String> _entryIdentityNames(Map<String, Object?> manifest) {
  final entries = manifest['entries']! as List<Object?>;
  return entries.map((raw) {
    final entry = raw! as Map<String, Object?>;
    final formula = entry['formulaname'] as String? ?? '';
    if (formula.isNotEmpty) {
      return formula;
    }
    final type = entry['type'] as String? ?? '';
    if (type.isNotEmpty && type != 'formula') {
      return type;
    }
    return entry['name']! as String;
  }).toSet();
}

Set<String> _unmatchedImageIdentityNames(Map<String, Object?> crawlManifest) {
  final parameterFiles = crawlManifest['parameter_files']! as List<Object?>;
  final parStems = parameterFiles.map((raw) {
    final basename = (raw! as String).split('/').last.toLowerCase();
    return basename
        .replaceFirst(RegExp(r'_gif\.par$'), '')
        .replaceFirst(RegExp(r'\.par$'), '');
  }).toSet();

  final imageLinks = crawlManifest['image_links']! as List<Object?>;
  return imageLinks.map((raw) => raw! as String).where((url) {
    final basename = url.split('/').last.toLowerCase();
    final stem = basename
        .replaceFirst(RegExp(r'\.(jpg|jpeg|png|gif)$'), '')
        .replaceFirst(RegExp(r'\.thumb$'), '');
    return !parStems.contains(stem) &&
        !parStems.contains(stem.replaceAll('_gif', ''));
  }).map((url) {
    return url
        .split('/')
        .last
        .replaceFirst(
            RegExp(r'\.(jpg|jpeg|png|gif)$', caseSensitive: false), '')
        .replaceFirst(RegExp(r'\.thumb$', caseSensitive: false), '');
  }).toSet();
}
