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
class F0203HNonMapMetadata {
  static const instance = F0203HNonMapMetadata._();
  const F0203HNonMapMetadata._();

  String get id => 'f0203_h_non_map';
  String get name => 'Hénon Map';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Henon attractor',
    'Henon map',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'M. Hénon',
      title: 'A two-dimensional mapping with a strange attractor',
      year: 1976,
      url: 'https://doi.org/10.1007/BF01608556',
    ),
  ];
}
