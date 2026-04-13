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
class F0657MagnetIiiMetadata {
  static const instance = F0657MagnetIiiMetadata._();
  const F0657MagnetIiiMetadata._();

  String get id => 'f0657_magnet_iii';
  String get name => 'Magnet III';
  String get category => 'Escape-Time (Complex Plane)';
  String get family => 'mandelbrot';

  List<String> get aliases => const [
    'Magnet_III',
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
