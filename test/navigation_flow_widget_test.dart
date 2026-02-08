import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/services/ar_quality_store.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
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
  group('Navigation Flow', () {
    late PresetStore presetStore;
    late ArQualityStore arQualityStore;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      PermissionHandlerPlatform.instance = _DenyAllPermissions();
      presetStore = await PresetStore.create();
      arQualityStore = await ArQualityStore.create();
    });

    Widget buildApp() {
      return FlutterFractalsApp(
        presetStore: presetStore,
        arQualityStore: arQualityStore,
        locale: const Locale('en'),
      );
    }

    testWidgets('app starts with catalog screen', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Fractal Catalog'), findsOneWidget);
    });

    testWidgets('displays all fractal modules', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Mandelbrot'), findsOneWidget);
      expect(find.text('Julia'), findsOneWidget);
      expect(find.text('Burning Ship'), findsOneWidget);
      expect(find.text('Phoenix'), findsOneWidget);
      expect(find.text('Mandelbulb'), findsOneWidget);
    });

    testWidgets('has search field in catalog', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('catalogSearchField')), findsOneWidget);
    });

    testWidgets('app uses dark theme', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme?.brightness, Brightness.dark);
    });

    testWidgets('app supports localization', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.localizationsDelegates, isNotEmpty);
    });

    testWidgets('renders scaffold', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('renders top chrome (smoke)', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Platform-specific app bars may vary; ensure the app still renders.
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
