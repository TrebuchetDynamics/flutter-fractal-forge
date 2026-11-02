import 'dart:io';

import 'package:flutter_fractals/core/modules/builders/escape_time_catalog.dart';

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
      'celtic plane': ('celtic', ['power_plane/celtic_power_gpu.frag']),
      'buffalo plane': ('buffalo', ['power_plane/buffalo_power_gpu.frag']),
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

  group('perpendicular fold axis is explicit', () {
    // The family used to ship two undocumented conventions in one name: some
    // members folded abs(z.x), others abs(z.y). One shader now carries both and
    // the control selects one, so the difference is visible in the UI.
    test('one shader offers both fold axes', () {
      final source = File(
              'shaders/escape_time_family/families/perpendicular/perpendicular_bs_power_gpu.frag')
          .readAsStringSync();
      expect(source, contains('uniform float uFoldAxis;'));
      expect(source, contains('vec2(abs(zPow.x), zPow.y)'));
      expect(source, contains('vec2(zPow.x, abs(zPow.y))'));
    });

    test('the folded entries split into the two documented axes', () {
      final registry = escapeTimeCatalog;
      double axisOf(String id) => (registry.firstWhere((c) => c.id == id)
              .extraParams
              .firstWhere((p) => p.id == 'foldAxis')
              .defaultValue as num)
          .toDouble();
      expect(axisOf('perpendicular_burning_ship'), 0.0);
      expect(axisOf('perpendicular_bs_cubic'), 0.0);
      expect(axisOf('perpendicular_bs_power4'), 1.0);
      expect(axisOf('perpendicular_bs_power5'), 1.0);
    });
  });
}
