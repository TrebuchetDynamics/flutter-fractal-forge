import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/models/wallpaper/wallpaper_options.dart';
import 'package:flutter_fractals/features/wallpaper/wallpaper_options_sheet.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<_WallpaperSheetHarness> pumpSheet(WidgetTester tester) async {
    final harness = _WallpaperSheetHarness();

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                harness.result = await WallpaperOptionsSheet.show(
                  context,
                  initial: const WallpaperOptions(),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    return harness;
  }

  testWidgets('wallpaper sheet returns selected options after it closes',
      (tester) async {
    final harness = await pumpSheet(tester);

    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    expect(find.text('Wallpaper'), findsOneWidget);
    expect(find.text('Apply'), findsOneWidget);

    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(harness.result, isNotNull);
    expect(harness.result!.target, WallpaperTarget.home);
  });

  testWidgets('wallpaper sheet returns null when dismissed', (tester) async {
    final harness = await pumpSheet(tester);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    expect(harness.result, isNull);
  });

  testWidgets('wallpaper sheet is width constrained on large screens',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await pumpSheet(tester);

    expect(tester.getSize(find.byType(WallpaperOptionsSheet)).width, 720);
    expect(tester.takeException(), isNull);
  });
}

class _WallpaperSheetHarness {
  WallpaperOptions? result;
}
