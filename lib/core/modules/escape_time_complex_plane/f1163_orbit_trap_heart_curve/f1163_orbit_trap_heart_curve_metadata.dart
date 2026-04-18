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
class F1163OrbitTrapHeartCurveMetadata {
  static const instance = F1163OrbitTrapHeartCurveMetadata._();
  const F1163OrbitTrapHeartCurveMetadata._();

  String get id => 'f1163_orbit_trap_heart_curve';
  String get name => 'Orbit Trap Heart Curve';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
    'Heart trap',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'C. Pickover',
      title: 'Computers, Pattern, Chaos and Beauty',
      year: 1990,
      url: 'https://en.wikipedia.org/wiki/Orbit_trap',
    ),
  ];
}
