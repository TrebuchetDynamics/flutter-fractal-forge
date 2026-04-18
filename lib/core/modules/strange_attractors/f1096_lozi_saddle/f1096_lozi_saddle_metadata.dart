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
class F1096LoziSaddleMetadata {
  static const instance = F1096LoziSaddleMetadata._();
  const F1096LoziSaddleMetadata._();

  String get id => 'f1096_lozi_saddle';
  String get name => 'Lozi Saddle';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Lozi a=1.4 b=0.3',
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
