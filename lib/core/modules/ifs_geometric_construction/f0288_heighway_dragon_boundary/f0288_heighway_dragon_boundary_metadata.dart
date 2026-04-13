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
class F0288HeighwayDragonBoundaryMetadata {
  static const instance = F0288HeighwayDragonBoundaryMetadata._();
  const F0288HeighwayDragonBoundaryMetadata._();

  String get id => 'f0288_heighway_dragon_boundary';
  String get name => 'Heighway Dragon Boundary';
  String get category => 'IFS &amp; Geometric Construction';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: 'Dragon boundary IFS',
      year: 2000,
      url: 'http://paulbourke.net/fractals/ifs/',
    ),
  ];
}
