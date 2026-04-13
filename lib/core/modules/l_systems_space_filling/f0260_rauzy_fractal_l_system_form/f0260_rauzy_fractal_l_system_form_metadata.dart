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
class F0260RauzyFractalLSystemFormMetadata {
  static const instance = F0260RauzyFractalLSystemFormMetadata._();
  const F0260RauzyFractalLSystemFormMetadata._();

  String get id => 'f0260_rauzy_fractal_l_system_form';
  String get name => 'Rauzy Fractal (L-system form)';
  String get category => 'L-Systems &amp; Space-Filling';

  List<String> get aliases => const [
    'Rauzy',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: 'Rauzy Fractal (L-system form)',
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
