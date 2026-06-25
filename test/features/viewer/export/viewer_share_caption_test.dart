import 'package:flutter_fractals/features/viewer/export/viewer_export_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('share caption includes hashtag, fractal name, and camera coordinates',
      () {
    final caption = ViewerShareCaption.build(
      fractalName: 'Mandelbulb',
      cameraX: -0.125,
      cameraY: 0.5,
      cameraZ: 1200000,
      rotationX: 0.1,
      rotationY: -0.2,
      rotationZ: 0,
    );

    expect(caption, contains('#fractalforge'));
    expect(caption, contains('Mandelbulb'));
    expect(caption, contains('Camera x=-0.125 y=0.5 z=1.2000e+6'));
    expect(caption, contains('Rotation x=0.1 y=-0.2 z=0'));
  });
}
