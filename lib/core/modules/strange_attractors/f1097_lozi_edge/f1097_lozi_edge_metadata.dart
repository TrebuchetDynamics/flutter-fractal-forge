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
class F1097LoziEdgeMetadata {
  static const instance = F1097LoziEdgeMetadata._();
  const F1097LoziEdgeMetadata._();

  String get id => 'f1097_lozi_edge';
  String get name => 'Lozi Edge';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Lozi a=1.5 b=0.45',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'R. Lozi',
      title: 'Un attracteur étrange du type attracteur de Hénon',
      year: 1978,
      url: 'https://en.wikipedia.org/wiki/Lozi_map',
    ),
  ];
}
