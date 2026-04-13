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
class F0471NeedleZoomMetadata {
  static const instance = F0471NeedleZoomMetadata._();
  const F0471NeedleZoomMetadata._();

  String get id => 'f0471_needle_zoom';
  String get name => 'Needle Zoom';
  String get category => 'Escape-Time (Complex Plane)';
  String get family => 'mandelbrot';

  List<String> get aliases => const [
    'view (-1.99999, 0.0) zoom 100000.0',
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
