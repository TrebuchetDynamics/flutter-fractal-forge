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
class F0098MultibrotD45Metadata {
  static const instance = F0098MultibrotD45Metadata._();
  const F0098MultibrotD45Metadata._();

  String get id => 'f0098_multibrot_d_4_5';
  String get name => 'Multibrot d=4.5';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
    'Multibrot z^4.5',
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
