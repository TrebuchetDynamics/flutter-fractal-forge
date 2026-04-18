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
class F0855FractalCanopyAsymmetricMetadata {
  static const instance = F0855FractalCanopyAsymmetricMetadata._();
  const F0855FractalCanopyAsymmetricMetadata._();

  String get id => 'f0855_fractal_canopy_asymmetric';
  String get name => 'Fractal Canopy Asymmetric';
  String get category => 'L-Systems & Space-Filling';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'P. Prusinkiewicz, A. Lindenmayer',
      title: 'The Algorithmic Beauty of Plants',
      year: 1990,
      url: 'http://algorithmicbotany.org/papers/abop/abop.pdf',
    ),
  ];
}
