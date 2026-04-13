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
class F0351CliffordStarMetadata {
  static const instance = F0351CliffordStarMetadata._();
  const F0351CliffordStarMetadata._();

  String get id => 'f0351_clifford_star';
  String get name => 'Clifford Star';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Clifford a=1.6 b=-0.6 c=-1.2 d=1.6',
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
