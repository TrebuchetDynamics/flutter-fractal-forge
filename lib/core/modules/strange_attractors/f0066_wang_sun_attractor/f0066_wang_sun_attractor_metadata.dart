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
class F0066WangSunAttractorMetadata {
  static const instance = F0066WangSunAttractorMetadata._();
  const F0066WangSunAttractorMetadata._();

  String get id => 'f0066_wang_sun_attractor';
  String get name => 'Wang-Sun Attractor';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Z. Wang, S. Sun',
      title: 'A new chaotic system with only one stable equilibrium',
      year: 2012,
      url: 'https://doi.org/10.1016/j.cnsns.2012.01.015',
    ),
  ];
}
