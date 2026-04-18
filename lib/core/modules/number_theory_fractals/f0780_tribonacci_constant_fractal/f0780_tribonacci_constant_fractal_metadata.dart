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
class F0780TribonacciConstantFractalMetadata {
  static const instance = F0780TribonacciConstantFractalMetadata._();
  const F0780TribonacciConstantFractalMetadata._();

  String get id => 'f0780_tribonacci_constant_fractal';
  String get name => 'Tribonacci Constant Fractal';
  String get category => 'Number-Theory Fractals';

  List<String> get aliases => const [
    'Tribonacci',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'G. Rauzy',
      title: 'Nombres algébriques et substitutions',
      year: 1982,
      url: 'https://doi.org/10.24033/bsmf.1957',
    ),
  ];
}
