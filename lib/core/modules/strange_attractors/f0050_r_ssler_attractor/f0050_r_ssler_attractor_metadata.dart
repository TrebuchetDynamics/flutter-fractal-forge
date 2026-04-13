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
class F0050RSslerAttractorMetadata {
  static const instance = F0050RSslerAttractorMetadata._();
  const F0050RSslerAttractorMetadata._();

  String get id => 'f0050_r_ssler_attractor';
  String get name => 'Rössler Attractor';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Roessler',
    'Rossler',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'O. E. Rössler',
      title: 'An equation for continuous chaos',
      year: 1976,
      url: 'https://doi.org/10.1016/0375-9601(76)90101-8',
    ),
  ];
}
