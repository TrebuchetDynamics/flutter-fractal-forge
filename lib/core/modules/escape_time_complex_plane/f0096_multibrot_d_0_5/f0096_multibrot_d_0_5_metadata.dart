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
class F0096MultibrotD05Metadata {
  static const instance = F0096MultibrotD05Metadata._();
  const F0096MultibrotD05Metadata._();

  String get id => 'f0096_multibrot_d_0_5';
  String get name => 'Multibrot d=0.5';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
    'Multibrot z^0.5',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Wikipedia',
      title: 'Multibrot set',
      year: 2024,
      url: 'https://en.wikipedia.org/wiki/Multibrot_set',
    ),
    Citation(
      author: 'Paul Bourke',
      title: 'Multibrot fractals (fractal catalog)',
      year: 2003,
      url: 'http://paulbourke.net/fractals/multibrot/',
    ),
  ];
}
