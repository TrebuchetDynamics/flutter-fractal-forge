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
class F0523ExpZZCMetadata {
  static const instance = F0523ExpZZCMetadata._();
  const F0523ExpZZCMetadata._();

  String get id => 'f0523_exp_z_z_c';
  String get name => 'exp(z) - z + c';
  String get category => 'Escape-Time (Complex Plane)';
  String get family => 'transcendental_exp';

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
