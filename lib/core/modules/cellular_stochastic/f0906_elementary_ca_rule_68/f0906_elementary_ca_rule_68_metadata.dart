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
class F0906ElementaryCaRule68Metadata {
  static const instance = F0906ElementaryCaRule68Metadata._();
  const F0906ElementaryCaRule68Metadata._();

  String get id => 'f0906_elementary_ca_rule_68';
  String get name => 'Elementary CA Rule 68';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
    'Wolfram rule 68',
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
