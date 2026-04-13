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
class F0043SprottLabyrinthChaosMetadata {
  static const instance = F0043SprottLabyrinthChaosMetadata._();
  const F0043SprottLabyrinthChaosMetadata._();

  String get id => 'f0043_sprott_labyrinth_chaos';
  String get name => 'Sprott Labyrinth Chaos';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Sprott-Labyrinth-Chaos',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'J. C. Sprott',
      title: 'Elegant Chaos: Algebraically Simple Chaotic Flows',
      year: 2010,
      url: 'https://sprott.physics.wisc.edu/pubs/paper356.pdf',
    ),
  ];
}
