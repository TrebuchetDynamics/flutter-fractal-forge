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
class F0544QuaternionJulia0291039903390437Metadata {
  static const instance = F0544QuaternionJulia0291039903390437Metadata._();
  const F0544QuaternionJulia0291039903390437Metadata._();

  String get id => 'f0544_quaternion_julia_0_291_0_399_0_339_0_437';
  String get name => 'Quaternion Julia (−0.291, −0.399, 0.339, 0.437)';
  String get category => '3D Raymarching & Hypercomplex';

  List<String> get aliases => const [
    'QJulia c=(-0.291,-0.399,0.339,0.437)',
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
