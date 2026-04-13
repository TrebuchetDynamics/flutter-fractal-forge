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
class F0372DeJongSpiralsMetadata {
  static const instance = F0372DeJongSpiralsMetadata._();
  const F0372DeJongSpiralsMetadata._();

  String get id => 'f0372_de_jong_spirals';
  String get name => 'de Jong Spirals';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'de Jong a=-2.7 b=-0.09 c=-0.86 d=-2.2',
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
