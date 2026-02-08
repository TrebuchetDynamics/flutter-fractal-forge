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

void main() {
  group('ArOverlayScreen', () {
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

    testWidgets('shows permission denied UI when camera denied', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Should show some indication that camera permission is denied
      expect(find.byType(Icon), findsWidgets);
    });

    testWidgets('sets transparent background on init', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Controller should have transparent background enabled
      expect(controller.transparentBackground, isTrue);
    });

    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('has buttons in permission denied state', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(ElevatedButton), findsWidgets);
    });
  });
}
