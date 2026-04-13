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
class F0040SprottLinzHMetadata {
  static const instance = F0040SprottLinzHMetadata._();
  const F0040SprottLinzHMetadata._();

  String get id => 'f0040_sprott_linz_h';
  String get name => 'Sprott-Linz H';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Sprott-Linz-H',
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
