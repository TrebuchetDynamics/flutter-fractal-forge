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
class F0844MurrayPolygonCurveOrder3Metadata {
  static const instance = F0844MurrayPolygonCurveOrder3Metadata._();
  const F0844MurrayPolygonCurveOrder3Metadata._();

  String get id => 'f0844_murray_polygon_curve_order_3';
  String get name => 'Murray Polygon Curve (Order 3)';
  String get category => 'L-Systems & Space-Filling';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: 'Murray polygon',
      year: 2002,
      url: 'http://paulbourke.net/fractals/lsys/',
    ),
  ];
}
