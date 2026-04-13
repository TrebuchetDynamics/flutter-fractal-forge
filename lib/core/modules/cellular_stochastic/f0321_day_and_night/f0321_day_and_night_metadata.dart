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
class F0321DayAndNightMetadata {
  static const instance = F0321DayAndNightMetadata._();
  const F0321DayAndNightMetadata._();

  String get id => 'f0321_day_and_night';
  String get name => 'Day and Night';
  String get category => 'Cellular &amp; Stochastic';

  List<String> get aliases => const [
    'B3678/S34678',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Nathan Thompson',
      title: 'Day and Night (cellular automaton)',
      year: 1997,
      url: 'https://en.wikipedia.org/wiki/Day_and_Night_(cellular_automaton)',
    ),
  ];
}
