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

    testWidgets('can navigate from catalog to viewer by tapping module', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mandelbrot'));
      await tester.pumpAndSettle();

      // Should show viewer with Mandelbrot title
      expect(find.byKey(const Key('fractalTestSurface')), findsOneWidget);
    });

    testWidgets('can navigate back from viewer to catalog', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Julia'));
      await tester.pumpAndSettle();

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Fractal Catalog'), findsOneWidget);
    });

    testWidgets('viewer shows correct module after navigation', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Burning Ship'));
      await tester.pumpAndSettle();

      // AppBar should show module name
      expect(find.text('Burning Ship'), findsNWidgets(1));
    });

    testWidgets('can open controls from viewer', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mandelbrot'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();

      expect(find.text('Controls'), findsOneWidget);
    });

    testWidgets('can open presets from viewer', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mandelbrot'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.bookmark));
      await tester.pumpAndSettle();

      expect(find.text('Presets'), findsOneWidget);
    });

    testWidgets('can apply preset and close sheet', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mandelbrot'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.bookmark));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Psychedelic'));
      await tester.pumpAndSettle();

      // Sheet should be closed
      expect(find.text('Presets'), findsNothing);
      // Renderer should be visible
      expect(find.byKey(const Key('fractalTestSurface')), findsOneWidget);
    });

    testWidgets('can navigate to different modules sequentially', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Go to Julia
      await tester.tap(find.text('Julia'));
      await tester.pumpAndSettle();
      expect(find.text('Julia'), findsOneWidget);

      // Go back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Go to Burning Ship
      await tester.tap(find.text('Burning Ship'));
      await tester.pumpAndSettle();
      expect(find.text('Burning Ship'), findsOneWidget);
    });

    testWidgets('can switch between Explore and AR tabs', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Fractal Catalog'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pumpAndSettle();

      expect(find.text('AR Mode'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.grid_view));
      await tester.pumpAndSettle();

      expect(find.text('Fractal Catalog'), findsOneWidget);
    });

    testWidgets('catalog search persists during navigation', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Search for Julia
      await tester.enterText(find.byKey(const Key('catalogSearchField')), 'Julia');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      // Navigate to Julia
      await tester.tap(find.text('Julia'));
      await tester.pumpAndSettle();

      // Go back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Catalog should be visible again
      expect(find.text('Fractal Catalog'), findsOneWidget);
    });

    testWidgets('3D module shows correct controls', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mandelbulb'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();

      expect(find.text('Controls'), findsOneWidget);
      expect(find.byType(Slider), findsWidgets);
    });

    testWidgets('export sheet opens from viewer', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mandelbrot'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.download));
      await tester.pumpAndSettle();

      expect(find.text('Export PNG'), findsOneWidget);
      expect(find.text('Export Transparent PNG'), findsOneWidget);
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

      // Should have localization delegates
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.localizationsDelegates, isNotEmpty);
    });
  });
}
