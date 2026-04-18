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
class F1095LoziClassicMetadata {
  static const instance = F1095LoziClassicMetadata._();
  const F1095LoziClassicMetadata._();

  String get id => 'f1095_lozi_classic';
  String get name => 'Lozi Classic';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Lozi a=1.7 b=0.5',
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
