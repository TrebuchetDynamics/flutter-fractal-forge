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
class F0600TetrahedralSierpinskiScaledMetadata {
  static const instance = F0600TetrahedralSierpinskiScaledMetadata._();
  const F0600TetrahedralSierpinskiScaledMetadata._();

  String get id => 'f0600_tetrahedral_sierpinski_scaled';
  String get name => 'Tetrahedral Sierpinski (scaled)';
  String get category => '3D Raymarching & Hypercomplex';

  List<String> get aliases => const [
    'Tetrahedral Sierpinski (scaled)',
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
