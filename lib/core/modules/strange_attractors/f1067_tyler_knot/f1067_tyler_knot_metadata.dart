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
class F1067TylerKnotMetadata {
  static const instance = F1067TylerKnotMetadata._();
  const F1067TylerKnotMetadata._();

  String get id => 'f1067_tyler_knot';
  String get name => 'Tyler Knot';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Tyler a=2.1 b=0.2',
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
