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
class F0647PhoenixD3P03Metadata {
  static const instance = F0647PhoenixD3P03Metadata._();
  const F0647PhoenixD3P03Metadata._();

  String get id => 'f0647_phoenix_d_3_p_0_3';
  String get name => 'Phoenix d=3 p=0.3';
  String get category => 'Escape-Time (Complex Plane)';
  String get family => 'multibrot_cubic';

  List<String> get aliases => const [
    'Phoenix d=3 p=0.3',
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
