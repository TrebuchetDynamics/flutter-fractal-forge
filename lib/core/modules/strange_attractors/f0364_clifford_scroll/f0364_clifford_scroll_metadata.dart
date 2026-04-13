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
class F0364CliffordScrollMetadata {
  static const instance = F0364CliffordScrollMetadata._();
  const F0364CliffordScrollMetadata._();

  String get id => 'f0364_clifford_scroll';
  String get name => 'Clifford Scroll';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Clifford a=1.4 b=1.5 c=-1.3 d=0.9',
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
