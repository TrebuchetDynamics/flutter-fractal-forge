import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/ar_quality_store.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/main.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _DenyAllPermissions extends PermissionHandlerPlatform {
  @override
  Future<Map<Permission, PermissionStatus>> requestPermissions(List<Permission> permissions) async {
    return {
      for (final permission in permissions) permission: PermissionStatus.denied,
    };
  }

  @override
  Future<PermissionStatus> checkPermissionStatus(Permission permission) async {
    return PermissionStatus.denied;
  }
}

void main() {
  group('Localization', () {
    late PresetStore presetStore;
    late ArQualityStore arQualityStore;
    late ModuleRegistry registry;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      PermissionHandlerPlatform.instance = _DenyAllPermissions();
      presetStore = await PresetStore.create();
      arQualityStore = await ArQualityStore.create();
      registry = ModuleRegistry();
    });

    testWidgets('English locale shows English text', (tester) async {
      await tester.pumpWidget(
        FlutterFractalsApp(
          presetStore: presetStore,
          arQualityStore: arQualityStore,
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Fractal Catalog'), findsOneWidget);
      expect(find.text('Explore'), findsOneWidget);
      expect(find.text('AR'), findsOneWidget);
    });

    testWidgets('Spanish locale shows Spanish text', (tester) async {
      await tester.pumpWidget(
        FlutterFractalsApp(
          presetStore: presetStore,
          arQualityStore: arQualityStore,
          locale: const Locale('es'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Catálogo de Fractales'), findsOneWidget);
      expect(find.text('Explorar'), findsOneWidget);
      expect(find.text('RA'), findsOneWidget);
    });

    testWidgets('AppLocalizations can be obtained from context', (tester) async {
      AppLocalizations? capturedL10n;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              capturedL10n = AppLocalizations.of(context);
              return const Text('Test');
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(capturedL10n, isNotNull);
    });

    testWidgets('all localization keys work in English', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return ListView(
                children: [
                  Text(l10n.appTitle),
                  Text(l10n.catalogTitle),
                  Text(l10n.arTitle),
                  Text(l10n.tabExplore),
                  Text(l10n.tabAr),
                  Text(l10n.controlsTitle),
                  Text(l10n.presetsTitle),
                  Text(l10n.resetView),
                  Text(l10n.resetParams),
                  Text(l10n.randomize),
                  Text(l10n.savePreset),
                  Text(l10n.builtInPresets),
                  Text(l10n.userPresets),
                ],
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Fractal Forge'), findsOneWidget);
      expect(find.text('Fractal Catalog'), findsOneWidget);
      expect(find.text('AR Mode'), findsOneWidget);
      expect(find.text('Explore'), findsOneWidget);
      expect(find.text('AR'), findsOneWidget);
      expect(find.text('Controls'), findsOneWidget);
      expect(find.text('Presets'), findsOneWidget);
      expect(find.text('Reset View'), findsOneWidget);
      expect(find.text('Reset Params'), findsOneWidget);
      expect(find.text('Randomize'), findsOneWidget);
    });

    testWidgets('all localization keys work in Spanish', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return ListView(
                children: [
                  Text(l10n.appTitle),
                  Text(l10n.catalogTitle),
                  Text(l10n.arTitle),
                  Text(l10n.tabExplore),
                  Text(l10n.tabAr),
                  Text(l10n.controlsTitle),
                  Text(l10n.presetsTitle),
                ],
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Fractal Forge'), findsOneWidget);
      expect(find.text('Catálogo de Fractales'), findsOneWidget);
      expect(find.text('Modo RA'), findsOneWidget);
      expect(find.text('Explorar'), findsOneWidget);
      expect(find.text('RA'), findsOneWidget);
      expect(find.text('Controles'), findsOneWidget);
      expect(find.text('Ajustes Guardados'), findsOneWidget);
    });

    testWidgets('module names are localized', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider.value(value: registry),
            Provider.value(value: arQualityStore),
          ],
          child: MaterialApp(
            locale: const Locale('es'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
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

      // Module names should appear in the list
      expect(find.byType(Text), findsNWidgets(5));
    });

    testWidgets('dimension labels are localized', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Column(
                children: [
                  Text(l10n.dimension2d),
                  Text(l10n.dimension3d),
                ],
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2D'), findsOneWidget);
      expect(find.text('3D'), findsOneWidget);
    });

    testWidgets('export labels are localized', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Column(
                children: [
                  Text(l10n.exportPng),
                  Text(l10n.exportTransparentPng),
                  Text(l10n.exporting),
                  Text(l10n.exportSaved),
                ],
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Export PNG'), findsOneWidget);
      expect(find.text('Export Transparent PNG'), findsOneWidget);
      expect(find.text('Exporting...'), findsOneWidget);
      expect(find.text('Exported successfully!'), findsOneWidget);
    });

    testWidgets('preset labels are localized', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Column(
                children: [
                  Text(l10n.presetDefault),
                  Text(l10n.presetClassic),
                  Text(l10n.presetSoftGlow),
                  Text(l10n.presetPsychedelic),
                  Text(l10n.presetDeepBloom),
                ],
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Default'), findsOneWidget);
      expect(find.text('Classic'), findsOneWidget);
      expect(find.text('Soft Glow'), findsOneWidget);
      expect(find.text('Psychedelic'), findsOneWidget);
      expect(find.text('Deep Bloom'), findsOneWidget);
    });

    testWidgets('AR mode labels are localized', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return ListView(
                children: [
                  Text(l10n.arPermissionDenied),
                  Text(l10n.arPermissionRequest),
                  Text(l10n.arCameraUnavailable),
                ],
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Camera Permission Denied'), findsOneWidget);
    });

    testWidgets('parameter labels are localized', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Column(
                children: [
                  Text(l10n.paramIterations),
                  Text(l10n.paramBailout),
                  Text(l10n.paramColorScheme),
                ],
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Iterations'), findsOneWidget);
      expect(find.text('Bailout'), findsOneWidget);
      expect(find.text('Color Scheme'), findsOneWidget);
    });
  });
}
