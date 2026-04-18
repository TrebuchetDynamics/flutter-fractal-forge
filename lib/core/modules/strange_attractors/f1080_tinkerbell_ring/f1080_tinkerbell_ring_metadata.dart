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
class F1080TinkerbellRingMetadata {
  static const instance = F1080TinkerbellRingMetadata._();
  const F1080TinkerbellRingMetadata._();

  String get id => 'f1080_tinkerbell_ring';
  String get name => 'Tinkerbell Ring';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Tinkerbell a=0.4',
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
