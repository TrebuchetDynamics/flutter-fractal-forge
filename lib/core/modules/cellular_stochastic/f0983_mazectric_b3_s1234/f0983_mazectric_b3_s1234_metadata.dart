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
class F0983MazectricB3S1234Metadata {
  static const instance = F0983MazectricB3S1234Metadata._();
  const F0983MazectricB3S1234Metadata._();

  String get id => 'f0983_mazectric_b3_s1234';
  String get name => 'Mazectric (B3/S1234)';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
    'B3-S1234',
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
