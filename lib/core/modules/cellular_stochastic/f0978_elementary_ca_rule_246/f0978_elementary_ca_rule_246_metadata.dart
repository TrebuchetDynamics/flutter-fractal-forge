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
class F0978ElementaryCaRule246Metadata {
  static const instance = F0978ElementaryCaRule246Metadata._();
  const F0978ElementaryCaRule246Metadata._();

  String get id => 'f0978_elementary_ca_rule_246';
  String get name => 'Elementary CA Rule 246';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
    'Wolfram rule 246',
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
