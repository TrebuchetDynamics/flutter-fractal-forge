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
class F1091ZaslavskyClassicMetadata {
  static const instance = F1091ZaslavskyClassicMetadata._();
  const F1091ZaslavskyClassicMetadata._();

  String get id => 'f1091_zaslavsky_classic';
  String get name => 'Zaslavsky Classic';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Zaslavsky eps=5.0',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'G. M. Zaslavsky',
      title: 'The simplest case of a strange attractor',
      year: 1978,
      url: 'https://en.wikipedia.org/wiki/Zaslavskii_map',
    ),
  ];
}
