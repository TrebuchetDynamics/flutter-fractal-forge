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
class F0087VanDerPolUnforcedMetadata {
  static const instance = F0087VanDerPolUnforcedMetadata._();
  const F0087VanDerPolUnforcedMetadata._();

  String get id => 'f0087_van_der_pol_unforced';
  String get name => 'Van der Pol (unforced)';
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
