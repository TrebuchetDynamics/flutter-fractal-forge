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
class F0878WilliamsBeasleyCurveMetadata {
  static const instance = F0878WilliamsBeasleyCurveMetadata._();
  const F0878WilliamsBeasleyCurveMetadata._();

  String get id => 'f0878_williams_beasley_curve';
  String get name => 'Williams-Beasley Curve';
  String get category => 'L-Systems & Space-Filling';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: 'Williams-Beasley',
      year: 2002,
      url: 'http://paulbourke.net/fractals/lsys/',
    ),
  ];
}
