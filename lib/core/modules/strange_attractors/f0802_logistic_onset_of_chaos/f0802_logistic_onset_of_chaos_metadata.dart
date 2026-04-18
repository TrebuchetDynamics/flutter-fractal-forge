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
class F0802LogisticOnsetOfChaosMetadata {
  static const instance = F0802LogisticOnsetOfChaosMetadata._();
  const F0802LogisticOnsetOfChaosMetadata._();

  String get id => 'f0802_logistic_onset_of_chaos';
  String get name => 'Logistic Onset of Chaos';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'logistic r=3.5699456',
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
