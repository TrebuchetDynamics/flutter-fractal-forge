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
class F0585AmazingBoxOpenMetadata {
  static const instance = F0585AmazingBoxOpenMetadata._();
  const F0585AmazingBoxOpenMetadata._();

  String get id => 'f0585_amazing_box_open';
  String get name => 'Amazing Box (open)';
  String get category => '3D Raymarching & Hypercomplex';

  List<String> get aliases => const [
    'AmazingBox s=2.4',
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
