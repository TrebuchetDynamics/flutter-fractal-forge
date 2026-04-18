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
class F1005MazeWithMiceB37S12345Metadata {
  static const instance = F1005MazeWithMiceB37S12345Metadata._();
  const F1005MazeWithMiceB37S12345Metadata._();

  String get id => 'f1005_maze_with_mice_b37_s12345';
  String get name => 'Maze with Mice (B37/S12345)';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
    'B37-S12345',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Mirek Wójtowicz',
      title: 'Mirek\'s Cellebration database',
      year: 1999,
      url: 'https://www.mirekw.com/ca/',
    ),
  ];
}
