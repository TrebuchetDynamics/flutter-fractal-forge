import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the "same map at a different power" claim for the families listed in
/// `docs/catalog/merge-candidates.md`.
///
/// Members of one family must fold the same axes. This guard exists because
/// `perpendicular_bs` did not: `cubic` folded x while `power4` and `power5`
/// folded y, so that "family" was two different maps sharing a name.
void main() {
  const root = 'shaders/escape_time_family/families';

  /// Axes folded by `abs(...)` in the map update.
  Set<String> foldAxes(String source) {
    final axes = <String>{};
    for (final m in RegExp(r'abs\(\s*([A-Za-z0-9_]*?)(?:\.([xy]))?\s*\)')
        .allMatches(source)) {
      final field = m.group(2);
      if (field != null) {
        axes.add(field);
        continue;
      }
      final name = m.group(1) ?? '';
      if (RegExp(r'^x\d*$').hasMatch(name)) axes.add('x');
      if (RegExp(r'^y\d*$').hasMatch(name)) axes.add('y');
    }
    return axes;
  }

  Set<String> familyAxes(String dir, List<String> files) {
    final axes = <String>{};
    for (final f in files) {
      axes.addAll(foldAxes(File('$root/$dir/$f').readAsStringSync()));
    }
    return axes;
  }

  group('power-variant families fold consistently', () {
    const clean = <String, (String, List<String>)>{
      'celtic plane': ('celtic', [
        'celtic_cubic_gpu.frag',
        'celtic_power4_gpu.frag',
        'celtic_power5_gpu.frag',
        'celtic_power6_gpu.frag',
        'celtic_power7_gpu.frag',
      ]),
      'buffalo plane': ('buffalo', [
        'buffalo_cubic_gpu.frag',
        'buffalo_power4_gpu.frag',
        'buffalo_power5_gpu.frag',
        'buffalo_power6_gpu.frag',
        'buffalo_power7_gpu.frag',
      ]),
    };

    clean.forEach((label, spec) {
      final (dir, files) = spec;
      test('$label folds one axis set', () {
        final perFile = {
          for (final f in files)
            f: foldAxes(File('$root/$dir/$f').readAsStringSync()),
        };
        final distinct = perFile.values.map((s) => s.join(',')).toSet();
        expect(distinct.length, 1,
            reason: 'members disagree: $perFile');
      });
    });

    // multibrot merged into one parameterised shader, which folds nothing.
    test('the merged multibrot shader folds nothing', () {
      expect(
        familyAxes('multibrot', const ['integer_powers/multibrot3_gpu.frag']),
        isEmpty,
      );
    });

    // mandelbar is no longer a family of files: it merged into
    // tricorn_gpu.frag, which folds nothing either. See
    // test/modules/mandelbar_merge_test.dart.
    test('the merged mandelbar shader folds nothing', () {
      expect(
        familyAxes('tricorn', const [
          'parameter_plane/tricorn_gpu.frag',
        ]),
        isEmpty,
      );
    });
  });

  group('known defect witness', () {
    // If this test fails, someone unified the perpendicular fold axis. That is
    // the fix, not a regression: delete this group and add the family to the
    // consistent list above.
    test('perpendicular burning ship still folds two different axes', () {
      final xGroup = familyAxes('perpendicular', const [
        'perpendicular_burning_ship_gpu.frag',
        'perpendicular_bs_cubic_gpu.frag',
      ]);
      final yGroup = familyAxes('perpendicular', const [
        'perpendicular_bs_power4_gpu.frag',
        'perpendicular_bs_power5_gpu.frag',
      ]);
      expect(xGroup, {'x'});
      expect(yGroup, {'y'});
      expect(xGroup, isNot(equals(yGroup)),
          reason: 'the family is two maps until one axis is chosen');
    });

    test('perpendicular celtic splits the same way', () {
      expect(familyAxes('celtic', const ['perp_celtic_gpu.frag']), {'x'});
      expect(familyAxes('celtic', const ['perp_celtic_cubic_gpu.frag']), {'y'});
    });
  });
}
