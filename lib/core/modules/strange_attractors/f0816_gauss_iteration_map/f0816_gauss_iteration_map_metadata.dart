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
class F0816GaussIterationMapMetadata {
  static const instance = F0816GaussIterationMapMetadata._();
  const F0816GaussIterationMapMetadata._();

  String get id => 'f0816_gauss_iteration_map';
  String get name => 'Gauss Iteration Map';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'C. F. Gauss',
      title: 'Disquisitiones Arithmeticae',
      year: 1801,
      url: 'https://en.wikipedia.org/wiki/Gauss_map',
    ),
  ];
}
