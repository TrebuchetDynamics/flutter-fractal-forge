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
class F0845MurrayPolygonCurveOrder5Metadata {
  static const instance = F0845MurrayPolygonCurveOrder5Metadata._();
  const F0845MurrayPolygonCurveOrder5Metadata._();

  String get id => 'f0845_murray_polygon_curve_order_5';
  String get name => 'Murray Polygon Curve (Order 5)';
  String get category => 'L-Systems & Space-Filling';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: 'Murray polygon 5',
      year: 2002,
      url: 'http://paulbourke.net/fractals/lsys/',
    ),
  ];
}
