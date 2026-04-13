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
class F0037SprottLinzEMetadata {
  static const instance = F0037SprottLinzEMetadata._();
  const F0037SprottLinzEMetadata._();

  String get id => 'f0037_sprott_linz_e';
  String get name => 'Sprott-Linz E';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Sprott-Linz-E',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'S. J. Linz, J. C. Sprott',
      title: 'Elementary chaotic flow',
      year: 1999,
      url: 'https://sprott.physics.wisc.edu/pubs/paper270.pdf',
    ),
  ];
}
