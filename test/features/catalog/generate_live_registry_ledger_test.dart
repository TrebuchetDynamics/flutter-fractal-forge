import 'dart:convert';
import 'dart:io';

import '../../../research/worlds-largest-fractal-catalog/tool/generate_live_registry_ledger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generates live registry promoted ledger', () {
    final ledger = buildLiveRegistryLedger(
      generatedAt: DateTime.utc(2026, 6, 26),
    );
    writeLiveRegistryLedger(ledger);

    final entries = ledger['entries']! as List<Object?>;
    final skipped = ledger['skipped']! as Map<String, Object>;

    expect(entries.length, greaterThanOrEqualTo(890));
    expect(skipped['missingThumbnail'], 0);
    expect(skipped['unknownFamily'], 0);
    expect(File(outputPath).existsSync(), isTrue);
    expect(File(thumbnailWorklistPath).existsSync(), isTrue);

    final decoded =
        jsonDecode(File(outputPath).readAsStringSync()) as Map<String, Object?>;
    expect(decoded['entries'], hasLength(entries.length));
    final decodedEntries =
        (decoded['entries']! as List).cast<Map<String, Object?>>();
    final lifeLike = decodedEntries.firstWhere(
      (entry) => entry['stable_id'] == 'life_like_b000_s000',
    );
    expect(lifeLike['family'], 'cellular_automata');

    final worklist = jsonDecode(File(thumbnailWorklistPath).readAsStringSync())
        as Map<String, Object?>;
    expect(worklist['missingCount'], 0);
    expect(worklist['batches'], isEmpty);
    expect(worklist['missingThumbnails'], isEmpty);
  });
}
