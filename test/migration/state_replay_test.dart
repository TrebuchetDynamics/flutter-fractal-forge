import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'support/replay_codec.dart';
import 'support/provenance_transition.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final recorded = <String, Map<String, Object?>>{};
  tearDownAll(() => exportReplays(recorded));

  for (final name in replayNames) {
    test('$name recomputes ordered Dart outputs and rejects expectation drift',
        () async {
      final file = File('migration/baseline/$name.json');
      final before = file.readAsStringSync();
      final document = jsonDecode(before) as Map<String, dynamic>;
      expect(document['schema'], 1);
      expect(document['kind'], name);
      final inputs = document['inputs'] as List;
      expect(inputs, isNotEmpty);
      Future<Object> run() async => name == 'state-replay'
          ? await replayState(inputs)
          : replayPrecision(inputs);
      final actual = await run();
      expect(await run(), actual,
          reason: 'Same ordered inputs must be deterministic');
      expect(jsonDecode(canonicalJson(actual)), actual,
          reason:
              'Outputs must be finite JSON and retain exact decimal strings');
      final sources = replaySourceBindings();
      final generated = <String, Object?>{
        ...document,
        'source_bindings': sources,
        'expected': actual,
      };
      verifyProvenanceTransition(
          name, before, generated, readProvenanceTransition());
      expect(actual, document['expected'], reason: name);
      expect(before, canonicalJson(document));

      final altered = jsonDecode(jsonEncode(actual)) as List;
      if (name == 'state-replay') {
        altered.first['history']['view']['zoom'] = -123;
      } else {
        altered.first['renderPath'] = 'cpu-not-a-real-expectation';
      }
      expect(() => expect(actual, altered), throwsA(isA<TestFailure>()),
          reason: 'The replay comparator must reject an altered expectation');
      final changed = jsonDecode(jsonEncode(generated)) as Map<String, dynamic>;
      changed['expected'] = altered;
      expect(
          () => verifyProvenanceTransition(
              name, before, changed, readProvenanceTransition()),
          throwsStateError);
      recorded[name] = generated;
      expect(file.readAsStringSync(), before,
          reason: 'Recording must never promote fixtures implicitly');
    });
  }
}
