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
class F0074QiChaoticSystemMetadata {
  static const instance = F0074QiChaoticSystemMetadata._();
  const F0074QiChaoticSystemMetadata._();

  String get id => 'f0074_qi_chaotic_system';
  String get name => 'Qi Chaotic System';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'G. Qi et al.',
      title: 'A new hyperchaotic system',
      year: 2008,
      url: 'https://doi.org/10.1016/j.physleta.2007.12.072',
    ),
  ];
}
