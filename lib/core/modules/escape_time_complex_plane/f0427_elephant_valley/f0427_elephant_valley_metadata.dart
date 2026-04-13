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
class F0427ElephantValleyMetadata {
  static const instance = F0427ElephantValleyMetadata._();
  const F0427ElephantValleyMetadata._();

  String get id => 'f0427_elephant_valley';
  String get name => 'Elephant Valley';
  String get category => 'Escape-Time (Complex Plane)';
  String get family => 'mandelbrot';

  List<String> get aliases => const [
    'elephant valley',
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
