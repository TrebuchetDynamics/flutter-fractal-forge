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
class F1122FractalFlameV21RingsMetadata {
  static const instance = F1122FractalFlameV21RingsMetadata._();
  const F1122FractalFlameV21RingsMetadata._();

  String get id => 'f1122_fractal_flame_v21_rings';
  String get name => 'Fractal Flame V21 Rings';
  String get category => 'IFS & Geometric Construction';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Scott Draves, Erik Reckase',
      title: 'The Fractal Flame Algorithm',
      year: 2008,
      url: 'http://flam3.com/flame_draves.pdf',
    ),
    Citation(
      author: 'Scott Draves',
      title: 'The Electric Sheep and their dreams in high fidelity',
      year: 2003,
      url: 'https://en.wikipedia.org/wiki/Fractal_flame',
    ),
  ];
}
