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
class F0656MagnetIiPlusMetadata {
  static const instance = F0656MagnetIiPlusMetadata._();
  const F0656MagnetIiPlusMetadata._();

  String get id => 'f0656_magnet_ii_plus';
  String get name => 'Magnet II Plus';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
    'Magnet_II_Plus',
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
