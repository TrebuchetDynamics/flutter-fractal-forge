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
class F0797LogisticFixedPointMetadata {
  static const instance = F0797LogisticFixedPointMetadata._();
  const F0797LogisticFixedPointMetadata._();

  String get id => 'f0797_logistic_fixed_point';
  String get name => 'Logistic Fixed Point';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'logistic r=2.5',
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
