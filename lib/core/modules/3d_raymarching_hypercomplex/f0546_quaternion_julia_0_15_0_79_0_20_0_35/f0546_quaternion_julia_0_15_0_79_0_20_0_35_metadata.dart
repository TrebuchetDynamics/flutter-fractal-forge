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
class F0546QuaternionJulia015079020035Metadata {
  static const instance = F0546QuaternionJulia015079020035Metadata._();
  const F0546QuaternionJulia015079020035Metadata._();

  String get id => 'f0546_quaternion_julia_0_15_0_79_0_20_0_35';
  String get name => 'Quaternion Julia (0.15, 0.79, 0.20, 0.35)';
  String get category => '3D Raymarching & Hypercomplex';

  List<String> get aliases => const [
    'QJulia c=(0.15,0.79,0.2,0.35)',
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
