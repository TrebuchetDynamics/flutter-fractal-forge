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
class F0557MandelbulbN4Metadata {
  static const instance = F0557MandelbulbN4Metadata._();
  const F0557MandelbulbN4Metadata._();

  String get id => 'f0557_mandelbulb_n_4';
  String get name => 'Mandelbulb n=4';
  String get category => '3D Raymarching & Hypercomplex';

  List<String> get aliases => const [
    'Mandelbulb power 4',
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
