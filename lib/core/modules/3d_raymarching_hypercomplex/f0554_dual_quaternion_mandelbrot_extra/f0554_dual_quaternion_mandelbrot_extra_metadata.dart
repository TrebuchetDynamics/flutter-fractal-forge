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
class F0554DualQuaternionMandelbrotExtraMetadata {
  static const instance = F0554DualQuaternionMandelbrotExtraMetadata._();
  const F0554DualQuaternionMandelbrotExtraMetadata._();

  String get id => 'f0554_dual_quaternion_mandelbrot_extra';
  String get name => 'Dual Quaternion Mandelbrot (extra)';
  String get category => '3D Raymarching & Hypercomplex';

  List<String> get aliases => const [
    'dual quaternion alt',
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
