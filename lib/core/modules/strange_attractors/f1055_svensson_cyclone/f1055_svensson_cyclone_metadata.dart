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
class F1055SvenssonCycloneMetadata {
  static const instance = F1055SvenssonCycloneMetadata._();
  const F1055SvenssonCycloneMetadata._();

  String get id => 'f1055_svensson_cyclone';
  String get name => 'Svensson Cyclone';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Svensson a=-2.34 b=-3.34 c=0.5 d=-1.0',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Johnny Svensson / Paul Bourke',
      title: 'Svensson attractor',
      year: 2001,
      url: 'http://paulbourke.net/fractals/peterdejong/',
    ),
  ];
}
