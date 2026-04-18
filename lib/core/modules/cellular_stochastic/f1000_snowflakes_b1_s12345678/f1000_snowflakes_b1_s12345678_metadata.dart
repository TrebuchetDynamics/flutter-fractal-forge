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
class F1000SnowflakesB1S12345678Metadata {
  static const instance = F1000SnowflakesB1S12345678Metadata._();
  const F1000SnowflakesB1S12345678Metadata._();

  String get id => 'f1000_snowflakes_b1_s12345678';
  String get name => 'Snowflakes (B1/S12345678)';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
    'B1-S12345678',
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
