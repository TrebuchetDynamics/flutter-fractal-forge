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
class F0109TricornD12Metadata {
  static const instance = F0109TricornD12Metadata._();
  const F0109TricornD12Metadata._();

  String get id => 'f0109_tricorn_d_12';
  String get name => 'Tricorn d=12';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
    'Mandelbar d=12',
    'Multicorn d=12',
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
