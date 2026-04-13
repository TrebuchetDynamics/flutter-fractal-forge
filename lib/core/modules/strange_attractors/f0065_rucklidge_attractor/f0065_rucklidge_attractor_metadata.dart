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
class F0065RucklidgeAttractorMetadata {
  static const instance = F0065RucklidgeAttractorMetadata._();
  const F0065RucklidgeAttractorMetadata._();

  String get id => 'f0065_rucklidge_attractor';
  String get name => 'Rucklidge Attractor';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'A. M. Rucklidge',
      title: 'Chaos in models of double convection',
      year: 1992,
      url: 'https://doi.org/10.1017/S0022112092001915',
    ),
  ];
}
