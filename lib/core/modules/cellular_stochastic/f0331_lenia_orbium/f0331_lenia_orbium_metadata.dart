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
class F0331LeniaOrbiumMetadata {
  static const instance = F0331LeniaOrbiumMetadata._();
  const F0331LeniaOrbiumMetadata._();

  String get id => 'f0331_lenia_orbium';
  String get name => 'Lenia (orbium)';
  String get category => 'Cellular &amp; Stochastic';

  List<String> get aliases => const [
    'Bert Chan Lenia',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Bert Wang-Chak Chan',
      title: 'Lenia — Biology of Artificial Life',
      year: 2019,
      url: 'https://arxiv.org/abs/1812.05433',
    ),
  ];
}
