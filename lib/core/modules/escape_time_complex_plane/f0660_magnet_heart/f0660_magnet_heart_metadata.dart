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
class F0660MagnetHeartMetadata {
  static const instance = F0660MagnetHeartMetadata._();
  const F0660MagnetHeartMetadata._();

  String get id => 'f0660_magnet_heart';
  String get name => 'Magnet-Heart';
  String get category => 'Escape-Time (Complex Plane)';
  String get family => 'mandelbrot';

  List<String> get aliases => const [
    'Magnet-Heart',
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
