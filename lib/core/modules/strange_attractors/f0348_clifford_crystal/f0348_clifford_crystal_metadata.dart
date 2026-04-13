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
class F0348CliffordCrystalMetadata {
  static const instance = F0348CliffordCrystalMetadata._();
  const F0348CliffordCrystalMetadata._();

  String get id => 'f0348_clifford_crystal';
  String get name => 'Clifford Crystal';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Clifford a=-1.3 b=-1.3 c=-1.8 d=1.8',
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
