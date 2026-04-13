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
class F0008ChebyshevSMethodMetadata {
  static const instance = F0008ChebyshevSMethodMetadata._();
  const F0008ChebyshevSMethodMetadata._();

  String get id => 'f0008_chebyshev_s_method';
  String get name => 'Chebyshev&#39;s Method';
  String get category => 'Newton / Root-Finding';

  List<String> get aliases => const [
    'Chebyshev iteration',
    'Chebyshev-Halley method',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Pafnuty Chebyshev',
      title: 'Chebyshev iteration (MathWorld)',
      year: 1838,
      url: 'https://mathworld.wolfram.com/ChebyshevIteration.html',
    ),
  ];
}
