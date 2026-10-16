import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vector_math/vector_math_64.dart' show Vector2, Vector3;
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/features/renderer/widgets/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/main.dart';

import '../helpers/ui_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Zig-Zag icon saved state reopens in the actual app viewer',
      (tester) async {
    final path = Platform.environment['ICON_VIEW_STATE'] ??
        'build/test_output/zigzag-icon/raw/zigzag-palette-10.json';
    final saved =
        jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
    expect(saved['moduleId'], 'f0186_zig_zag_julia');
    SharedPreferences.setMockInitialValues({});
    final presetStore = await PresetStore.create();
    final accessibility = await AccessibilityService.create();
    final rendererSettings = await RendererSettingsService.create();
    final key = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
      key: key,
      child: FlutterFractalsApp(
        presetStore: presetStore,
        accessibilityService: accessibility,
        rendererSettingsService: rendererSettings,
        locale: const Locale('en'),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await enterCatalogSearch(tester, 'Zig-Zag Julia');
    final card = catalogModuleCard('core.f0186_zig_zag_julia');
    expect(card, findsOneWidget);
    await tester.ensureVisible(card);
    await tester.pumpAndSettle(const Duration(milliseconds: 80));
    await tester.tap(card);
    for (var frame = 0;
        frame < 100 && find.byType(FractalRenderer).evaluate().isEmpty;
        frame++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    final renderer = find.byType(FractalRenderer);
    expect(renderer, findsOneWidget);
    final controller =
        Provider.of<FractalController>(tester.element(renderer), listen: false);
    final v = saved['view'] as Map<String, dynamic>;
    final preset = FractalPreset(
      id: 'zigzag-app-icon-candidate',
      createdAt: DateTime.now().toUtc(),
      moduleId: saved['moduleId'] as String,
      name: 'Zig-Zag Julia icon candidate',
      params: Map<String, Object>.from(saved['params'] as Map),
      view: FractalViewState(
        pan: Vector2(
            (v['panX'] as num).toDouble(), (v['panY'] as num).toDouble()),
        zoom: (v['zoom'] as num).toDouble(),
        rotation: Vector3((v['rotX'] as num).toDouble(),
            (v['rotY'] as num).toDouble(), (v['rotZ'] as num).toDouble()),
      ),
    );
    controller.applyPreset(preset);
    await tester.pump(const Duration(seconds: 2));
    final widget = tester.widget<FractalRenderer>(renderer);
    final snapshot = widget.renderSnapshotSink?.snapshot;
    expect(snapshot, isNotNull,
        reason: 'Actual viewer must paint a renderer frame.');
    expect(snapshot!.module.id, saved['moduleId']);
    expect(snapshot.state.params, saved['params']);
    expect(snapshot.state.view.zoom, saved['view']['zoom']);
    expect(snapshot.state.view.pan.x, saved['view']['panX']);
    expect(snapshot.state.view.pan.y, saved['view']['panY']);
    expect(find.text('Shader Error'), findsNothing);
    final out = Directory('build/test_output/zigzag-icon')
      ..createSync(recursive: true);
    final presetJson =
        const JsonEncoder.withIndent('  ').convert(preset.toJson());
    File('${out.path}/preset.json').writeAsStringSync('$presetJson\n');
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1);
    final png = (await image.toByteData(format: ui.ImageByteFormat.png))!;
    image.dispose();
    File('${out.path}/viewer.png').writeAsBytesSync(png.buffer.asUint8List());
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
