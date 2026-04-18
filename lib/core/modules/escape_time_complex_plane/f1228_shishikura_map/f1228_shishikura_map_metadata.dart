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
class F1228ShishikuraMapMetadata {
  static const instance = F1228ShishikuraMapMetadata._();
  const F1228ShishikuraMapMetadata._();

  String get id => 'f1228_shishikura_map';
  String get name => 'Shishikura Map';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
    'Shishikura',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'M. Shishikura',
      title: 'The Hausdorff dimension of the boundary of the Mandelbrot set and the Julia sets',
      year: 1998,
      url: 'https://doi.org/10.2307/121009',
    ),
  ];
}
