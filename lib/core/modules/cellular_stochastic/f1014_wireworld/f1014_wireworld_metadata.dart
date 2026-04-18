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
class F1014WireworldMetadata {
  static const instance = F1014WireworldMetadata._();
  const F1014WireworldMetadata._();

  String get id => 'f1014_wireworld';
  String get name => 'Wireworld';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
    'Silverman wireworld',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'B. Silverman',
      title: 'Wireworld cellular automaton',
      year: 1987,
      url: 'https://en.wikipedia.org/wiki/Wireworld',
    ),
  ];
}
