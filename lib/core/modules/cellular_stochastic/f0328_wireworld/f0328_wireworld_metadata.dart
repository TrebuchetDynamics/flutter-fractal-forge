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
class F0328WireworldMetadata {
  static const instance = F0328WireworldMetadata._();
  const F0328WireworldMetadata._();

  String get id => 'f0328_wireworld';
  String get name => 'Wireworld';
  String get category => 'Cellular &amp; Stochastic';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Brian Silverman',
      title: 'Wireworld cellular automaton',
      year: 1987,
      url: 'https://en.wikipedia.org/wiki/Wireworld',
    ),
  ];
}
