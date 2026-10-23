import 'dart:math' as math;

// Independent binomial expansion, deliberately not the shader's cmul chain.
(double, double) binomialPower(double x, double y, int n) {
  var re = 0.0, im = 0.0, choose = 1;
  for (var k = 0; k <= n; k++) {
    final term = choose * math.pow(x, n - k) * math.pow(y, k);
    switch (k % 4) {
      case 0:
        re += term;
      case 1:
        im += term;
      case 2:
        re -= term;
      case 3:
        im -= term;
    }
    if (k < n) choose = choose * (n - k) ~/ (k + 1);
  }
  return (re, im);
}

(double, double) orbitStep((double, double) z, (double, double) c) {
  final a = binomialPower(z.$1, z.$2, 5);
  final b = binomialPower(z.$1, z.$2, 3);
  final d = binomialPower(z.$1, z.$2, 2);
  return (a.$1 + b.$1 + 3 * d.$1 + c.$1, a.$2 + b.$2 + 3 * d.$2 + c.$2);
}

double escapeRadius(double cx, double cy, [double bailout = 4]) => [
      2.0,
      math.pow(12, 1 / 3).toDouble(),
      math.pow(4 * math.sqrt(cx * cx + cy * cy), 1 / 5).toDouble(),
      bailout
    ].reduce(math.max);

// Whether escape was observed among exactly N updates, including z_N.
bool escaped(double cx, double cy, int n, [double bailout = 4]) {
  final radius = escapeRadius(cx, cy, bailout);
  var z = (0.0, 0.0);
  for (var i = 0; i < n; i++) {
    z = orbitStep(z, (cx, cy));
    if (z.$1 * z.$1 + z.$2 * z.$2 > radius * radius) return true;
  }
  return false;
}
