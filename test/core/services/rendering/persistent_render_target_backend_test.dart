import 'dart:ui' as ui;

import 'package:flutter_fractals/core/services/rendering/persistent_render_target_backend.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ensureTarget keeps a named image until size changes', () async {
    final backend = PersistentRenderTargetBackend();
    addTearDown(backend.dispose);

    final first = await backend.ensureTarget(name: 'dye', width: 4, height: 3);
    final again = await backend.ensureTarget(name: 'dye', width: 4, height: 3);

    expect(identical(first, again), isTrue);
    expect(backend.hasTarget('dye'), isTrue);
    expect(backend.imageOf('dye'), same(first));

    final resized =
        await backend.ensureTarget(name: 'dye', width: 2, height: 2);
    expect(identical(first, resized), isFalse);
    expect(backend.imageOf('dye'), same(resized));
  });

  test('frame exposes previous target image to shader pass binders', () async {
    final backend = PersistentRenderTargetBackend();
    addTearDown(backend.dispose);

    final previous = await backend.ensureTarget(
      name: 'velocity',
      width: 2,
      height: 2,
    );
    PersistentRenderTargetFrame? frame;

    await backend.renderPass(
      targetName: 'velocity',
      width: 2,
      height: 2,
      shaderAsset: 'shaders/diagnostic/test_uniform_only.frag',
      setUniforms: (ui.FragmentShader shader, PersistentRenderTargetFrame f) {
        frame = f;
        shader.setFloat(0, f.width.toDouble());
        shader.setFloat(1, f.height.toDouble());
      },
    );

    expect(frame?.previous, same(previous));
  });
}
