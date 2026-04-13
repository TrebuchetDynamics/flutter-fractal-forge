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
class F0106TricornD9Metadata {
  static const instance = F0106TricornD9Metadata._();
  const F0106TricornD9Metadata._();

  String get id => 'f0106_tricorn_d_9';
  String get name => 'Tricorn d=9';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
    'Mandelbar d=9',
    'Multicorn d=9',
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
