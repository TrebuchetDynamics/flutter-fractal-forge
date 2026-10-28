import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/platform/deep_link_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart' show Vector2;

const _reportedUrl =
    'https://fractal.trebuchetdynamics.com/?t=f1102_fractal_flame_v1_sinusoidal'
    '&z=0.36192259106109115&x=0.06326771682388173&y=-0.2552528247585492'
    '&rx=0&ry=0&rz=0'
    '&p=eyJ-YiI6NS42LCJ-YyI6NjEsIn5pIjoxODUsInN5bW1ldHJ5IjowLCJ2YXJpYXRpb24iOjF9'
    '&transparent=false&rotationLocked=false&glowEnabled=false&glowSigma=1'
    '&glowIntensity=0.35&fluidModeEnabled=true&fluidStrength=1'
    '&kaleidoscopeEnabled=false&kaleidoscopeSectors=8&kaleidoscopeMirror=true'
    '&kaleidoscopeRotation=0&kaleidoscopeMirrorMode=0';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final module = ModuleRegistry().byId('f1102_fractal_flame_v1_sinusoidal');
  final reported = DeepLinkService.parseIncomingLink(_reportedUrl)!;

  Future<List<int>> render(
    String name, {
    Map<String, Object>? params,
    FractalViewState? view,
    bool transparent = false,
    double time = 0,
    int width = 160,
    int height = 160,
  }) async {
    final program = await ui.FragmentProgram.fromAsset(module.shaderAsset);
    final shader = program.fragmentShader();
    final size = ui.Size(width.toDouble(), height.toDouble());
    module.setUniforms(
      shader,
      FractalRenderState(
        params: params ?? module.defaultPreset.params,
        view: view ?? module.defaultPreset.view,
        transparentBackground: transparent,
      ),
      size,
      time,
    );
    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder)
        .drawRect(ui.Offset.zero & size, ui.Paint()..shader = shader);
    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);
    try {
      final output = Platform.environment['FLAME_PREVIEW_DIR'];
      if (output != null) {
        Directory(output).createSync(recursive: true);
        File('$output/$name.png').writeAsBytesSync(
          (await image.toByteData(format: ui.ImageByteFormat.png))!
              .buffer
              .asUint8List(),
        );
      }
      return (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!
          .buffer
          .asUint8List();
    } finally {
      image.dispose();
      picture.dispose();
      shader.dispose();
    }
  }

  test('reported link preserves parameters, camera and enabled fluid effect',
      () {
    expect(reported.type, module.id);
    expect(reported.toParams(), {
      'iterations': 185,
      'bailout': 5.6,
      'colorScheme': 61,
      'variation': 1,
      'symmetry': 0,
    });
    expect(reported.zoom, 0.36192259106109115);
    expect(reported.x, 0.06326771682388173);
    expect(reported.y, -0.2552528247585492);
    expect(reported.transparentBackground, isFalse);
    expect(reported.fluidModeEnabled, isTrue);
    expect(reported.fluidStrength, 1);
  });

  test('default square view contains the sinusoidal orbit with a margin', () {
    final view = module.defaultPreset.view;
    final radius = 0.5 / view.zoom;
    // Outward-rounded bounds of a time-zero orbit, not renderer-derived values.
    expect(view.pan.x - radius, lessThan(-0.55 - 0.07));
    expect(view.pan.x + radius, greaterThan(0.75 + 0.07));
    expect(view.pan.y - radius, lessThan(-0.22 - 0.07));
    expect(view.pan.y + radius, greaterThan(0.70 + 0.07));
  });

  test('default density separates the fine orbit from empty background',
      () async {
    final bytes = await render('default-transparent', transparent: true);
    var visible = 0;
    var clear = 0;
    for (var offset = 3; offset < bytes.length; offset += 4) {
      if (bytes[offset] > 127) visible++;
      if (bytes[offset] == 0) clear++;
    }
    final pixels = bytes.length ~/ 4;
    print(
        'Default density: visible=${visible / pixels}, clear=${clear / pixels}');
    expect(visible / pixels, inExclusiveRange(0.1, 0.8));
    expect(clear / pixels, greaterThan(0.15),
        reason:
            'A broad blurred kernel must not fill the entire default view.');
  });

  test('reported normal-map palette leaves distant background empty', () async {
    final opaque = await render('reported',
        params: reported.toParams(), view: reported.toViewState());
    final transparent = await render('reported-transparent',
        params: reported.toParams(),
        view: reported.toViewState(),
        transparent: true);
    for (final offset in [
      0,
      (160 - 1) * 4,
      (160 * 159) * 4,
      (160 * 160 - 1) * 4
    ]) {
      expect(opaque.sublist(offset, offset + 4), [0, 0, 0, 255],
          reason: 'Normal-map lighting must not illuminate zero density.');
      expect(transparent.sublist(offset, offset + 4), [0, 0, 0, 0]);
    }
    var visible = 0;
    for (var offset = 0; offset < opaque.length; offset += 4) {
      expect(opaque[offset + 3], 255);
      if (opaque[offset] + opaque[offset + 1] + opaque[offset + 2] > 24)
        visible++;
      expect(transparent[offset], lessThanOrEqualTo(transparent[offset + 3]));
    }
    expect(visible, greaterThan(300),
        reason: 'The captured orbit must remain visible.');
  });

  test('subpixel camera motion does not resample stochastic normal-map bands',
      () async {
    final view = reported.toViewState();
    final first = await render('coherence-first',
        params: reported.toParams(), view: view);
    final shifted = await render('coherence-shifted',
        params: reported.toParams(),
        view: view.copyWith(
            pan: view.pan + Vector2(0.01 / (160 * view.zoom), 0)));
    var difference = 0;
    for (var i = 0; i < first.length; i += 4) {
      for (var channel = 0; channel < 3; channel++) {
        difference += (first[i + channel] - shifted[i + channel]).abs();
      }
    }
    final meanDifference = difference / (160 * 160 * 3);
    print('0.01-pixel camera shift: mean RGB difference=$meanDifference');
    expect(meanDifference, lessThan(1),
        reason:
            'Tiny motion should translate a smooth field, not select new orbits.');
    expect(meanDifference, greaterThan(0));
  });

  test('minimum supported iteration count still draws a visible orbit',
      () async {
    final minimum =
        module.parameters.firstWhere((p) => p.id == 'iterations').min;
    final pixels = await render('minimum-iterations', params: {
      ...module.defaultPreset.params,
      'iterations': minimum,
    });
    var visible = 0;
    for (var i = 0; i < pixels.length; i += 4) {
      if (pixels[i] + pixels[i + 1] + pixels[i + 2] > 24) visible++;
    }
    expect(visible, greaterThan(300));
  });

  test(
      'sinusoidal rendering is repeatable, animated and honors iteration count',
      () async {
    final first = await render('default');
    expect(await render('default-replay'), orderedEquals(first));
    expect(await render('animated', time: 200), isNot(orderedEquals(first)));
    expect(
      await render('lower-iterations', params: {
        ...module.defaultPreset.params,
        'iterations': 50,
      }),
      isNot(orderedEquals(first)),
    );
  });
}
