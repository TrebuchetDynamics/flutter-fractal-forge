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
class F0715RauzyFractalTilingMetadata {
  static const instance = F0715RauzyFractalTilingMetadata._();
  const F0715RauzyFractalTilingMetadata._();

  String get id => 'f0715_rauzy_fractal_tiling';
  String get name => 'Rauzy Fractal Tiling';
  String get category => 'Tiling & Aperiodic';

  List<String> get aliases => const [
    'Rauzy',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'G. Rauzy',
      title: 'Nombres algébriques et substitutions',
      year: 1982,
      url: 'https://doi.org/10.24033/bsmf.1957',
    ),
  ];
}
