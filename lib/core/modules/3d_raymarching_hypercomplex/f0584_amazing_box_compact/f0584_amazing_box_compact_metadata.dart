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
class F0584AmazingBoxCompactMetadata {
  static const instance = F0584AmazingBoxCompactMetadata._();
  const F0584AmazingBoxCompactMetadata._();

  String get id => 'f0584_amazing_box_compact';
  String get name => 'Amazing Box (compact)';
  String get category => '3D Raymarching & Hypercomplex';

  List<String> get aliases => const [
    'AmazingBox s=1.7',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'T. Lowe',
      title: 'Mandelbox',
      year: 2010,
      url: 'https://sites.google.com/site/mandelbox/',
    ),
    Citation(
      author: 'Paul Bourke',
      title: '3D Fractal catalog',
      year: 2010,
      url: 'http://paulbourke.net/fractals/',
    ),
  ];
}
