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
class F0597SierpinskiCarpet3dMengerCrossMetadata {
  static const instance = F0597SierpinskiCarpet3dMengerCrossMetadata._();
  const F0597SierpinskiCarpet3dMengerCrossMetadata._();

  String get id => 'f0597_sierpinski_carpet_3d_menger_cross';
  String get name => 'Sierpinski Carpet 3D (Menger cross)';
  String get category => '3D Raymarching & Hypercomplex';

  List<String> get aliases => const [
    'Sierpinski Carpet 3D (Menger cross)',
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
