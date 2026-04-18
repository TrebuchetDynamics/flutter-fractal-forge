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
class F0706TruchetTileExtendedMultiArcMetadata {
  static const instance = F0706TruchetTileExtendedMultiArcMetadata._();
  const F0706TruchetTileExtendedMultiArcMetadata._();

  String get id => 'f0706_truchet_tile_extended_multi_arc';
  String get name => 'Truchet Tile (Extended Multi-Arc)';
  String get category => 'Tiling & Aperiodic';

  List<String> get aliases => const [
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
