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
class F0051RSslerHyperchaosMetadata {
  static const instance = F0051RSslerHyperchaosMetadata._();
  const F0051RSslerHyperchaosMetadata._();

  String get id => 'f0051_r_ssler_hyperchaos';
  String get name => 'Rössler Hyperchaos';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'O. E. Rössler',
      title: 'An equation for hyperchaos',
      year: 1979,
      url: 'https://doi.org/10.1016/0375-9601(79)90150-6',
    ),
  ];
}
