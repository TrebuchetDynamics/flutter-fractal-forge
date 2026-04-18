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
class F0683PenroseP1TilingMetadata {
  static const instance = F0683PenroseP1TilingMetadata._();
  const F0683PenroseP1TilingMetadata._();

  String get id => 'f0683_penrose_p1_tiling';
  String get name => 'Penrose P1 Tiling';
  String get category => 'Tiling & Aperiodic';

  List<String> get aliases => const [
    'P1',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'R. Penrose',
      title: 'The Role of Aesthetics in Pure and Applied Mathematical Research',
      year: 1974,
      url: 'https://en.wikipedia.org/wiki/Penrose_tiling',
    ),
  ];
}
