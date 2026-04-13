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
class F0337Rule184TrafficMetadata {
  static const instance = F0337Rule184TrafficMetadata._();
  const F0337Rule184TrafficMetadata._();

  String get id => 'f0337_rule_184_traffic';
  String get name => 'Rule 184 (Traffic)';
  String get category => 'Cellular &amp; Stochastic';

  List<String> get aliases => const [
    'Rule 184',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'S. Wolfram',
      title: 'Rule 184 (traffic)',
      year: 2002,
      url: 'https://mathworld.wolfram.com/ElementaryCellularAutomaton.html',
    ),
  ];
}
