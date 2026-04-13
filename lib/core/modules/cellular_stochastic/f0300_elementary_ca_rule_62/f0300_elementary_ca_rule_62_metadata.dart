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
class F0300ElementaryCaRule62Metadata {
  static const instance = F0300ElementaryCaRule62Metadata._();
  const F0300ElementaryCaRule62Metadata._();

  String get id => 'f0300_elementary_ca_rule_62';
  String get name => 'Elementary CA Rule 62';
  String get category => 'Cellular &amp; Stochastic';

  List<String> get aliases => const [
    'Wolfram rule 62',
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
