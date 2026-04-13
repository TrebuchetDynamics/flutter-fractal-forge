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
class F0662MagnetInverseIMetadata {
  static const instance = F0662MagnetInverseIMetadata._();
  const F0662MagnetInverseIMetadata._();

  String get id => 'f0662_magnet_inverse_i';
  String get name => 'Magnet-Inverse I';
  String get category => 'Escape-Time (Complex Plane)';
  String get family => 'mandelbrot';

  List<String> get aliases => const [
    'Magnet-Inverse_I',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Shigehiro Ushiki',
      title: 'Magnet-I and Magnet-II fractals',
      year: 1988,
      url: 'http://paulbourke.net/fractals/magnet/',
    ),
  ];
}
