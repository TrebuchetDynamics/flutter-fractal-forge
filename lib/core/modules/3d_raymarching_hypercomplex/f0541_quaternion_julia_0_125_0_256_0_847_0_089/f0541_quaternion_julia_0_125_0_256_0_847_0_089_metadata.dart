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
class F0541QuaternionJulia0125025608470089Metadata {
  static const instance = F0541QuaternionJulia0125025608470089Metadata._();
  const F0541QuaternionJulia0125025608470089Metadata._();

  String get id => 'f0541_quaternion_julia_0_125_0_256_0_847_0_089';
  String get name => 'Quaternion Julia (−0.125, −0.256, 0.847, 0.0895)';
  String get category => '3D Raymarching & Hypercomplex';

  List<String> get aliases => const [
    'QJulia c=(-0.125,-0.256,0.847,0.0895)',
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
