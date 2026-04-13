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
class F0130Magnet2Metadata {
  static const instance = F0130Magnet2Metadata._();
  const F0130Magnet2Metadata._();

  String get id => 'f0130_magnet_2';
  String get name => 'Magnet 2';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Wikipedia / Paul Bourke / Fractal Forums',
      title: 'Magnet 2',
      year: 2024,
      url: 'http://paulbourke.net/fractals/magnet/',
    ),
  ];
}
