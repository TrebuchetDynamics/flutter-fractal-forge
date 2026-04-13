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
class F0367CliffordVeilMetadata {
  static const instance = F0367CliffordVeilMetadata._();
  const F0367CliffordVeilMetadata._();

  String get id => 'f0367_clifford_veil';
  String get name => 'Clifford Veil';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Clifford a=-1.95 b=1.83 c=0.52 d=-0.74',
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
