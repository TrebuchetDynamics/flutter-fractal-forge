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
class F0809DoublingMapMetadata {
  static const instance = F0809DoublingMapMetadata._();
  const F0809DoublingMapMetadata._();

  String get id => 'f0809_doubling_map';
  String get name => 'Doubling Map';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'bit shift',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'J. Milnor',
      title: 'Dynamics in one complex variable',
      year: 2006,
      url: 'https://en.wikipedia.org/wiki/Dyadic_transformation',
    ),
  ];
}
