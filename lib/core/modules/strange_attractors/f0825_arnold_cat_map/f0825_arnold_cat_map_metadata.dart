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
class F0825ArnoldCatMapMetadata {
  static const instance = F0825ArnoldCatMapMetadata._();
  const F0825ArnoldCatMapMetadata._();

  String get id => 'f0825_arnold_cat_map';
  String get name => 'Arnold Cat Map';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'cat map',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'V. I. Arnold, A. Avez',
      title: 'Ergodic problems of classical mechanics',
      year: 1968,
      url: 'https://en.wikipedia.org/wiki/Arnold%27s_cat_map',
    ),
  ];
}
