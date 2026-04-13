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
class F0335SandPileModelBtwMetadata {
  static const instance = F0335SandPileModelBtwMetadata._();
  const F0335SandPileModelBtwMetadata._();

  String get id => 'f0335_sand_pile_model_btw';
  String get name => 'Sand Pile Model (BTW)';
  String get category => 'Cellular &amp; Stochastic';

  List<String> get aliases => const [
    'BTW sandpile',
    'sandpile model',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'P. Bak, C. Tang, K. Wiesenfeld',
      title: 'Self-organized criticality: An explanation of 1/f noise',
      year: 1987,
      url: 'https://doi.org/10.1103/PhysRevLett.59.381',
    ),
  ];
}
