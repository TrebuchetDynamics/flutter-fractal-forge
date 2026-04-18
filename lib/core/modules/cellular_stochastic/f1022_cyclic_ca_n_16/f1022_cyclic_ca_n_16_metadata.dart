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
class F1022CyclicCaN16Metadata {
  static const instance = F1022CyclicCaN16Metadata._();
  const F1022CyclicCaN16Metadata._();

  String get id => 'f1022_cyclic_ca_n_16';
  String get name => 'Cyclic CA (n=16)';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'D. Griffeath',
      title: 'Primordial soup kitchen',
      year: 1996,
      url: 'https://psoup.math.wisc.edu/kitchen.html',
    ),
  ];
}
