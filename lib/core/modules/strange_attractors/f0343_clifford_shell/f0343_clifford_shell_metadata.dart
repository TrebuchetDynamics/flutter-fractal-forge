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
class F0343CliffordShellMetadata {
  static const instance = F0343CliffordShellMetadata._();
  const F0343CliffordShellMetadata._();

  String get id => 'f0343_clifford_shell';
  String get name => 'Clifford Shell';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Clifford a=-1.24 b=1.1 c=-1.25 d=-1.02',
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
