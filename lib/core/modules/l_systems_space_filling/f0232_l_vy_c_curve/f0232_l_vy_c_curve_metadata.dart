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
class F0232LVyCCurveMetadata {
  static const instance = F0232LVyCCurveMetadata._();
  const F0232LVyCCurveMetadata._();

  String get id => 'f0232_l_vy_c_curve';
  String get name => 'Lévy C Curve';
  String get category => 'L-Systems &amp; Space-Filling';

  List<String> get aliases => const [
    'Levy C',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: 'Lévy C Curve',
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
