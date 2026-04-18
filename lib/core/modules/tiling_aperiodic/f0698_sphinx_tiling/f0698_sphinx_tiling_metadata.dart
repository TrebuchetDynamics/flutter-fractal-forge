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
class F0698SphinxTilingMetadata {
  static const instance = F0698SphinxTilingMetadata._();
  const F0698SphinxTilingMetadata._();

  String get id => 'f0698_sphinx_tiling';
  String get name => 'Sphinx Tiling';
  String get category => 'Tiling & Aperiodic';

  List<String> get aliases => const [
    'Sphinx hexiamond',
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
