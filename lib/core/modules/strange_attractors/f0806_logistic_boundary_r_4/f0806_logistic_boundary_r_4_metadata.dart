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
class F0806LogisticBoundaryR4Metadata {
  static const instance = F0806LogisticBoundaryR4Metadata._();
  const F0806LogisticBoundaryR4Metadata._();

  String get id => 'f0806_logistic_boundary_r_4';
  String get name => 'Logistic Boundary r=4';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'logistic r=4.0',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'R. M. May',
      title: 'Simple mathematical models with very complicated dynamics',
      year: 1976,
      url: 'https://doi.org/10.1038/261459a0',
    ),
  ];
}
