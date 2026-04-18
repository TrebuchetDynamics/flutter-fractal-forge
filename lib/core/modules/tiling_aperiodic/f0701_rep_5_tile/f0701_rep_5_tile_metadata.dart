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
class F0701Rep5TileMetadata {
  static const instance = F0701Rep5TileMetadata._();
  const F0701Rep5TileMetadata._();

  String get id => 'f0701_rep_5_tile';
  String get name => 'Rep-5 Tile';
  String get category => 'Tiling & Aperiodic';

  List<String> get aliases => const [
    'rep-tile 5',
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
