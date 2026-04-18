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
class F1086BogdanovBirthMetadata {
  static const instance = F1086BogdanovBirthMetadata._();
  const F1086BogdanovBirthMetadata._();

  String get id => 'f1086_bogdanov_birth';
  String get name => 'Bogdanov Birth';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Bogdanov k=1.0',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'R. I. Bogdanov',
      title: 'Bifurcations of a limit cycle for a family of vector fields on the plane',
      year: 1976,
      url: 'https://en.wikipedia.org/wiki/Bogdanov_map',
    ),
  ];
}
