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
class F0823StandardMapK60Metadata {
  static const instance = F0823StandardMapK60Metadata._();
  const F0823StandardMapK60Metadata._();

  String get id => 'f0823_standard_map_k_6_0';
  String get name => 'Standard Map K=6.0';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'G. Casati et al.',
      title: 'Stochastic behavior of a quantum pendulum',
      year: 1979,
      url: 'https://en.wikipedia.org/wiki/Standard_map',
    ),
  ];
}
