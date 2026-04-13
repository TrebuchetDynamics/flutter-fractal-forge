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
class F0664MagnetQuarticMetadata {
  static const instance = F0664MagnetQuarticMetadata._();
  const F0664MagnetQuarticMetadata._();

  String get id => 'f0664_magnet_quartic';
  String get name => 'Magnet-Quartic';
  String get category => 'Escape-Time (Complex Plane)';
  String get family => 'multibrot_quartic';

  List<String> get aliases => const [
    'Magnet-Quartic',
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
