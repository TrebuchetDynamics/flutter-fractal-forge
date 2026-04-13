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
class F0306ElementaryCaRule122Metadata {
  static const instance = F0306ElementaryCaRule122Metadata._();
  const F0306ElementaryCaRule122Metadata._();

  String get id => 'f0306_elementary_ca_rule_122';
  String get name => 'Elementary CA Rule 122';
  String get category => 'Cellular &amp; Stochastic';

  List<String> get aliases => const [
    'Wolfram rule 122',
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
