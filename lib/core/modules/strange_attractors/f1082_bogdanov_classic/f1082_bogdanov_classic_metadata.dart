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
class F1082BogdanovClassicMetadata {
  static const instance = F1082BogdanovClassicMetadata._();
  const F1082BogdanovClassicMetadata._();

  String get id => 'f1082_bogdanov_classic';
  String get name => 'Bogdanov Classic';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Bogdanov k=1.2',
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
