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
class F0325Replicator2ColorMetadata {
  static const instance = F0325Replicator2ColorMetadata._();
  const F0325Replicator2ColorMetadata._();

  String get id => 'f0325_replicator_2_color';
  String get name => 'Replicator (2-color)';
  String get category => 'Cellular &amp; Stochastic';

  List<String> get aliases => const [
    'Fredkin replicator',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Edward Fredkin',
      title: 'Replicator CA',
      year: 1960,
      url: 'https://en.wikipedia.org/wiki/Fredkin%27s_paradox',
    ),
  ];
}
