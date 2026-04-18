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
class F0796MobiusFunctionFractalMetadata {
  static const instance = F0796MobiusFunctionFractalMetadata._();
  const F0796MobiusFunctionFractalMetadata._();

  String get id => 'f0796_mobius_function_fractal';
  String get name => 'Mobius Function Fractal';
  String get category => 'Number-Theory Fractals';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'A. F. Möbius',
      title: 'Über eine besondere Art von Umkehrung der Reihen',
      year: 1832,
      url: 'https://mathworld.wolfram.com/MoebiusFunction.html',
    ),
  ];
}
