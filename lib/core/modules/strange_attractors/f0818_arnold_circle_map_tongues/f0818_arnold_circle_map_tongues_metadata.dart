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
class F0818ArnoldCircleMapTonguesMetadata {
  static const instance = F0818ArnoldCircleMapTonguesMetadata._();
  const F0818ArnoldCircleMapTonguesMetadata._();

  String get id => 'f0818_arnold_circle_map_tongues';
  String get name => 'Arnold Circle Map (Tongues)';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Arnold circle',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'V. I. Arnold',
      title: 'Small denominators I: mappings of the circumference into itself',
      year: 1961,
      url: 'https://en.wikipedia.org/wiki/Arnold_tongue',
    ),
  ];
}
