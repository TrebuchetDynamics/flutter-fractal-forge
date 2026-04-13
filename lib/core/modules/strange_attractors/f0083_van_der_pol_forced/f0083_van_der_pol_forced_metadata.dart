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
class F0083VanDerPolForcedMetadata {
  static const instance = F0083VanDerPolForcedMetadata._();
  const F0083VanDerPolForcedMetadata._();

  String get id => 'f0083_van_der_pol_forced';
  String get name => 'Van der Pol (forced)';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'B. van der Pol',
      title: 'On relaxation-oscillations',
      year: 1926,
      url: 'https://doi.org/10.1080/14786442608564127',
    ),
  ];
}
