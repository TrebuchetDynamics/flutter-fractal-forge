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
class F1061TylerSpiralMetadata {
  static const instance = F1061TylerSpiralMetadata._();
  const F1061TylerSpiralMetadata._();

  String get id => 'f1061_tyler_spiral';
  String get name => 'Tyler Spiral';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Tyler a=1.5 b=0.3',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Tim Tyler / Paul Bourke',
      title: 'Tyler attractor',
      year: 2003,
      url: 'http://paulbourke.net/fractals/tyler/',
    ),
  ];
}
