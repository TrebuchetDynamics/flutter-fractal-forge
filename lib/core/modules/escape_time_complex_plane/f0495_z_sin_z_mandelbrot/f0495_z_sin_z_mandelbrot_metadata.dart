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
class F0495ZSinZMandelbrotMetadata {
  static const instance = F0495ZSinZMandelbrotMetadata._();
  const F0495ZSinZMandelbrotMetadata._();

  String get id => 'f0495_z_sin_z_mandelbrot';
  String get name => 'z·sin(z) Mandelbrot';
  String get category => 'Escape-Time (Complex Plane)';
  String get family => 'trigonometric_sine';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'R. L. Devaney',
      title: 'Complex Exponential Dynamics',
      year: 1999,
      url: 'https://math.bu.edu/people/bob/papers.html',
    ),
    Citation(
      author: 'Paul Bourke',
      title: 'Transcendental fractals (catalog)',
      year: 2004,
      url: 'http://paulbourke.net/fractals/',
    ),
  ];
}
