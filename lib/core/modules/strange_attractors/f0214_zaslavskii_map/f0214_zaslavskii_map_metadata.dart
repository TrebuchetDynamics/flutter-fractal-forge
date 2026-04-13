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
class F0214ZaslavskiiMapMetadata {
  static const instance = F0214ZaslavskiiMapMetadata._();
  const F0214ZaslavskiiMapMetadata._();

  String get id => 'f0214_zaslavskii_map';
  String get name => 'Zaslavskii Map';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'G. M. Zaslavskii',
      title: 'The simplest case of a strange attractor',
      year: 1978,
      url: 'https://en.wikipedia.org/wiki/Zaslavskii_map',
    ),
  ];
}
