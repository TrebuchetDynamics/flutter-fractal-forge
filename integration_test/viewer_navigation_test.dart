// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_fractals/core/services/onboarding_service.dart';
import 'package:flutter_fractals/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Viewer navigation and dialog smoke test', (tester) async {
    // 1. Setup
    SharedPreferences.setMockInitialValues({
      'onboarding_complete': true,
    });

    app.main();
    // Allow app to settle initially
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // 2. Open Catalog
    expect(find.byType(MaterialApp), findsOneWidget);

    // Find and tap "Mandelbrot" card
    final fractalCard = find.text('Mandelbrot');
    expect(fractalCard, findsOneWidget);
    await tester.tap(fractalCard.first);
    
    // Pump frames for navigation animation (do NOT use pumpAndSettle due to infinite shader loop)
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    // 3. Verify Viewer matches
    expect(find.text('Mandelbrot'), findsOneWidget); // App bar title
    debugPrint('Viewer loaded successfully');
    
    // 4. Open Controls (tune icon)
    // Find tune icon
    final tuneIcon = find.byIcon(Icons.tune_rounded);
    expect(tuneIcon, findsOneWidget);
    await tester.tap(tuneIcon);
    
    // Pump for sheet animation
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    
    // Verify controls sheet content
    expect(find.text('Parameters'), findsOneWidget);
    debugPrint('Controls sheet opened successfully');
    
    // Close sheet by tapping scrim (top left of screen usually safe) or back button
    // Simulate back button which closes modal
    // await tester.pageBack(); // Can be flaky in tests
    // Try tapping outside
    await tester.tapAt(const Offset(10, 10));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 5. Open Presets (bookmark icon)
    final presetsBtn = find.byIcon(Icons.bookmark_rounded);
    expect(presetsBtn, findsOneWidget);
    await tester.tap(presetsBtn);
    
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    
    // Verify presets sheet
    expect(find.text('Presets'), findsOneWidget);
    debugPrint('Presets sheet opened successfully');
    
    // Close presets
    await tester.tapAt(const Offset(10, 10));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    
    debugPrint('Test completed successfully');
  });
}
