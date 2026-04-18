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
class F1177OrbitTrapFieldLinesMetadata {
  static const instance = F1177OrbitTrapFieldLinesMetadata._();
  const F1177OrbitTrapFieldLinesMetadata._();

  String get id => 'f1177_orbit_trap_field_lines';
  String get name => 'Orbit Trap Field Lines';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'C. T. McMullen',
      title: 'Complex Dynamics and Renormalization',
      year: 1994,
      url: 'https://en.wikipedia.org/wiki/External_ray',
    ),
  ];
}
