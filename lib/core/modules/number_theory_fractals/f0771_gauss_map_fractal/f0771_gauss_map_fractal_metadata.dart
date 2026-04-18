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
class F0771GaussMapFractalMetadata {
  static const instance = F0771GaussMapFractalMetadata._();
  const F0771GaussMapFractalMetadata._();

  String get id => 'f0771_gauss_map_fractal';
  String get name => 'Gauss Map Fractal';
  String get category => 'Number-Theory Fractals';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'C. F. Gauss',
      title: 'Disquisitiones Arithmeticae',
      year: 1801,
      url: 'https://mathworld.wolfram.com/GaussMap.html',
    ),
  ];
}
