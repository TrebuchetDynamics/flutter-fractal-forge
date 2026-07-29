import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

const _shader = 'shaders/root_finding/zeta_newton_gpu.frag';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('zeta Newton basins is registered and shader-backed', () {
    final module =
        ModuleRegistry().modules.where((m) => m.id == 'zeta_newton').toList();
    expect(module, hasLength(1),
        reason: 'zeta_newton should be a single production module');
    expect(module.single.shaderAsset, _shader);
    expect(File(_shader).existsSync(), isTrue);
  });

  test('the shader evaluates zeta through the alternating series', () {
    // The plain Dirichlet sum only converges for Re(s) > 1, which excludes the
    // critical strip where every nontrivial zero lives. Lock the alternating
    // (Dirichlet eta) form and the reflection denominator so a future
    // simplification cannot quietly reintroduce a divergent sum.
    final src = File(_shader).readAsStringSync();
    expect(src, contains('sign = -sign'),
        reason: 'alternating series requires a sign flip per term');
    expect(src, contains('1 - 2^(1-s)'),
        reason: 'zeta(s) = eta(s) / (1 - 2^(1-s))');
    expect(src, contains('LN2'),
        reason: "eta's reflection factor and its derivative need log 2");
  });

  test('the default view frames the critical line', () {
    final module =
        ModuleRegistry().modules.firstWhere((m) => m.id == 'zeta_newton');
    final view = module.defaultPreset.view;
    // Nontrivial zeros sit on Re(s) = 1/2, the first few near Im(s) 14-25.
    expect(view.pan.x, closeTo(0.5, 1e-9),
        reason: 'should be centred on the critical line');
    expect(view.pan.y, greaterThan(5.0),
        reason: 'should look where the nontrivial zeros are');
  });

  test('zeta Newton shader compiles as a Flutter runtime effect', () async {
    final program = await ui.FragmentProgram.fromAsset(_shader);
    expect(program, isNotNull);
  }, timeout: const Timeout(Duration(seconds: 120)));
}
