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
class F0987StainsB3678S235678Metadata {
  static const instance = F0987StainsB3678S235678Metadata._();
  const F0987StainsB3678S235678Metadata._();

  String get id => 'f0987_stains_b3678_s235678';
  String get name => 'Stains (B3678/S235678)';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
    'B3678-S235678',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Mirek Wójtowicz',
      title: 'Mirek\'s Cellebration database',
      year: 1999,
      url: 'https://www.mirekw.com/ca/',
    ),
  ];
}
