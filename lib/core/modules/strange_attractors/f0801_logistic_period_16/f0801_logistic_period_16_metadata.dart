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
class F0801LogisticPeriod16Metadata {
  static const instance = F0801LogisticPeriod16Metadata._();
  const F0801LogisticPeriod16Metadata._();

  String get id => 'f0801_logistic_period_16';
  String get name => 'Logistic Period-16';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'logistic r=3.564',
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
