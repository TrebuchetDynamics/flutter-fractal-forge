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
class F0643PhoenixD2P01Metadata {
  static const instance = F0643PhoenixD2P01Metadata._();
  const F0643PhoenixD2P01Metadata._();

  String get id => 'f0643_phoenix_d_2_p_0_1';
  String get name => 'Phoenix d=2 p=0.1';
  String get category => 'Escape-Time (Complex Plane)';
  String get family => 'mandelbrot';

  List<String> get aliases => const [
    'Phoenix d=2 p=0.1',
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
