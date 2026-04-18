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
class F1084BogdanovChaosMetadata {
  static const instance = F1084BogdanovChaosMetadata._();
  const F1084BogdanovChaosMetadata._();

  String get id => 'f1084_bogdanov_chaos';
  String get name => 'Bogdanov Chaos';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Bogdanov k=1.5',
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
