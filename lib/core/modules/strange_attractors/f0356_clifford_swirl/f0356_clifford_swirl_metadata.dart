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
class F0356CliffordSwirlMetadata {
  static const instance = F0356CliffordSwirlMetadata._();
  const F0356CliffordSwirlMetadata._();

  String get id => 'f0356_clifford_swirl';
  String get name => 'Clifford Swirl';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Clifford a=-1.9 b=-1.9 c=1.3 d=-0.9',
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
