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
class F0652PhoenixD7P05Metadata {
  static const instance = F0652PhoenixD7P05Metadata._();
  const F0652PhoenixD7P05Metadata._();

  String get id => 'f0652_phoenix_d_7_p_0_5';
  String get name => 'Phoenix d=7 p=-0.5';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
    'Phoenix d=7 p=-0.5',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'S. Ushiki',
      title: 'Phoenix: a new Mandelbrot-like set',
      year: 1988,
      url: 'https://en.wikipedia.org/wiki/Phoenix_(fractal)',
    ),
    Citation(
      author: 'Paul Bourke',
      title: 'Phoenix fractals',
      year: 2003,
      url: 'http://paulbourke.net/fractals/phoenix/',
    ),
  ];
}
