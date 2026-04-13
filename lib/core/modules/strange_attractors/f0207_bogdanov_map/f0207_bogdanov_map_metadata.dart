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
class F0207BogdanovMapMetadata {
  static const instance = F0207BogdanovMapMetadata._();
  const F0207BogdanovMapMetadata._();

  String get id => 'f0207_bogdanov_map';
  String get name => 'Bogdanov Map';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'R. Bogdanov',
      title: 'Versal deformations of a singular point of a vector field',
      year: 1975,
      url: 'https://en.wikipedia.org/wiki/Bogdanov_map',
    ),
  ];
}
