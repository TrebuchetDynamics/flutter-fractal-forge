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
class F0712TTileTetrominoAperiodicMetadata {
  static const instance = F0712TTileTetrominoAperiodicMetadata._();
  const F0712TTileTetrominoAperiodicMetadata._();

  String get id => 'f0712_t_tile_tetromino_aperiodic';
  String get name => 'T-Tile (Tetromino Aperiodic)';
  String get category => 'Tiling & Aperiodic';

  List<String> get aliases => const [
    'T-tile',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: 'Tiling and rep-tiles',
      year: 2001,
      url: 'http://paulbourke.net/geometry/tilings/',
    ),
  ];
}
