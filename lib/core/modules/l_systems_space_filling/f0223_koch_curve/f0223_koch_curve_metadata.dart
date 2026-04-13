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
class F0223KochCurveMetadata {
  static const instance = F0223KochCurveMetadata._();
  const F0223KochCurveMetadata._();

  String get id => 'f0223_koch_curve';
  String get name => 'Koch Curve';
  String get category => 'L-Systems &amp; Space-Filling';

  List<String> get aliases => const [
    'Koch',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: 'Koch Curve',
      year: 2002,
      url: 'http://paulbourke.net/fractals/lsys/',
    ),
    Citation(
      author: 'P. Prusinkiewicz, A. Lindenmayer',
      title: 'The Algorithmic Beauty of Plants',
      year: 1990,
      url: 'http://algorithmicbotany.org/papers/abop/abop.pdf',
    ),
  ];
}
