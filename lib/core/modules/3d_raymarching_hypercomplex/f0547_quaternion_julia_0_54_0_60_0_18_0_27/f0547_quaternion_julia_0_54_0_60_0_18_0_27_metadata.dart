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
class F0547QuaternionJulia054060018027Metadata {
  static const instance = F0547QuaternionJulia054060018027Metadata._();
  const F0547QuaternionJulia054060018027Metadata._();

  String get id => 'f0547_quaternion_julia_0_54_0_60_0_18_0_27';
  String get name => 'Quaternion Julia (−0.54, 0.60, 0.18, 0.27)';
  String get category => '3D Raymarching & Hypercomplex';

  List<String> get aliases => const [
    'QJulia c=(-0.54,0.6,0.18,0.27)',
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
