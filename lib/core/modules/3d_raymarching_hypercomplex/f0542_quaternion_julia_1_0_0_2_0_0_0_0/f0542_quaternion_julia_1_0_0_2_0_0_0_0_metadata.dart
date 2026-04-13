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
class F0542QuaternionJulia10020000Metadata {
  static const instance = F0542QuaternionJulia10020000Metadata._();
  const F0542QuaternionJulia10020000Metadata._();

  String get id => 'f0542_quaternion_julia_1_0_0_2_0_0_0_0';
  String get name => 'Quaternion Julia (−1.0, 0.2, 0.0, 0.0)';
  String get category => '3D Raymarching & Hypercomplex';

  List<String> get aliases => const [
    'QJulia c=(-1.0,0.2,0.0,0.0)',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'A. Norton',
      title: 'Generation and Display of Geometric Fractals in 3-D',
      year: 1982,
      url: 'https://doi.org/10.1145/965105.807250',
    ),
    Citation(
      author: 'Paul Bourke',
      title: '3D Fractal catalog',
      year: 2010,
      url: 'http://paulbourke.net/fractals/',
    ),
  ];
}
