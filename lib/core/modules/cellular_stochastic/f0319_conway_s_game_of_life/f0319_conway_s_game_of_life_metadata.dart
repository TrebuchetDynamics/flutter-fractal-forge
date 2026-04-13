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
class F0319ConwaySGameOfLifeMetadata {
  static const instance = F0319ConwaySGameOfLifeMetadata._();
  const F0319ConwaySGameOfLifeMetadata._();

  String get id => 'f0319_conway_s_game_of_life';
  String get name => 'Conway&#39;s Game of Life';
  String get category => 'Cellular &amp; Stochastic';

  List<String> get aliases => const [
    'Game of Life',
    'B3/S23',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Martin Gardner',
      title: 'Mathematical Games: The fantastic combinations of John Conway&#39;s new solitaire game &#39;life&#39;',
      year: 1970,
      url: 'https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life',
    ),
  ];
}
