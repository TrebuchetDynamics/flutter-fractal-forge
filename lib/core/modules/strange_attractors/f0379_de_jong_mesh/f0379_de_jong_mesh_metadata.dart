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
class F0379DeJongMeshMetadata {
  static const instance = F0379DeJongMeshMetadata._();
  const F0379DeJongMeshMetadata._();

  String get id => 'f0379_de_jong_mesh';
  String get name => 'de Jong Mesh';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'de Jong a=2.0 b=-2.0 c=-1.2 d=2.0',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Peter de Jong / Clifford Pickover',
      title: 'Symmetric de Jong attractors',
      year: 1988,
      url: 'http://paulbourke.net/fractals/peterdejong/',
    ),
  ];
}
