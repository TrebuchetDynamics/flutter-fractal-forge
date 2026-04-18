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
class F0834HilbertCurve3dGosperMetadata {
  static const instance = F0834HilbertCurve3dGosperMetadata._();
  const F0834HilbertCurve3dGosperMetadata._();

  String get id => 'f0834_hilbert_curve_3d_gosper';
  String get name => 'Hilbert Curve 3D Gosper';
  String get category => 'L-Systems & Space-Filling';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: '3D Hilbert Gosper',
      year: 2002,
      url: 'http://paulbourke.net/fractals/lsys/',
    ),
  ];
}
