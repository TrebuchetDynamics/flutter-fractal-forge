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
class F0355CliffordDiskMetadata {
  static const instance = F0355CliffordDiskMetadata._();
  const F0355CliffordDiskMetadata._();

  String get id => 'f0355_clifford_disk';
  String get name => 'Clifford Disk';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Clifford a=2.0 b=2.0 c=1.0 d=1.0',
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
