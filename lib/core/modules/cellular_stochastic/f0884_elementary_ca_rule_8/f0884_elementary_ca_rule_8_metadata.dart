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
class F0884ElementaryCaRule8Metadata {
  static const instance = F0884ElementaryCaRule8Metadata._();
  const F0884ElementaryCaRule8Metadata._();

  String get id => 'f0884_elementary_ca_rule_8';
  String get name => 'Elementary CA Rule 8';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
    'Wolfram rule 8',
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
