import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/ar/arcore_anchor_screen.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';

// A minimal 1x1 white pixel PNG for use as a dummy fractal texture.
// Generated from the standard PNG byte sequence for a 1x1 RGB image.
final Uint8List _dummyTexture = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, // IHDR chunk header
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, // 1x1 pixels
  0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53, // 8-bit RGB
  0xDE, 0x00, 0x00, 0x00, 0x0C, 0x49, 0x44, 0x41, // IDAT chunk header
  0x54, 0x08, 0xD7, 0x63, 0xF8, 0xCF, 0xC0, 0x00,
  0x00, 0x00, 0x02, 0x00, 0x01, 0xE2, 0x21, 0xBC,
  0x33, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, // IEND chunk
  0x44, 0xAE, 0x42, 0x60, 0x82,
]);

void main() {
  group('ArCoreAnchorScreen', () {
    late ModuleRegistry registry;
    late FractalController controller;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      registry = ModuleRegistry();
      controller = FractalController(registry);
    });

    Widget buildTestWidget({Uint8List? textureBytes, String? fractalName}) {
      return MultiProvider(
        providers: [
          Provider.value(value: registry),
          ChangeNotifierProvider.value(value: controller),
        ],
        child: MaterialApp(
          home: ArCoreAnchorScreen(
            fractalTextureBytes: textureBytes ?? _dummyTexture,
            fractalName: fractalName,
          ),
        ),
      );
    }

    // ArCoreView renders a "not supported" Text widget on non-Android
    // platforms (including the Linux test runner). The rest of the
    // Flutter widget chrome (top bar, bottom panel) renders normally.

    testWidgets('widget builds without crash on non-Android platform',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // No exception should propagate from the build.
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'constructor accepts fractalTextureBytes with optional fractalName',
        (tester) async {
      // Verify that ArCoreAnchorScreen can be constructed with both the
      // required byte buffer and the optional fractalName parameter.
      await tester.pumpWidget(buildTestWidget(
        textureBytes: _dummyTexture,
        fractalName: 'mandelbrot',
      ));
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('back button (arrow_back_rounded) is present in top bar',
        (tester) async {
      // The screen places a glass-pill back button in the top SafeArea.
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });

    testWidgets('fractalName parameter is shown in bottom panel when provided',
        (tester) async {
      // When fractalName is supplied it is displayed in the bottom panel
      // instead of the module id from FractalController.
      await tester.pumpWidget(
          buildTestWidget(fractalName: 'my_custom_fractal'));
      await tester.pump();

      expect(find.text('my_custom_fractal'), findsOneWidget);
    });

    testWidgets('falls back to module id when fractalName is null',
        (tester) async {
      // Without a fractalName the widget reads the id from FractalController.
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text(controller.module.id), findsOneWidget);
    });

    testWidgets('bottom panel contains Share, Save, Clear, Re-scan buttons',
        (tester) async {
      // The bottom action bar has four labelled buttons.
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Share'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Clear'), findsOneWidget);
      expect(find.text('Re-scan'), findsOneWidget);
    });

    testWidgets('bottom panel action icons are present', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.share_rounded), findsOneWidget);
      expect(find.byIcon(Icons.save_alt_rounded), findsOneWidget);
      expect(find.byIcon(Icons.delete_sweep_rounded), findsOneWidget);
      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
    });

    testWidgets('size slider is visible in bottom panel', (tester) async {
      // The pre-placement size slider is always shown in the bottom panel.
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(Slider), findsOneWidget);
      // The size label shows the current value in metres.
      expect(find.textContaining('Size:'), findsOneWidget);
    });

    testWidgets('status chip shows scanning message on startup',
        (tester) async {
      // Before any ARCore plane is detected the status chip reads
      // "Scanning for surfaces..." (the _StatusState.scanning text).
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Scanning for surfaces...'), findsOneWidget);
    });

    testWidgets('renders without exception on non-Android platform',
        (tester) async {
      // ArCoreView falls through to a "not supported" Text on Linux/macOS.
      // The widget shell must not throw.
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });

  group('ArCoreAnchorScreen.isSupportedOnDevice', () {
    test('returns false when native ARCore channel is unavailable', () async {
      TestWidgetsFlutterBinding.ensureInitialized();

      // In the test environment the MethodChannel for ARCore is not registered,
      // so checkArCoreAvailability() throws a MissingPluginException.
      // isSupportedOnDevice() catches any exception and returns false.
      final result = await ArCoreAnchorScreen.isSupportedOnDevice();
      expect(result, isFalse);
    });
  });
}
