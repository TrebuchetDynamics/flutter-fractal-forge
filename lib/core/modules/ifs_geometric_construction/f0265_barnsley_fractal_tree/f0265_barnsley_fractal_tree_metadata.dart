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
class F0265BarnsleyFractalTreeMetadata {
  static const instance = F0265BarnsleyFractalTreeMetadata._();
  const F0265BarnsleyFractalTreeMetadata._();

  String get id => 'f0265_barnsley_fractal_tree';
  String get name => 'Barnsley Fractal Tree';
  String get category => 'IFS &amp; Geometric Construction';

  List<String> get aliases => const [
    'Barnsley tree',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'M. F. Barnsley',
      title: 'Fractals Everywhere',
      year: 1988,
      url: 'https://doi.org/10.1016/C2013-0-10335-2',
    ),
  ];
}
