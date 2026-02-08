import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/ar_quality_store.dart';
import 'package:flutter_fractals/features/ar/ar_overlay_screen.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
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

class _GrantAllPermissions extends PermissionHandlerPlatform {
  @override
  Future<Map<Permission, PermissionStatus>> requestPermissions(List<Permission> permissions) async {
    return {
      for (final permission in permissions) permission: PermissionStatus.granted,
    };
  }

  @override
  Future<PermissionStatus> checkPermissionStatus(Permission permission) async {
    return PermissionStatus.granted;
  }
}

void main() {
  group('ArOverlayScreen', () {
    late ModuleRegistry registry;
    late FractalController controller;
    late ArQualityStore arQualityStore;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      registry = ModuleRegistry();
      controller = FractalController(registry);
      arQualityStore = await ArQualityStore.create();
    });

    Widget buildTestWidget() {
      return MultiProvider(
        providers: [
          Provider.value(value: registry),
          ChangeNotifierProvider.value(value: controller),
          Provider.value(value: arQualityStore),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: ArOverlayScreen()),
        ),
      );
    }

    group('permission denied state', () {
      setUp(() {
        PermissionHandlerPlatform.instance = _DenyAllPermissions();
      });

      testWidgets('shows permission denied icon', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.no_photography), findsOneWidget);
      });

      testWidgets('shows permission denied title', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Camera Permission Denied'), findsOneWidget);
      });

      testWidgets('shows permission request message', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('AR mode needs camera access. Please allow the camera permission in settings.'), findsOneWidget);
      });

      testWidgets('shows Open Settings button', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Open Settings'), findsOneWidget);
        expect(find.widgetWithText(ElevatedButton, 'Open Settings'), findsOneWidget);
      });

      testWidgets('shows Retry button', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Retry'), findsOneWidget);
        expect(find.widgetWithText(OutlinedButton, 'Retry'), findsOneWidget);
      });

      testWidgets('tapping Retry attempts to reinitialize camera', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(OutlinedButton, 'Retry'));
        await tester.pumpAndSettle();

        // Should show permission denied again since still denied
        expect(find.byIcon(Icons.no_photography), findsOneWidget);
      });
    });

    group('camera unavailable state', () {
      setUp(() {
        // Grant permission but camera will still fail in tests
        PermissionHandlerPlatform.instance = _GrantAllPermissions();
      });

      testWidgets('shows camera unavailable state when no cameras', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // In test environment, availableCameras() will fail
        expect(
          find.byIcon(Icons.no_photography).evaluate().isNotEmpty ||
          find.byIcon(Icons.camera_alt_outlined).evaluate().isNotEmpty,
          isTrue,
        );
      });
    });

    group('AR controls (mocked camera)', () {
      setUp(() {
        PermissionHandlerPlatform.instance = _DenyAllPermissions();
      });

      testWidgets('sets transparent background on init', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Controller should have transparent background enabled
        expect(controller.transparentBackground, isTrue);
      });
    });
  });

  group('ArOverlayScreen UI elements', () {
    late ModuleRegistry registry;
    late FractalController controller;
    late ArQualityStore arQualityStore;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      PermissionHandlerPlatform.instance = _DenyAllPermissions();
      registry = ModuleRegistry();
      controller = FractalController(registry);
      arQualityStore = await ArQualityStore.create();
    });

    Widget buildTestWidget() {
      return MultiProvider(
        providers: [
          Provider.value(value: registry),
          ChangeNotifierProvider.value(value: controller),
          Provider.value(value: arQualityStore),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: ArOverlayScreen()),
        ),
      );
    }

    testWidgets('status state has centered content', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('has properly structured error message', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Icon, title, message, buttons should all be present
      expect(find.byType(Icon), findsWidgets);
      expect(find.byType(Text), findsWidgets);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
    });
  });
}
