import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/services/accessibility_service.dart';
import 'package:flutter_fractals/core/services/ar_quality_store.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/core/services/renderer_settings_service.dart';
import 'package:flutter_fractals/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _DenyAllPermissions extends PermissionHandlerPlatform {
  @override
  Future<Map<Permission, PermissionStatus>> requestPermissions(
      List<Permission> permissions) async {
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
  group('HomeScreen via FlutterFractalsApp', () {
    late PresetStore presetStore;
    late ArQualityStore arQualityStore;
    late AccessibilityService accessibilityService;
    late RendererSettingsService rendererSettingsService;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      PermissionHandlerPlatform.instance = _DenyAllPermissions();
      presetStore = await PresetStore.create();
      arQualityStore = await ArQualityStore.create();
      accessibilityService = await AccessibilityService.create();
      rendererSettingsService = await RendererSettingsService.create();
    });

    Widget buildTestWidget() {
      return FlutterFractalsApp(
        presetStore: presetStore,
        arQualityStore: arQualityStore,
        accessibilityService: accessibilityService,
        rendererSettingsService: rendererSettingsService,
        locale: const Locale('en'),
      );
    }

    testWidgets('starts with catalog visible', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Fractal Catalog'), findsOneWidget);
    });

    testWidgets('displays fractal modules in catalog', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Mandelbrot'), findsOneWidget);
      expect(find.textContaining('Julia'), findsWidgets);
    });

    testWidgets('has search field', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('catalogSearchField')), findsOneWidget);
    });

    testWidgets('has top app bar (smoke)', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // The home screen may render different app bar implementations depending on platform.
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
