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
class F0830BungalowPeriodDoublingMetadata {
  static const instance = F0830BungalowPeriodDoublingMetadata._();
  const F0830BungalowPeriodDoublingMetadata._();

  String get id => 'f0830_bungalow_period_doubling';
  String get name => 'Bungalow (Period-doubling)';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'R. M. May',
      title: 'Bifurcations and dynamic complexity in simple ecological models',
      year: 1976,
      url: 'https://en.wikipedia.org/wiki/Logistic_map',
    ),
  ];
}
