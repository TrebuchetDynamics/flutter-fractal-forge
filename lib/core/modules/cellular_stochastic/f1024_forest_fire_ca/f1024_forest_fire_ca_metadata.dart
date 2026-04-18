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
class F1024ForestFireCaMetadata {
  static const instance = F1024ForestFireCaMetadata._();
  const F1024ForestFireCaMetadata._();

  String get id => 'f1024_forest_fire_ca';
  String get name => 'Forest Fire CA';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
    'Drossel-Schwabl',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'B. Drossel, F. Schwabl',
      title: 'Self-organized critical forest-fire model',
      year: 1992,
      url: 'https://doi.org/10.1103/PhysRevLett.69.1629',
    ),
  ];
}
