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
class F0057ThomasAttractorMetadata {
  static const instance = F0057ThomasAttractorMetadata._();
  const F0057ThomasAttractorMetadata._();

  String get id => 'f0057_thomas_attractor';
  String get name => 'Thomas Attractor';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Thomas cyclically symmetric attractor',
    'labyrinth chaos',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'R. Thomas',
      title: 'Deterministic chaos seen in terms of feedback circuits',
      year: 1999,
      url: 'https://doi.org/10.1142/S0218127499001383',
    ),
  ];
}
