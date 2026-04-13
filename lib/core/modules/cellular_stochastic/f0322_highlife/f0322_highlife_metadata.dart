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
class F0322HighlifeMetadata {
  static const instance = F0322HighlifeMetadata._();
  const F0322HighlifeMetadata._();

  String get id => 'f0322_highlife';
  String get name => 'HighLife';
  String get category => 'Cellular &amp; Stochastic';

  List<String> get aliases => const [
    'B36/S23',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Nathan Thompson',
      title: 'HighLife',
      year: 1994,
      url: 'https://en.wikipedia.org/wiki/Highlife_(cellular_automaton)',
    ),
  ];
}
