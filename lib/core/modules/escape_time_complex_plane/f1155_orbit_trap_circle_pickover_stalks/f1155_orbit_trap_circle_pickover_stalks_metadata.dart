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
class F1155OrbitTrapCirclePickoverStalksMetadata {
  static const instance = F1155OrbitTrapCirclePickoverStalksMetadata._();
  const F1155OrbitTrapCirclePickoverStalksMetadata._();

  String get id => 'f1155_orbit_trap_circle_pickover_stalks';
  String get name => 'Orbit Trap Circle (Pickover Stalks)';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
    'Pickover stalks',
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
