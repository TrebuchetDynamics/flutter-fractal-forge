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
class F0795EulerTotientFractalMetadata {
  static const instance = F0795EulerTotientFractalMetadata._();
  const F0795EulerTotientFractalMetadata._();

  String get id => 'f0795_euler_totient_fractal';
  String get name => 'Euler Totient Fractal';
  String get category => 'Number-Theory Fractals';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'L. Euler',
      title: 'Theoremata arithmetica nova methodo demonstrata',
      year: 1763,
      url: 'https://mathworld.wolfram.com/TotientFunction.html',
    ),
  ];
}
