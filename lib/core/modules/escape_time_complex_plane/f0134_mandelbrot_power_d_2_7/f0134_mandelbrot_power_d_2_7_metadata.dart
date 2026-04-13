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
class F0134MandelbrotPowerD27Metadata {
  static const instance = F0134MandelbrotPowerD27Metadata._();
  const F0134MandelbrotPowerD27Metadata._();

  String get id => 'f0134_mandelbrot_power_d_2_7';
  String get name => 'Mandelbrot Power (d=2.7)';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Wikipedia / Paul Bourke / Fractal Forums',
      title: 'Mandelbrot Power (d=2.7)',
      year: 2024,
      url: 'https://en.wikipedia.org/wiki/Multibrot_set',
    ),
  ];
}
