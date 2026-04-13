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
class F0534WeierstrassEllipticMetadata {
  static const instance = F0534WeierstrassEllipticMetadata._();
  const F0534WeierstrassEllipticMetadata._();

  String get id => 'f0534_weierstrass_elliptic';
  String get name => 'Weierstrass Elliptic';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
    'Weierstrass fractal',
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
