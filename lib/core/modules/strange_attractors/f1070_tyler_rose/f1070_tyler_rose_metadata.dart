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
class F1070TylerRoseMetadata {
  static const instance = F1070TylerRoseMetadata._();
  const F1070TylerRoseMetadata._();

  String get id => 'f1070_tyler_rose';
  String get name => 'Tyler Rose';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Tyler a=2.0 b=-0.3',
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
