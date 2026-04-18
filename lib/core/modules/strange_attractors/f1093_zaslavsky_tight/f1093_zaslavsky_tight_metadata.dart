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
class F1093ZaslavskyTightMetadata {
  static const instance = F1093ZaslavskyTightMetadata._();
  const F1093ZaslavskyTightMetadata._();

  String get id => 'f1093_zaslavsky_tight';
  String get name => 'Zaslavsky Tight';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Zaslavsky eps=3.0',
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
