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
class F0296FractalFlameSwirlMetadata {
  static const instance = F0296FractalFlameSwirlMetadata._();
  const F0296FractalFlameSwirlMetadata._();

  String get id => 'f0296_fractal_flame_swirl';
  String get name => 'Fractal Flame (swirl)';
  String get category => 'IFS &amp; Geometric Construction';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Scott Draves',
      title: 'Fractal flame variations',
      year: 2003,
      url: 'http://flam3.com/flame_draves.pdf',
    ),
  ];
}
