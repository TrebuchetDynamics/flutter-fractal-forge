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
class F0359CliffordKnotMetadata {
  static const instance = F0359CliffordKnotMetadata._();
  const F0359CliffordKnotMetadata._();

  String get id => 'f0359_clifford_knot';
  String get name => 'Clifford Knot';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Clifford a=0.5 b=-1.3 c=2.0 d=-2.1',
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
