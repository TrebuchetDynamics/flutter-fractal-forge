import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fractals/features/viewer/export/viewer_export_overlay.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final label in ['Copy link', 'Share link']) {
    testWidgets('$label retains medium-impact feedback', (tester) async {
      final calls = <MethodCall>[];
      tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
        calls.add(call);
        return null;
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null));
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
            builder: (context) => Scaffold(
                body: TextButton(
                    onPressed: () => showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => ShareSheet(
                            uri: Uri.parse('https://example.test/fractal'),
                            fractalName: 'Mandelbrot',
                            shareText: (_, {subject}) async {})),
                    child: const Text('Open')))),
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(label));
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(
          calls.where((call) =>
              call.method == 'HapticFeedback.vibrate' &&
              call.arguments == 'HapticFeedbackType.mediumImpact'),
          hasLength(1));
    });
  }
  testWidgets('Share supports keyboard activation of native action',
      (tester) async {
    var shared = false;
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
          body: ShareSheet(
        uri: Uri.parse('https://example.test/fractal'),
        fractalName: 'Mandelbrot',
        shareText: (_, {subject}) async {
          shared = true;
        },
      )),
    ));
    final action = find.widgetWithText(FilledButton, 'Share link');
    expect(action, findsOneWidget);
    Focus.of(tester.element(find.text('Share link'))).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(shared, isTrue);
  });

  testWidgets(
      'Share scrolls long URL and actions at 200 percent on short screen',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 360));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final link = Uri.parse(
        'https://example.test/fractal?configuration=${List.filled(100, 'abcdef').join()}');
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!),
      home: Scaffold(body: ShareSheet(uri: link, fractalName: 'Mandelbrot')),
    ));
    expect(tester.takeException(), isNull);
    expect(find.text(link.toString()), findsNothing);
    await tester.ensureVisible(find.text('Show full link'));
    await tester.tap(find.text('Show full link'));
    await tester.pumpAndSettle();
    expect(find.text(link.toString()), findsOneWidget);
    await tester.ensureVisible(find.text('Share link'));
    await tester.pumpAndSettle();
    expect(find.text('Share link').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
