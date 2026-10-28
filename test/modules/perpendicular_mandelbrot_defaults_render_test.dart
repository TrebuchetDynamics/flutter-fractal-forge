import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/platform/deep_link_service.dart';
import 'package:flutter_test/flutter_test.dart';

const _reportUrl =
    'https://fractal.trebuchetdynamics.com/?t=perpendicular_mandelbrot'
    '&z=0.3650088278280761&x=-0.8066774018864231&y=0.10742852378999629'
    '&rx=0&ry=0&rz=0&p=eyJ-YiI6Ny45LCJ-YyI6NTksIn5pIjozN30'
    '&transparent=false&rotationLocked=false&glowEnabled=false&glowSigma=1'
    '&glowIntensity=0.35&fluidModeEnabled=true&fluidStrength=1'
    '&kaleidoscopeEnabled=false&kaleidoscopeSectors=8&kaleidoscopeMirror=true'
    '&kaleidoscopeRotation=0&kaleidoscopeMirrorMode=0';
const _size = 128;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final module = ModuleRegistry().byId('perpendicular_mandelbrot');
  final report = DeepLinkService.parseIncomingLink(_reportUrl)!;

  Future<Uint8List> render(String name,
      {Map<String, Object>? params,
      FractalViewState? view,
      bool transparent = false,
      int width = _size,
      int height = _size}) async {
    final program = await ui.FragmentProgram.fromAsset(module.shaderAsset);
    final shader = program.fragmentShader();
    ui.Picture? picture;
    ui.Image? image;
    try {
      final size = ui.Size(width.toDouble(), height.toDouble());
      module.setUniforms(
        shader,
        FractalRenderState(
          params: params ?? module.defaultPreset.params,
          view: view ?? module.defaultPreset.view,
          transparentBackground: transparent,
        ),
        size,
        0,
      );
      final recorder = ui.PictureRecorder();
      ui.Canvas(recorder)
          .drawRect(ui.Offset.zero & size, ui.Paint()..shader = shader);
      picture = recorder.endRecording();
      image = await picture.toImage(width, height);
      final output = Platform.environment['PERPENDICULAR_PREVIEW_DIR'];
      if (output != null) {
        Directory(output).createSync(recursive: true);
        File('$output/$name.png').writeAsBytesSync(
            (await image.toByteData(format: ui.ImageByteFormat.png))!
                .buffer
                .asUint8List());
      }
      final bytes =
          (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      return Uint8List.fromList(
          bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
    } finally {
      image?.dispose();
      picture?.dispose();
      shader.dispose();
    }
  }

  test('reported link retains its edited parameters, camera and fluid flag',
      () {
    expect(report.type, module.id);
    expect(report.toParams(),
        {'iterations': 37, 'bailout': 7.9, 'colorScheme': 59});
    expect(report.zoom, 0.3650088278280761);
    expect(report.x, -0.8066774018864231);
    expect(report.y, 0.10742852378999629);
    expect(report.toViewState().rotation.z, 0);
    expect(report.transparentBackground, isFalse);
    expect(report.glowEnabled, isFalse);
    expect(report.kaleidoscopeEnabled, isFalse);
    expect(report.fluidModeEnabled, isTrue);
    expect(report.fluidStrength, 1);
  });

  test('reported normal-palette frame renders nonuniform opaque output',
      () async {
    final pixels = await render('reported',
        params: report.toParams(), view: report.toViewState());
    final colors = <int>{};
    for (var i = 0; i < pixels.length; i += 4) {
      expect(pixels[i + 3], 255);
      colors.add((pixels[i] << 16) | (pixels[i + 1] << 8) | pixels[i + 2]);
    }
    expect(colors.length, greaterThan(80));
  });

  test('initial overview contains the bounded body with an exterior margin',
      () async {
    // Rendering alpha identifies the bounded interior without depending on the
    // palette's brightness. A close-up mistaken for the default clips this body.
    await render('default');
    for (final dimensions in [(128, 128), (128, 224), (224, 128)]) {
      final (width, height) = dimensions;
      final pixels = await render('default-$width-$height',
          transparent: true, width: width, height: height);
      var bounded = 0;
      var minX = width;
      var minY = height;
      var maxX = 0;
      var maxY = 0;
      for (var y = 0; y < height; y++) {
        for (var x = 0; x < width; x++) {
          if (pixels[(y * width + x) * 4 + 3] != 0) continue;
          bounded++;
          if (x < minX) minX = x;
          if (x > maxX) maxX = x;
          if (y < minY) minY = y;
          if (y > maxY) maxY = y;
        }
      }
      print('Perpendicular $width x $height: bounded=$bounded '
          'bounds=($minX,$minY)-($maxX,$maxY)');
      // Prevent solving clipping simply by shrinking the body to a speck.
      expect(bounded / (_size * _size), inExclusiveRange(.1, .3));
      expect(minX, greaterThanOrEqualTo(6));
      expect(minY, greaterThanOrEqualTo(6));
      expect(maxX, lessThan(width - 6));
      expect(maxY, lessThan(height - 6));
    }
  });

  test('overview detail agrees with a higher-iteration interior reference',
      () async {
    final pixels = await render('default-interior', transparent: true);
    final view = module.defaultPreset.view;
    var mismatch = 0;
    for (var y = 0; y < _size; y++) {
      for (var x = 0; x < _size; x++) {
        final cx = ((x + .5 - _size / 2) / _size) / view.zoom + view.pan.x;
        final cy = ((y + .5 - _size / 2) / _size) / view.zoom + view.pan.y;
        final reference = _boundedAt(cx, cy);
        if ((pixels[(y * _size + x) * 4 + 3] == 0) != reference) mismatch++;
      }
    }
    print('Perpendicular default vs 400-step reference: '
        '$mismatch/${_size * _size} disagree');
    expect(mismatch / (_size * _size), lessThan(.005));
    final iterations = module.defaultPreset.params['iterations'] as num;
    expect(iterations, lessThanOrEqualTo(160),
        reason: 'The initial overview should not silently hit the mobile cap.');
  });

  test('Stone Fold remains available as a separate detail view', () {
    final detail =
        module.builtInPresets.singleWhere((p) => p.id == 'perp-mandel-relief');
    expect(
        detail.params, {'iterations': 200, 'bailout': 4.0, 'colorScheme': 52});
    expect(detail.view.pan.x, -.5);
    expect(detail.view.pan.y, 0);
    expect(detail.view.zoom, 1);
    expect(module.defaultPreset.view.zoom, lessThan(detail.view.zoom));
  });
}

// Independent scalar membership oracle for the shader's existing recurrence.
// No renderer code or default parameters are used to compute its classification.
bool _boundedAt(double cx, double cy) {
  var x = 0.0;
  var y = 0.0;
  for (var i = 0; i < 400; i++) {
    final nextX = (x * x - y * y).abs() + cx;
    y = 2 * x * y + cy;
    x = nextX;
    if (x * x + y * y > 16) return false;
  }
  return true;
}
