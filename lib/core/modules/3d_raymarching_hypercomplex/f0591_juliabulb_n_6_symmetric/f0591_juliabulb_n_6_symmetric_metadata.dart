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
class F0591JuliabulbN6SymmetricMetadata {
  static const instance = F0591JuliabulbN6SymmetricMetadata._();
  const F0591JuliabulbN6SymmetricMetadata._();

  String get id => 'f0591_juliabulb_n_6_symmetric';
  String get name => 'Juliabulb n=6 symmetric';
  String get category => '3D Raymarching & Hypercomplex';

  List<String> get aliases => const [
    'Juliabulb n=6 c=(0.1, 0.0, 0.0)',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'D. White, P. Nylander',
      title: 'Mandelbulb (web page)',
      year: 2009,
      url: 'http://www.skytopia.com/project/fractal/mandelbulb.html',
    ),
  ];
}
