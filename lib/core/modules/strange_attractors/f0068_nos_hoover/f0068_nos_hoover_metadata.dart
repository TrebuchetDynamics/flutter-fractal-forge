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
class F0068NosHooverMetadata {
  static const instance = F0068NosHooverMetadata._();
  const F0068NosHooverMetadata._();

  String get id => 'f0068_nos_hoover';
  String get name => 'Nosé-Hoover';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Nose-Hoover',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'W. G. Hoover',
      title: 'Canonical dynamics: Equilibrium phase-space distributions',
      year: 1985,
      url: 'https://doi.org/10.1103/PhysRevA.31.1695',
    ),
  ];
}
