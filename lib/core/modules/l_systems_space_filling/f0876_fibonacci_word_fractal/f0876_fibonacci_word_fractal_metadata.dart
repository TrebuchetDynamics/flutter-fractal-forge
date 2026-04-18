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
class F0876FibonacciWordFractalMetadata {
  static const instance = F0876FibonacciWordFractalMetadata._();
  const F0876FibonacciWordFractalMetadata._();

  String get id => 'f0876_fibonacci_word_fractal';
  String get name => 'Fibonacci Word Fractal';
  String get category => 'L-Systems & Space-Filling';

  List<String> get aliases => const [
    'Fibonacci word',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'A. Monnerot-Dumaine',
      title: 'The Fibonacci word fractal',
      year: 2009,
      url: 'https://hal.archives-ouvertes.fr/hal-00367972',
    ),
  ];
}
