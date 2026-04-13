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
class F0347CliffordWebMetadata {
  static const instance = F0347CliffordWebMetadata._();
  const F0347CliffordWebMetadata._();

  String get id => 'f0347_clifford_web';
  String get name => 'Clifford Web';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Clifford a=1.7 b=0.7 c=1.2 d=1.8',
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
