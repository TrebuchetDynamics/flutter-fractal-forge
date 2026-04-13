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
class F0121HeartMandelbrotMetadata {
  static const instance = F0121HeartMandelbrotMetadata._();
  const F0121HeartMandelbrotMetadata._();

  String get id => 'f0121_heart_mandelbrot';
  String get name => 'Heart Mandelbrot';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Wikipedia / Paul Bourke / Fractal Forums',
      title: 'Heart Mandelbrot',
      year: 2024,
      url: 'http://paulbourke.net/fractals/',
    ),
  ];
}
