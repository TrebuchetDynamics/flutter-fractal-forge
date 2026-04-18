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
class F0765TakagiBlancmangeCurveMetadata {
  static const instance = F0765TakagiBlancmangeCurveMetadata._();
  const F0765TakagiBlancmangeCurveMetadata._();

  String get id => 'f0765_takagi_blancmange_curve';
  String get name => 'Takagi (Blancmange) Curve';
  String get category => 'Number-Theory Fractals';

  List<String> get aliases => const [
    'Blancmange',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'T. Takagi',
      title: 'A simple example of a continuous function without derivative',
      year: 1901,
      url: 'https://mathworld.wolfram.com/TakagiFractalCurve.html',
    ),
  ];
}
