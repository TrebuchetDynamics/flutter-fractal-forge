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
class F0768CollatzFractalMetadata {
  static const instance = F0768CollatzFractalMetadata._();
  const F0768CollatzFractalMetadata._();

  String get id => 'f0768_collatz_fractal';
  String get name => 'Collatz Fractal';
  String get category => 'Number-Theory Fractals';

  List<String> get aliases => const [
    '3n+1',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'L. Collatz',
      title: 'On the motivation and origin of the (3n+1)-problem',
      year: 1986,
      url: 'https://mathworld.wolfram.com/CollatzProblem.html',
    ),
  ];
}
