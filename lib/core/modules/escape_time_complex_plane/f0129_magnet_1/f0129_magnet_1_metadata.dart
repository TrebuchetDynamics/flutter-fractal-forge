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
class F0129Magnet1Metadata {
  static const instance = F0129Magnet1Metadata._();
  const F0129Magnet1Metadata._();

  String get id => 'f0129_magnet_1';
  String get name => 'Magnet 1';
  String get category => 'Escape-Time (Complex Plane)';
  String get family => 'mandelbrot';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Wikipedia / Paul Bourke / Fractal Forums',
      title: 'Magnet 1',
      year: 2024,
      url: 'http://paulbourke.net/fractals/magnet/',
    ),
  ];
}
