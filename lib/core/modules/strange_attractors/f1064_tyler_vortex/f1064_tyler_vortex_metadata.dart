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
class F1064TylerVortexMetadata {
  static const instance = F1064TylerVortexMetadata._();
  const F1064TylerVortexMetadata._();

  String get id => 'f1064_tyler_vortex';
  String get name => 'Tyler Vortex';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Tyler a=1.7 b=-0.4',
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
