import 'package:flutter_fractals/features/viewer/export/viewer_export_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('share caption carries brand handle, hashtag, and fractal name', () {
    final caption = ViewerShareCaption.build(fractalName: 'Mandelbulb');

    expect(caption, contains('Mandelbulb'));
    expect(caption, contains('@FractalForgeApp'));
    expect(caption, contains('#fractal'));
  });

  test('share caption embeds a direct fractal URL when provided', () {
    const url =
        'https://fractal.trebuchetdynamics.com/?type=mandelbrot&zoom=10';
    final caption = ViewerShareCaption.build(
      fractalName: 'Mandelbrot',
      shareUrl: url,
    );

    expect(caption.split('\n'), contains(url));
    expect(caption, startsWith('Mandelbrot in Fractal Forge.'));
  });

  test('share caption omits the link line when no url is available', () {
    final caption = ViewerShareCaption.build(fractalName: 'Julia');

    expect(caption, isNot(contains('https://')));
    // Still discoverable: handle + hashtag are always present.
    expect(caption, contains('@FractalForgeApp'));
  });
}
