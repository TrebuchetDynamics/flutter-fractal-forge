import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/renderer/models/fractal_render_snapshot.dart';
import 'package:flutter_fractals/features/renderer/widgets/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/features/viewer/rendering/compare_renderer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('compare mode routes snapshots from only the active pane',
      (tester) async {
    final registry = ModuleRegistry();
    final controllerA = FractalController(registry);
    final controllerB = FractalController(registry);
    final sink = FractalRenderSnapshotSink();
    addTearDown(controllerA.dispose);
    addTearDown(controllerB.dispose);

    Future<void> pump(int activePane) => tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: controllerA,
            child: MaterialApp(
              home: CompareRenderer(
                keyA: GlobalKey(),
                keyB: GlobalKey(),
                controllerB: controllerB,
                sliderMode: false,
                divider: 0.5,
                activePane: activePane,
                onDividerChanged: (_) {},
                onActivePaneChanged: (_) {},
                onOpenControls: () {},
                onOpenPresets: () {},
                onOpenExport: () {},
                freezeFrame: false,
                activeSnapshotSink: sink,
              ),
            ),
          ),
        );

    await pump(0);
    var renderers = tester
        .widgetList<FractalRenderer>(find.byType(FractalRenderer))
        .toList();
    expect(renderers, hasLength(2));
    expect(renderers[0].renderSnapshotSink, same(sink));
    expect(renderers[1].renderSnapshotSink, isNull);

    await pump(1);
    renderers = tester
        .widgetList<FractalRenderer>(find.byType(FractalRenderer))
        .toList();
    expect(renderers[0].renderSnapshotSink, isNull);
    expect(renderers[1].renderSnapshotSink, same(sink));
  });
}
