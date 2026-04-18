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
class F0952ElementaryCaRule178Metadata {
  static const instance = F0952ElementaryCaRule178Metadata._();
  const F0952ElementaryCaRule178Metadata._();

  String get id => 'f0952_elementary_ca_rule_178';
  String get name => 'Elementary CA Rule 178';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
    'Wolfram rule 178',
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
