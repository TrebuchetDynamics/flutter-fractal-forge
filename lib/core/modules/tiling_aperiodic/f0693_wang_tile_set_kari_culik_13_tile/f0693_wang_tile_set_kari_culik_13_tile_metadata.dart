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
class F0693WangTileSetKariCulik13TileMetadata {
  static const instance = F0693WangTileSetKariCulik13TileMetadata._();
  const F0693WangTileSetKariCulik13TileMetadata._();

  String get id => 'f0693_wang_tile_set_kari_culik_13_tile';
  String get name => 'Wang Tile Set (Kari-Culik 13-tile)';
  String get category => 'Tiling & Aperiodic';

  List<String> get aliases => const [
    'Wang tiles',
    'Kari-Culik',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'J. Kari',
      title: 'A small aperiodic set of Wang tiles',
      year: 1996,
      url: 'https://doi.org/10.1016/0012-365X(94)00179-M',
    ),
  ];
}
