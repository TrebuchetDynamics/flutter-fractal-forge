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
class F1018SayamaSEvoloopMetadata {
  static const instance = F1018SayamaSEvoloopMetadata._();
  const F1018SayamaSEvoloopMetadata._();

  String get id => 'f1018_sayama_s_evoloop';
  String get name => 'Sayama\'s Evoloop';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'H. Sayama',
      title: 'A new structurally dissolvable self-reproducing loop evolving in a simple cellular automata space',
      year: 1999,
      url: 'https://doi.org/10.1162/106454699568665',
    ),
  ];
}
