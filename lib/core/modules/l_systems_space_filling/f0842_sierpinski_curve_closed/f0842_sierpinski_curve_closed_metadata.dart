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
class F0842SierpinskiCurveClosedMetadata {
  static const instance = F0842SierpinskiCurveClosedMetadata._();
  const F0842SierpinskiCurveClosedMetadata._();

  String get id => 'f0842_sierpinski_curve_closed';
  String get name => 'Sierpinski Curve (Closed)';
  String get category => 'L-Systems & Space-Filling';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: 'Sierpinski curve closed',
      year: 2002,
      url: 'http://paulbourke.net/fractals/lsys/',
    ),
  ];
}
