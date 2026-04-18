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
class F1021CyclicCaN4Metadata {
  static const instance = F1021CyclicCaN4Metadata._();
  const F1021CyclicCaN4Metadata._();

  String get id => 'f1021_cyclic_ca_n_4';
  String get name => 'Cyclic CA (n=4)';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
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
