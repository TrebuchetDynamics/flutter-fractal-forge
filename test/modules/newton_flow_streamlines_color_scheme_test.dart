import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Newton-Flow Streamlines uses randomized color schemes for lines', () {
    final shader = File(
      'shaders/root_finding/newton_flow_streamlines_gpu.frag',
    ).readAsStringSync();

    expect(shader, contains('int scheme=int(clamp(floor(s+0.5),0.0,63.0))'));
    expect(shader, contains('lineColor=palette'));
    expect(shader, isNot(contains('vec3(0.7,0.9,1.0)*stream')));
  });
}
