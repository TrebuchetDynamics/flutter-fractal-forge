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
class F1226ChebyshevJuliaT5Metadata {
  static const instance = F1226ChebyshevJuliaT5Metadata._();
  const F1226ChebyshevJuliaT5Metadata._();

  String get id => 'f1226_chebyshev_julia_t_5';
  String get name => 'Chebyshev Julia T_5';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
    'Chebyshev T5',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'J. Milnor',
      title: 'Dynamics in one complex variable',
      year: 2006,
      url: 'https://en.wikipedia.org/wiki/Complex_dynamics',
    ),
  ];
}
