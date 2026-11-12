import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'support/provenance_transition.dart';

void main() {
  test(
      'baseline-only stage composes unchanged maps without widening task policy',
      () {
    final stages = readProvenanceStages();
    final baseline =
        stages.singleWhere((s) => s['task'] == 'ACAD-015-BASELINE');
    final task = stages.singleWhere((s) => s['task'] == 'ACAD-015');
    for (final id in (baseline['binding_maps'] as Map).keys.cast<String>()) {
      final before = baseline['binding_maps'][id]['before'] as Map;
      final after = task['binding_maps'][id]['after'] as Map;
      verifySourceStages(id, before, after, stages: [task, baseline]);
    }

    final changed = jsonDecode(jsonEncode(baseline)) as Map;
    changed['allowed_paths'] = task['allowed_paths'];
    expect(() => validateProvenanceStage(changed), throwsStateError);
    // The reconciliation cannot turn a missing stage into implicit acceptance.
    expect(
      () => verifySourceStages(
        'physical-events',
        baseline['binding_maps']['physical-events']['before'] as Map,
        task['binding_maps']['physical-events']['after'] as Map,
        stages: [task],
      ),
      throwsStateError,
    );
  });
}
