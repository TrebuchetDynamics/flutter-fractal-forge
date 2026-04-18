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
class F1069TylerCoralMetadata {
  static const instance = F1069TylerCoralMetadata._();
  const F1069TylerCoralMetadata._();

  String get id => 'f1069_tyler_coral';
  String get name => 'Tyler Coral';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Tyler a=2.3 b=0.4',
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
