import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('web app exposes X/Twitter card thumbnail metadata', () {
    final html = File('web/index.html').readAsStringSync();

    expect(html,
        contains('<meta name="twitter:card" content="summary_large_image">'));
    expect(
      html,
      contains(
        '<meta name="twitter:image" content="https://fractal.trebuchetdynamics.com/landing-assets/web_viewer_smoke.png">',
      ),
    );
    expect(
      html,
      contains(
        '<meta property="og:image" content="https://fractal.trebuchetdynamics.com/landing-assets/web_viewer_smoke.png">',
      ),
    );
  });
}
