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
class F0286GalaxySpiralIfsMetadata {
  static const instance = F0286GalaxySpiralIfsMetadata._();
  const F0286GalaxySpiralIfsMetadata._();

  String get id => 'f0286_galaxy_spiral_ifs';
  String get name => 'Galaxy Spiral IFS';
  String get category => 'IFS &amp; Geometric Construction';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: 'Galaxy IFS',
      year: 2000,
      url: 'http://paulbourke.net/fractals/ifs/',
    ),
  ];
}
