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
class F0659MagnetVMetadata {
  static const instance = F0659MagnetVMetadata._();
  const F0659MagnetVMetadata._();

  String get id => 'f0659_magnet_v';
  String get name => 'Magnet V';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
    'Magnet_V',
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
