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
class F0694Wang11TileSetJeandelRaoMetadata {
  static const instance = F0694Wang11TileSetJeandelRaoMetadata._();
  const F0694Wang11TileSetJeandelRaoMetadata._();

  String get id => 'f0694_wang_11_tile_set_jeandel_rao';
  String get name => 'Wang 11-Tile Set (Jeandel-Rao)';
  String get category => 'Tiling & Aperiodic';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'E. Jeandel, M. Rao',
      title: 'An aperiodic set of 11 Wang tiles',
      year: 2015,
      url: 'https://arxiv.org/abs/1506.06492',
    ),
  ];
}
