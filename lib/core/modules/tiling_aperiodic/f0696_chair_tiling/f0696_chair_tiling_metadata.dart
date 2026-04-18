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
class F0696ChairTilingMetadata {
  static const instance = F0696ChairTilingMetadata._();
  const F0696ChairTilingMetadata._();

  String get id => 'f0696_chair_tiling';
  String get name => 'Chair Tiling';
  String get category => 'Tiling & Aperiodic';

  List<String> get aliases => const [
    'L-tromino',
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
