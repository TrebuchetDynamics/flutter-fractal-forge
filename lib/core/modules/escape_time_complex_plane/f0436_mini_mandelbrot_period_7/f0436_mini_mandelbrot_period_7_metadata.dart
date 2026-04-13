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
class F0436MiniMandelbrotPeriod7Metadata {
  static const instance = F0436MiniMandelbrotPeriod7Metadata._();
  const F0436MiniMandelbrotPeriod7Metadata._();

  String get id => 'f0436_mini_mandelbrot_period_7';
  String get name => 'Mini Mandelbrot (period 7)';
  String get category => 'Escape-Time (Complex Plane)';
  String get family => 'mandelbrot';

  List<String> get aliases => const [
    'view (-0.2282, 1.1151) zoom 500.0',
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
