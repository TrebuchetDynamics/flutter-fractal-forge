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
class F0059ShimizuMoriokaMetadata {
  static const instance = F0059ShimizuMoriokaMetadata._();
  const F0059ShimizuMoriokaMetadata._();

  String get id => 'f0059_shimizu_morioka';
  String get name => 'Shimizu-Morioka';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'T. Shimizu, N. Morioka',
      title: 'Bifurcation of a symmetric limit cycle in a simple model',
      year: 1980,
      url: 'https://doi.org/10.1016/0375-9601(80)90363-5',
    ),
  ];
}
