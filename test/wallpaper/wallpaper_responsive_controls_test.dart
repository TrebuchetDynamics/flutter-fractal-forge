import 'dart:ui' show Tristate, CheckedState;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_fractals/core/models/wallpaper/wallpaper_options.dart';
import 'package:flutter_fractals/features/wallpaper/wallpaper_options_sheet.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final locale in ['en', 'es']) {
    for (final size in [
      const Size(320, 568),
      const Size(360, 640),
      const Size(390, 720),
      const Size(640, 360)
    ]) {
      for (final scale in [1.0, 2.0, 3.0]) {
        testWidgets(
            '$locale $size ${scale}x: complete targets, reachable presets and footer',
            (tester) async {
          await tester.binding.setSurfaceSize(size);
          addTearDown(() => tester.binding.setSurfaceSize(null));
          final semantics = tester.ensureSemantics();
          try {
            WallpaperOptions? result;
            await tester.pumpWidget(MaterialApp(
              locale: Locale(locale),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                      textScaler: TextScaler.linear(scale),
                      viewPadding: const EdgeInsets.only(bottom: 32),
                      systemGestureInsets: const EdgeInsets.only(bottom: 48),
                      viewInsets: EdgeInsets.only(
                          bottom: size.width > size.height ? 80 : 0)),
                  child: child!),
              home: Scaffold(
                  resizeToAvoidBottomInset: false,
                  body: Builder(
                      builder: (context) => TextButton(
                          onPressed: () async {
                            result = await WallpaperOptionsSheet.show(context);
                          },
                          child: const Text('Open')))),
            ));
            await tester.tap(find.text('Open'));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            final l10n = AppLocalizations.of(
                tester.element(find.byType(WallpaperOptionsSheet)))!;
            final scroll = find.byType(Scrollable).first;
            for (final label in [
              l10n.wallpaperTargetHome,
              l10n.wallpaperTargetLock,
              l10n.wallpaperTargetBoth
            ]) {
              await tester.scrollUntilVisible(find.text(label), 90,
                  scrollable: scroll);
              await tester.ensureVisible(find.text(label));
              await tester.pumpAndSettle();
              final paragraph =
                  tester.renderObject<RenderParagraph>(find.text(label));
              final boxes = paragraph.getBoxesForSelection(
                  TextSelection(baseOffset: 0, extentOffset: label.length));
              expect(boxes.map((box) => box.top).toSet(), hasLength(1),
                  reason: '$label must not wrap mid-word');
              final option = find.widgetWithText(OutlinedButton, label);
              expect(tester.getSize(option).height, greaterThanOrEqualTo(48));
              if (label == l10n.wallpaperTargetHome) {
                expect(
                    tester
                        .getSemantics(option)
                        .getSemanticsData()
                        .flagsCollection
                        .isSelected,
                    Tristate.isTrue);
              }
              await tester.tap(find.text(label));
              await tester.pumpAndSettle();
              final data = tester.getSemantics(option).getSemanticsData();
              expect(data.flagsCollection.isSelected, Tristate.isTrue);
              expect(data.flagsCollection.isChecked, CheckedState.isTrue);
              expect(data.flagsCollection.isInMutuallyExclusiveGroup, isTrue);
            }
            for (final label in [
              l10n.wallpaperPresetPlain,
              l10n.wallpaperPresetHome,
              l10n.wallpaperPresetLock
            ]) {
              final option = find.widgetWithText(OutlinedButton, label);
              await tester.scrollUntilVisible(option, 90, scrollable: scroll);
              await Scrollable.ensureVisible(tester.element(option),
                  alignment: 1);
              await tester.pumpAndSettle();
              expect(find.text(label).hitTestable(), findsOneWidget);
              final rect = tester.getRect(option);
              expect(
                  rect.bottom,
                  lessThanOrEqualTo(tester
                      .getRect(find.widgetWithText(
                          FilledButton, l10n.wallpaperApply))
                      .top));
              expect(tester.getSize(option).height, greaterThanOrEqualTo(48));
              if (label == l10n.wallpaperPresetPlain) {
                expect(
                    tester
                        .getSemantics(find.widgetWithText(
                            OutlinedButton, l10n.wallpaperPresetHome))
                        .getSemanticsData()
                        .flagsCollection
                        .isSelected,
                    Tristate.isTrue);
              }
              await tester.tap(find.text(label));
              await tester.pumpAndSettle();
              final data = tester.getSemantics(option).getSemanticsData();
              expect(data.flagsCollection.isChecked, CheckedState.isTrue);
              expect(data.flagsCollection.isSelected, Tristate.isTrue);
              expect(data.flagsCollection.isInMutuallyExclusiveGroup, isTrue);
            }
            await tester.scrollUntilVisible(find.byType(SwitchListTile), 90,
                scrollable: scroll);
            await Scrollable.ensureVisible(
                tester.element(find.byType(SwitchListTile)),
                alignment: 1);
            await tester.pumpAndSettle();
            expect(
                tester.getRect(find.byType(SwitchListTile)).bottom,
                lessThanOrEqualTo(tester
                    .getRect(
                        find.widgetWithText(FilledButton, l10n.wallpaperApply))
                    .top));
            expect(
                tester
                    .widget<SwitchListTile>(find.byType(SwitchListTile))
                    .value,
                isTrue);
            await tester.ensureVisible(find.byType(Switch));
            await tester.tap(find.byType(Switch));
            await tester.tap(find.text(l10n.wallpaperApply));
            await tester.pumpAndSettle();
            expect(
                result,
                const WallpaperOptions(
                    target: WallpaperTarget.both,
                    style: WallpaperStyle.lockOptimized,
                    saveCopy: false));
            expect(tester.takeException(), isNull);
          } finally {
            semantics.dispose();
          }
        });
      }
    }
  }
}
