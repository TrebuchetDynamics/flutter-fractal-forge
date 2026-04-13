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
class F0661MagnetStarMetadata {
  static const instance = F0661MagnetStarMetadata._();
  const F0661MagnetStarMetadata._();

  String get id => 'f0661_magnet_star';
  String get name => 'Magnet-Star';
  String get category => 'Escape-Time (Complex Plane)';
  String get family => 'multibrot_cubic';

  List<String> get aliases => const [
    'Magnet-Star',
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
