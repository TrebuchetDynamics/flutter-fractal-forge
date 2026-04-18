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
class F0713Fibonacci1dSubstitutionMetadata {
  static const instance = F0713Fibonacci1dSubstitutionMetadata._();
  const F0713Fibonacci1dSubstitutionMetadata._();

  String get id => 'f0713_fibonacci_1d_substitution';
  String get name => 'Fibonacci 1D Substitution';
  String get category => 'Tiling & Aperiodic';

  List<String> get aliases => const [
    'Fibonacci tiling',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'N. P. Fogg',
      title: 'Substitutions in dynamics, arithmetics and combinatorics',
      year: 2002,
      url: 'https://doi.org/10.1007/b13861',
    ),
  ];
}
