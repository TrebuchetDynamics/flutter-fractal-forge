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
class F0575MandelboxS27Metadata {
  static const instance = F0575MandelboxS27Metadata._();
  const F0575MandelboxS27Metadata._();

  String get id => 'f0575_mandelbox_s_2_7';
  String get name => 'Mandelbox s=2.7';
  String get category => '3D Raymarching & Hypercomplex';

  List<String> get aliases => const [
    'Mandelbox scale 2.7',
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
