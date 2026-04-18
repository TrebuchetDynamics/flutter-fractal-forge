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
class F0704TruchetTileClassicMetadata {
  static const instance = F0704TruchetTileClassicMetadata._();
  const F0704TruchetTileClassicMetadata._();

  String get id => 'f0704_truchet_tile_classic';
  String get name => 'Truchet Tile (Classic)';
  String get category => 'Tiling & Aperiodic';

  List<String> get aliases => const [
    'Truchet',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'S. Truchet',
      title: 'Mémoire sur les combinaisons',
      year: 1704,
      url: 'https://en.wikipedia.org/wiki/Truchet_tiles',
    ),
  ];
}
