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
class F0062BurkeShawMetadata {
  static const instance = F0062BurkeShawMetadata._();
  const F0062BurkeShawMetadata._();

  String get id => 'f0062_burke_shaw';
  String get name => 'Burke-Shaw';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'W. Burke, R. Shaw',
      title: 'Strange attractor in a double-pendulum experiment',
      year: 1981,
      url: 'https://doi.org/10.1016/0375-9601(81)90040-X',
    ),
  ];
}
