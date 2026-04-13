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
class F0112TricornD15Metadata {
  static const instance = F0112TricornD15Metadata._();
  const F0112TricornD15Metadata._();

  String get id => 'f0112_tricorn_d_15';
  String get name => 'Tricorn d=15';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
    'Mandelbar d=15',
    'Multicorn d=15',
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
