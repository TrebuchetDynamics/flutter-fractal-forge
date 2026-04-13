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
class F0586AmazingBoxNegativeMetadata {
  static const instance = F0586AmazingBoxNegativeMetadata._();
  const F0586AmazingBoxNegativeMetadata._();

  String get id => 'f0586_amazing_box_negative';
  String get name => 'Amazing Box (negative)';
  String get category => '3D Raymarching & Hypercomplex';

  List<String> get aliases => const [
    'AmazingBox s=-2.0',
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
