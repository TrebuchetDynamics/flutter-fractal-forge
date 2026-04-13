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
class F0342CliffordSpiralsMetadata {
  static const instance = F0342CliffordSpiralsMetadata._();
  const F0342CliffordSpiralsMetadata._();

  String get id => 'f0342_clifford_spirals';
  String get name => 'Clifford Spirals';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Clifford a=-2.0 b=-2.0 c=-1.2 d=2.0',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Clifford A. Pickover',
      title: 'Chaos in Wonderland: Visual Adventures in a Fractal World',
      year: 1994,
      url: 'https://en.wikipedia.org/wiki/Clifford_A._Pickover',
    ),
    Citation(
      author: 'Paul Bourke',
      title: 'Clifford attractors',
      year: 2006,
      url: 'http://paulbourke.net/fractals/clifford/',
    ),
  ];
}
