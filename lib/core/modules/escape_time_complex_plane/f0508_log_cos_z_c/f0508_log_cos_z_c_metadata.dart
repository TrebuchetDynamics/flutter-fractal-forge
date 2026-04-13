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
class F0508LogCosZCMetadata {
  static const instance = F0508LogCosZCMetadata._();
  const F0508LogCosZCMetadata._();

  String get id => 'f0508_log_cos_z_c';
  String get name => 'log(cos(z)) + c';
  String get category => 'Escape-Time (Complex Plane)';
  String get family => 'trigonometric_cosine';

  List<String> get aliases => const [
    'log-cos fractal',
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
