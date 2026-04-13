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
class F0349CliffordLaceMetadata {
  static const instance = F0349CliffordLaceMetadata._();
  const F0349CliffordLaceMetadata._();

  String get id => 'f0349_clifford_lace';
  String get name => 'Clifford Lace';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Clifford a=-1.08 b=-1.1 c=0.73 d=-0.65',
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
