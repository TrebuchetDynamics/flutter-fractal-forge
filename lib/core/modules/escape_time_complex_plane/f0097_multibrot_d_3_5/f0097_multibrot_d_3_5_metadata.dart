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
class F0097MultibrotD35Metadata {
  static const instance = F0097MultibrotD35Metadata._();
  const F0097MultibrotD35Metadata._();

  String get id => 'f0097_multibrot_d_3_5';
  String get name => 'Multibrot d=3.5';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
    'Multibrot z^3.5',
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
