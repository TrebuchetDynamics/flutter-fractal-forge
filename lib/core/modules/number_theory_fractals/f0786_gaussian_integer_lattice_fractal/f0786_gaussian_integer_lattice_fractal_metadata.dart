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
class F0786GaussianIntegerLatticeFractalMetadata {
  static const instance = F0786GaussianIntegerLatticeFractalMetadata._();
  const F0786GaussianIntegerLatticeFractalMetadata._();

  String get id => 'f0786_gaussian_integer_lattice_fractal';
  String get name => 'Gaussian Integer Lattice Fractal';
  String get category => 'Number-Theory Fractals';

  List<String> get aliases => const [
    'Gaussian primes',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'C. F. Gauss',
      title: 'Disquisitiones Arithmeticae',
      year: 1801,
      url: 'https://mathworld.wolfram.com/GaussianInteger.html',
    ),
  ];
}
