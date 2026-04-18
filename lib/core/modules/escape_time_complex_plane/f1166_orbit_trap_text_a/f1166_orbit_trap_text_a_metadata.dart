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
class F1166OrbitTrapTextAMetadata {
  static const instance = F1166OrbitTrapTextAMetadata._();
  const F1166OrbitTrapTextAMetadata._();

  String get id => 'f1166_orbit_trap_text_a';
  String get name => 'Orbit Trap Text \'A\'';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
    'text trap',
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
