import 'package:flutter/material.dart';
import 'package:flutter_fractals/features/debug/shader_lab_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildTestWidget() {
  return const MaterialApp(
    locale: Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: ShaderLabScreen(),
  );
}

void main() {
  group('ShaderLabScreen', () {
    testWidgets('renders without error or crash', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      // Pump enough to let the scheduleMicrotask + 400 ms delay fire and
      // resolve (the shader load will fail gracefully in the test environment).
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(tester.takeException(), isNull);
    });

    testWidgets('AppBar has correct title "Shader Lab"', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Shader Lab'), findsOneWidget);
    });

    testWidgets('three test panel labels are visible', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Panel titles rendered as Text inside each _tile widget.
      expect(find.textContaining('Solid color'), findsOneWidget);
      expect(find.textContaining('LinearGradient'), findsOneWidget);
      expect(find.textContaining('runtime_effect'), findsOneWidget);
    });

    testWidgets('Run test button is present in the AppBar actions',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Before running, button shows "Run test".
      expect(find.text('Run test'), findsOneWidget);
    });

    testWidgets('handles shader load failure gracefully — no exception thrown',
        (tester) async {
      // In the test environment ui.FragmentProgram.fromAsset() throws because
      // the shader asset is not bundled. The screen catches the error and
      // updates _loadError; it must not rethrow.
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump(); // let scheduleMicrotask queue fire
      await tester.pump(const Duration(milliseconds: 500)); // past the 400 ms delay

      // No exception should propagate out of the widget.
      expect(tester.takeException(), isNull);

      // The screen should now show the error status text instead of "loading".
      final statusFinder = find.textContaining('FragmentProgram');
      expect(statusFinder, findsWidgets);
    });

    testWidgets('status indicator shows initial loading or error state',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget());

      // Immediately after first frame the status should say "loading…"
      // because the 400 ms delay has not elapsed yet.
      expect(find.text('FragmentProgram: loading\u2026'), findsOneWidget);

      // After the delay fires the status transitions to error (no asset in
      // test env) — no exception, but the error text appears.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Status text is one of the two known states (error or loaded).
      final errorFinder = find.textContaining('FragmentProgram load error');
      final loadedFinder = find.text('FragmentProgram: loaded');
      expect(
        errorFinder.evaluate().isNotEmpty || loadedFinder.evaluate().isNotEmpty,
        isTrue,
        reason: 'Status should be either error or loaded after delay',
      );
    });

    testWidgets('Scaffold uses black background', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, Colors.black);
    });

    testWidgets('each panel shows darkRatio placeholder "—" initially',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Before "Run test" is pressed all three ratio values are null → "—".
      final dashFinder = find.textContaining('darkRatio: \u2014');
      expect(dashFinder.evaluate().length, greaterThanOrEqualTo(3));
    });
  });
}
