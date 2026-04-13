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
class F0323LifeWithoutDeathMetadata {
  static const instance = F0323LifeWithoutDeathMetadata._();
  const F0323LifeWithoutDeathMetadata._();

  String get id => 'f0323_life_without_death';
  String get name => 'Life without Death';
  String get category => 'Cellular &amp; Stochastic';

  List<String> get aliases => const [
    'B3/S012345678',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'D. Griffeath, C. Moore',
      title: 'Life without death is P-complete',
      year: 1996,
      url: 'https://en.wikipedia.org/wiki/Life_without_Death',
    ),
  ];
}
