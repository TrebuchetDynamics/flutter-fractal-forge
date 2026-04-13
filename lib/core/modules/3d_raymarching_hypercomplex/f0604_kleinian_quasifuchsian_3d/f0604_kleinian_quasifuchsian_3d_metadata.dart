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
class F0604KleinianQuasifuchsian3dMetadata {
  static const instance = F0604KleinianQuasifuchsian3dMetadata._();
  const F0604KleinianQuasifuchsian3dMetadata._();

  String get id => 'f0604_kleinian_quasifuchsian_3d';
  String get name => 'Kleinian QuasiFuchsian 3D';
  String get category => '3D Raymarching & Hypercomplex';

  List<String> get aliases => const [
    'Kleinian QuasiFuchsian 3D',
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
