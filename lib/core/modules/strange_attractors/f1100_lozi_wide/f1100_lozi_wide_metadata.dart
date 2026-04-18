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
class F1100LoziWideMetadata {
  static const instance = F1100LoziWideMetadata._();
  const F1100LoziWideMetadata._();

  String get id => 'f1100_lozi_wide';
  String get name => 'Lozi Wide';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Lozi a=2.0 b=0.4',
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
