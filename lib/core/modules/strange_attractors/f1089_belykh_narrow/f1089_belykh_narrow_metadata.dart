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
class F1089BelykhNarrowMetadata {
  static const instance = F1089BelykhNarrowMetadata._();
  const F1089BelykhNarrowMetadata._();

  String get id => 'f1089_belykh_narrow';
  String get name => 'Belykh Narrow';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Belykh a=1.2',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'V. N. Belykh',
      title: 'Models of discrete systems of phase synchronization',
      year: 1976,
      url: 'https://en.wikipedia.org/wiki/Belykh_map',
    ),
  ];
}
