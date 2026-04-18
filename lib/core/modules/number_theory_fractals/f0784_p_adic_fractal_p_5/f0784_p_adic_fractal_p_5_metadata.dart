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
class F0784PAdicFractalP5Metadata {
  static const instance = F0784PAdicFractalP5Metadata._();
  const F0784PAdicFractalP5Metadata._();

  String get id => 'f0784_p_adic_fractal_p_5';
  String get name => 'p-adic Fractal (p=5)';
  String get category => 'Number-Theory Fractals';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Y. A. Katznelson',
      title: 'An introduction to harmonic analysis',
      year: 1968,
      url: 'https://mathworld.wolfram.com/p-adicNumber.html',
    ),
  ];
}
