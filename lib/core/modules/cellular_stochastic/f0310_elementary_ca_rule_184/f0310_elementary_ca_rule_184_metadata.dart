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
class F0310ElementaryCaRule184Metadata {
  static const instance = F0310ElementaryCaRule184Metadata._();
  const F0310ElementaryCaRule184Metadata._();

  String get id => 'f0310_elementary_ca_rule_184';
  String get name => 'Elementary CA Rule 184';
  String get category => 'Cellular &amp; Stochastic';

  List<String> get aliases => const [
    'Wolfram rule 184',
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
