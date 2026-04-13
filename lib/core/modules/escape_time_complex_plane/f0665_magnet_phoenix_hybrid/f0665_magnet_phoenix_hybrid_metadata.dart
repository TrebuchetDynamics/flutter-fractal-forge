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
class F0665MagnetPhoenixHybridMetadata {
  static const instance = F0665MagnetPhoenixHybridMetadata._();
  const F0665MagnetPhoenixHybridMetadata._();

  String get id => 'f0665_magnet_phoenix_hybrid';
  String get name => 'Magnet-Phoenix hybrid';
  String get category => 'Escape-Time (Complex Plane)';
  String get family => 'mandelbrot';

  List<String> get aliases => const [
    'Magnet-Phoenix_hybrid',
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
