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
class F0327MazeMetadata {
  static const instance = F0327MazeMetadata._();
  const F0327MazeMetadata._();

  String get id => 'f0327_maze';
  String get name => 'Maze';
  String get category => 'Cellular &amp; Stochastic';

  List<String> get aliases => const [
    'B3/S12345',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Mirek Wójtowicz',
      title: 'Maze CA',
      year: 1999,
      url: 'https://www.conwaylife.com/wiki/OCA:Maze',
    ),
  ];
}
