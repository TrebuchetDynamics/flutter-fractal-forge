// Run-skill driver for Flutter Fractal Forge on Linux.
//
// run.sh copies this file to integration_test/zz_run_skill_driver_test.dart
// (so `flutter test -d linux` treats it as an integration test and the
// relative helper import resolves), runs it under Xvfb, then deletes the copy.
//
// It boots the real app, then executes STEPS (a `;`-separated list):
//   shot:<name>          screenshot the X screen to $CAPTURE_DIR/<name>.png
//   search:<query>       type into the catalog search field
//   open:<query>|<id>    search, then tap the card `catalogModuleCard_core.<id>`
//   set:<param>=<num>    FractalController.updateParam(param, num) in the viewer
//   wait:<seconds>       keep pumping frames
//   back                 pop the viewer route
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/ui_test_helpers.dart';

const _out = String.fromEnvironment('CAPTURE_DIR');
const _steps = String.fromEnvironment('STEPS', defaultValue: 'shot:catalog');

// Xvfb renders in software (~2-3 fps), so pump real time instead of
// pumpAndSettle, which never settles on animated viewers.
Future<void> _wait(WidgetTester tester, num seconds) async {
  for (var i = 0; i < seconds * 4; i++) {
    await tester.pump(const Duration(milliseconds: 250));
  }
}

final _viewer = find.byKey(const Key('fractalViewerRoot'));

FractalController _controller(WidgetTester tester) =>
    Provider.of<FractalController>(tester.element(_viewer), listen: false);

Future<void> _step(WidgetTester tester, String step) async {
  final i = step.indexOf(':');
  final verb = i < 0 ? step : step.substring(0, i);
  final arg = i < 0 ? '' : step.substring(i + 1);
  debugPrint('STEP $step');
  switch (verb) {
    case 'shot':
      await _wait(tester, 4);
      final r = await Process.run('import', ['-window', 'root', '$_out/$arg.png']);
      debugPrint('CAPTURE $arg exit=${r.exitCode} ${r.stderr}');
      expect(r.exitCode, 0, reason: 'ImageMagick import failed for $arg');
    case 'search':
      await enterCatalogSearch(tester, arg);
      await _wait(tester, 2);
    case 'open':
      final [query, id] = arg.split('|');
      await enterCatalogSearch(tester, query);
      await _wait(tester, 2);
      final card = catalogModuleCard('core.$id');
      expect(card, findsWidgets, reason: 'no catalog card core.$id for "$query"');
      await tester.ensureVisible(card.first);
      await tester.pump();
      await tester.tap(card.first);
      await _wait(tester, 3);
      expect(_viewer, findsOneWidget, reason: 'viewer did not open for $id');
    case 'set':
      final [key, value] = arg.split('=');
      _controller(tester).updateParam(key, num.parse(value));
      await _wait(tester, 1);
    case 'wait':
      await _wait(tester, num.parse(arg));
    case 'back':
      tester.state<NavigatorState>(find.byType(Navigator).first).pop();
      await _wait(tester, 2);
    default:
      fail('unknown step "$step"');
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('run-skill driver', (tester) async {
    expect(_out, isNotEmpty, reason: 'pass --dart-define=CAPTURE_DIR=...');
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(FlutterFractalsApp(
      presetStore: await PresetStore.create(),
      accessibilityService: await AccessibilityService.create(),
      rendererSettingsService: await RendererSettingsService.create(),
      locale: const Locale('en'),
    ));
    await pumpForAppBoot(tester);
    for (final step in _steps.split(';').where((s) => s.trim().isNotEmpty)) {
      await _step(tester, step.trim());
    }
  });
}
