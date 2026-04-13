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
class F0293FractalFlameIfsLinearMetadata {
  static const instance = F0293FractalFlameIfsLinearMetadata._();
  const F0293FractalFlameIfsLinearMetadata._();

  String get id => 'f0293_fractal_flame_ifs_linear';
  String get name => 'Fractal Flame IFS (linear)';
  String get category => 'IFS &amp; Geometric Construction';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Scott Draves, Erik Reckase',
      title: 'The Fractal Flame Algorithm',
      year: 2003,
      url: 'http://flam3.com/flame_draves.pdf',
    ),
  ];
}
