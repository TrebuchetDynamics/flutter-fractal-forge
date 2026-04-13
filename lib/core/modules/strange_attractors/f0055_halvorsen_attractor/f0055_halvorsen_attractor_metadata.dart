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
class F0055HalvorsenAttractorMetadata {
  static const instance = F0055HalvorsenAttractorMetadata._();
  const F0055HalvorsenAttractorMetadata._();

  String get id => 'f0055_halvorsen_attractor';
  String get name => 'Halvorsen Attractor';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Chlouverakis &amp; Sprott',
      title: 'Chaotic hyperjerk systems',
      year: 2006,
      url: 'https://sprott.physics.wisc.edu/pubs/paper330.pdf',
    ),
  ];
}
