import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/viewer/chrome/fractal_controls_hud.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The viewer must choose the HUD's height before it builds the HUD, so the
/// height arithmetic lives in [ControlsHudMetrics] and both sides read it.
/// These tests pin the contract, not the widget tree that renders it.
void main() {
  late FractalController controller;
  late AccessibilityService accessibility;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    controller = FractalController(ModuleRegistry());
    accessibility = AccessibilityService(await SharedPreferences.getInstance());
  });

  tearDown(() {
    controller.dispose();
    accessibility.dispose();
  });

  /// Pumps the HUD at [height] and returns the metrics measured from its
  /// build context.
  Future<ControlsHudMetrics> measureHud(
    WidgetTester tester, {
    double height = 400,
    double textScale = 1,
    bool largeTargets = false,
    double bottomInset = 48,
    double gestureInset = 0,
  }) async {
    await accessibility.setLargeTargets(largeTargets);
    late ControlsHudMetrics metrics;
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<FractalController>.value(value: controller),
        ChangeNotifierProvider<AccessibilityService>.value(
            value: accessibility),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
            padding: EdgeInsets.only(bottom: bottomInset),
            viewPadding: EdgeInsets.only(bottom: bottomInset),
            systemGestureInsets: EdgeInsets.only(bottom: gestureInset),
          ),
          child: child!,
        ),
        home: Scaffold(
          body: Builder(builder: (context) {
            metrics = ControlsHudMetrics.of(context);
            return Stack(children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: height,
                child: const FractalControlsHud(),
              ),
            ]);
          }),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    return metrics;
  }

  Finder scrollAncestorOfHeader() => find.ancestor(
        of: find.byKey(const ValueKey('controlsHudDragHandle')),
        matching: find.byType(SingleChildScrollView),
      );

  testWidgets('minimum usable height is the header plus one body row',
      (tester) async {
    final metrics = await measureHud(tester);
    expect(
      metrics.minimumUsableHeight,
      metrics.headerHeight + 1 + metrics.bottomInset + metrics.touchTarget + 16,
    );
    expect(metrics.touchTarget, AccessibleSizing.minTouchTarget);
    expect(metrics.bottomInset, 48);
  });

  testWidgets('header scrolls only below the minimum usable height',
      (tester) async {
    final metrics = await measureHud(tester, height: 600);
    expect(metrics.headerScrolls(metrics.minimumUsableHeight), isFalse);
    expect(metrics.headerScrolls(metrics.minimumUsableHeight - 0.5), isTrue);

    expect(scrollAncestorOfHeader(), findsNothing);

    await measureHud(tester, height: metrics.minimumUsableHeight - 1);
    expect(scrollAncestorOfHeader(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('large targets raise the touch target and the minimum height',
      (tester) async {
    final normal = await measureHud(tester);
    final large = await measureHud(tester, largeTargets: true);
    expect(large.touchTarget, AccessibleSizing.largeTouchTarget);
    expect(
      large.minimumUsableHeight,
      greaterThan(normal.minimumUsableHeight),
    );
  });

  testWidgets('a title taller than the touch target raises the header',
      (tester) async {
    final normal = await measureHud(tester);
    // The header keeps one touch target of height until the scaled title is
    // taller than that target, at roughly 3x text on a 14px titleSmall.
    final scaled = await measureHud(tester, textScale: 3);
    expect(scaled.headerHeight, greaterThan(normal.headerHeight));
  });

  testWidgets('the largest bottom inset wins, as the HUD pads with it',
      (tester) async {
    final padding = await measureHud(tester, bottomInset: 48);
    final gesture = await measureHud(tester, bottomInset: 34, gestureInset: 50);
    expect(gesture.bottomInset, 50);
    expect(gesture.minimumUsableHeight,
        greaterThan(padding.minimumUsableHeight));
  });
}
