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
class F0385DeJongHurricaneMetadata {
  static const instance = F0385DeJongHurricaneMetadata._();
  const F0385DeJongHurricaneMetadata._();

  String get id => 'f0385_de_jong_hurricane';
  String get name => 'de Jong Hurricane';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'de Jong a=-1.9 b=1.8 c=-1.9 d=-1.7',
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
