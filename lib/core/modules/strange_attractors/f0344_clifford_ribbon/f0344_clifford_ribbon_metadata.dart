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
class F0344CliffordRibbonMetadata {
  static const instance = F0344CliffordRibbonMetadata._();
  const F0344CliffordRibbonMetadata._();

  String get id => 'f0344_clifford_ribbon';
  String get name => 'Clifford Ribbon';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Clifford a=1.5 b=-1.8 c=1.6 d=0.9',
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
