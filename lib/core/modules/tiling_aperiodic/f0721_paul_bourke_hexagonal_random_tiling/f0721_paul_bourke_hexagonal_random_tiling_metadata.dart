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
class F0721PaulBourkeHexagonalRandomTilingMetadata {
  static const instance = F0721PaulBourkeHexagonalRandomTilingMetadata._();
  const F0721PaulBourkeHexagonalRandomTilingMetadata._();

  String get id => 'f0721_paul_bourke_hexagonal_random_tiling';
  String get name => 'Paul Bourke Hexagonal Random Tiling';
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
