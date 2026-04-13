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
class F0218GumowskiMiraMapMetadata {
  static const instance = F0218GumowskiMiraMapMetadata._();
  const F0218GumowskiMiraMapMetadata._();

  String get id => 'f0218_gumowski_mira_map';
  String get name => 'Gumowski-Mira Map';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Mira map',
    'Gumowski-Mira',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'I. Gumowski, C. Mira',
      title: 'Recurrences and Discrete Dynamic Systems',
      year: 1980,
      url: 'https://en.wikipedia.org/wiki/Gumowski-Mira_map',
    ),
  ];
}
