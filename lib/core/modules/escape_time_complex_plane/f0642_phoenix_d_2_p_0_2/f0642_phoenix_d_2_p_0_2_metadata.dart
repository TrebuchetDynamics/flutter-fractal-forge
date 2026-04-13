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
class F0642PhoenixD2P02Metadata {
  static const instance = F0642PhoenixD2P02Metadata._();
  const F0642PhoenixD2P02Metadata._();

  String get id => 'f0642_phoenix_d_2_p_0_2';
  String get name => 'Phoenix d=2 p=-0.2';
  String get category => 'Escape-Time (Complex Plane)';
  String get family => 'mandelbrot';

  List<String> get aliases => const [
    'Phoenix d=2 p=-0.2',
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
