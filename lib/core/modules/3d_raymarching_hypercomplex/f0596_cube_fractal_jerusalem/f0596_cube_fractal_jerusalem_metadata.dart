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
class F0596CubeFractalJerusalemMetadata {
  static const instance = F0596CubeFractalJerusalemMetadata._();
  const F0596CubeFractalJerusalemMetadata._();

  String get id => 'f0596_cube_fractal_jerusalem';
  String get name => 'Cube Fractal (Jerusalem)';
  String get category => '3D Raymarching & Hypercomplex';

  List<String> get aliases => const [
    'Cube Fractal (Jerusalem)',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: '3D Fractal catalog',
      year: 2010,
      url: 'http://paulbourke.net/fractals/',
    ),
  ];
}
