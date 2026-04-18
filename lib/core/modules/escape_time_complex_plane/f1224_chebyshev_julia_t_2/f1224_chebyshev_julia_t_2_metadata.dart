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
class F1224ChebyshevJuliaT2Metadata {
  static const instance = F1224ChebyshevJuliaT2Metadata._();
  const F1224ChebyshevJuliaT2Metadata._();

  String get id => 'f1224_chebyshev_julia_t_2';
  String get name => 'Chebyshev Julia T_2';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
    'Chebyshev T2',
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
