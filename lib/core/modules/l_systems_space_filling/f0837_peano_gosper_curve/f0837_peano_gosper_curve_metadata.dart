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
class F0837PeanoGosperCurveMetadata {
  static const instance = F0837PeanoGosperCurveMetadata._();
  const F0837PeanoGosperCurveMetadata._();

  String get id => 'f0837_peano_gosper_curve';
  String get name => 'Peano-Gosper Curve';
  String get category => 'L-Systems & Space-Filling';

  List<String> get aliases => const [
    'Gosper curve',
    'Flowsnake',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: 'Peano-Gosper',
      year: 2002,
      url: 'http://paulbourke.net/fractals/lsys/',
    ),
  ];
}
