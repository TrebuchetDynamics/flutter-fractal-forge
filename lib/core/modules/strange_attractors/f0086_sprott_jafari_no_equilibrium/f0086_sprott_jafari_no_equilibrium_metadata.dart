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
class F0086SprottJafariNoEquilibriumMetadata {
  static const instance = F0086SprottJafariNoEquilibriumMetadata._();
  const F0086SprottJafariNoEquilibriumMetadata._();

  String get id => 'f0086_sprott_jafari_no_equilibrium';
  String get name => 'Sprott-Jafari No-Equilibrium';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'S. Jafari, J. C. Sprott, M. Golpayegani',
      title: 'Elementary chaotic flows with no equilibria',
      year: 2013,
      url: 'https://doi.org/10.1016/j.physleta.2013.07.042',
    ),
  ];
}
