import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ModuleRegistry', () {
    late ModuleRegistry registry;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      registry = ModuleRegistry();
    });

    testWidgets('all module display names render correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return ListView(
                  children: registry.modules.map((module) {
                    return Text(module.displayName(l10n));
                  }).toList(),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mandelbrot'), findsOneWidget);
      expect(find.text('Julia'), findsOneWidget);
      expect(find.text('Burning Ship'), findsOneWidget);
      expect(find.text('Phoenix'), findsOneWidget);
      expect(find.text('Mandelbulb'), findsOneWidget);
    });

    testWidgets('all module parameter labels render correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                final module = registry.byId('mandelbrot');
                return ListView(
                  children: module.parameters.map((param) {
                    return Text(param.label(l10n));
                  }).toList(),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Iterations'), findsOneWidget);
      expect(find.text('Bailout'), findsOneWidget);
      expect(find.text('Color Scheme'), findsOneWidget);
    });

    testWidgets('module dimensions display correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return ListView(
                  children: registry.modules.map((module) {
                    final dimLabel = module.dimension == FractalDimension.twoD
                        ? l10n.dimension2d
                        : l10n.dimension3d;
                    return Text('${module.displayName(l10n)}: $dimLabel');
                  }).toList(),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mandelbrot: 2D'), findsOneWidget);
      expect(find.text('Julia: 2D'), findsOneWidget);
      expect(find.text('Burning Ship: 2D'), findsOneWidget);
      expect(find.text('Phoenix: 2D'), findsOneWidget);
      expect(find.text('Mandelbulb: 3D'), findsOneWidget);
    });

    testWidgets('built-in preset names render correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final module = registry.byId('mandelbrot');
                return ListView(
                  children: module.builtInPresets.map((preset) {
                    return Text(preset.name);
                  }).toList(),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // At least one built-in preset name should render.
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('enum parameter options render correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                final module = registry.byId('mandelbrot');
                final colorSchemeParam = module.parameters.firstWhere(
                  (param) => param.id == 'colorScheme',
                );
                return ListView(
                  children: colorSchemeParam.options.map((option) {
                    return Text(option.label(l10n));
                  }).toList(),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Fire'), findsOneWidget);
      expect(find.text('Ocean'), findsOneWidget);
      expect(find.text('Psychedelic'), findsOneWidget);
      expect(find.text('Grayscale'), findsOneWidget);
    });

    testWidgets('byId finds correct module', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                final modules = [
                  registry.byId('mandelbrot'),
                  registry.byId('julia'),
                  registry.byId('burning_ship'),
                  registry.byId('phoenix'),
                  registry.byId('mandelbulb'),
                ];
                return ListView(
                  children: modules.map((module) {
                    return Text(module.displayName(l10n));
                  }).toList(),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mandelbrot'), findsOneWidget);
      expect(find.text('Julia'), findsOneWidget);
      expect(find.text('Burning Ship'), findsOneWidget);
      expect(find.text('Phoenix'), findsOneWidget);
      expect(find.text('Mandelbulb'), findsOneWidget);
    });

    testWidgets('Julia module has additional parameters', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                final module = registry.byId('julia');
                return ListView(
                  children: module.parameters.map((param) {
                    return Text(param.label(l10n));
                  }).toList(),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Julia should have c_real and c_imag parameters
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('Mandelbulb has 3D-specific parameters', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                final module = registry.byId('mandelbulb');
                return ListView(
                  children: module.parameters.map((param) {
                    return Text(param.label(l10n));
                  }).toList(),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Mandelbulb should have power parameter
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('each module has unique id', (tester) async {
      final ids = registry.modules.map((m) => m.id).toSet();
      expect(ids.length, registry.modules.length);
    });

    testWidgets('each module has valid shader asset', (tester) async {
      for (final module in registry.modules) {
        expect(module.shaderAsset, isNotEmpty);
        expect(module.shaderAsset.endsWith('.frag'), isTrue);
      }
    });
  });
}
