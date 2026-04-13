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
class F0041SprottLinzIMetadata {
  static const instance = F0041SprottLinzIMetadata._();
  const F0041SprottLinzIMetadata._();

  String get id => 'f0041_sprott_linz_i';
  String get name => 'Sprott-Linz I';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Sprott-Linz-I',
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
