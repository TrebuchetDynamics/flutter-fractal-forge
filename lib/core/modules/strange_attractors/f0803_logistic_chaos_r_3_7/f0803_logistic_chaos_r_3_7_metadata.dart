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
class F0803LogisticChaosR37Metadata {
  static const instance = F0803LogisticChaosR37Metadata._();
  const F0803LogisticChaosR37Metadata._();

  String get id => 'f0803_logistic_chaos_r_3_7';
  String get name => 'Logistic Chaos r=3.7';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'logistic r=3.7',
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
