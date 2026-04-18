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
class F1079TinkerbellWingMetadata {
  static const instance = F1079TinkerbellWingMetadata._();
  const F1079TinkerbellWingMetadata._();

  String get id => 'f1079_tinkerbell_wing';
  String get name => 'Tinkerbell Wing';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Tinkerbell a=0.7',
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
