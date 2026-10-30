import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/wallpaper/wallpaper_options_sheet.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('wallpaper styles honor the app large-target theme at 1x text',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    // Match FlutterFractalsApp's largeTargetsEnabled theme, without enlarging
    // text: large labels must not accidentally mask an undersized hit target.
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark.copyWith(
        visualDensity: const VisualDensity(
          horizontal: VisualDensity.maximumDensity,
          vertical: VisualDensity.maximumDensity,
        ),
        materialTapTargetSize: MaterialTapTargetSize.padded,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => WallpaperOptionsSheet.show(context),
            child: const Text('Open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    final l10n = AppLocalizations.of(
        tester.element(find.byType(WallpaperOptionsSheet)))!;
    final home = find.widgetWithText(OutlinedButton, l10n.wallpaperTargetHome);
    await tester.ensureVisible(home);
    await tester.pumpAndSettle();
    expect(tester.getSize(home).height, greaterThanOrEqualTo(56));
    for (final label in [
      l10n.wallpaperPresetPlain,
      l10n.wallpaperPresetHome,
      l10n.wallpaperPresetLock,
    ]) {
      final option = find.widgetWithText(OutlinedButton, label);
      await tester.ensureVisible(option);
      await tester.pumpAndSettle();
      expect(option.hitTestable(), findsOneWidget);
      expect(tester.getSize(option).height, greaterThanOrEqualTo(56),
          reason: '$label must not override the large-target theme density');
    }
    final apply = find.widgetWithText(FilledButton, l10n.wallpaperApply);
    expect(tester.getSize(apply).height, greaterThanOrEqualTo(56));
    expect(tester.takeException(), isNull);
  });
}
