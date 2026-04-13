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
class F0350CliffordMistMetadata {
  static const instance = F0350CliffordMistMetadata._();
  const F0350CliffordMistMetadata._();

  String get id => 'f0350_clifford_mist';
  String get name => 'Clifford Mist';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Clifford a=-0.2 b=-1.1 c=-0.5 d=1.3',
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
