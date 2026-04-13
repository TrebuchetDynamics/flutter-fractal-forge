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
class F0077BoualiAttractorMetadata {
  static const instance = F0077BoualiAttractorMetadata._();
  const F0077BoualiAttractorMetadata._();

  String get id => 'f0077_bouali_attractor';
  String get name => 'Bouali Attractor';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'S. Bouali',
      title: 'A novel strange attractor with a stretched loop',
      year: 2012,
      url: 'https://doi.org/10.1007/s11071-011-0260-7',
    ),
  ];
}
