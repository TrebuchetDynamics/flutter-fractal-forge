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
class F0833HilbertCurve3dBetaMetadata {
  static const instance = F0833HilbertCurve3dBetaMetadata._();
  const F0833HilbertCurve3dBetaMetadata._();

  String get id => 'f0833_hilbert_curve_3d_beta';
  String get name => 'Hilbert Curve 3D Beta';
  String get category => 'L-Systems & Space-Filling';

  List<String> get aliases => const [
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
      title: '3D Hilbert beta',
      year: 2002,
      url: 'http://paulbourke.net/fractals/lsys/',
    ),
  ];
}
