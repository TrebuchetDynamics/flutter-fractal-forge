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
class F0718Danzer7FoldTilingMetadata {
  static const instance = F0718Danzer7FoldTilingMetadata._();
  const F0718Danzer7FoldTilingMetadata._();

  String get id => 'f0718_danzer_7_fold_tiling';
  String get name => 'Danzer 7-Fold Tiling';
  String get category => 'Tiling & Aperiodic';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'L. Danzer',
      title: 'A family of 4D-spacefillers not yet classified',
      year: 1996,
      url: 'https://en.wikipedia.org/wiki/Danzer%27s_tiling',
    ),
  ];
}
