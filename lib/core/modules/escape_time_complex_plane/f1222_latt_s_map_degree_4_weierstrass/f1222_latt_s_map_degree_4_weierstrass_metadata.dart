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
class F1222LattSMapDegree4WeierstrassMetadata {
  static const instance = F1222LattSMapDegree4WeierstrassMetadata._();
  const F1222LattSMapDegree4WeierstrassMetadata._();

  String get id => 'f1222_latt_s_map_degree_4_weierstrass';
  String get name => 'Lattès Map (degree 4, Weierstrass)';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
    'Lattes degree 4',
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
