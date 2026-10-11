import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';

void main() {
  const shaderAsset =
      'shaders/3d_and_hypercomplex/raymarched_volumes/mandelbulb_time_modulated_gpu.frag';
  const activeMandelbulbShader = 'shaders/legacy/raymarched_3d/mandelbulb.frag';

  test('time-modulated Mandelbulb passes pan into the shader target', () {
    final builder = File(
      'lib/core/modules/builders/raymarched_3d/builder.dart',
    ).readAsStringSync();
    final uniformLayout = File(
      'lib/core/modules/builders/uniform_layout.dart',
    ).readAsStringSync();
    final shader = File(shaderAsset).readAsStringSync();

    expect(builder, contains('setRaymarched3DFrameUniforms('));
    expect(builder, contains('view: state.view,'));
    expect(uniformLayout,
        contains('setFloat(Raymarched3DUniformSlots.panX, pan.x)'));
    expect(uniformLayout,
        contains('setFloat(Raymarched3DUniformSlots.panY, pan.y)'));
    expect(shader, contains('vec3 target = vec3(uMousePos, 0.0);'));
    expect(shader, contains('vec3 camPos = target + rot * vec3'));
  });

  test('time-modulated Mandelbulb shader compiles', () async {
    expect(await ui.FragmentProgram.fromAsset(shaderAsset), isNotNull);
  });

  test(
      'registered Mandelbulb shader uses its pan target and full camera rotation',
      () {
    final module = ModuleRegistry().byId('mandelbulb');
    expect(module.shaderAsset, activeMandelbulbShader);

    final shader = File(activeMandelbulbShader).readAsStringSync();
    expect(shader, contains('vec3 target = vec3(uMousePos, 0.0);'));
    expect(shader, contains('vec3 cameraPos = target + gRotation * vec3'));
    expect(
      shader,
      contains(
        'vec3 direction = normalize(gRotation * vec3(uv.x, uv.y, -1.0));',
      ),
    );
    expect(shader, contains('vec3 calculateLighting('));
    expect(
      shader,
      contains('vec3 position, vec3 normal, vec3 color, vec3 cameraPosition)'),
    );
    expect(shader, contains('normalize(cameraPosition - position)'));
    expect(
      shader,
      contains('calculateLighting(hit.xyz, normal, color, cameraPos);'),
    );
  });

  test('custom 3D modules use the shared camera uniform layout', () {
    const moduleSources = {
      'mandelbulb': 'lib/core/modules/fractals/mandelbulb_module.dart',
      'mandelbox': 'lib/core/modules/fractals/mandelbox_module.dart',
      'hydrogen_orbital':
          'lib/core/modules/fractals/hydrogen_orbital_module.dart',
      'quaternion_julia_3d':
          'lib/core/modules/fractals/quaternion_julia_3d_module.dart',
      'juliabulb_3d': 'lib/core/modules/fractals/juliabulb_3d_module.dart',
    };
    final registry = ModuleRegistry();
    final uniformPatterns = [
      RegExp(r'uniform\s+float\s+uTime\s*;'),
      RegExp(r'uniform\s+vec2\s+uResolution\s*;'),
      RegExp(r'uniform\s+vec2\s+uMousePos\s*;'),
      RegExp(r'uniform\s+float\s+uZoom\s*;'),
      RegExp(r'uniform\s+vec3\s+uRotation\s*;'),
    ];

    for (final entry in moduleSources.entries) {
      final module = registry.byId(entry.key);
      final shader = File(module.shaderAsset).readAsStringSync();
      final source = File(entry.value).readAsStringSync();
      final positions = uniformPatterns
          .map((pattern) => pattern.firstMatch(shader)?.start ?? -1)
          .toList();

      expect(source, contains('setRaymarched3DFrameUniforms('),
          reason: entry.key);
      expect(source, contains('view: state.view,'), reason: entry.key);
      expect(positions.every((position) => position >= 0), isTrue,
          reason: '${entry.key} must declare every shared camera uniform');
      expect(positions, orderedEquals([...positions]..sort()),
          reason: '${entry.key} shader uniform order must match shared slots');
    }
  });

  test('custom 3D shader assets compile with the shared layout', () async {
    const moduleIds = {
      'mandelbulb',
      'mandelbox',
      'hydrogen_orbital',
      'quaternion_julia_3d',
      'juliabulb_3d',
    };
    final modules = ModuleRegistry()
        .modules
        .where((module) => moduleIds.contains(module.id));

    expect(modules, hasLength(moduleIds.length));
    for (final module in modules) {
      expect(
        await ui.FragmentProgram.fromAsset(module.shaderAsset),
        isNotNull,
        reason: module.id,
      );
    }
  });

  test('all registered 3D shaders apply the shared pan target', () {
    final modules = ModuleRegistry()
        .modules
        .where((module) => module.dimension == FractalDimension.threeD);

    expect(modules, isNotEmpty);
    final ignoredModules = <String>[];
    for (final module in modules) {
      final shader = File(module.shaderAsset).readAsStringSync();
      final hasPanUsage = shader.split('\n').any((line) {
        final code = line.trimLeft();
        return !code.startsWith('//') &&
            !code.startsWith('uniform ') &&
            code.contains('uMousePos');
      });
      if (!hasPanUsage) {
        ignoredModules.add('${module.id} (${module.shaderAsset})');
      }
    }
    expect(
      ignoredModules,
      isEmpty,
      reason:
          '3D shaders ignoring the shared pan target: ${ignoredModules.join(', ')}',
    );
  });
}
