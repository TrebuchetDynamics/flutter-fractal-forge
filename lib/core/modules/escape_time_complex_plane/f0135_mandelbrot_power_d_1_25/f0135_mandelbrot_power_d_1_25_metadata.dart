// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class Citation {
  final String? author;
  final String? title;
  final int? year;
  final String url;
  const Citation({this.author, this.title, this.year, required this.url});
}

@immutable
class F0135MandelbrotPowerD125Metadata {
  static const instance = F0135MandelbrotPowerD125Metadata._();
  const F0135MandelbrotPowerD125Metadata._();

  String get id => 'f0135_mandelbrot_power_d_1_25';
  String get name => 'Mandelbrot Power (d=1.25)';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Wikipedia / Paul Bourke / Fractal Forums',
      title: 'Mandelbrot Power (d=1.25)',
      year: 2024,
      url: 'https://en.wikipedia.org/wiki/Multibrot_set',
    ),
  ];
}
