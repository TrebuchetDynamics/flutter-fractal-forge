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
class F0553CoquaternionMandelbrotMetadata {
  static const instance = F0553CoquaternionMandelbrotMetadata._();
  const F0553CoquaternionMandelbrotMetadata._();

  String get id => 'f0553_coquaternion_mandelbrot';
  String get name => 'Coquaternion Mandelbrot';
  String get category => '3D Raymarching & Hypercomplex';

  List<String> get aliases => const [
    'split-quaternion',
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
