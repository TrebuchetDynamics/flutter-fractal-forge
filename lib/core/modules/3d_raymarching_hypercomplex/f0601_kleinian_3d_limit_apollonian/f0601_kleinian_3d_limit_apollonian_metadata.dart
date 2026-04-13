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
class F0601Kleinian3dLimitApollonianMetadata {
  static const instance = F0601Kleinian3dLimitApollonianMetadata._();
  const F0601Kleinian3dLimitApollonianMetadata._();

  String get id => 'f0601_kleinian_3d_limit_apollonian';
  String get name => 'Kleinian 3D Limit (Apollonian)';
  String get category => '3D Raymarching & Hypercomplex';

  List<String> get aliases => const [
    'Kleinian 3D Limit (Apollonian)',
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
