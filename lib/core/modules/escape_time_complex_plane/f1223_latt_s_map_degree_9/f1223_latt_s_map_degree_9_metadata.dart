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
class F1223LattSMapDegree9Metadata {
  static const instance = F1223LattSMapDegree9Metadata._();
  const F1223LattSMapDegree9Metadata._();

  String get id => 'f1223_latt_s_map_degree_9';
  String get name => 'Lattès Map (degree 9)';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
    'Lattes degree 9',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'J. Milnor',
      title: 'Dynamics in one complex variable',
      year: 2006,
      url: 'https://en.wikipedia.org/wiki/Complex_dynamics',
    ),
  ];
}
