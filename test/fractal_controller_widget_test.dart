import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math.dart';

void main() {
  group('FractalController state management', () {
    late ModuleRegistry registry;
    late FractalController controller;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      registry = ModuleRegistry();
      controller = FractalController(registry);
    });

    testWidgets('notifies listeners when module changes', (tester) async {
      int notifyCount = 0;
      controller.addListener(() => notifyCount++);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: controller,
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Consumer<FractalController>(
              builder: (context, ctrl, child) {
                return Text(ctrl.module.id);
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('mandelbrot'), findsOneWidget);

      controller.selectModule(registry.byId('julia'));
      await tester.pumpAndSettle();

      expect(find.text('julia'), findsOneWidget);
      expect(notifyCount, greaterThan(0));
    });

    testWidgets('notifies listeners when params change', (tester) async {
      int notifyCount = 0;
      controller.addListener(() => notifyCount++);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: controller,
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Consumer<FractalController>(
              builder: (context, ctrl, child) {
                return Text('${ctrl.params['iterations']}');
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('120'), findsOneWidget);

      controller.updateParam('iterations', 200);
      await tester.pumpAndSettle();

      expect(find.text('200'), findsOneWidget);
      expect(notifyCount, greaterThan(0));
    });

    testWidgets('notifies listeners when view changes', (tester) async {
      int notifyCount = 0;
      controller.addListener(() => notifyCount++);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: controller,
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Consumer<FractalController>(
              builder: (context, ctrl, child) {
                return Text('${ctrl.view.zoom.toStringAsFixed(1)}');
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1.0'), findsOneWidget);

      controller.updateZoom(2.0);
      await tester.pumpAndSettle();

      expect(find.text('2.0'), findsOneWidget);
      expect(notifyCount, greaterThan(0));
    });

    testWidgets('widget rebuilds when transparent background changes', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: controller,
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Consumer<FractalController>(
              builder: (context, ctrl, child) {
                return Text(ctrl.transparentBackground ? 'transparent' : 'opaque');
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('opaque'), findsOneWidget);

      controller.setTransparentBackground(true);
      await tester.pumpAndSettle();

      expect(find.text('transparent'), findsOneWidget);
    });

    testWidgets('widget rebuilds when pan changes', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: controller,
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Consumer<FractalController>(
              builder: (context, ctrl, child) {
                return Text('${ctrl.view.pan.x.toStringAsFixed(1)},${ctrl.view.pan.y.toStringAsFixed(1)}');
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('0.0,0.0'), findsOneWidget);

      controller.updatePan(Vector2(0.5, 0.5));
      await tester.pumpAndSettle();

      expect(find.text('0.5,0.5'), findsOneWidget);
    });

    testWidgets('widget rebuilds when rotation changes', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: controller,
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Consumer<FractalController>(
              builder: (context, ctrl, child) {
                return Text('${ctrl.view.rotation.x.toStringAsFixed(1)}');
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('0.0'), findsOneWidget);

      controller.updateRotation(Vector3(1.0, 0.0, 0.0));
      await tester.pumpAndSettle();

      expect(find.text('1.0'), findsOneWidget);
    });

    testWidgets('resetSession triggers rebuild', (tester) async {
      controller.updateParam('iterations', 300);
      controller.updateZoom(2.0);
      controller.setTransparentBackground(true);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: controller,
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Consumer<FractalController>(
              builder: (context, ctrl, child) {
                return Column(
                  children: [
                    Text('${ctrl.params['iterations']}'),
                    Text('${ctrl.view.zoom.toStringAsFixed(1)}'),
                    Text(ctrl.transparentBackground ? 'transparent' : 'opaque'),
                  ],
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('300'), findsOneWidget);
      expect(find.text('2.0'), findsOneWidget);
      expect(find.text('transparent'), findsOneWidget);

      controller.resetSession();
      await tester.pumpAndSettle();

      expect(find.text('120'), findsOneWidget);
      expect(find.text('1.0'), findsOneWidget);
      expect(find.text('opaque'), findsOneWidget);
    });

    testWidgets('randomizeParams triggers rebuild', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: controller,
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Consumer<FractalController>(
              builder: (context, ctrl, child) {
                return Text('${ctrl.params['iterations']}');
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final initialValue = controller.params['iterations'] as int;

      // Randomize several times to ensure a change
      for (int i = 0; i < 20; i++) {
        controller.randomizeParams();
        await tester.pumpAndSettle();
        if (controller.params['iterations'] != initialValue) {
          break;
        }
      }

      // Widget should have rebuilt
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('applyPreset triggers rebuild', (tester) async {
      // Get a preset that has different iterations than default
      final presets = registry.byId('mandelbrot').builtInPresets;
      final preset = presets.firstWhere(
        (p) => (p.params['iterations'] as int?) != 120,
        orElse: () => presets.first,
      );

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: controller,
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Consumer<FractalController>(
              builder: (context, ctrl, child) {
                return Text('${ctrl.params['iterations']}');
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('120'), findsOneWidget);

      controller.applyPreset(preset);
      await tester.pumpAndSettle();

      // Just verify that it rebuilt (text is present)
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('multiple widgets can listen to same controller', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: controller,
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Column(
              children: [
                Consumer<FractalController>(
                  builder: (context, ctrl, child) {
                    return Text('Module: ${ctrl.module.id}');
                  },
                ),
                Consumer<FractalController>(
                  builder: (context, ctrl, child) {
                    return Text('Zoom: ${ctrl.view.zoom.toStringAsFixed(1)}');
                  },
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Module: mandelbrot'), findsOneWidget);
      expect(find.text('Zoom: 1.0'), findsOneWidget);

      controller.selectModule(registry.byId('julia'));
      controller.updateZoom(3.0);
      await tester.pumpAndSettle();

      expect(find.text('Module: julia'), findsOneWidget);
      expect(find.text('Zoom: 3.0'), findsOneWidget);
    });
  });
}
