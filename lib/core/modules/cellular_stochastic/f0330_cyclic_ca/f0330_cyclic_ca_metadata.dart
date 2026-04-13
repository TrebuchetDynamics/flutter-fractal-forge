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
class F0330CyclicCaMetadata {
  static const instance = F0330CyclicCaMetadata._();
  const F0330CyclicCaMetadata._();

  String get id => 'f0330_cyclic_ca';
  String get name => 'Cyclic CA';
  String get category => 'Cellular &amp; Stochastic';

  List<String> get aliases => const [
    'Griffeath CCA',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'D. Griffeath',
      title: 'Cyclic cellular automata',
      year: 1988,
      url: 'https://psoup.math.wisc.edu/kitchen.html',
    ),
  ];
}
