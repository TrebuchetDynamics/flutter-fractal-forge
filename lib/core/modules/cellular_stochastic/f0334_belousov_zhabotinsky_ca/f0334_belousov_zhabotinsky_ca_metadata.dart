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
class F0334BelousovZhabotinskyCaMetadata {
  static const instance = F0334BelousovZhabotinskyCaMetadata._();
  const F0334BelousovZhabotinskyCaMetadata._();

  String get id => 'f0334_belousov_zhabotinsky_ca';
  String get name => 'Belousov-Zhabotinsky CA';
  String get category => 'Cellular &amp; Stochastic';

  List<String> get aliases => const [
    'BZ CA',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'A. T. Winfree',
      title: 'Spiral waves of chemical activity',
      year: 1972,
      url: 'https://doi.org/10.1126/science.175.4022.634',
    ),
  ];
}
