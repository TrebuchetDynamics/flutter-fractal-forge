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
class F0799LogisticPeriod4Metadata {
  static const instance = F0799LogisticPeriod4Metadata._();
  const F0799LogisticPeriod4Metadata._();

  String get id => 'f0799_logistic_period_4';
  String get name => 'Logistic Period-4';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'logistic r=3.45',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'R. M. May',
      title: 'Simple mathematical models with very complicated dynamics',
      year: 1976,
      url: 'https://doi.org/10.1038/261459a0',
    ),
  ];
}
