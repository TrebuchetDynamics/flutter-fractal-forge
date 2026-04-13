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
class F0085LangfordAttractorMetadata {
  static const instance = F0085LangfordAttractorMetadata._();
  const F0085LangfordAttractorMetadata._();

  String get id => 'f0085_langford_attractor';
  String get name => 'Langford Attractor';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'W. F. Langford',
      title: 'Numerical studies of torus bifurcations',
      year: 1984,
      url: 'https://doi.org/10.1007/978-3-0348-6256-1_19',
    ),
  ];
}
