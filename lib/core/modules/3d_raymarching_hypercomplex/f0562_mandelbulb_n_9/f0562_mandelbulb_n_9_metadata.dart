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
class F0562MandelbulbN9Metadata {
  static const instance = F0562MandelbulbN9Metadata._();
  const F0562MandelbulbN9Metadata._();

  String get id => 'f0562_mandelbulb_n_9';
  String get name => 'Mandelbulb n=9';
  String get category => '3D Raymarching & Hypercomplex';

  List<String> get aliases => const [
    'Mandelbulb power 9',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'D. White, P. Nylander',
      title: 'Mandelbulb (web page)',
      year: 2009,
      url: 'http://www.skytopia.com/project/fractal/mandelbulb.html',
    ),
    Citation(
      author: 'Paul Bourke',
      title: '3D Fractal catalog',
      year: 2010,
      url: 'http://paulbourke.net/fractals/',
    ),
  ];
}
