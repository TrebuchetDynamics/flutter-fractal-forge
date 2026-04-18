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
class F1077TinkerbellClassicMetadata {
  static const instance = F1077TinkerbellClassicMetadata._();
  const F1077TinkerbellClassicMetadata._();

  String get id => 'f1077_tinkerbell_classic';
  String get name => 'Tinkerbell Classic';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Tinkerbell a=0.9',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'C. Pickover',
      title: 'Mazes for the Mind',
      year: 1992,
      url: 'https://en.wikipedia.org/wiki/Tinkerbell_map',
    ),
  ];
}
