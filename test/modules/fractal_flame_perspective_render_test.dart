import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/platform/deep_link_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart' show Vector2;

const _reportedUrl =
    'https://fractal.trebuchetdynamics.com/?t=f1131_fractal_flame_v30_perspective'
    '&z=0.48294658264339185&x=0.08571551956964188&y=0.13766104243663269'
    '&rx=0&ry=0&rz=-0.3721352915540459'
    '&p=eyJ-YiI6Mi4xLCJ-YyI6MzksIn5pIjoxNzQsInN5bW1ldHJ5IjowLCJ2YXJpYXRpb24iOjMwfQ'
    '&transparent=false&rotationLocked=false&glowEnabled=false&glowSigma=1'
    '&glowIntensity=0.35&fluidModeEnabled=true&fluidStrength=1'
    '&kaleidoscopeEnabled=false&kaleidoscopeSectors=8&kaleidoscopeMirror=true'
    '&kaleidoscopeRotation=0&kaleidoscopeMirrorMode=0';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final module = ModuleRegistry().byId('f1131_fractal_flame_v30_perspective');
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
      final output = Platform.environment['PERSPECTIVE_PREVIEW_DIR'];
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

  test('reported perspective link preserves parameters, rotation and fluid',
      () {
    expect(reported.type, module.id);
    expect(reported.toParams(), {
      'iterations': 174,
      'bailout': 2.1,
      'colorScheme': 39,
      'variation': 30,
      'symmetry': 0,
    });
    expect(reported.zoom, 0.48294658264339185);
    expect(reported.x, 0.08571551956964188);
    expect(reported.y, 0.13766104243663269);
    expect(reported.toViewState().rotation.z, -0.3721352915540459);
    expect(reported.fluidModeEnabled, isTrue);
    expect(reported.fluidStrength, 1);
  });

  test('first projected sample has canonical perspective foreshortening',
      () async {
    // affine0(0)=(0.2,-0.1), distance=1, sin(tilt)=0.35.
    // Canonical V30: (x, cos(tilt)*y)/(1-sin(tilt)*y).
    // These independently evaluated coordinates catch the missing cosine term.
    final projected = Vector2(0.19323671497584542, -0.090507217365729);
    // Probe the Gaussian's unsaturated alpha tail, not an arbitrary palette.
    final weight = math.exp(-128 * 0.2 * 0.2);
    final logDensity = math.log(1 + 5 * weight) / math.log(6);
    final t = logDensity / 0.05;
    final expectedAlpha = (255 * t * t * (3 - 2 * t)).round();
    for (final offset in [Vector2(.2, 0), Vector2(0, .2), Vector2(0, -.2)]) {
      final bytes = await render('projection-${offset.x}-${offset.y}',
          width: 1,
          height: 1,
          transparent: true,
          params: {...module.defaultPreset.params, 'iterations': 1},
          view: module.defaultPreset.view.copyWith(pan: projected + offset));
      expect(bytes[3], closeTo(expectedAlpha, 2), reason: 'offset=$offset');
    }
  });

  test('default view contains the finite perspective body with a margin', () {
    final view = module.defaultPreset.view;
    final radius = .5 / view.zoom;
    // Outward-rounded bounds for the finite orbit body at bailout 2.1.
    expect(view.pan.x - radius, lessThan(-1.2 - .1));
    expect(view.pan.x + radius, greaterThan(1.55 + .1));
    expect(view.pan.y - radius, lessThan(-.4 - .1));
    expect(view.pan.y + radius, greaterThan(1.95 + .1));
  });

  test('default perspective branches have detail and empty background',
      () async {
    final bytes = await render('default-transparent', transparent: true);
    var visible = 0;
    var clear = 0;
    for (var i = 3; i < bytes.length; i += 4) {
      if (bytes[i] > 127) visible++;
      if (bytes[i] == 0) clear++;
      expect(bytes[i - 3], lessThanOrEqualTo(bytes[i]));
      expect(bytes[i - 2], lessThanOrEqualTo(bytes[i]));
      expect(bytes[i - 1], lessThanOrEqualTo(bytes[i]));
    }
    final pixels = bytes.length ~/ 4;
    print(
        'Perspective coverage: visible=${visible / pixels}, clear=${clear / pixels}');
    expect(visible / pixels, inExclusiveRange(.08, .75));
    expect(clear / pixels, greaterThan(.2));
  });

  test('subpixel camera motion translates rather than resamples the flame',
      () async {
    final view = reported.toViewState();
    final first =
        await render('reported', params: reported.toParams(), view: view);
    final shifted = await render('reported-shifted',
        params: reported.toParams(),
        view:
            view.copyWith(pan: view.pan + Vector2(.01 / (160 * view.zoom), 0)));
    var difference = 0;
    for (var i = 0; i < first.length; i += 4) {
      for (var c = 0; c < 3; c++) {
        difference += (first[i + c] - shifted[i + c]).abs();
      }
    }
    final mean = difference / (160 * 160 * 3);
    print('Perspective 0.01-pixel shift: mean RGB difference=$mean');
    expect(mean, inExclusiveRange(0, 1));
  });

  test('perspective bailout limits divergent samples instead of being ignored',
      () async {
    final narrow = await render('bailout-2.1',
        params: {...reported.toParams(), 'bailout': 2.1});
    final wide = await render('bailout-8',
        params: {...reported.toParams(), 'bailout': 8.0});
    expect(wide, isNot(orderedEquals(narrow)));
  });

  test('minimum iterations and animated normal palette remain visible',
      () async {
    final minimum =
        module.parameters.firstWhere((p) => p.id == 'iterations').min;
    for (final iterations in [minimum, 174]) {
      final first = await render('normal-$iterations',
          params: {
            ...reported.toParams(),
            'iterations': iterations,
            'colorScheme': 61
          },
          transparent: true);
      final again = await render('normal-replay-$iterations',
          params: {
            ...reported.toParams(),
            'iterations': iterations,
            'colorScheme': 61
          },
          transparent: true);
      expect(again, orderedEquals(first));
      var visible = 0;
      var clear = 0;
      for (var i = 0; i < first.length; i += 4) {
        if (first[i] + first[i + 1] + first[i + 2] > 24) visible++;
        if (first[i + 3] == 0) clear++;
        expect(first[i], lessThanOrEqualTo(first[i + 3]));
      }
      expect(visible, greaterThan(50));
      expect(clear, greaterThan(500));
    }
    final initial = await render('default');
    expect(await render('animated', time: 200), isNot(orderedEquals(initial)));
  });
}
