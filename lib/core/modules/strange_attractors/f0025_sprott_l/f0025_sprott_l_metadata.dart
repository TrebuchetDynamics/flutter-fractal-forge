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
class F0025SprottLMetadata {
  static const instance = F0025SprottLMetadata._();
  const F0025SprottLMetadata._();

  String get id => 'f0025_sprott_l';
  String get name => 'Sprott L';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Sprott-L',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'J. C. Sprott',
      title: 'Some simple chaotic flows',
      year: 1994,
      url: 'https://sprott.physics.wisc.edu/pubs/paper229.pdf',
    ),
    Citation(
      author: 'J. C. Sprott',
      title: 'A to S chaotic flows catalog',
      year: 1994,
      url: 'https://sprott.physics.wisc.edu/chaos/abchaos.htm',
    ),
  ];
}
