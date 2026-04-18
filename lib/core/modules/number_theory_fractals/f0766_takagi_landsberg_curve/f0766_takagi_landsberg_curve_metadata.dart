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
class F0766TakagiLandsbergCurveMetadata {
  static const instance = F0766TakagiLandsbergCurveMetadata._();
  const F0766TakagiLandsbergCurveMetadata._();

  String get id => 'f0766_takagi_landsberg_curve';
  String get name => 'Takagi-Landsberg Curve';
  String get category => 'Number-Theory Fractals';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'G. Landsberg',
      title: 'Über eine einfache Methode zur Konstruktion stetiger nirgends differenzierbarer Funktionen',
      year: 1908,
      url: 'https://mathworld.wolfram.com/TakagiFractalCurve.html',
    ),
  ];
}
