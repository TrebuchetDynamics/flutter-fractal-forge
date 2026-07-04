import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('quaternion Julia 3D ray basis uses the full rotation input', () {
    final shader = File(
      'shaders/3d_and_hypercomplex/raymarched_volumes/quaternion_julia_3d_gpu.frag',
    ).readAsStringSync();

    expect(shader, contains('vec3 camPos = target + rot * vec3'));
    expect(shader,
        contains('vec3 rayDir = normalize(rot * vec3(uv.x, uv.y, -1.5));'));
    expect(shader, isNot(contains('cross(vec3(0.0, 1.0, 0.0), forward)')));
  });
}
