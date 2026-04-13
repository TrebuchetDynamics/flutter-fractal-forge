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
class F0467ArithmeticSpiralMetadata {
  static const instance = F0467ArithmeticSpiralMetadata._();
  const F0467ArithmeticSpiralMetadata._();

  String get id => 'f0467_arithmetic_spiral';
  String get name => 'Arithmetic Spiral';
  String get category => 'Escape-Time (Complex Plane)';
  String get family => 'mandelbrot';

  List<String> get aliases => const [
    'view (-0.7432, 0.1319) zoom 20000.0',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Robert Munafo',
      title: 'Mu-Ency: The Encyclopedia of the Mandelbrot Set',
      year: 2023,
      url: 'https://mrob.com/pub/muency/',
    ),
    Citation(
      author: 'Wikipedia',
      title: 'Mandelbrot set',
      year: 2024,
      url: 'https://en.wikipedia.org/wiki/Mandelbrot_set',
    ),
  ];
}
