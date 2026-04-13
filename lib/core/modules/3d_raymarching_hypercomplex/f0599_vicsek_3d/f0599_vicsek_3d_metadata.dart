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
class F0599Vicsek3dMetadata {
  static const instance = F0599Vicsek3dMetadata._();
  const F0599Vicsek3dMetadata._();

  String get id => 'f0599_vicsek_3d';
  String get name => 'Vicsek 3D';
  String get category => '3D Raymarching & Hypercomplex';

  List<String> get aliases => const [
    'Vicsek 3D',
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
