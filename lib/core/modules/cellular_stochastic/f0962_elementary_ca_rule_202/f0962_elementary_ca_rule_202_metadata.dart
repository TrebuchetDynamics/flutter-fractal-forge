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
class F0962ElementaryCaRule202Metadata {
  static const instance = F0962ElementaryCaRule202Metadata._();
  const F0962ElementaryCaRule202Metadata._();

  String get id => 'f0962_elementary_ca_rule_202';
  String get name => 'Elementary CA Rule 202';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
    'Wolfram rule 202',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'S. Wolfram',
      title: 'A New Kind of Science',
      year: 2002,
      url: 'https://mathworld.wolfram.com/ElementaryCellularAutomaton.html',
    ),
  ];
}
