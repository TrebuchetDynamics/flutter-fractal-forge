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
class F0783PAdicFractalP3Metadata {
  static const instance = F0783PAdicFractalP3Metadata._();
  const F0783PAdicFractalP3Metadata._();

  String get id => 'f0783_p_adic_fractal_p_3';
  String get name => 'p-adic Fractal (p=3)';
  String get category => 'Number-Theory Fractals';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'K. Hensel',
      title: 'Theorie der algebraischen Zahlen',
      year: 1908,
      url: 'https://mathworld.wolfram.com/p-adicNumber.html',
    ),
  ];
}
