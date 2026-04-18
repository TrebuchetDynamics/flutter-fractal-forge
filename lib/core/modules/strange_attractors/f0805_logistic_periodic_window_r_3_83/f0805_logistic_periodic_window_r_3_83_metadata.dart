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
class F0805LogisticPeriodicWindowR383Metadata {
  static const instance = F0805LogisticPeriodicWindowR383Metadata._();
  const F0805LogisticPeriodicWindowR383Metadata._();

  String get id => 'f0805_logistic_periodic_window_r_3_83';
  String get name => 'Logistic Periodic Window r=3.83';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'logistic r=3.83',
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
