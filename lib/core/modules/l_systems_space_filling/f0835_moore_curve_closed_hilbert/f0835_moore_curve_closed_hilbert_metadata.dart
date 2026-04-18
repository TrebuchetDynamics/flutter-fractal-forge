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
class F0835MooreCurveClosedHilbertMetadata {
  static const instance = F0835MooreCurveClosedHilbertMetadata._();
  const F0835MooreCurveClosedHilbertMetadata._();

  String get id => 'f0835_moore_curve_closed_hilbert';
  String get name => 'Moore Curve (Closed Hilbert)';
  String get category => 'L-Systems & Space-Filling';

  List<String> get aliases => const [
    'Moore',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'P. Prusinkiewicz, A. Lindenmayer',
      title: 'The Algorithmic Beauty of Plants',
      year: 1990,
      url: 'http://algorithmicbotany.org/papers/abop/abop.pdf',
    ),
    Citation(
      author: 'Paul Bourke',
      title: 'Moore curve',
      year: 2002,
      url: 'http://paulbourke.net/fractals/lsys/',
    ),
  ];
}
