import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/services/accessibility_service.dart';
import 'package:flutter_fractals/features/settings/accessibility_settings_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Builds the widget under test wrapped with required infrastructure.
Widget _buildScreen(AccessibilityService service) {
  return ChangeNotifierProvider<AccessibilityService>.value(
    value: service,
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const AccessibilitySettingsScreen(),
    ),
  );
}

Future<AccessibilityService> _makeService() async {
  final prefs = await SharedPreferences.getInstance();
  return AccessibilityService(prefs);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AccessibilitySettingsScreen', () {
    testWidgets('renders without error', (tester) async {
      final service = await _makeService();
      await tester.pumpWidget(_buildScreen(service));
      await tester.pumpAndSettle();
      expect(find.byType(AccessibilitySettingsScreen), findsOneWidget);
    });

    testWidgets('has AppBar with Accessibility title', (tester) async {
      final service = await _makeService();
      await tester.pumpWidget(_buildScreen(service));
      await tester.pumpAndSettle();
      // l10n.accessibilityTitle == 'Accessibility'
      expect(find.text('Accessibility'), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows High Contrast toggle option', (tester) async {
      final service = await _makeService();
      await tester.pumpWidget(_buildScreen(service));
      await tester.pumpAndSettle();
      expect(find.text('High Contrast'), findsOneWidget);
    });

    testWidgets('shows Reduced Motion toggle option', (tester) async {
      final service = await _makeService();
      await tester.pumpWidget(_buildScreen(service));
      await tester.pumpAndSettle();
      expect(find.text('Reduced Motion'), findsOneWidget);
    });

    testWidgets('shows Large Touch Targets toggle option', (tester) async {
      final service = await _makeService();
      await tester.pumpWidget(_buildScreen(service));
      await tester.pumpAndSettle();
      expect(find.text('Large Touch Targets'), findsOneWidget);
    });

    testWidgets('all three Switch widgets render with initial off state',
        (tester) async {
      final service = await _makeService();
      await tester.pumpWidget(_buildScreen(service));
      await tester.pumpAndSettle();

      final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
      expect(switches.length, 3);
      for (final sw in switches) {
        expect(sw.value, isFalse);
      }
    });

    testWidgets('tapping High Contrast tile enables highContrastEnabled',
        (tester) async {
      final service = await _makeService();
      await tester.pumpWidget(_buildScreen(service));
      await tester.pumpAndSettle();

      expect(service.highContrastEnabled, isFalse);

      // Tap the High Contrast row (GestureDetector wrapping it)
      await tester.tap(find.text('High Contrast'));
      await tester.pumpAndSettle();

      expect(service.highContrastEnabled, isTrue);
    });

    testWidgets('tapping Reduced Motion tile enables reducedMotionEnabled',
        (tester) async {
      final service = await _makeService();
      await tester.pumpWidget(_buildScreen(service));
      await tester.pumpAndSettle();

      expect(service.reducedMotionEnabled, isFalse);

      await tester.tap(find.text('Reduced Motion'));
      await tester.pumpAndSettle();

      expect(service.reducedMotionEnabled, isTrue);
    });

    testWidgets('tapping Large Touch Targets tile enables largeTargetsEnabled',
        (tester) async {
      final service = await _makeService();
      await tester.pumpWidget(_buildScreen(service));
      await tester.pumpAndSettle();

      expect(service.largeTargetsEnabled, isFalse);

      await tester.tap(find.text('Large Touch Targets'));
      await tester.pumpAndSettle();

      expect(service.largeTargetsEnabled, isTrue);
    });

    testWidgets('toggling on then off via Switch returns to false',
        (tester) async {
      final service = await _makeService();
      await tester.pumpWidget(_buildScreen(service));
      await tester.pumpAndSettle();

      // Toggle high contrast on via the Switch widget itself
      final switchFinder = find.byType(Switch).first;
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();
      expect(service.highContrastEnabled, isTrue);

      await tester.tap(switchFinder);
      await tester.pumpAndSettle();
      expect(service.highContrastEnabled, isFalse);
    });

    testWidgets('Switch reflects pre-enabled state from service', (tester) async {
      SharedPreferences.setMockInitialValues({
        'accessibility_high_contrast': true,
        'accessibility_reduced_motion': true,
        'accessibility_large_targets': false,
      });
      final service = await _makeService();
      await tester.pumpWidget(_buildScreen(service));
      await tester.pumpAndSettle();

      final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
      expect(switches[0].value, isTrue);   // High Contrast
      expect(switches[1].value, isTrue);   // Reduced Motion
      expect(switches[2].value, isFalse);  // Large Touch Targets
    });

    testWidgets('uses l10n subtitle strings for hint text', (tester) async {
      final service = await _makeService();
      await tester.pumpWidget(_buildScreen(service));
      await tester.pumpAndSettle();

      expect(
        find.text('Use bright colors with maximum contrast'),
        findsOneWidget,
      );
      expect(
        find.text('Minimize animations and transitions'),
        findsOneWidget,
      );
      expect(
        find.text('Increase size of interactive elements'),
        findsOneWidget,
      );
    });

    testWidgets('AppBar back button has semantic tooltip', (tester) async {
      final service = await _makeService();
      await tester.pumpWidget(_buildScreen(service));
      await tester.pumpAndSettle();

      final backButton = tester.widget<IconButton>(
        find.byType(IconButton).first,
      );
      expect(backButton.tooltip, 'Go back to previous screen');
    });

    testWidgets('setting tiles have Semantics toggled property', (tester) async {
      final service = await _makeService();
      await tester.pumpWidget(_buildScreen(service));
      await tester.pumpAndSettle();

      // Each _SettingTile wraps a Semantics with toggled: value
      final semanticsNodes = tester
          .widgetList<Semantics>(find.byType(Semantics))
          .where((s) => s.properties.toggled != null)
          .toList();

      // Three toggleable semantic nodes (one per setting tile)
      expect(semanticsNodes.length, greaterThanOrEqualTo(3));
      for (final node in semanticsNodes) {
        expect(node.properties.toggled, isFalse);
      }
    });

    testWidgets('semantic toggle label changes after enabling High Contrast',
        (tester) async {
      final service = await _makeService();
      await tester.pumpWidget(_buildScreen(service));
      await tester.pumpAndSettle();

      // Before: semanticToggleOff('High Contrast') label present in tree
      expect(
        find.bySemanticsLabel(
            RegExp('High Contrast, currently off')),
        findsOneWidget,
      );

      await tester.tap(find.text('High Contrast'));
      await tester.pumpAndSettle();

      // After: semanticToggleOn('High Contrast') label present
      expect(
        find.bySemanticsLabel(
            RegExp('High Contrast, currently on')),
        findsOneWidget,
      );
    });

    testWidgets('body is wrapped in AccessibleGroup with accessibility label',
        (tester) async {
      final service = await _makeService();
      await tester.pumpWidget(_buildScreen(service));
      await tester.pumpAndSettle();

      // AccessibleGroup emits a Semantics container with label == accessibilityTitle
      final containers = tester
          .widgetList<Semantics>(find.byType(Semantics))
          .where((s) =>
              s.properties.label == 'Accessibility' && s.container == true)
          .toList();

      expect(containers, isNotEmpty);
    });
  });
}
