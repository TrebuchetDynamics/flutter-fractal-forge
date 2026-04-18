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
class F0792UlamSpiralMetadata {
  static const instance = F0792UlamSpiralMetadata._();
  const F0792UlamSpiralMetadata._();

  String get id => 'f0792_ulam_spiral';
  String get name => 'Ulam Spiral';
  String get category => 'Number-Theory Fractals';

  List<String> get aliases => const [
    'Ulam spiral',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'S. M. Ulam',
      title: 'A visual display of some properties of the distribution of primes',
      year: 1964,
      url: 'https://mathworld.wolfram.com/PrimeSpiral.html',
    ),
  ];
}
