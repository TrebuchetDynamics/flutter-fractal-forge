import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/services/accessibility_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/settings/accessibility_settings_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../shared/a11y_test_helpers.dart';

void main() {
  group('AccessibilitySettingsScreen accessibility', () {
    late AccessibilityService accessibilityService;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      accessibilityService = await AccessibilityService.create();
    });

    Widget buildApp() {
      return ChangeNotifierProvider<AccessibilityService>.value(
        value: accessibilityService,
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.dark,
          home: const AccessibilitySettingsScreen(),
        ),
      );
    }

    testWidgets('meets Android tap target guideline', (tester) async {
      await tester.pumpWidget(buildApp());
      await expectMeetsAccessibilityGuideline(
          tester, androidTapTargetGuideline);
    });

    testWidgets('meets labeled tap target guideline', (tester) async {
      await tester.pumpWidget(buildApp());
      await expectMeetsAccessibilityGuideline(
          tester, labeledTapTargetGuideline);
    });

    testWidgets('meets text contrast guideline', (tester) async {
      await tester.pumpWidget(buildApp());
      await expectMeetsAccessibilityGuideline(tester, textContrastGuideline);
    });
  });
}
