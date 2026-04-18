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
class F1225ChebyshevJuliaT3Metadata {
  static const instance = F1225ChebyshevJuliaT3Metadata._();
  const F1225ChebyshevJuliaT3Metadata._();

  String get id => 'f1225_chebyshev_julia_t_3';
  String get name => 'Chebyshev Julia T_3';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
    'Chebyshev T3',
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
