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
class F0362CliffordTendrilsMetadata {
  static const instance = F0362CliffordTendrilsMetadata._();
  const F0362CliffordTendrilsMetadata._();

  String get id => 'f0362_clifford_tendrils';
  String get name => 'Clifford Tendrils';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Clifford a=-1.1 b=2.0 c=-1.7 d=1.3',
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
