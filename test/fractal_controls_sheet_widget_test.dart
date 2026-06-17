import 'package:flutter/material.dart';
import 'package:flutter_fractals/features/controls/fractal_controls.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets(
      'FractalControlsSheet renders controls and Reset Params restores defaults',
      (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final controller = FractalController(ModuleRegistry());
    final defaultIterations = controller.params['iterations'] as int;
    expect(defaultIterations, greaterThan(0));

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: FractalControlsSheet()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Controls'), findsOneWidget);
    expect(find.text('Reset View'), findsOneWidget);
    expect(find.text('Reset Params'), findsOneWidget);
    expect(find.text('Randomize'), findsOneWidget);

    // Change controller state (as if user moved a slider elsewhere).
    controller.updateParam('iterations', 500);
    await tester.pumpAndSettle();
    expect(controller.params['iterations'], 500);

    // Actions live in a card below the parameter list, so scroll it in first.
    await tester.ensureVisible(find.text('Reset Params'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset Params'));
    await tester.pumpAndSettle();

    expect(controller.params['iterations'], defaultIterations);

    // Ensure we rendered sliders and chips for the default module.
    expect(find.byType(Slider), findsWidgets);
    // Chips may be rendered differently depending on platform/theme.
    expect(find.text('Color Scheme'), findsOneWidget);
  });
}
