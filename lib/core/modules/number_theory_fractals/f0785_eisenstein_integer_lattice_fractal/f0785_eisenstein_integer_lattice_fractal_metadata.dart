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
class F0785EisensteinIntegerLatticeFractalMetadata {
  static const instance = F0785EisensteinIntegerLatticeFractalMetadata._();
  const F0785EisensteinIntegerLatticeFractalMetadata._();

  String get id => 'f0785_eisenstein_integer_lattice_fractal';
  String get name => 'Eisenstein Integer Lattice Fractal';
  String get category => 'Number-Theory Fractals';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'G. Eisenstein',
      title: 'Genaue Untersuchung der unendlichen Doppelproducte',
      year: 1844,
      url: 'https://mathworld.wolfram.com/EisensteinInteger.html',
    ),
  ];
}
