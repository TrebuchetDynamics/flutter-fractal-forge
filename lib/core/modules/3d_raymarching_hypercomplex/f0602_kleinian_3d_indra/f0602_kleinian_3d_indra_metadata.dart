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
class F0602Kleinian3dIndraMetadata {
  static const instance = F0602Kleinian3dIndraMetadata._();
  const F0602Kleinian3dIndraMetadata._();

  String get id => 'f0602_kleinian_3d_indra';
  String get name => 'Kleinian 3D Indra';
  String get category => '3D Raymarching & Hypercomplex';

  List<String> get aliases => const [
    'Kleinian 3D Indra',
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
