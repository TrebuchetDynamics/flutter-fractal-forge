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
class F0973ElementaryCaRule230Metadata {
  static const instance = F0973ElementaryCaRule230Metadata._();
  const F0973ElementaryCaRule230Metadata._();

  String get id => 'f0973_elementary_ca_rule_230';
  String get name => 'Elementary CA Rule 230';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
    'Wolfram rule 230',
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
