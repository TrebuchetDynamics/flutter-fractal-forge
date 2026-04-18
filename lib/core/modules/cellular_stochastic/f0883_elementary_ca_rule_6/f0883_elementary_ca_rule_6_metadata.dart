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
class F0883ElementaryCaRule6Metadata {
  static const instance = F0883ElementaryCaRule6Metadata._();
  const F0883ElementaryCaRule6Metadata._();

  String get id => 'f0883_elementary_ca_rule_6';
  String get name => 'Elementary CA Rule 6';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
    'Wolfram rule 6',
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
