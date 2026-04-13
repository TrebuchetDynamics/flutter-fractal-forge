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
class F0219SinaiMapArithmeticMetadata {
  static const instance = F0219SinaiMapArithmeticMetadata._();
  const F0219SinaiMapArithmeticMetadata._();

  String get id => 'f0219_sinai_map_arithmetic';
  String get name => 'Sinai Map (arithmetic)';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Y. Sinai',
      title: 'Ergodic properties of the Lorentz gas',
      year: 1963,
      url: 'https://en.wikipedia.org/wiki/Anosov_diffeomorphism',
    ),
  ];
}
