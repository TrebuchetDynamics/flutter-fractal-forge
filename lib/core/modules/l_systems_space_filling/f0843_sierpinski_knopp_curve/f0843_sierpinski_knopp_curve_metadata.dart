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
class F0843SierpinskiKnoppCurveMetadata {
  static const instance = F0843SierpinskiKnoppCurveMetadata._();
  const F0843SierpinskiKnoppCurveMetadata._();

  String get id => 'f0843_sierpinski_knopp_curve';
  String get name => 'Sierpinski-Knopp Curve';
  String get category => 'L-Systems & Space-Filling';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'K. Knopp',
      title: 'Theorie und Anwendung der unendlichen Reihen',
      year: 1917,
      url: 'https://en.wikipedia.org/wiki/Sierpi%C5%84ski_curve',
    ),
  ];
}
