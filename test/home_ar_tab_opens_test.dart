import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/ar_quality_store.dart';
import 'package:flutter_fractals/features/home/home_screen.dart';
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
  testWidgets('AR tab opens without Provider errors (permission denied path)', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

    // Avoid platform channels in widget tests.
    PermissionHandlerPlatform.instance = _DenyAllPermissions();

    final registry = ModuleRegistry();
    final arQualityStore = await ArQualityStore.create();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider.value(value: registry),
          Provider.value(value: arQualityStore),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomeScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Switch to AR tab.
    await tester.tap(find.byIcon(Icons.camera_alt));
    // Let permission request future complete.
    await tester.pumpAndSettle();

    // Should show permission denied UI state, not crash.
    expect(find.byIcon(Icons.no_photography), findsOneWidget);
  });
}
