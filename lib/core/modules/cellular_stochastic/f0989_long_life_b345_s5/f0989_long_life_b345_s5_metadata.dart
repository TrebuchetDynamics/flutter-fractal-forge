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
class F0989LongLifeB345S5Metadata {
  static const instance = F0989LongLifeB345S5Metadata._();
  const F0989LongLifeB345S5Metadata._();

  String get id => 'f0989_long_life_b345_s5';
  String get name => 'Long Life (B345/S5)';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
    'B345-S5',
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
