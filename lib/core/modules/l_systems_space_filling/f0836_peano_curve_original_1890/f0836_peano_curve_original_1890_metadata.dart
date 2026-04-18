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
class F0836PeanoCurveOriginal1890Metadata {
  static const instance = F0836PeanoCurveOriginal1890Metadata._();
  const F0836PeanoCurveOriginal1890Metadata._();

  String get id => 'f0836_peano_curve_original_1890';
  String get name => 'Peano Curve (Original 1890)';
  String get category => 'L-Systems & Space-Filling';

  List<String> get aliases => const [
    'Peano original',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'G. Peano',
      title: 'Sur une courbe, qui remplit toute une aire plane',
      year: 1890,
      url: 'https://doi.org/10.1007/BF01199438',
    ),
  ];
}
