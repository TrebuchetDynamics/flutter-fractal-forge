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
class F0354CliffordFlowerMetadata {
  static const instance = F0354CliffordFlowerMetadata._();
  const F0354CliffordFlowerMetadata._();

  String get id => 'f0354_clifford_flower';
  String get name => 'Clifford Flower';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Clifford a=-1.24 b=-1.25 c=-1.88 d=-1.11',
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
