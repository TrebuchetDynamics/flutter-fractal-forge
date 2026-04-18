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
class F1229CriticalOrbitMapMetadata {
  static const instance = F1229CriticalOrbitMapMetadata._();
  const F1229CriticalOrbitMapMetadata._();

  String get id => 'f1229_critical_orbit_map';
  String get name => 'Critical Orbit Map';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'L. Carleson, T. W. Gamelin',
      title: 'Complex Dynamics',
      year: 1993,
      url: 'https://doi.org/10.1007/978-1-4612-4364-9',
    ),
  ];
}
