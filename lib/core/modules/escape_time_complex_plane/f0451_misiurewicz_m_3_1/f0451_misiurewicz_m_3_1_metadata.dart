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
class F0451MisiurewiczM31Metadata {
  static const instance = F0451MisiurewiczM31Metadata._();
  const F0451MisiurewiczM31Metadata._();

  String get id => 'f0451_misiurewicz_m_3_1';
  String get name => 'Misiurewicz M(3,1)';
  String get category => 'Escape-Time (Complex Plane)';
  String get family => 'mandelbrot';

  List<String> get aliases => const [
    'Misiurewicz 3,1',
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
