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
class F0695RobinsonTilesMetadata {
  static const instance = F0695RobinsonTilesMetadata._();
  const F0695RobinsonTilesMetadata._();

  String get id => 'f0695_robinson_tiles';
  String get name => 'Robinson Tiles';
  String get category => 'Tiling & Aperiodic';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'R. M. Robinson',
      title: 'Undecidability and nonperiodicity for tilings of the plane',
      year: 1971,
      url: 'https://doi.org/10.1007/BF01418780',
    ),
  ];
}
