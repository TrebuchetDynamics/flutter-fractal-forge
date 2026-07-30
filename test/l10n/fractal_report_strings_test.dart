import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final es = lookupAppLocalizations(const Locale('es'));

  group('fractal report feedback', () {
    test('both messages interpolate their argument', () {
      expect(en.fractalReportSaved('/tmp/report.json'),
          contains('/tmp/report.json'));
      expect(es.fractalReportSaved('/tmp/report.json'),
          contains('/tmp/report.json'));
      expect(en.fractalReportFailed('disk full'), contains('disk full'));
      expect(es.fractalReportFailed('disk full'), contains('disk full'));
    });

    test('Spanish is translated, not copied from English', () {
      expect(es.fractalReportSaved('x'), isNot(en.fractalReportSaved('x')));
      expect(es.fractalReportFailed('x'), isNot(en.fractalReportFailed('x')));
    });

    // The viewer's report card and the GPU debug report are separate features
    // that happen to word this the same way today. They get separate keys so
    // either can be reworded without touching the other — the keys must both
    // survive, but their text is free to match.
    test('the debug report keeps a key of its own', () {
      expect(en.debugReportSavedReport('/tmp/a'), contains('/tmp/a'));
      expect(es.debugReportSavedReport('/tmp/a'), contains('/tmp/a'));
    });

    // The two snack bars this covers were built from string interpolation, so
    // a regression looks like working code rather than a missing key.
    test('neither snack bar hardcodes English any more', () {
      final source = File('lib/features/viewer/fractal_viewer_screen.dart')
          .readAsStringSync();
      expect(source, isNot(contains("'Saved report: ")));
      expect(source, isNot(contains("'Report failed: ")));
    });
  });
}
