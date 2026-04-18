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
class F0700Rep4LTileMetadata {
  static const instance = F0700Rep4LTileMetadata._();
  const F0700Rep4LTileMetadata._();

  String get id => 'f0700_rep_4_l_tile';
  String get name => 'Rep-4 L-Tile';
  String get category => 'Tiling & Aperiodic';

  List<String> get aliases => const [
    'rep-tile 4',
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
