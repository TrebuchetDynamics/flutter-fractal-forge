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
class F0593SierpinskiTetrahedron3dMetadata {
  static const instance = F0593SierpinskiTetrahedron3dMetadata._();
  const F0593SierpinskiTetrahedron3dMetadata._();

  String get id => 'f0593_sierpinski_tetrahedron_3d';
  String get name => 'Sierpinski Tetrahedron 3D';
  String get category => '3D Raymarching & Hypercomplex';

  List<String> get aliases => const [
    'Sierpinski Tetrahedron 3D',
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
