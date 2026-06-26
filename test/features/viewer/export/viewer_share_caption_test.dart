import 'package:flutter_fractals/features/viewer/export/viewer_export_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('share caption carries brand handle, hashtag, and fractal name', () {
    final caption = ViewerShareCaption.build(fractalName: 'Mandelbulb');

    expect(caption, contains('Mandelbulb'));
    expect(caption, contains('@FractalForge'));
    expect(caption, contains('#fractalforge'));
  });

  test('share caption embeds the reproducible deep link when provided', () {
    const url =
        'https://fractal.trebuchetdynamics.com/view?type=mandelbrot&zoom=10';
    final caption = ViewerShareCaption.build(
      fractalName: 'Mandelbrot',
      shareUrl: url,
    );

    expect(caption, contains(url));
    expect(caption, contains('Open this exact view'));
  });

  test('share caption omits the link line when no url is available', () {
    final caption = ViewerShareCaption.build(fractalName: 'Julia');

    expect(caption, isNot(contains('Open this exact view')));
    // Still discoverable: handle + hashtag are always present.
    expect(caption, contains('@FractalForge'));
  });
}
