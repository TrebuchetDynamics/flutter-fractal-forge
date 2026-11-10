import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'support/randomization_oracle.dart';
import 'support/provenance_transition.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('seeded public Dart outputs are exact, source-bound and immutable',
      () async {
    final file = File('migration/oracles/randomization.json');
    final before = file.existsSync() ? file.readAsStringSync() : null;
    final actual = await buildRandomizationOracle();
    expect(await buildRandomizationOracle(), actual,
        reason:
            'Two complete executions must agree, including pending actions');
    expect(jsonDecode(canonicalJson(actual)), actual,
        reason: 'Every output must be finite JSON with exact decimal cells');
    expect((actual['runtime'] as Map)['dart'], '3.13.7');
    expect((actual['runtime'] as Map)['flutter'], '3.47.9');

    final general = (actual['general'] as List).cast<Map>();
    expect(general.length, 3 * oracleSeeds.length);
    for (final scenario in general) {
      final expected = scenario['expected'] as Map;
      final oldParams = expected['before']['params'] as Map;
      final params = expected['after']['params'] as Map;
      for (final id in ['colorScheme', 'colorCycleSpeed']) {
        expect(params[id], oldParams[id], reason: '${scenario['id']}/$id');
      }
      if ((scenario['id'] as String).startsWith('synthetic/')) {
        final draws = (expected['draws'] as List).cast<Map>();
        expect(
            draws.map((d) => [d['method'], d['bound']]),
            [
              ['nextDouble', null],
              ['nextInt', 5],
              ['nextDouble', null],
              ['nextDouble', null],
              ['nextInt', 2],
              ['nextInt', 2],
              ['nextInt', 2],
              ['nextInt', 2],
              ['nextBool', null],
            ],
            reason: 'Palette, decimal and empty enum consume no draw');
        expect(params['decimal'], '9007199254740993');
        expect(expected['after']['paramKinds'],
            containsPair('enumDouble', 'double'));
      }
    }

    final walls = (actual['numberWalls'] as List).cast<Map>();
    expect(walls.length, 2 * oracleSeeds.length + 3);
    expect(
        walls
            .where((s) => s['input']['randomizeModulus'] == true)
            .map((s) => s['expected']['randomized']['params']['prime'])
            .toSet(),
        {'2', '3', '5', '7', '11', '13'});
    for (final scenario in walls) {
      final expected = scenario['expected'] as Map;
      final prior = expected['before'] as Map;
      final randomized = expected['randomized'] as Map;
      final undone = expected['afterUndo'] as Map;
      final input = scenario['input'] as Map;
      expect(randomized['params']['randomSeed'],
          (input['seed'] as int) & 0x7fffffff);
      expect(randomized['status'], 'verifiedPrime');
      expect(randomized['grid']['cells'], hasLength(4));
      for (final row in randomized['grid']['cells'] as List) {
        expect(row, hasLength(16));
      }
      expect(
          randomized['params']['prime'],
          input['randomizeModulus'] == true
              ? isIn(['2', '3', '5', '7', '11', '13'])
              : '97');
      expect(expected['undone'], isTrue);
      expect(undone['params'], prior['params']);
      expect(undone['grid'], prior['grid']);
      expect(expected['edited']['view'], isNot(prior['view']));
      expect(undone['view'], expected['edited']['view']);
      expect(undone['transparentBackground'], isTrue);
      expect(expected['secondUndo'], isFalse);
      expect(expected['afterSecondUndo'], undone);
    }

    final events = (actual['unsuccessful'] as Map)['expected'] as List;
    List<dynamic> actions(String op) =>
        events.where((event) => event['op'] == op).toList();
    final undo = actions('undoNumberWallRandomization');
    expect(undo.map((event) => event['result']), [false, true, false, false]);
    expect(actions('awaitRandomizeNumberWall').map((event) => event['result']),
        [false, false],
        reason: 'Cancelled and abandoned randomization');
    final rejected = actions('loadState').single;
    expect(rejected['result'], isFalse, reason: 'Composite ingress');
    expect(rejected['state']['status'], 'composite');
    expect(actions('awaitGuardedLoadState').single['result'], isFalse,
        reason: 'Revoked ownership');
    expect(undo[1]['state']['params'], events[0]['state']['params'],
        reason: 'Unsuccessful requests cannot replace the committed undo');
    expect(undo[1]['state']['grid'], events[0]['state']['grid']);
    expect(actions('randomizeNumberWall').last['result'], isFalse,
        reason: 'Navigation cannot randomize the old wall');
    expect(actions('selectModule').single['state']['canUndo'], isFalse,
        reason: 'Navigation clears the previously committed undo');

    void compare(Object? document) => expect(
        () => verifyBoundDocument('randomization', before!, document as Map),
        returnsNormally);
    compare(actual);
    compare(jsonDecode(canonicalJson(actual)));
    expect(before, canonicalJson(jsonDecode(before!)));
    final changedSource = jsonDecode(canonicalJson(actual)) as Map;
    (changedSource['source_bindings']
        as Map)['lib/core/controllers/fractal_controller.dart'] = 'changed';
    expect(() => compare(changedSource), throwsA(isA<TestFailure>()));
    final changedCell = jsonDecode(canonicalJson(actual)) as Map;
    changedCell['numberWalls'][0]['expected']['randomized']['grid']['cells'][2]
        [7] = '999999999999999999';
    expect(() => compare(changedCell), throwsA(isA<TestFailure>()),
        reason: 'A nested changed expectation must not pass comparison');
    expect(file.existsSync() ? file.readAsStringSync() : null, before,
        reason: 'Normal and scratch runs never promote the fixture');
    exportRandomizationOracle(actual);
  });
}
