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
class F0213DuffingMapMetadata {
  static const instance = F0213DuffingMapMetadata._();
  const F0213DuffingMapMetadata._();

  String get id => 'f0213_duffing_map';
  String get name => 'Duffing Map';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Wikipedia',
      title: 'Duffing map',
      year: 2024,
      url: 'https://en.wikipedia.org/wiki/Duffing_map',
    ),
  ];
}
