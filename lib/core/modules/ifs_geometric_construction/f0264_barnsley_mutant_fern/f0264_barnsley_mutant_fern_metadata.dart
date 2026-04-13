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
class F0264BarnsleyMutantFernMetadata {
  static const instance = F0264BarnsleyMutantFernMetadata._();
  const F0264BarnsleyMutantFernMetadata._();

  String get id => 'f0264_barnsley_mutant_fern';
  String get name => 'Barnsley Mutant Fern';
  String get category => 'IFS &amp; Geometric Construction';

  List<String> get aliases => const [
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
