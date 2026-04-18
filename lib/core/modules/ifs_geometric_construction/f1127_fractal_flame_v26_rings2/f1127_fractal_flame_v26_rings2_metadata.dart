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
class F1127FractalFlameV26Rings2Metadata {
  static const instance = F1127FractalFlameV26Rings2Metadata._();
  const F1127FractalFlameV26Rings2Metadata._();

  String get id => 'f1127_fractal_flame_v26_rings2';
  String get name => 'Fractal Flame V26 Rings2';
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
