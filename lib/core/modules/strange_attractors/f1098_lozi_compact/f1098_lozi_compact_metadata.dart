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
class F1098LoziCompactMetadata {
  static const instance = F1098LoziCompactMetadata._();
  const F1098LoziCompactMetadata._();

  String get id => 'f1098_lozi_compact';
  String get name => 'Lozi Compact';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Lozi a=1.8 b=0.6',
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
