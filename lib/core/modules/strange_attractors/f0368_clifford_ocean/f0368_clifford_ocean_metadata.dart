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
class F0368CliffordOceanMetadata {
  static const instance = F0368CliffordOceanMetadata._();
  const F0368CliffordOceanMetadata._();

  String get id => 'f0368_clifford_ocean';
  String get name => 'Clifford Ocean';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Clifford a=-2.0 b=1.9 c=0.3 d=1.3',
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
