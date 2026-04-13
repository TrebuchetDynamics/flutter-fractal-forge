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
class F0061DadrasAttractorMetadata {
  static const instance = F0061DadrasAttractorMetadata._();
  const F0061DadrasAttractorMetadata._();

  String get id => 'f0061_dadras_attractor';
  String get name => 'Dadras Attractor';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'S. Dadras, H. R. Momeni',
      title: 'A novel three-dimensional autonomous chaotic system',
      year: 2009,
      url: 'https://doi.org/10.1016/j.physleta.2009.05.015',
    ),
  ];
}
