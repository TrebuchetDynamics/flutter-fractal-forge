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
class F0033SprottLinzAMetadata {
  static const instance = F0033SprottLinzAMetadata._();
  const F0033SprottLinzAMetadata._();

  String get id => 'f0033_sprott_linz_a';
  String get name => 'Sprott-Linz A';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Sprott-Linz-A',
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
