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
class F0336LangtonSAntMultiColorMetadata {
  static const instance = F0336LangtonSAntMultiColorMetadata._();
  const F0336LangtonSAntMultiColorMetadata._();

  String get id => 'f0336_langton_s_ant_multi_color';
  String get name => 'Langton&#39;s Ant (multi-color)';
  String get category => 'Cellular &amp; Stochastic';

  List<String> get aliases => const [
    'generalized Langton&#39;s ant',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Chris Langton',
      title: 'Studying artificial life with cellular automata',
      year: 1986,
      url: 'https://doi.org/10.1016/0167-2789(86)90237-X',
    ),
  ];
}
