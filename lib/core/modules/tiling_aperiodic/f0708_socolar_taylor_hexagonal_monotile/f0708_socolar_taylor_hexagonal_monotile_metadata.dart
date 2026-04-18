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
class F0708SocolarTaylorHexagonalMonotileMetadata {
  static const instance = F0708SocolarTaylorHexagonalMonotileMetadata._();
  const F0708SocolarTaylorHexagonalMonotileMetadata._();

  String get id => 'f0708_socolar_taylor_hexagonal_monotile';
  String get name => 'Socolar-Taylor Hexagonal Monotile';
  String get category => 'Tiling & Aperiodic';

  List<String> get aliases => const [
    'Socolar-Taylor',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'J. E. S. Socolar, J. M. Taylor',
      title: 'An aperiodic hexagonal tile',
      year: 2011,
      url: 'https://doi.org/10.1016/j.jcta.2010.11.002',
    ),
  ];
}
