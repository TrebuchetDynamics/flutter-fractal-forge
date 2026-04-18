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
class F0829FeigenbaumUniversalMapMetadata {
  static const instance = F0829FeigenbaumUniversalMapMetadata._();
  const F0829FeigenbaumUniversalMapMetadata._();

  String get id => 'f0829_feigenbaum_universal_map';
  String get name => 'Feigenbaum Universal Map';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Feigenbaum fixed point',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'M. J. Feigenbaum',
      title: 'Quantitative universality for a class of nonlinear transformations',
      year: 1978,
      url: 'https://doi.org/10.1007/BF01020332',
    ),
  ];
}
