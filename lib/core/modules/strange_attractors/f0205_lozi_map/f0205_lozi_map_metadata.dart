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
class F0205LoziMapMetadata {
  static const instance = F0205LoziMapMetadata._();
  const F0205LoziMapMetadata._();

  String get id => 'f0205_lozi_map';
  String get name => 'Lozi Map';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'R. Lozi',
      title: 'Un attracteur étrange du type attracteur de Hénon',
      year: 1978,
      url: 'https://doi.org/10.1051/jphyscol:1978505',
    ),
  ];
}
