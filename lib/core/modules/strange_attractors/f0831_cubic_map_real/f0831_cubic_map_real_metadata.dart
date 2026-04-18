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
class F0831CubicMapRealMetadata {
  static const instance = F0831CubicMapRealMetadata._();
  const F0831CubicMapRealMetadata._();

  String get id => 'f0831_cubic_map_real';
  String get name => 'Cubic Map (Real)';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'R. Devaney',
      title: 'An introduction to chaotic dynamical systems',
      year: 1989,
      url: 'https://en.wikipedia.org/wiki/Cubic_map',
    ),
  ];
}
