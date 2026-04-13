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
class F0244FractalPlantCanonicalMetadata {
  static const instance = F0244FractalPlantCanonicalMetadata._();
  const F0244FractalPlantCanonicalMetadata._();

  String get id => 'f0244_fractal_plant_canonical';
  String get name => 'Fractal Plant (Canonical)';
  String get category => 'L-Systems &amp; Space-Filling';

  List<String> get aliases => const [
    'Algorithmic Plant',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: 'Fractal Plant (Canonical)',
      year: 2002,
      url: 'http://paulbourke.net/fractals/lsys/',
    ),
    Citation(
      author: 'P. Prusinkiewicz, A. Lindenmayer',
      title: 'The Algorithmic Beauty of Plants',
      year: 1990,
      url: 'http://algorithmicbotany.org/papers/abop/abop.pdf',
    ),
  ];
}
