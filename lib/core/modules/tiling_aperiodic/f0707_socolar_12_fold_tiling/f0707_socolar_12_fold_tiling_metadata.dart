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
class F0707Socolar12FoldTilingMetadata {
  static const instance = F0707Socolar12FoldTilingMetadata._();
  const F0707Socolar12FoldTilingMetadata._();

  String get id => 'f0707_socolar_12_fold_tiling';
  String get name => 'Socolar 12-Fold Tiling';
  String get category => 'Tiling & Aperiodic';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'J. E. S. Socolar',
      title: 'Simple octagonal and dodecagonal quasicrystals',
      year: 1989,
      url: 'https://doi.org/10.1103/PhysRevB.39.10519',
    ),
  ];
}
