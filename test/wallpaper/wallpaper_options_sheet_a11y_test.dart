import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/models/wallpaper/wallpaper_options.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/wallpaper/wallpaper_options_sheet.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/shared/widgets/app_bottom_sheet.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/overflow_guard.dart';

Future<void> _pumpSheet(
  WidgetTester tester, {
  double textScale = 1.0,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => WallpaperOptionsSheet.show(
              context,
              initial: const WallpaperOptions(),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  group('WallpaperOptionsSheet accessibility', () {
    testWidgets('text meets the AA contrast ratio', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpSheet(tester);
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });

    testWidgets('every control meets the 48px tap target', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpSheet(tester);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('every control is named', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpSheet(tester);
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    for (final scale in const [1.0, 1.3, 2.0, 3.0]) {
      for (final size in const [Size(360, 640), Size(320, 568)]) {
        testWidgets('no overflow at ${scale}x on $size', (tester) async {
          await tester.binding.setSurfaceSize(size);
          addTearDown(() => tester.binding.setSurfaceSize(null));
          await expectNoOverflow(
            () => _pumpSheet(tester, textScale: scale),
            reason: '$scale x on $size',
          );
        });
      }
    }

    testWidgets('the scrollable body keeps height at a 3x text scale',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 568));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await _pumpSheet(tester, textScale: 3.0);

      // The header and footer are fixed children of the sheet's Column, so an
      // unbounded header takes its space from the body rather than scrolling.
      // Left uncapped the header reached 195px here and the body collapsed to
      // zero, hiding every option.
      final header = tester.getSize(find.byType(AppBottomSheetHeader).first);
      expect(header.height, lessThan(160),
          reason: 'header grew unbounded and will starve the body');
      expect(
        tester.getSize(find.byType(ListView).first).height,
        greaterThan(0),
        reason: 'options body collapsed to nothing',
      );
    });
  });
}
