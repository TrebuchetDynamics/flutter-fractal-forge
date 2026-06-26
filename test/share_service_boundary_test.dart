import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/services/export/share_service.dart';
import 'package:flutter_fractals/features/viewer/export/viewer_export_overlay.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('share_plus is isolated behind AppShareService', () {
    final directShareImports = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .where((file) =>
            file.path != 'lib/core/services/export/share_service.dart')
        .where((file) => file.readAsStringSync().contains('package:share_plus'))
        .map((file) => file.path)
        .toList()
      ..sort();

    expect(directShareImports, isEmpty);
  });

  testWidgets('ShareSheet reports share failures instead of dropping them',
      (tester) async {
    await _pumpShareSheet(
      tester,
      shareText: (_, {subject}) async {
        throw StateError('share unavailable');
      },
    );

    await tester.tap(find.text('Share'));
    await tester.pumpAndSettle();

    expect(find.textContaining('share unavailable'), findsOneWidget);
    expect(find.text('Share Fractal'), findsOneWidget);
  });

  testWidgets('ShareSheet closes after successful share', (tester) async {
    var sharedText = '';
    String? sharedSubject;
    await _pumpShareSheet(
      tester,
      shareText: (text, {subject}) async {
        sharedText = text;
        sharedSubject = subject;
      },
    );

    await tester.tap(find.text('Share'));
    await tester.pumpAndSettle();

    expect(sharedText, contains('Mandelbrot'));
    expect(sharedSubject, contains('Mandelbrot'));
    expect(find.text('Share Fractal'), findsNothing);
  });
}

Future<void> _pumpShareSheet(
  WidgetTester tester, {
  required ShareTextCallback shareText,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              builder: (_) => ShareSheet(
                uri: Uri.parse('https://example.test/fractal'),
                fractalName: 'Mandelbrot',
                shareText: shareText,
              ),
            ),
            child: const Text('open share sheet'),
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.text('open share sheet'));
  await tester.pumpAndSettle();
}
