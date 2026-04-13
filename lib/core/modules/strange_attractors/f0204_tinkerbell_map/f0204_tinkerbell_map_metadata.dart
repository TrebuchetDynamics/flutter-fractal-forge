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
class F0204TinkerbellMapMetadata {
  static const instance = F0204TinkerbellMapMetadata._();
  const F0204TinkerbellMapMetadata._();

  String get id => 'f0204_tinkerbell_map';
  String get name => 'Tinkerbell Map';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Wikipedia',
      title: 'Tinkerbell map',
      year: 2024,
      url: 'https://en.wikipedia.org/wiki/Tinkerbell_map',
    ),
  ];
}
