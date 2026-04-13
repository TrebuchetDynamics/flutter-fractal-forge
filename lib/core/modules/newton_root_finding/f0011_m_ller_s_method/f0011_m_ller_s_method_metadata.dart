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
class F0011MLlerSMethodMetadata {
  static const instance = F0011MLlerSMethodMetadata._();
  const F0011MLlerSMethodMetadata._();

  String get id => 'f0011_m_ller_s_method';
  String get name => 'Müller&#39;s Method';
  String get category => 'Newton / Root-Finding';

  List<String> get aliases => const [
    'Muller',
    'Mueller',
    'Quadratic interpolation method',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'David E. Müller',
      title: 'A Method for Solving Algebraic Equations Using an Automatic Computer',
      year: 1956,
      url: 'https://en.wikipedia.org/wiki/M%C3%BCller%27s_method',
    ),
  ];
}
