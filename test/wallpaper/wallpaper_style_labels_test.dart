import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/wallpaper/wallpaper_options_sheet.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final locale in ['en', 'es']) {
    for (final profile in [
      (const Size(320, 568), 3.0),
      (const Size(360, 640), 2.0),
      (const Size(390, 720), 1.0),
      (const Size(640, 360), 3.0),
    ]) {
      testWidgets('complete wallpaper style labels $locale $profile',
          (tester) async {
        await tester.binding.setSurfaceSize(profile.$1);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.dark,
          locale: Locale(locale),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(profile.$2)),
            child: child!,
          ),
          home: Scaffold(
              body: Builder(
                  builder: (context) => TextButton(
                        onPressed: () => WallpaperOptionsSheet.show(context),
                        child: const Text('Open'),
                      ))),
        ));
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        final l10n = AppLocalizations.of(
            tester.element(find.byType(WallpaperOptionsSheet)))!;
        for (final label in [
          l10n.wallpaperPresetPlain,
          l10n.wallpaperPresetHome,
          l10n.wallpaperPresetLock
        ]) {
          final text = find.text(label);
          await tester.scrollUntilVisible(text, 90,
              scrollable: find.byType(Scrollable).first);
          await tester.ensureVisible(text);
          await tester.pumpAndSettle();
          final paragraph = tester.renderObject<RenderParagraph>(text);
          final boxes = paragraph.getBoxesForSelection(
              TextSelection(baseOffset: 0, extentOffset: label.length));
          expect(boxes, isNotEmpty);
          for (final box in boxes) {
            expect(box.left, greaterThanOrEqualTo(-0.5), reason: label);
            expect(box.right, lessThanOrEqualTo(paragraph.size.width + 0.5),
                reason: '$label must be fully painted, not faded/clipped');
            expect(box.bottom, lessThanOrEqualTo(paragraph.size.height + 0.5),
                reason: label);
          }
        }
        expect(tester.takeException(), isNull);
      });
    }
  }
  for (final entry in [
    ('dark', AppTheme.dark),
    ('high contrast', AppTheme.highContrast)
  ]) {
    testWidgets('wallpaper selected icons retain contrast ${entry.$1}',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: entry.$2,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
            body: Builder(
                builder: (context) => TextButton(
                      onPressed: () => WallpaperOptionsSheet.show(context),
                      child: const Text('Open'),
                    ))),
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(
          tester.element(find.byType(WallpaperOptionsSheet)))!;
      final selected =
          find.widgetWithText(OutlinedButton, l10n.wallpaperPresetHome);
      final button = tester.widget<OutlinedButton>(selected);
      final foregroundColor = button.style!.foregroundColor!.resolve({});
      expect(foregroundColor, entry.$2.colorScheme.onPrimaryContainer);
      final check = find.descendant(
          of: selected, matching: find.byIcon(Icons.check_circle_rounded));
      expect(check, findsOneWidget);
      expect(IconTheme.of(tester.element(check)).color, foregroundColor);
      final foreground = foregroundColor!.computeLuminance();
      final background =
          button.style!.backgroundColor!.resolve({})!.computeLuminance();
      final contrast = foreground > background
          ? (foreground + .05) / (background + .05)
          : (background + .05) / (foreground + .05);
      expect(contrast, greaterThanOrEqualTo(3),
          reason:
              'The selected icon must remain distinguishable without relying on hue.');
    });
  }
}
