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
class F0777FibonacciWordFractalMetadata {
  static const instance = F0777FibonacciWordFractalMetadata._();
  const F0777FibonacciWordFractalMetadata._();

  String get id => 'f0777_fibonacci_word_fractal';
  String get name => 'Fibonacci Word Fractal';
  String get category => 'Number-Theory Fractals';

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
