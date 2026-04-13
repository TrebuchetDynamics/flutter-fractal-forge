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
class F0028SprottOMetadata {
  static const instance = F0028SprottOMetadata._();
  const F0028SprottOMetadata._();

  String get id => 'f0028_sprott_o';
  String get name => 'Sprott O';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Sprott-O',
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
