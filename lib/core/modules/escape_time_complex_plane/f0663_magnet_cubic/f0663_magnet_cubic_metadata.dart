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
class F0663MagnetCubicMetadata {
  static const instance = F0663MagnetCubicMetadata._();
  const F0663MagnetCubicMetadata._();

  String get id => 'f0663_magnet_cubic';
  String get name => 'Magnet-Cubic';
  String get category => 'Escape-Time (Complex Plane)';
  String get family => 'multibrot_cubic';

  List<String> get aliases => const [
    'Magnet-Cubic',
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
