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
class F0075HadleyCirculationMetadata {
  static const instance = F0075HadleyCirculationMetadata._();
  const F0075HadleyCirculationMetadata._();

  String get id => 'f0075_hadley_circulation';
  String get name => 'Hadley Circulation';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Hadley 1735; Lorenz 1984',
      title: 'Atmospheric circulation model',
      year: 1984,
      url: 'https://doi.org/10.3402/tellusa.v36i2.11473',
    ),
  ];
}
