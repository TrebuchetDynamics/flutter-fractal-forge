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
class F0108TricornD11Metadata {
  static const instance = F0108TricornD11Metadata._();
  const F0108TricornD11Metadata._();

  String get id => 'f0108_tricorn_d_11';
  String get name => 'Tricorn d=11';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
    'Mandelbar d=11',
    'Multicorn d=11',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'W. D. Crowe, R. Hasson, P. J. Rippon, P. E. D. Strain-Clark',
      title: 'On the structure of the Mandelbar set',
      year: 1989,
      url: 'https://doi.org/10.1088/0951-7715/2/4/001',
    ),
    Citation(
      author: 'Wikipedia',
      title: 'Tricorn (mathematics)',
      year: 2024,
      url: 'https://en.wikipedia.org/wiki/Tricorn_(mathematics)',
    ),
  ];
}
