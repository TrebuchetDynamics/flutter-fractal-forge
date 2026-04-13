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
class F0048Lorenz84Metadata {
  static const instance = F0048Lorenz84Metadata._();
  const F0048Lorenz84Metadata._();

  String get id => 'f0048_lorenz_84';
  String get name => 'Lorenz-84';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Lorenz 84',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'E. N. Lorenz',
      title: 'Irregularity: a fundamental property of the atmosphere',
      year: 1984,
      url: 'https://doi.org/10.1111/j.1600-0870.1984.tb00230.x',
    ),
  ];
}
