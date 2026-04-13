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
class F0206GingerbreadmanMapMetadata {
  static const instance = F0206GingerbreadmanMapMetadata._();
  const F0206GingerbreadmanMapMetadata._();

  String get id => 'f0206_gingerbreadman_map';
  String get name => 'Gingerbreadman Map';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Devaney&#39;s Gingerbreadman',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'R. L. Devaney',
      title: 'A First Course in Chaotic Dynamical Systems',
      year: 1992,
      url: 'https://en.wikipedia.org/wiki/Gingerbreadman_map',
    ),
  ];
}
