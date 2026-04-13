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
class F0387DeJongRibbonMetadata {
  static const instance = F0387DeJongRibbonMetadata._();
  const F0387DeJongRibbonMetadata._();

  String get id => 'f0387_de_jong_ribbon';
  String get name => 'de Jong Ribbon';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'de Jong a=-2.1 b=1.9 c=-1.2 d=0.45',
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
