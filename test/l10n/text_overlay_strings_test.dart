import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('text overlay subtitle is localized in English and Spanish', () {
    final en = lookupAppLocalizations(const Locale('en'));
    final es = lookupAppLocalizations(const Locale('es'));

    expect(en.textOverlaySubtitle, isNotEmpty);
    expect(es.textOverlaySubtitle, isNotEmpty);
    expect(es.textOverlaySubtitle, isNot(en.textOverlaySubtitle));

    final source = File('lib/features/viewer/fractal_viewer_screen.dart')
        .readAsStringSync();
    expect(source, contains('subtitle: l10n.textOverlaySubtitle'));
    expect(
      source,
      isNot(
          contains("subtitle: 'Add a short caption over the rendered image.'")),
    );
  });
}
