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
class F0820LotkaVolterraDiscreteMetadata {
  static const instance = F0820LotkaVolterraDiscreteMetadata._();
  const F0820LotkaVolterraDiscreteMetadata._();

  String get id => 'f0820_lotka_volterra_discrete';
  String get name => 'Lotka-Volterra Discrete';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'M. P. Hassell',
      title: 'The dynamics of arthropod predator-prey systems',
      year: 1976,
      url: 'https://en.wikipedia.org/wiki/Lotka%E2%80%93Volterra_equations',
    ),
  ];
}
