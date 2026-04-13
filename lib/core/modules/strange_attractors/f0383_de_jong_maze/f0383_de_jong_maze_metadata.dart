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
class F0383DeJongMazeMetadata {
  static const instance = F0383DeJongMazeMetadata._();
  const F0383DeJongMazeMetadata._();

  String get id => 'f0383_de_jong_maze';
  String get name => 'de Jong Maze';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'de Jong a=-1.7 b=-1.7 c=1.7 d=1.7',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Peter de Jong / Clifford Pickover',
      title: 'Symmetric de Jong attractors',
      year: 1988,
      url: 'http://paulbourke.net/fractals/peterdejong/',
    ),
  ];
}
