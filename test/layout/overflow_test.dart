import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/services/accessibility_service.dart';
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
      for (final p in permissions) p: PermissionStatus.denied,
    };
  }

  @override
  Future<PermissionStatus> checkPermissionStatus(Permission permission) async {
    return PermissionStatus.denied;
  }
}

/// Viewport configurations to test against.
const _viewports = <String, Size>{
  'medium_phone_375x812': Size(375, 812),
  'large_phone_428x926': Size(428, 926),
  'tablet_768x1024': Size(768, 1024),
};

/// Text scale factors to test.
const _textScales = <double>[1.0, 1.5, 2.0];

void main() {
  group('Layout overflow tests — HomeScreen / Catalog', () {
    late PresetStore presetStore;
    late AccessibilityService accessibilityService;
    late RendererSettingsService rendererSettingsService;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      PermissionHandlerPlatform.instance = _DenyAllPermissions();
      presetStore = await PresetStore.create();
      accessibilityService = await AccessibilityService.create();
      rendererSettingsService = await RendererSettingsService.create();
    });

    for (final viewport in _viewports.entries) {
      for (final textScale in _textScales) {
        testWidgets(
          'no overflow at ${viewport.key} textScale=$textScale',
          (tester) async {
            // Track overflow errors.
            final overflowErrors = <String>[];
            final originalOnError = FlutterError.onError;
            FlutterError.onError = (details) {
              final msg = details.exceptionAsString();
              if (msg.contains('overflowed') ||
                  msg.contains('OVERFLOW') ||
                  msg.contains('RenderFlex')) {
                overflowErrors.add(msg);
              } else {
                // Forward non-overflow errors to the default handler.
                originalOnError?.call(details);
              }
            };

            try {
              tester.view.physicalSize = viewport.value * tester.view.devicePixelRatio;
              tester.view.devicePixelRatio = tester.view.devicePixelRatio;

              await tester.pumpWidget(
                MediaQuery(
                  data: MediaQueryData(
                    size: viewport.value,
                    textScaler: TextScaler.linear(textScale),
                  ),
                  child: FlutterFractalsApp(
                    presetStore: presetStore,
                    accessibilityService: accessibilityService,
                    rendererSettingsService: rendererSettingsService,
                    locale: const Locale('en'),
                  ),
                ),
              );
              await tester.pumpAndSettle();

              if (overflowErrors.isNotEmpty) {
                // ignore: avoid_print
                print(
                  'OVERFLOW at ${viewport.key} textScale=$textScale:\n'
                  '${overflowErrors.join('\n')}',
                );
              }

              expect(
                overflowErrors,
                isEmpty,
                reason:
                    'Overflow detected at ${viewport.key} textScale=$textScale',
              );
            } finally {
              FlutterError.onError = originalOnError;
              tester.view.resetPhysicalSize();
              tester.view.resetDevicePixelRatio();
            }
          },
        );
      }
    }
  });
}
