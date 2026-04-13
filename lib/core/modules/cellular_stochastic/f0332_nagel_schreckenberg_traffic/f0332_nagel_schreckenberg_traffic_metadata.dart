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
class F0332NagelSchreckenbergTrafficMetadata {
  static const instance = F0332NagelSchreckenbergTrafficMetadata._();
  const F0332NagelSchreckenbergTrafficMetadata._();

  String get id => 'f0332_nagel_schreckenberg_traffic';
  String get name => 'Nagel-Schreckenberg Traffic';
  String get category => 'Cellular &amp; Stochastic';

  List<String> get aliases => const [
    'NaSch traffic',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'K. Nagel, M. Schreckenberg',
      title: 'A cellular automaton model for freeway traffic',
      year: 1992,
      url: 'https://doi.org/10.1051/jp1:1992277',
    ),
  ];
}
