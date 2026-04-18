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
class F1027FhpLatticeGasMetadata {
  static const instance = F1027FhpLatticeGasMetadata._();
  const F1027FhpLatticeGasMetadata._();

  String get id => 'f1027_fhp_lattice_gas';
  String get name => 'FHP Lattice Gas';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
    'FHP gas',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'U. Frisch, B. Hasslacher, Y. Pomeau',
      title: 'Lattice-gas automata for the Navier-Stokes equation',
      year: 1986,
      url: 'https://doi.org/10.1103/PhysRevLett.56.1505',
    ),
  ];
}
