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
class F0047LorenzSystemMetadata {
  static const instance = F0047LorenzSystemMetadata._();
  const F0047LorenzSystemMetadata._();

  String get id => 'f0047_lorenz_system';
  String get name => 'Lorenz System';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Lorenz butterfly',
    'butterfly attractor',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'E. N. Lorenz',
      title: 'Deterministic nonperiodic flow',
      year: 1963,
      url: 'https://doi.org/10.1175/1520-0469(1963)020%3C0130:DNF%3E2.0.CO;2',
    ),
  ];
}
