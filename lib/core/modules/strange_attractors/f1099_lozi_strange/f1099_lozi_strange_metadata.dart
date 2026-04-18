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
class F1099LoziStrangeMetadata {
  static const instance = F1099LoziStrangeMetadata._();
  const F1099LoziStrangeMetadata._();

  String get id => 'f1099_lozi_strange';
  String get name => 'Lozi Strange';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Lozi a=1.3 b=0.7',
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
