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
class F1065TylerMeshMetadata {
  static const instance = F1065TylerMeshMetadata._();
  const F1065TylerMeshMetadata._();

  String get id => 'f1065_tyler_mesh';
  String get name => 'Tyler Mesh';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Tyler a=2.4 b=0.5',
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
