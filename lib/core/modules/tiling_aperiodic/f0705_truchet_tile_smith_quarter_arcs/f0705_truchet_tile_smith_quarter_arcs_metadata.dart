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
class F0705TruchetTileSmithQuarterArcsMetadata {
  static const instance = F0705TruchetTileSmithQuarterArcsMetadata._();
  const F0705TruchetTileSmithQuarterArcsMetadata._();

  String get id => 'f0705_truchet_tile_smith_quarter_arcs';
  String get name => 'Truchet Tile (Smith Quarter-Arcs)';
  String get category => 'Tiling & Aperiodic';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Cyril S. Smith',
      title: 'The tiling patterns of Sebastien Truchet',
      year: 1987,
      url: 'https://en.wikipedia.org/wiki/Truchet_tiles',
    ),
  ];
}
