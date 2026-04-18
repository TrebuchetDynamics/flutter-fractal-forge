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
class F1083BogdanovPeriod4Metadata {
  static const instance = F1083BogdanovPeriod4Metadata._();
  const F1083BogdanovPeriod4Metadata._();

  String get id => 'f1083_bogdanov_period_4';
  String get name => 'Bogdanov Period 4';
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
