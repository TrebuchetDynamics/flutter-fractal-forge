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
class F0208CliffordAttractorMetadata {
  static const instance = F0208CliffordAttractorMetadata._();
  const F0208CliffordAttractorMetadata._();

  String get id => 'f0208_clifford_attractor';
  String get name => 'Clifford Attractor';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Clifford A. Pickover',
      title: 'Chaos in Wonderland',
      year: 1994,
      url: 'https://paulbourke.net/fractals/clifford/',
    ),
  ];
}
