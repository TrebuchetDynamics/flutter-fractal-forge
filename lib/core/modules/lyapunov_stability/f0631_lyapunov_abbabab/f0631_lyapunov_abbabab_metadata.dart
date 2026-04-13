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
class F0631LyapunovAbbababMetadata {
  static const instance = F0631LyapunovAbbababMetadata._();
  const F0631LyapunovAbbababMetadata._();

  String get id => 'f0631_lyapunov_abbabab';
  String get name => 'Lyapunov ABBABAB';
  String get category => 'Lyapunov & Stability';

  List<String> get aliases => const [
    'Lyap_ABBABAB',
    'Markus-Lyapunov ABBABAB',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'M. Markus, B. Hess',
      title: 'Lyapunov exponents of the logistic map with periodic forcing',
      year: 1989,
      url: 'https://doi.org/10.1016/0097-8493(89)90091-2',
    ),
    Citation(
      author: 'Wikipedia',
      title: 'Lyapunov fractal',
      year: 2024,
      url: 'https://en.wikipedia.org/wiki/Lyapunov_fractal',
    ),
  ];
}
